//
//  MALEmulationScreen.h
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MALGameWindow : NSWindow {
	NSOpenGLView * openGLview;
	
	NSWindow * hiddenWindow;
	NSOpenGLView * offscreenGLview;
	NSOpenGLContext * offscreenContext;
	GLuint renderTexture,renderBuffer;
	GLvoid * offscreenBuffer;
}
+(NSWindowController*) gameWindow;

-(void) setFramebufferSize:(NSSize)size attributes:(NSArray*)pixelAttributes;
-(void) drawFramebuffer;
@end
