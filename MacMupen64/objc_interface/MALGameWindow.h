//
//  MALEmulationScreen.h
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MALGameWindow;

@protocol MALGameWindowEventDelegate
-(void) keyDown:(NSEvent*)event;
-(void) keyUp:(NSEvent*)event;
-(void) flagsChanged:(NSEvent*)event;
@end


@interface MALGameWindow : NSWindow {
	NSOpenGLView * openGLview;
	id<MALGameWindowEventDelegate> keyDelegate;
}
@property (readwrite, retain) NSOpenGLView * openGLview;
@property (readwrite, assign) id<MALGameWindowEventDelegate> keyDelegate;
+(NSWindowController*) gameWindowWithDelegate:(id<MALGameWindowEventDelegate>)delegate;
@end
