//
//  MALEmulationScreen.m
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALGameWindow.h"

@implementation MALGameWindow
@synthesize keyDelegate;
-(NSOpenGLView*) openGLview {return openGLview;}
-(void) setOpenGLview:(NSOpenGLView *)glview {
	[glview retain];
	[openGLview release];
	openGLview = glview;
	[self setContentView:openGLview];
}

+(NSWindowController*) gameWindowWithDelegate:(id<MALGameWindowEventDelegate>)delegate {
	NSWindowController * wc = [[NSWindowController alloc] initWithWindowNibName:@"GameWindow"];
	MALGameWindow * emu = (MALGameWindow*)[wc window];
	[emu setOpenGLview:[[[NSOpenGLView alloc] initWithFrame:[emu frame] pixelFormat:[NSOpenGLView defaultPixelFormat]] autorelease]];
	[emu setKeyDelegate:delegate];
	[emu setDelegate:delegate];
	return [wc autorelease];
}

-(void)keyDown:(NSEvent *)theEvent {
	[keyDelegate keyDown:theEvent];
	[super keyDown:theEvent];
}
-(void)keyUp:(NSEvent *)theEvent {
	[keyDelegate keyUp:theEvent];
	[super keyUp:theEvent];
}
-(void)flagsChanged:(NSEvent *)theEvent {
	[keyDelegate flagsChanged:theEvent];
	[super flagsChanged:theEvent];
}
@end
