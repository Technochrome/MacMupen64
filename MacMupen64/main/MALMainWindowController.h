
#import <Foundation/Foundation.h>

@class MALMupenEngine,MALMupenRom,MALPreferencesWindowController,MALGetCoverWindowController;
@interface MALMainWindowController : NSObject <NSApplicationDelegate> {
	IBOutlet NSWindow * mainWindow;
	IBOutlet NSTableView * romListView;
	IBOutlet NSArrayController * romListController;
	IBOutlet MALMupenEngine * engine;
	
	MALPreferencesWindowController * preferencesController;
	MALGetCoverWindowController * getCoverController;
	MALMupenRom * openROM;
	
	//rom objects
	NSCountedSet * allROMs; //This keeps track of whether a rom should be in the list
	NSMutableArray * romList;
	NSMutableArray * romFolderList;
	NSMutableDictionary * romFolders;
}
@property (assign) NSWindow *mainWindow;
@property (readwrite, retain)  MALMupenRom * openROM;
@property (readonly) MALMupenEngine * engine;
@property (readwrite, retain) NSArray *romFolderList;
@property (readwrite, retain) NSArray * romList;
- (IBAction) increaseVolume:(id)sender;
- (IBAction) decreaseVolume:(id)sender;

- (IBAction) startOpenPanelForROM:(id)sender;
- (IBAction) startEmulation:(id)sender;
- (IBAction) openPreferencesWindow:(id)sender;
- (IBAction) getCover:(id)sender;
@end