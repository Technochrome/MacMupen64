//
//  MALPathArrayController.m
//  mupen
//
//  Created by Rovolo on 9/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALPathArrayInserter.h"


@implementation MALPathArrayInserter
@synthesize canRemove;
-(id) selection {return nil;}
-(void) setSelection:(id)s {
	[self setCanRemove:[s count]!=0];
}
-(void) awakeFromNib {
	[self bind:@"selection" toObject:array withKeyPath:@"selectedObjects" 
	   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSContinuouslyUpdatesValueBindingOption]];
}
-(IBAction) add:(id)sender {
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:YES];
	if([openPanel runModalForDirectory:nil file:nil types:nil]
	   == NSFileHandlingPanelOKButton) {
		
		NSArray * urls = [openPanel URLs];
		for(NSURL *url in urls) [array addObject:[url relativePath]];
	}
}
-(IBAction) remove:(id)sender {
	[array removeObjectsAtArrangedObjectIndexes:[array selectionIndexes]];
}
@end
