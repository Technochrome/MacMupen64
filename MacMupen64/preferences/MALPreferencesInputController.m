//
//  MALPreferencesInputController.m
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import "MALPreferencesInputController.h"

@implementation MALPreferencesInputController

-(void) awakeFromNib {
	// Make the key-binding buttons point to me
	for(NSButton * subview in [view subviews]) {
		NSString * identifier = [subview identifier];
		if(![identifier hasPrefix:@"controller"]) continue;
		
		[subview setAction:@selector(changeKeyBinding:)];
		[subview setTarget:self];
	}
}

-(IBAction) changeKeyBinding:(id)sender {
	NSLog(@"Change key:%@",[sender identifier]);
}

@end
