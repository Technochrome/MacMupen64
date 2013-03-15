//
//  MALPreferencesInputController.m
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import "MALPreferencesInputController.h"
#import <MALInput/MALInput.h>

@implementation MALPreferencesInputController

-(void) awakeFromNib {
	// Make the key-binding buttons point to me
	for(NSButton * subview in [view subviews]) {
		NSString * identifier = [subview identifier];
		if(![identifier hasPrefix:@"controller"]) continue;
		
		[subview setAction:@selector(changeKeyBinding:)];
		[subview setTarget:self];
		[subview setButtonType:NSPushOnPushOffButton];
		[subview setState:0];
	}
}

-(IBAction) changeKeyBinding:(id)sender {
	if(!currentKeyBinder) {
		currentKeyBinder = [sender identifier];
		[sender setState:1];
		[[MALInputCenter shared] setInputListener:^(MALInputElement* el) {
			if([el isBoolean] && [el boolValue]) {
				[sender setTitle:[el description]];
				[sender setState:0];
				[[MALInputCenter shared] setInputListener:nil];
				currentKeyBinder = nil;
			}
		}];
	} else {
		[sender setState:0];
	}
}

@end
