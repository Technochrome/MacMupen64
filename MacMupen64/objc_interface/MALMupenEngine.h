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
	BOOL isRunning, muted, fullscreen;
	BOOL shouldDefrost;
	int framesUntilStop; // Stopping requires an extra frame to flush the command queue
	int volume;
}
@property (readwrite, retain) NSMutableArray * plugins;
@property (readonly) MALMupenCore * core;
@property (readonly) BOOL isRunning;
@property (readwrite, retain) MALMupenRom * mainROM;
@property (readonly) NSArray * controllerBindings;

@property (readwrite) BOOL muted,fullscreen;
@property (readwrite) int volume;

+(MALInputDevice*) n64Controller;

-(void) runWithRom:(MALMupenRom*)rom;
-(void) takeScreenShot;
-(void) freeze;
-(void) defrost;
+(MALMupenEngine*) shared;

-(void) stopEmulation;

-(void) emulationStarted;
-(void) emulationStopped;
-(void) emulationPaused;
@end
