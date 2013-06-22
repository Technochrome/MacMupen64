//
//  MALPreferencesWindowController.m
//  mupen
//
//  Created by Rovolo on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALPreferencesWindowController.h"
#import "MALMainWindowController.h"


////////////////// MALPathArrayInserter

@interface MALPathArrayInserter : NSObject {
	IBOutlet NSArrayController * array;
	
	BOOL canRemove;
}
@property (readwrite) BOOL canRemove;
@property (readwrite,retain) id selection;
-(IBAction) add:(id)sender;
-(IBAction) remove:(id)sender;
@end

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
	if([openPanel runModal] == NSFileHandlingPanelOKButton) {
		
		NSArray * urls = [openPanel URLs];
		for(NSURL *url in urls) [array addObject:[url relativePath]];
	}
}
-(IBAction) remove:(id)sender {
	[array removeObjectsAtArrangedObjectIndexes:[array selectionIndexes]];
}
@end

////////////////// MALPreferencePaneController

@interface MALPreferencePaneController : NSObject {
	IBOutlet NSToolbarItem * toolbarPane;
	IBOutlet NSView * pane;
	NSDictionary * prefs;
}
@property (readonly) NSToolbarItem * toolbarPane;
@property (readonly) NSView * pane;
@property (readwrite,retain) NSDictionary * prefs;
@end

@implementation MALPreferencePaneController
@synthesize toolbarPane,pane,prefs;
@end


////////////////// MALPreferencesWindowController

@implementation MALPreferencesWindowController
@synthesize prefs;
-(void) dealloc {
	[panes release];
	[prefs release];
	[paneIdentifiers release];
	[defaults release];
	[super dealloc];
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
	// Get the preference pane that we're switching to
	[[self window] setTitle:[sender label]];
	NSString * ident = [sender itemIdentifier];
	NSView * pane = [[panes objectForKey:ident] pane];
	
	// Get some content size info
	NSSize oldSize = [[[self window] contentView] frame].size;
	NSSize newSize = [pane frame].size;
	NSRect frame = [[self window] frame];
	
	// Necessary to keep the top-left in the same place,
	// the coordinate system is from the bottom-left
	float yDiff = newSize.height - oldSize.height;
	frame.size.width += newSize.width - oldSize.width;
	frame.size.height += yDiff;
	frame.origin.y -= yDiff;
	
	// Swap to the new pane
	[[self window] setContentView:pane];
	[[self window] setFrame:frame display:YES animate: YES];
}
-(void) awakeFromNib {
	[super awakeFromNib];
	NSURL * prefPanesURL = [[[NSBundle mainBundle] builtInPlugInsURL] URLByAppendingPathComponent:@"Preference Panes.bundle"];
	prefPaneBundle = [[NSBundle bundleWithURL:prefPanesURL] retain];
	[prefPaneBundle load];
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
		//NSLog(@"Preference Pane Plugin id: %@",identifier);
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
