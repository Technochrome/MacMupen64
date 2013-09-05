//
//  MALGetCoverWindowController.m
//  MacMupen64
//
//  Created by Rovolo on 8/30/13.
//
//

#import "MALGetCoverWindowController.h"
#import "MALMainWindowController.h"
#import "MALMupenRom.h"
#import "MALEditCoverWindowController.h"

#import "TFHpple.h"

@interface MALGetCoverWindowController ()

@end

@implementation MALGetCoverWindowController
-(id) init {
	if(self = [super initWithWindowNibName:@"GetCoverWindow"]) {
//		webView = [[WebView alloc] init];
	}
	return self;
}

-(void) showWindow:(id)sender {
	[super showWindow:sender];
	MALMainWindowController * wc = sender;
	MALMupenRom * rom = wc.openROM;
	
	NSString * gameTitle = rom.gameTitle;
	
//	[rom getCoverProjectCover:nil];
	
	// Remove Rom Attrs; I don't think any names have ()[] in the title
	NSRange range = [gameTitle rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"()[]"]];
	if(range.location != NSNotFound) {
		gameTitle = [gameTitle substringToIndex:range.location - 1];
	}
	
	// Remove apostraphes, because the search function can't handle it
	gameTitle = [gameTitle stringByReplacingOccurrencesOfString:@"'" withString:@" "];
	
	[searchField setStringValue:gameTitle];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[editWindowController showWindow:nil];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
/*
 @{@"(U)":@"us",
   @"(E)":@"eu",
   @"(UK)":@"gb",
   @"(J)":@"jp",
   @"(A)":@"au",}
 */
-(void) search {
	[progressIndicator startAnimation:nil];
	[titlesController performSelectorOnMainThread:@selector(addObjects:)
									   withObject:[MALMupenRom coverProjectGamesMatchingSearch:searchField.stringValue]
									waitUntilDone:NO];
	[progressIndicator stopAnimation:nil];
}
-(void) getCovers:(NSString*)href {
	[progressIndicator startAnimation:nil];
	
	[titlesController performSelectorOnMainThread:@selector(addObjects:)
									   withObject:[MALMupenRom coverProjectCoversAtHref:href]
									waitUntilDone:NO];
	
	[progressIndicator stopAnimation:nil];
}
-(IBAction) downloadCover:(id)sender {
	[editWindowController showWindow:[titlesController selectedObjects][0][@"href"]];

}
-(IBAction) listCovers:(id)sender {
	NSString * href = [titlesController selectedObjects][0][@"href"];
	[titlesController removeObjects:[titlesController arrangedObjects]];
	[self performSelectorInBackground:@selector(getCovers:) withObject:href];
}

-(IBAction) search:(id)sender {
	[titlesController removeObjects:[titlesController arrangedObjects]];
	[self performSelectorInBackground:@selector(search) withObject:nil];
}
@end
