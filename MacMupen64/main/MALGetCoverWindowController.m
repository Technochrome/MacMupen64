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
	
	[searchField setStringValue:rom.gameTitle];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
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
	// sanitize the value by removing 1) rom attrs 2) apostraphes
	NSString * searchString = searchField.stringValue;
	searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	for(int i=1; i<1000; i++) {
		NSURL *url = [NSURL URLWithString:
					  [NSString stringWithFormat:@"http://www.thecoverproject.net/view.php?page=%d&searchstring=%@",i,searchString]];
		NSData *htmlData = [NSData dataWithContentsOfURL:url];
		
		TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
		NSArray *results = [htmlParser searchWithXPathQuery:@"//td[@class='pageBody']//a"];
		if ([results count] == 0) break;
		for (TFHppleElement *element in results) {
			NSString * text = [element text], *href = [element objectForKey:@"href"];
			NSRange textIndex = [text rangeOfString:@"(n64)" options:NSCaseInsensitiveSearch];
			if(textIndex.location != NSNotFound) {
				NSRange equalsIndex = [href rangeOfString:@"=" options:NSBackwardsSearch];
				[titlesController performSelectorOnMainThread:@selector(addObject:)
												   withObject:@{@"title":[text substringToIndex:textIndex.location],
				 @"id":[href substringFromIndex:equalsIndex.location+1]} waitUntilDone:NO];
			}
		}
	}
	[progressIndicator stopAnimation:nil];
}

-(IBAction) search:(id)sender {
	[titlesController removeObjects:[titlesController arrangedObjects]];
	[self performSelectorInBackground:@selector(search) withObject:nil];
}
@end
