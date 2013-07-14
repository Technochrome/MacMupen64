//
//  MALEmulationScreen.m
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALGameWindow.h"

@implementation MALGameWindow
-(NSOpenGLView*) openGLview {return openGLview;}
-(void) setOpenGLview:(NSOpenGLView *)glview {
	[glview retain];
	[openGLview release];
	openGLview = glview;
	[self setContentView:openGLview];
}

+(NSWindowController*) gameWindow {
	NSWindowController * wc = [[NSWindowController alloc] initWithWindowNibName:@"GameWindow"];
	MALGameWindow * emu = (MALGameWindow*)[wc window];
	[emu setOpenGLview:[[[NSOpenGLView alloc] initWithFrame:[emu frame] pixelFormat:[NSOpenGLView defaultPixelFormat]] autorelease]];
	return [wc autorelease];
}
@end
