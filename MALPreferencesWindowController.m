//
//  MALPreferencesWindowController.m
//  mupen
//
//  Created by Rovolo on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALPreferencesWindowController.h"
#import "MALPreferencePaneController.h"
#import "MALMainWindowController.h"

@implementation MALPreferencesWindowController
@synthesize prefs;
-(void) dealloc {
	[panes release];
	[prefs release];
	[paneIdentifiers release];
	[defaults release];
}
-(id) init {
	if(self = [super initWithWindowNibName:@"Preferences"]) {
		panes = [[NSMutableDictionary alloc] init];
		paneIdentifiers = [[NSMutableArray alloc] init];
		defaults = [[NSUserDefaultsController sharedUserDefaultsController] retain];
		
	}
	return self;
}
-(id) initWithPreferenceItems:(NSDictionary*)p {
	if(self=[self init]) {
		prefs=[p retain];
	}
	return self;
}
-(void) changePane:(NSToolbarItem*)sender {
	[[self window] setTitle:[sender label]];
	NSString * ident = [sender itemIdentifier];
	NSView * pane = [[panes objectForKey:ident] pane];
	
	[[[self window] toolbar] setSelectedItemIdentifier:ident];
	
	NSSize oldSize = [[[self window] contentView] frame].size;
	NSSize newSize = [pane frame].size;
	NSRect frame = [[self window] frame];
	
	float yDiff = newSize.height - oldSize.height;
	frame.size.width += newSize.width - oldSize.width;
	frame.size.height += yDiff;
	frame.origin.y -= yDiff;
	
	[[self window] setContentView:pane];
	[[self window] setFrame:frame display:YES animate: YES];
}
-(void) awakeFromNib {
	[super awakeFromNib];
	prefPaneBundle = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Preference Panes" ofType:@"bundle"]] retain];
	NSArray * panePaths = [prefPaneBundle pathsForResourcesOfType:@"nib" inDirectory:nil];
	
	NSToolbarItem * toolbarItem = nil;
	for(NSString * path in panePaths) {
		MALPreferencePaneController * pane = [[MALPreferencePaneController alloc] init];
		[pane setPrefs:prefs];
		NSNib * nib = [[NSNib alloc] initWithNibNamed:[[path lastPathComponent] stringByDeletingPathExtension] bundle:prefPaneBundle];
		[nib instantiateNibWithOwner:pane topLevelObjects:NULL];
		
		toolbarItem = [pane toolbarPane];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(changePane:)];
		NSString * identifier = [toolbarItem itemIdentifier];
		NSLog(@"%@",identifier);
		[panes setObject:pane forKey:identifier];
		[paneIdentifiers addObject:identifier];
		[[[self window] toolbar] insertItemWithItemIdentifier:identifier atIndex:0];
		
		[pane release];
		[nib release];
	}
	[self changePane:toolbarItem];
}
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    return [[panes objectForKey:itemIdentifier] toolbarPane];
}
@end
