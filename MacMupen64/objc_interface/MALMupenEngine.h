//
//  MALMupenPlugins.h
//  mupen
//
//  Created by Rovolo on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MALGameWindow.h"
#import <MALInput/MALInput.h>

extern NSString * const MALMupenEngineStarted;
extern NSString * const MALMupenEngineFinished;

@class MALMupenRom,MALMupenCore;
@interface MALMupenEngine : NSObject {
	NSMutableArray * plugins,*controllerBindings;
	NSWindowController * gameWindow;
	BOOL isRunning, muted, fullscreen, shouldAutoload;
	int volume;
}
@property (readwrite, retain) NSMutableArray * plugins;
@property (readonly) MALMupenCore * core;
@property (readonly) BOOL isRunning;
@property (readwrite, retain) MALMupenRom * mainROM;
@property (readonly) NSArray * controllerBindings;

@property (readwrite) BOOL muted,fullscreen;
@property (readwrite) int volume;

@property (readwrite) NSSize videoSize;

+(MALInputDevice*) n64Controller;

-(void) runWithRom:(MALMupenRom*)rom;
+(MALMupenEngine*) shared;

-(void) stopEmulation;

-(void) emulationStarted;
-(void) emulationStopped;
-(void) emulationPaused;
@end

@interface MALMupenEngine (interface)
-(IBAction) takeScreenShot:(id)sender;
-(IBAction) freeze:(id)sender;
-(IBAction) defrost:(id)sender;
-(IBAction) reset:(id)sender;
-(IBAction) hardwareReset:(id)sender;
@end

@interface MALMupenEngine (rawInterface)
-(void) pauseEmulation;
-(void) resumeEmulation;
-(void) saveScreenshotToFile:(NSURL*)file;
@end