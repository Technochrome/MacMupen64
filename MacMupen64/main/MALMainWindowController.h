
#import <Foundation/Foundation.h>

@class MALMupenEngine,MALMupenRom,MALPreferencesWindowController;
@interface MALMainWindowController : NSObject <NSApplicationDelegate> {
	IBOutlet NSWindow * mainWindow;
	IBOutlet NSTableView * romListView;
	IBOutlet NSArrayController * romListController;
	
	MALPreferencesWindowController * preferencesController;
	MALMupenRom * openROM;
	MALMupenEngine * engine;
	
	//rom objects
	NSCountedSet * allROMs; //This keeps track of whether a rom should be in the list
	NSMutableArray * romList;
	NSMutableArray * romFolderList;
	NSMutableDictionary * romFolders;
}
@property (assign) IBOutlet NSWindow *mainWindow;
@property (readwrite, retain)  MALMupenRom * openROM;
@property (readonly) MALMupenEngine * engine;
@property (readwrite, retain) NSArray *romFolderList;
@property (readwrite, retain) NSArray * romList;
- (IBAction) increaseVolume:(id)sender;
- (IBAction) decreaseVolume:(id)sender;

- (IBAction) startOpenPanelForROM:(id)sender;
- (IBAction) startEmulation:(id)sender;
- (IBAction) openPreferencesWindow:(id)sender;
- (IBAction) takeScreenShot:(id)sender;
@end

/*
 LIST OF THINGS TO DO:
 
 * Make the plugins load and unload correctly
 * Get freezes and defrosts working
 * Get ROM pictues from amazon
 * ROM listing on the main window
 
 */