//
//  MALEditCoverWindowController.h
//  MacMupen64
//
//  Created by Rovolo on 9/3/13.
//
//

#import <Cocoa/Cocoa.h>

@interface MALEditCoverView : NSView {
	NSImage * srcImg;
	float edgeTop, edgeBottom;
}
@property (retain) NSImage * srcImg;
@property (readwrite) float edgeTop, edgeBottom;
@end

@interface MALEditCoverWindowController : NSWindowController {
	IBOutlet MALEditCoverView * editView;
	NSImage * srcImg;
}

@end
