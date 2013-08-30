//
//  MALEmulationScreen.h
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MALMupenEngine;

@interface MALGameWindow : NSWindow <NSWindowDelegate> {
	NSOpenGLView * openGLview;
	
	NSWindow * hiddenWindow;
	NSOpenGLView * offscreenGLview;
	NSOpenGLContext * offscreenContext;
	GLuint renderTexture,renderBuffer;
	GLubyte * offscreenBuffer;
	MALMupenEngine * engine;
	
	NSInteger oldLevel;
	NSRect oldFrame;
	NSString * oldTitle;
}
@property (readwrite, assign) MALMupenEngine * engine;
@property (readwrite, retain) NSString * oldTitle;
+(NSWindowController*) gameWindow;

-(void) setFramebufferSize:(NSSize)size attributes:(NSArray*)pixelAttributes;
-(void) drawFramebuffer;
-(void) setFullscreen:(BOOL)fullscreen;
@end
