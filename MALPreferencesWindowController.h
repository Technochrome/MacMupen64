//
//  MALPreferencesWindowController.h
//  mupen
//
//  Created by Rovolo on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MALMupenEngine;
@interface MALPreferencesWindowController : NSWindowController {
	//Objects
	NSUserDefaultsController * defaults;
	NSDictionary * prefs;
	NSBundle * prefPaneBundle;
	
	NSMutableDictionary * panes;
	NSMutableArray * paneIdentifiers;
}
@property (readonly) NSDictionary * prefs;
-(id) initWithPreferenceItems:(NSDictionary*)p;
@end
