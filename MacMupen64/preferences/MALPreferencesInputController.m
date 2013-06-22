//
//  MALPreferencesInputController.m
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import "MALPreferencesInputController.h"
#import <MALInput/MALInput.h>

BOOL (^isAvailableDevice)(MALInputDevice* );

@implementation MALPreferencesInputController
-(id) init {
	if ((self = [super init])) {
		redDefaultKeys = [[NSMutableDictionary alloc] init];
		bindingKeys = [[NSMutableDictionary alloc] init];
		isAvailableDevice = [^BOOL(MALInputDevice * device) {
			// show specific gamepads, generic non-gamepads (keyboard, mouse, etc.)
			return ([device.deviceID isEqualToString:@"Gamepad"] ? device.location != 0 : device.location == 0);
		} copy];
	}
	return self;
}
-(void) awakeFromNib {
	// Make the key-binding buttons point to me
	for(NSButton * subview in [[firstButton superview] subviews]) {
		NSString * identifier = [subview identifier];
		if(![identifier hasPrefix:@"controller"]) continue;
		
		[subview setAction:@selector(changeKeyBinding:)];
		[subview setTarget:self];
		[subview setButtonType:NSPushOnPushOffButton];
		[subview setState:0];
		
		NSMutableParagraphStyle * center = [[NSMutableParagraphStyle alloc] init];
		[center setAlignment:NSCenterTextAlignment];
		NSAttributedString * redString =
			[[NSAttributedString alloc] initWithString:[subview title] attributes:@{
						 NSForegroundColorAttributeName: [NSColor redColor],
									NSFontAttributeName: [NSFont systemFontOfSize:13],
						  NSParagraphStyleAttributeName: center}];
		[subview setAttributedTitle:redString];
		redDefaultKeys[[subview identifier]] = redString;
		bindingKeys[[subview identifier]] = subview;
	}
	
	for (MALInputDevice *device in [[MALInputCenter shared] devicesPassingTest:isAvailableDevice]) {
		[connectedDevicesController addObject:device];
	}
	[[NSNotificationCenter defaultCenter] addObserverForName:MALInputDeviceConnectionNotification object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  MALInputDevice * device = [[MALInputCenter shared] deviceAtPath:note.userInfo[@"path"]];
													  if(!isAvailableDevice(device)) return;
													  [connectedDevicesController addObject:device];
													  NSLog(@"connect: %@, %@",device.name, device);
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:MALInputDeviceDisconnectionNotification object:nil queue:nil
											  usingBlock:^(NSNotification *note) {
												  [connectedDevicesController removeObject:[[MALInputCenter shared] deviceAtPath:note.userInfo[@"path"]]];
												  MALInputDevice * device = [[MALInputCenter shared] deviceAtPath:note.userInfo[@"path"]];
												  if(!isAvailableDevice(device)) return;
												  [connectedDevicesController removeObject:device];
												  NSLog(@"disconnect: %@",device.name);
											  }];
}

-(IBAction) changeKeyBinding:(NSButton*)sender {
	[currentKeyBinder setState:0];
	
	if(currentKeyBinder != sender) {
		currentKeyBinder = sender;
		[sender setState:1];
		[[MALInputCenter shared] setInputListener:^(MALInputElement* el) {
			if([el isBoolean] && [el boolValue] && ![[el fullID] isEqualToString:@"Mouse~left"]) {
				[self->currentKeyBinder setTitle:[el elementID]];
				[self->currentKeyBinder setState:0];
				[[MALInputCenter shared] setInputListener:nil];
				self->currentKeyBinder = nil;
			}
		}];
	} else { // Wrong behaviour. Clicking again should cancel, and clicking another should start that.
		currentKeyBinder = nil;
	}
}

@end
