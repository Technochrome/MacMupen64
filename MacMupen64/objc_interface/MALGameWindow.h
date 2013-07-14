//
//  MALEmulationScreen.h
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MALGameWindow;

@interface MALGameWindow : NSWindow {
	NSOpenGLView * openGLview;
}
@property (readwrite, retain) NSOpenGLView * openGLview;
+(NSWindowController*) gameWindow;
@end
