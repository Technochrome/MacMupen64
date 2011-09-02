//
//  MALPreferencePaneController.h
//  mupen
//
//  Created by Rovolo on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MALPreferencePaneController : NSObject {
	IBOutlet NSToolbarItem * toolbarPane;
	IBOutlet NSView * pane;
	NSDictionary * prefs;
}
@property (readonly) NSToolbarItem * toolbarPane;
@property (readonly) NSView * pane;
@property (readwrite,retain) NSDictionary * prefs;
@end
