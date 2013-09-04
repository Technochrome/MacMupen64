//
//  MALMainController.m
//  mupen64plus
//
//  Created by Rovolo on 8/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALMainWindowController.h"
#import "preferences.h"
#import <MacMupen/MALMupenEngine.h>
#import "MALPreferencesWindowController.h"
#import "MALGetCoverWindowController.h"
#import "MALMupenRom.h"

#import "MALBackporting.h"
#import "MALAdditions.h"
#import "MALGameWindow.h"
#import "videoExtension.h"

@implementation MALMainWindowController
#pragma mark accessors
@synthesize mainWindow,engine,romList,romFolderList;

- (IBAction) increaseVolume:(id)sender {
	engine.volume = engine.volume + 10;
}
- (IBAction) decreaseVolume:(id)sender {
	engine.volume = engine.volume - 10;
}

-(MALMupenRom*) openROM {return openROM;}
-(void) setOpenROM:(id)newROM {
	if(newROM==nil) return;
	
	if([newROM isKindOfClass:[NSArray class]]) {
		newROM=[newROM lastObject];
	}
	if([newROM isKindOfClass:[MALMupenRom class]]) {
		[self willChangeValueForKey:@"openROM"];
		[newROM retain];
		[openROM release];
		openROM=newROM;
		[self didChangeValueForKey:@"openROM"];
	}
}

#pragma mark init & dealloc
-(void) dealloc {
	[preferencesController release];
	[openROM release];
	[engine release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[allROMs release];
	[romList release];
	[super dealloc];
}
-(id) init {
	if(self = [super init]) {
		engine = [MALMupenEngine shared];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emulationFinished:) name:MALMupenEngineFinished object:engine];
		allROMs = [[NSCountedSet alloc] init];
		romList = [[NSMutableArray alloc] init];
		romFolders = [[NSMutableDictionary alloc] init];
		
		self.romFolderList = [[NSUserDefaults standardUserDefaults] objectForKey:MALDefaultROMFoldersKey];
		
		[[NSUserDefaultsController sharedUserDefaultsController]
		 addObserver:self
		 forKeyPath:[@"values." stringByAppendingString:MALDefaultROMFoldersKey]
		 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
		 context:NULL];
	}
	return self;
}
-(void) applicationDidFinishLaunching:(NSNotification *)notification {
	[romListView.window makeFirstResponder:romListView];
}

#pragma mark Rom List Management
-(void) addROMToList:(MALMupenRom*)rom {
	if(rom==nil) return;
	[allROMs addObject:rom];
	if([allROMs countForObject:rom]==1) {
		OBJprintf(@"- ");
		[romListController performSelectorOnMainThread:@selector(addObject:) withObject:rom waitUntilDone:YES];
	} else OBJprintf(@"+ ");
	OBJprintf(@"%p %@\n",rom,[rom path]);
}
-(void) removeROMFromList:(MALMupenRom*)rom {
	if(rom==nil) return;
	if([allROMs countForObject:rom]==1) [romListController removeObject:rom];
	[allROMs removeObject:rom];
}
-(void) addROMsToList:(NSArray*)roms {
	for(id rom in roms) [self addROMToList:rom];
}
-(void) removeROMsFromList:(NSArray*) roms {
	for(id rom in roms) [self removeROMFromList:rom];
}

-(void)loadROMsInFolders:(NSArray*)Folders {
	NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
	
	NSFileManager * fm = [NSFileManager defaultManager];
	NSError * error=nil;
	for(NSString * folder in Folders) {
		NSDirectoryEnumerator * spider = [fm enumeratorAtPath:folder];
		NSMutableArray * roms = [NSMutableArray array];
		for(NSString * path in spider) {
			NSString * absPath = [NSString stringWithFormat:@"%@/%@",folder,path];
			NSString * extension = nil;
			if([@"org.mupen64plus.rom" isEqual:[[NSWorkspace sharedWorkspace] typeOfFile:absPath error:&error]]
			   || ((extension = [path pathExtension]) && ([extension isEqual:@"z64"] || [extension isEqual:@"n64"] || [extension isEqual:@"v64"]))
			   ) {
				MALMupenRom * rom = [MALMupenRom mupenROMAtPath:absPath];
				if(rom!=nil) {
//					NSLog(@"%@",absPath);
					[roms addObject:rom];
				} else {
					NSLog(@"MALMupenRom REject: %@",absPath);
				}

			}
		}
		[romFolders setObject:roms forKey:folder];
		[self addROMsToList:roms];
	}
	
	[pl drain];
}

#pragma mark application delegates
-(BOOL)application:(NSApplication*)app openFile:(NSString*)path {
	[self setOpenROM:[MALMupenRom mupenROMAtPath:path]];
	[self startEmulation:self];
	
	return YES;
}
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if(engine.isRunning) {
		[engine stopEmulation];
		[[NSNotificationCenter defaultCenter] addObserverForName:MALMupenEngineFinished object:engine queue:nil usingBlock:^(NSNotification *note) {
			
			[NSApp replyToApplicationShouldTerminate:YES];
		}];
		return NSTerminateLater;
	} else {
		return NSTerminateNow;
	}
}

#pragma mark Notifications
-(void) emulationFinished:(NSNotification*) notification {
	//cycle main window back in
	[mainWindow orderFront:self];
	[mainWindow makeKeyWindow];
}
-(void) romOpened:(NSNotification*) notification {
	[self addROMToList:[notification object]];
}
-(void)awakeFromNib {
	[self addROMsToList:[MALMupenRom recentlyOpenedROMs]];
	
	[NSThread detachNewThreadSelector:@selector(loadROMsInFolders:) toTarget:self withObject:romFolderList];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(romOpened:) name:MALMupenRomNewROMOpened object:nil];
	
	[self bind:@"openROM" toObject:romListController withKeyPath:@"selectedObjects" 
	   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSContinuouslyUpdatesValueBindingOption]];
	[romListController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastOpened" ascending:NO]]];
	[romListController selectNext:self];
}
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(object==[NSUserDefaultsController sharedUserDefaultsController]) {
//		NSLog(@"%@",[change objectForKey:NSKeyValueChangeNewKey]);
//		 ^ shows that for some reason the change type isn't passed, ergo finding the difference ourself
		NSMutableSet * oldFolders = [NSMutableSet setWithArray:romFolderList];
		self.romFolderList=[[NSUserDefaults standardUserDefaults] objectForKey:MALDefaultROMFoldersKey];
		NSSet * _newFolders = [NSSet setWithArray:romFolderList];
		NSMutableSet * newFolders = [NSMutableSet setWithSet:_newFolders];
		[newFolders minusSet:oldFolders];
		[oldFolders minusSet:_newFolders];
		for(NSString * minus in oldFolders) [self removeROMsFromList:[romFolders objectForKey:minus]];
		for(NSString * plus in newFolders) {
			NSArray * roms = [romFolders objectForKey:plus];
			if(roms == nil) {
				[NSThread detachNewThreadSelector:@selector(loadROMsInFolders:) toTarget:self withObject:[NSArray arrayWithObject:plus]];
			}
			else {
				[self addROMsToList:roms];
			}
		}
	}
}

#pragma mark IBActions
-(IBAction) startOpenPanelForROM:(id)sender {
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setResolvesAliases:YES];
	[openPanel setAllowedFileTypes:[defaults objectForKey:MALDefaultROMExtensionsKey]];
	[openPanel setAllowsOtherFileTypes:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setDirectoryURL:[NSURL URLWithString:[defaults objectForKey:MALDefaultOpenPanelDirectoryKey]]];
	if([openPanel runModal] == NSFileHandlingPanelOKButton) {
		
		[defaults setObject:[[openPanel directoryURL] absoluteString] forKey:MALDefaultOpenPanelDirectoryKey];
		MALMupenRom * rom = [MALMupenRom mupenROMAtURL:[openPanel URL]];
		[self addROMToList:rom];
		[romListController setSelectionIndex:[romList indexOfObject:rom]];
		[self startEmulation:self];
	}
}
- (IBAction) startEmulation:(id)sender {
	//hide main window while the game is playing
	[mainWindow orderOut:self];
	
	[engine runWithRom:openROM];
}
- (IBAction) openPreferencesWindow:(id)sender {
	if (preferencesController==nil) {
		NSArrayController * romFolderListController = [[NSArrayController alloc] initWithContent:romFolderList];
		[romFolderListController addObserver:self forKeyPath:@"arrangedObjects" 
									 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
									 context:NULL];
		preferencesController = [[MALPreferencesWindowController alloc] initWithPreferenceItems:
								 @{@"engine":engine, @"romFolderList":romFolderListController}];
	}
	[preferencesController showWindow:self];
}
- (IBAction) getCover:(id)sender {
	if (getCoverController==nil) {
		getCoverController = [[MALGetCoverWindowController alloc] init];
	}
	[getCoverController showWindow:self];
}
@end
