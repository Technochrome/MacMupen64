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

#import "UKKQueue.h"

NSString *const MALMupenEngineFinished = @"MALMupenEngine Finished Running";
NSString *const MALMupenEngineStarted = @"MALMupenEngine Started Running";

MALMupenEngine * _shared = nil;

@interface MALMupenEngine()
@property (readwrite) NSArray * controllerBindings;
@property (readwrite, retain) NSURL * screenshotSaveLocation;
-(NSURL*) autosaveLocation;
@end

@implementation MALMupenEngine (rawInterface)
-(void) shutdown {
	(*CoreDoCommand)(M64CMD_STOP,0,0);
}
-(void) detachROM {
	(*CoreDoCommand)(M64CMD_ROM_CLOSE, 0,NULL);
	self.mainROM = nil;
}
-(BOOL) attachROM:(MALMupenRom*)rom {
	NSData * romData = [rom contents];
	self.mainROM = rom;
	return (*CoreDoCommand)(M64CMD_ROM_OPEN, (int)[romData length], (unsigned char*)[romData bytes]) == M64ERR_SUCCESS;
}

-(BOOL) saveStateToFile:(NSString*)filepath {
	return (*CoreDoCommand)(M64CMD_STATE_SAVE,1,(void*)[filepath UTF8String]) == M64ERR_SUCCESS;
}
-(BOOL) loadStateFromFile:(NSString*)filepath {
	return (*CoreDoCommand)(M64CMD_STATE_LOAD,0,(void*)[filepath UTF8String]) == M64ERR_SUCCESS;
}

-(BOOL) freezeToFile:(NSURL*)filepath {
	filepath = [[filepath URLByDeletingPathExtension] URLByAppendingPathExtension:@"n64_freeze"];
	[[NSFileManager defaultManager] removeItemAtURL:filepath error:NULL];
	[[NSFileManager defaultManager] createDirectoryAtURL:filepath withIntermediateDirectories:NO attributes:nil error:NULL];
	[self saveStateToFile:[[filepath URLByAppendingPathComponent:@"freeze"] relativePath]];
	[self saveScreenshotToFile:[filepath URLByAppendingPathComponent:@"screen.png"]];
	[@{@"freezeDate":[NSDate date]} writeToURL:[filepath URLByAppendingPathComponent:@"info.plist"] atomically:NO];
	return YES;
}
-(BOOL) defrostFromFile:(NSURL*)filepath {
	return [self loadStateFromFile:[[filepath URLByAppendingPathComponent:@"freeze"] relativePath]];
}
-(void) setState:(m64p_core_param)state toValue:(int)value {
	(*CoreDoCommand)(M64CMD_CORE_STATE_SET,state,&value);
}
-(int) getState:(m64p_core_param)state {
	int ret;
	(*CoreDoCommand)(M64CMD_CORE_STATE_QUERY,state,&ret);
	return ret;
}
-(void) pauseEmulation {
	(*CoreDoCommand)(M64CMD_PAUSE,0,NULL);
}
-(void) resumeEmulation {
	(*CoreDoCommand)(M64CMD_RESUME,0,NULL);
}
-(void) saveScreenshotToFile:(NSURL*)file {
	self.screenshotSaveLocation = file;
	(*CoreDoCommand)(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
}
@end

@implementation MALMupenEngine (interface)


-(IBAction) takeScreenShot:(id)sender {
	NSSavePanel * savePanel = [NSSavePanel savePanel];
	savePanel.allowedFileTypes = @[@"png"];
	if([savePanel runModal] == NSFileHandlingPanelOKButton) {
		[self saveScreenshotToFile:savePanel.URL];
	}
}
-(IBAction) freeze:(id)sender {
	NSSavePanel * savePanel = [NSSavePanel savePanel];
	savePanel.allowedFileTypes = @[@"n64_freeze"];
	if([savePanel runModal] == NSFileHandlingPanelOKButton) {
		[self freezeToFile:savePanel.URL];
	}
}
-(IBAction) defrost:(id)sender {
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	openPanel.allowedFileTypes = @[@"n64_freeze"];
	if([openPanel runModal] == NSFileHandlingPanelOKButton) {
		[self defrostFromFile:openPanel.URL];
	}
}
-(IBAction) reset:(id)sender {
	(*CoreDoCommand)(M64CMD_RESET,0,NULL);
}
-(IBAction) hardwareReset:(id)sender {
	(*CoreDoCommand)(M64CMD_RESET,1,NULL);
}
@end

@implementation MALMupenEngine
-(NSURL*) autosaveLocation {
	return [self.mainROM.freezesPath URLByAppendingPathComponent:@"Autosave.n64_freeze"];
}
-(void) frameCallback {
}
-(void) emulationStarted {
	self.volume = volume;
	if(shouldAutoload) {
		[self autoload];
		shouldAutoload = NO;
	}
}
-(void) emulationStopped {
	[malwin close];
}
-(void) emulationPaused {
	
}
#pragma mark Accessors and Setters
@synthesize plugins,mainROM,isRunning,controllerBindings=controllerBindings;
-(void) setIsRunning:(BOOL)value {
	if(value==isRunning) return; //Don't post a notification if it doesn't change
	
	[self willChangeValueForKey:@"isRunning"];
	isRunning=value;
	[self didChangeValueForKey:@"isRunning"];
	if(isRunning) {
		gameWindow = [[MALGameWindow gameWindow] retain];
		malwin = (MALGameWindow*)[gameWindow window];
		malwin.engine = self;
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
-(void) autosave {
	[self freezeToFile:[self autosaveLocation]];
}
-(void) autoload {
	[self defrostFromFile:[self autosaveLocation]];
}
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
			[self detachROM];
			return NO;
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
-(void) stopEmulation {
	[[NSNotificationCenter defaultCenter] addObserverForName:MALNotificationMupenSaveComplete object:nil queue:nil usingBlock:^(NSNotification *note) {
		[self shutdown];
	}];
	[self autosave];
}
-(void) attachControllers {
	MALInputCenter * inputCenter = [MALInputCenter shared];
	NSArray * availableControllers = [[inputCenter gamepads] arrayByAddingObject:[inputCenter keyboard]];
	NSDictionary * bindingProfiles = [[[NSMutableDictionary alloc] initWithContentsOfURL:MALKeybindingsFile] autorelease];
	self.controllerBindings = [NSMutableArray array];
	
	for (MALInputDevice * device in availableControllers) {
		MALInputProfile * profile = [MALInputProfile profileWithOutputDevice:[MALMupenEngine n64Controller]];
		[profile loadBindings:bindingProfiles[device.name]];
		NSLog(@"%@",device);
		MALInputDevice * outputDevice = [[MALInputCenter shared] deviceUsingProfile:profile withDevices:@[device]];
		[controllerBindings addObject:outputDevice];
	}
}

m64p_handle ConfigSectionHandle;
static void ParameterListCallback(void * context, const char *ParamName, m64p_type ParamType) {
	printf("  %s = ",ParamName);
	switch (ParamType) {
		case M64TYPE_INT:
			printf("%d\n",(*ConfigGetParamInt)(ConfigSectionHandle, ParamName)); break;
		case M64TYPE_FLOAT:
			printf("%f\n",(*ConfigGetParamFloat)(ConfigSectionHandle, ParamName)); break;
		case M64TYPE_BOOL:
			printf("%s\n",(*ConfigGetParamInt)(ConfigSectionHandle, ParamName) ? "true" : "false"); break;
		case M64TYPE_STRING:
			printf("%s\n",(*ConfigGetParamString)(ConfigSectionHandle, ParamName)); break;
	}
	printf("    %s\n",(*ConfigGetParameterHelp)(ConfigSectionHandle, ParamName));
}

static void SectionListCallback(void * context, const char * SectionName) {
	printf("== %s ==\n",SectionName);
	(*ConfigOpenSection)(SectionName, &ConfigSectionHandle);
	(*ConfigListParameters)(ConfigSectionHandle, NULL, ParameterListCallback);
}

static void printConfigSections() {
	(*ConfigListSections)(NULL, SectionListCallback);
}

-(void) runWithRom:(MALMupenRom *)rom{
	if([NSThread isMainThread]) {
		[NSThread detachNewThreadSelector:_cmd toTarget:self withObject:rom];
		return;
	}
	
	@autoreleasepool {
		[[NSThread currentThread] setName:@"Mupen Engine"];
		[self setIsRunning:YES];
		
		(*ConfigListSections)(NULL,configCallback);
		[self attachROM:rom];
		[self attachPluginsToCore];
		
		pixelAttributes = [[NSMutableArray alloc] init];
		(*CoreOverrideVidExt)(&videoExtensionFunctions);
		
		shouldAutoload = YES;
		
		[self attachControllers];
//		printConfigSections();
		(*CoreDoCommand)(M64CMD_EXECUTE, 0, NULL);
		
		[self detachPluginsFromCore];
		[self detachROM];
		
		[self setIsRunning:NO];
	}
}
+(MALInputDevice*) n64Controller {
	static MALInputDevice * device = nil;
	if(device) return device;
	device = [[MALInputDevice alloc] init];
	
#define directional(name) name ".up" , name ".down", name ".left", name ".right"
	for (NSString * path in @[@"a",@"b", @"l",@"r",@"z", @"start",  directional(@"c"), directional(@"dpad")])
		[device setElement:[MALOutputElement boolElement] forPath:path];
	for (NSString * path in @[directional(@"joy")])
		[device setElement:[MALOutputElement joyElement] forPath:path];
#undef directional
	
	return device;
}

#pragma mark initialization
-(void) dealloc {
	[self setIsRunning:NO];
	[plugins release]; plugins = nil;
	[super dealloc];
}

static void frameCallback(unsigned int FrameIndex) {
	[[MALMupenEngine shared] frameCallback];
}

-(void) screenshotPathWritten:(NSNotification*)note {
	NSString *screenshotPath = [MALScreenshotFolder relativePath];
	if([note.userInfo[@"path"] isEqual:screenshotPath]) {
		NSFileManager * fm = [NSFileManager defaultManager];
		NSArray * screenshots = [fm subpathsAtPath:screenshotPath];
		
		if([screenshots count]) {
			NSURL * screenshotURL = [MALScreenshotFolder URLByAppendingPathComponent:screenshots[0]];
			NSLog(@"Move %@ to %@",screenshotURL, self.screenshotSaveLocation);
			[fm moveItemAtURL:screenshotURL toURL:self.screenshotSaveLocation error:NULL];
			self.screenshotSaveLocation = nil;
		}
		for(int i=1; i<[screenshots count]; i++) {
			[fm removeItemAtURL:[MALScreenshotFolder URLByAppendingPathComponent:screenshots[i]] error:NULL];
		}
	}
}
-(id) init {
	if(_shared) {
		[self release];
		return [_shared retain];
	}
	if(self = [super init]) {
		_shared = self;
		plugins = [[NSMutableArray alloc] initWithCapacity:5];
		[plugins addObject:[MALMupenCore defaultCore]];
		
		[[UKKQueue sharedFileWatcher] addPath:[MALScreenshotFolder relativePath]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotPathWritten:) name:UKFileWatcherWriteNotification object:nil];
		
		muted = NO;
		for (int i=1; i<5; i++) [plugins addObject:[[[MALMupenPlugin alloc] init] autorelease]];
		for (int i=1; i<5; i++) [self loadPluginType:(m64p_plugin_type)i];
		
		self.core.engine = self;
		(*CoreDoCommand)(M64CMD_SET_FRAME_CALLBACK,0,frameCallback);
		
		[self bind:@"volume" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.volume" options:nil];
	}
	return self;
}
+(MALMupenEngine*) shared {
	if(!_shared) [[MALMupenEngine alloc] init];
	return _shared;
}

#pragma mark Parameters

-(void) setVolume:(int)v {
	v = MIN(MAX(v,0), 100);
	self.muted = NO;
	if(v == volume) return;
	
	[self setState:M64CORE_AUDIO_VOLUME toValue:v];
	
	[self willChangeValueForKey:@"volume"];
	volume = v;
	[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:@(volume) forKey:MALDefaultVolumeKey];
	[self didChangeValueForKey:@"volume"];
}
-(int) volume { return volume; }
-(void) setMuted:(BOOL)m {
	if(m == muted) return;
	
	[self setState:M64CORE_AUDIO_MUTE toValue:m];
	
	[self willChangeValueForKey:@"muted"];
	muted = m;
	[self didChangeValueForKey:@"muted"];
}
-(BOOL) muted { return muted; }
-(void) setFullscreen:(BOOL)full {
	if(full == fullscreen) return;
	
	[malwin setFullscreen:full];
	
	[self willChangeValueForKey:@"fullscreen"];
	fullscreen = full;
	[self didChangeValueForKey:@"fullscreen"];
}
-(BOOL) fullscreen { return fullscreen; }
-(void) setVideoSize:(NSSize)videoSize {
	[self willChangeValueForKey:@"videoSize"];
	[self setState:M64CORE_VIDEO_SIZE toValue:((int)videoSize.width<<16) + videoSize.height];
	[self didChangeValueForKey:@"videoSize"];
}
-(NSSize) videoSize {
	int size = [self getState:M64CORE_VIDEO_SIZE];
	return NSMakeSize(size>>16, size & ((1<<16)-1));
}
@end
