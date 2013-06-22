//
//  MALPreferencesInputController.h
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import <Foundation/Foundation.h>

@interface MALPreferencesInputController : NSObject {
	IBOutlet NSButton *firstButton;
	IBOutlet NSArrayController *connectedDevicesController;
	NSButton *currentKeyBinder;
	
	NSMutableDictionary *redDefaultKeys;
	NSMutableDictionary *bindingKeys;
}

@end
