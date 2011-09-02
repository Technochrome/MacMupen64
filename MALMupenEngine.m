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
#import "videoExtension.h"

#import "CocoaToSDLKeyMap.h"

NSString * MALMupenEngineFinished = @"MALMupenEngine Finished Running";
NSString * MALMupenEngineStarted = @"MALMupenEngine Started Running";

@implementation MALMupenEngine
#pragma mark Accessors and Setters
@synthesize plugins,mainROM,isRunning;
-(void) setIsRunning:(BOOL)value {
	if(value==isRunning) return; //Don't post a notification if it doesn't change
//	if(![NSThread isMainThread]) {
//		[self performSelectorOnMainThread:@selector(setIsRunning:) withObject:[NSNumber numberWithBool:value] waitUntilDone:YES];
//		return;
//	}
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
-(void) loadPluginType:(m64p_plugin_type)type {
	int index;
	switch (type) {
		case M64PLUGIN_CORE: index = 0; break;
		case M64PLUGIN_GFX: index = 1; break;
		case M64PLUGIN_AUDIO: index = 2; break;
		case M64PLUGIN_INPUT: index = 3; break;
		case M64PLUGIN_RSP: index = 4; break;
		default: index = 5; break;
	} 
	MALMupenPlugin * plugin = [plugins objectAtIndex:index];
	[plugin unloadPlugin];
	[plugin loadPluginWithName:[[[NSUserDefaults standardUserDefaults] objectForKey:MALDefaultPluginPathsKey] objectForKey:pluginStringForType(type)]];
	//start it up
	
	/* call the plugin's initialization function and make sure it starts okay */
	ptr_PluginStartup PluginStartup = (ptr_PluginStartup) osal_dynlib_getproc([plugin handle], "PluginStartup");
	if (PluginStartup == NULL)
	{
		NSLog(@"couldn't find startuphandle");
	}
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
/*
if(pluginType != M64PLUGIN_CORE) {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDidReload:) name:MALNotificationCoreReloaded object:nil];
}*/
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
	int a=[event keyCode],b=[[event charactersIgnoringModifiers] characterAtIndex:0];
//	NSLog(@"%d = %c , %d = %c",a,a,b,b);
	(*CoreDoCommand)(M64CMD_SEND_SDL_KEYDOWN,MAC_keymap[[event keyCode]], NULL);
}
-(void) keyUp:(NSEvent*)event {
	(*CoreDoCommand)(M64CMD_SEND_SDL_KEYUP,MAC_keymap[[event keyCode]], NULL);
}
-(void) flagsChanged:(NSEvent*)event {
	int newFlags = [event modifierFlags];
	// If keydown, there are more flags than previously
	m64p_command command = (newFlags>modFlags ? M64CMD_SEND_SDL_KEYDOWN : M64CMD_SEND_SDL_KEYUP);
	int key = (newFlags ^ modFlags);
	
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
	(*CoreDoCommand)(command,key,NULL);
} 
-(void) windowClosed:(MALGameWindow *)window {;}
-(void) windowDidMove:(NSNotification *)notification {
//	(*CoreDoCommand)(M64CMD_PAUSE,0,0); 
}
-(void) windowWillMove:(NSNotification *)notification{
//	(*CoreDoCommand)(M64CMD_PAUSE,0,0); 
}

#pragma mark initialization
-(void) dealloc {
	[self setIsRunning:NO];
	[plugins release]; plugins = nil;
	[super dealloc];
}
-(id) init {
	if(self = [super init]) {
		initSDLKeyMap();
		plugins = [[NSMutableArray alloc] initWithCapacity:5];
		[plugins addObject:[MALMupenCore defaultCore]];
		modFlags=0;
		for (int i=1; i<5; i++) [plugins addObject:[[[MALMupenPlugin alloc] init] autorelease]];
		for (int i=1; i<5; i++) [self loadPluginType:(m64p_plugin_type)i];
	}
	return self;
}

#pragma mark API
-(void) runWithRom:(MALMupenRom *)rom{
	[NSThread detachNewThreadSelector:@selector(spawnInThreadWithROM:) toTarget:self withObject:rom];
}
-(void) takeScreenShot {
	(*CoreDoCommand)(M64CMD_TAKE_NEXT_SCREENSHOT,NULL,NULL);
}
@end
