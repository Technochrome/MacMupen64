//
//  MALGetCoverWindowController.h
//  MacMupen64
//
//  Created by Rovolo on 8/30/13.
//
//

#import <Cocoa/Cocoa.h>

@interface MALGetCoverWindowController : NSWindowController {
	IBOutlet NSTextField * searchField;
	IBOutlet NSProgressIndicator * progressIndicator;
	IBOutlet NSArrayController * titlesController;
}


-(IBAction) search:(id)sender;
@end
