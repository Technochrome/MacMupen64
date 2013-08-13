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
	GLuint renderTexture,renderBuffer,renderDepth;
}
@property (readwrite, retain) NSOpenGLView * openGLview;
+(NSWindowController*) gameWindow;

-(void) setFramebufferSize:(NSSize)size attributes:(NSArray*)pixelAttributes;
-(void) drawFramebuffer;
@end
