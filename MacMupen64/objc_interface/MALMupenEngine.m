//
//  MALMupenPlugins.m
//  mupen
//
//  Created by Rovolo on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALMupenEngine.h"
#import "MALMupenCore.h"
#import "MALMupenRom.h"
#import "preferences.h"
#import "m64p_common.h"
#import "main.h"

#import "core_interface.h"
#import "osal_dynamiclib.h"
#import "version.h"
#import "m64p_plugin.h"
#import "videoExtension.h"

#import "CocoaToSDLKeyMap.h"

NSString * MALMupenEngineFinished = @"MALMupenEngine Finished Running";
NSString * MALMupenEngineStarted = @"MALMupenEngine Started Running";

MALMupenEngine * _shared = nil;

@implementation MALMupenEngine
#pragma mark Accessors and Setters
@synthesize plugins,mainROM,isRunning;
-(void) setIsRunning:(BOOL)value {
	if(value==isRunning) return; //Don't post a notification if it doesn't change
	
	[self willChangeValueForKey:@"isRunning"];
	isRunning=value;
	[self didChangeValueForKey:@"isRunning"];
	if(isRunning) {
		gameWindow = [[MALGameWindow gameWindowWithDelegate:self] retain];
		malwin = (MALGameWindow*)[gameWindow window];
		[gameWindow performSelectorOnMainThread:@selector(showWindow:) withObject:self waitUntilDone:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:MALMupenEngineStarted object:self];
	} else {
		[gameWindow close];
		[gameWindow release];
		[[NSNotificationCenter defaultCenter] postNotificationName:MALMupenEngineFinished object:self];
	}
}
-(MALMupenCore*) core {
	return [plugins objectAtIndex:0];
}
#pragma mark core methods
-(void) unloadPluginIndex:(int)type {
	
}
-(int) indexForPluginType:(m64p_plugin_type)type {
	int index;
	switch (type) {
		case M64PLUGIN_CORE: index = 0; break;
		case M64PLUGIN_GFX: index = 1; break;
		case M64PLUGIN_AUDIO: index = 2; break;
		case M64PLUGIN_INPUT: index = 3; break;
		case M64PLUGIN_RSP: index = 4; break;
		default: index = 5; break;
	}
	return index;
}
-(void) loadPluginType:(m64p_plugin_type)type {
	int index = [self indexForPluginType:type];
	MALMupenPlugin * plugin = [plugins objectAtIndex:index];
	[plugin unloadPlugin];
	[plugin loadPluginWithName:[[[NSUserDefaults standardUserDefaults] objectForKey:MALDefaultPluginPathsKey] objectForKey:pluginStringForType(type)]];
	//start it up
	
	/* call the plugin's initialization function and make sure it starts okay */
	ptr_PluginStartup PluginStartup = (ptr_PluginStartup) osal_dynlib_getproc([plugin handle], "PluginStartup");
	if (PluginStartup == NULL) {
		NSLog(@"couldn't find startuphandle");
		return;
	}
	
	//fixme, don't want to figure out how to handle a plugin of a different archetecture right now.
	m64p_error rval = (*PluginStartup)([[self core] handle], (void*)[plugin typeString], DebugCallback);  /* DebugCallback is in main.c */
	if (rval != M64ERR_SUCCESS)
	{
		NSLog(@"init fail for %@",pluginStringForType(type));
	}
}
-(BOOL) attachPluginsToCore {
	/* attach plugins to core */
	for (int i = 1; i < [plugins count]; i++) {
		MALMupenPlugin * plugin = [plugins objectAtIndex:i];
		m64p_error err;
		if ((err = (*CoreAttachPlugin)([plugin type], [plugin handle]) != M64ERR_SUCCESS)) {
			NSLog(@"UI-Console: from core while attaching %@ plugin.\n%s\n", [plugin typeString], (*CoreErrorMessage)(err));
			(*CoreDoCommand)(M64CMD_ROM_CLOSE, 0, NULL);
			return 13;
		}
	}
	return YES;
}
-(BOOL) detachPluginsFromCore {
	for(int i=1 ; i < [plugins count]; i++) {
		MALMupenPlugin * plugin = [plugins objectAtIndex:i];
		(*CoreDetachPlugin)([plugin type]);
	}
	return YES;
}
-(BOOL) attachROM:(MALMupenRom*)rom {
	NSData * romData = [rom contents];
	return (*CoreDoCommand)(M64CMD_ROM_OPEN, (int)[romData length], (unsigned char*)[romData bytes]) == M64ERR_SUCCESS;
}
-(void) detachROM {
	(*CoreDoCommand)(M64CMD_ROM_CLOSE, 0,NULL);
}
-(void) spawnInThreadWithROM:(MALMupenRom*)rom {
	NSAutoreleasePool * pl = [[NSAutoreleasePool alloc] init];
	[self setIsRunning:YES];
	
	(*ConfigListSections)(NULL,configCallback);
	[self attachROM:rom];
	[self attachPluginsToCore];
	TestOtherMain();
	[self detachPluginsFromCore];
	[self detachROM];
	
	[self setIsRunning:NO];
	[pl drain];
}
#pragma mark key events
-(void) keyDown:(NSEvent*)event{
	if([event isARepeat]) return;
//	int a=[event keyCode],b=[[event charactersIgnoringModifiers] characterAtIndex:0];
	(*CoreDoCommand)(M64CMD_SEND_SDL_KEYDOWN,MAC_keymap[[event keyCode]], NULL);
}
-(void) keyUp:(NSEvent*)event {
	(*CoreDoCommand)(M64CMD_SEND_SDL_KEYUP,MAC_keymap[[event keyCode]], NULL);
}
-(void) flagsChanged:(NSEvent*)event {
	NSUInteger newFlags = [event modifierFlags];
	// If keydown, there are more flags than previously
	m64p_command command = (newFlags>modFlags ? M64CMD_SEND_SDL_KEYDOWN : M64CMD_SEND_SDL_KEYUP);
	NSUInteger key = (newFlags ^ modFlags);
	
	if(key & NSAlphaShiftKeyMask) ; //Caps Lock
	else if(key & NSShiftKeyMask)
		key = SDLK_LSHIFT;
	else if(key & NSControlKeyMask)
		key = SDLK_LCTRL;
	else if(key & NSAlternateKeyMask)
		key = SDLK_LALT;
	else if(key & NSCommandKeyMask)
		key = SDLK_LMETA;
	
	modFlags = newFlags;
	(*CoreDoCommand)(command,(int)key,NULL);
} 
-(void) windowWillClose:(NSNotification *)notification {
	(*CoreDoCommand)(M64CMD_STOP,0,0);
}
-(void) windowDidMove:(NSNotification *)notification {
}
-(void) windowWillMove:(NSNotification *)notification{
}

#pragma mark initialization
-(void) dealloc {
	[self setIsRunning:NO];
	[plugins release]; plugins = nil;
	[super dealloc];
}
-(id) init {
	if(self = [super init]) {
		_shared = self;
		initSDLKeyMap();
		plugins = [[NSMutableArray alloc] initWithCapacity:5];
		[plugins addObject:[MALMupenCore defaultCore]];
		modFlags=0;
		muted = NO;
		for (int i=1; i<5; i++) [plugins addObject:[[[MALMupenPlugin alloc] init] autorelease]];
		for (int i=1; i<5; i++) [self loadPluginType:(m64p_plugin_type)i];
	}
	return self;
}
+(MALMupenEngine*) shared {
	if(!_shared) [[MALMupenEngine alloc] init];
	return _shared;
}

#pragma mark API

#define pluginFunction(plugin,func,argv...) {\
	MALMupenPlugin * p = [plugins objectAtIndex:[self indexForPluginType:plugin]]; \
	ptr_##func func = osal_dynlib_getproc([p handle], #func); \
	if (func) { \
		func(argv); \
	} }

-(void) runWithRom:(MALMupenRom *)rom{
	[NSThread detachNewThreadSelector:@selector(spawnInThreadWithROM:) toTarget:self withObject:rom];
}
-(void) setVolume:(int)v {
	v = MIN(MAX(v,0), 100);
	if(v == volume && !(muted && volume!=0)) return;
	if(v != 0) self.muted = NO;
	
	pluginFunction(M64PLUGIN_AUDIO, VolumeSetLevel, volume)
	
	[self willChangeValueForKey:@"volume"];
	volume = v;
	[self didChangeValueForKey:@"volume"];
}
-(int) volume { return volume; }
-(void) setMuted:(BOOL)m {
	if(m == muted) return;
	
	pluginFunction(M64PLUGIN_AUDIO, VolumeMute);
	
	[self willChangeValueForKey:@"muted"];
	muted = m;
	[self didChangeValueForKey:@"muted"];
}
-(BOOL) muted { return muted; }

-(void) takeScreenShot {
	(*CoreDoCommand)(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
}
@end
