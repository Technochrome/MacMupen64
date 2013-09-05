//
//  MALGetCoverWindowController.h
//  MacMupen64
//
//  Created by Rovolo on 8/30/13.
//
//

#import <Cocoa/Cocoa.h>

@class MALEditCoverWindowController;

@interface MALGetCoverWindowController : NSWindowController {
	IBOutlet NSTextField * searchField;
	IBOutlet NSProgressIndicator * progressIndicator;
	IBOutlet NSArrayController * titlesController;
	IBOutlet MALEditCoverWindowController * editWindowController;
}

-(IBAction) downloadCover:(id)sender;
-(IBAction) listCovers:(id)sender;
-(IBAction) search:(id)sender;
@end
