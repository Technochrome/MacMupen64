//
//  MALPreferencesInputController.m
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import "MALPreferencesInputController.h"
#import <MALInput/MALInput.h>
#import "preferences.h"

BOOL (^isAvailableDevice)(MALInputDevice* );

@implementation MALPreferencesInputController
-(NSURL*) bindingProfilesURL {
	return [getApplicationSupportFolder() URLByAppendingPathComponent:@"keyBindings.plist"];
}
-(id) init {
	if ((self = [super init])) {
		redDefaultKeys = [[NSMutableDictionary alloc] init];
		bindingKeys = [[NSMutableDictionary alloc] init];
		bindingProfiles = [[NSMutableDictionary alloc] initWithContentsOfURL:[self bindingProfilesURL]];
		if(!bindingProfiles) bindingProfiles = [[NSMutableDictionary alloc] init];
		isAvailableDevice = [^BOOL(MALInputDevice * device) {
			if([device.name isEqualToString:@"Mouse"]) return NO;
			return device.location == 0;
			
			// show specific gamepads, generic non-gamepads (keyboard, mouse, etc.)
			//return ([device.deviceID isEqualToString:@"Gamepad"] ? device.location != 0 : device.location == 0);
		} copy];
	}
	return self;
}

-(MALInputDevice*) n64Controller {
	static MALInputDevice * device = nil;
	if(device) return device;
	device = [[MALInputDevice alloc] init];
	
#define directional(name) name ".up" , name ".down", name ".left", name ".right"
	for (NSString * path in @[@"a",@"b", @"l",@"r",@"z", @"start",  directional(@"c"), directional(@"dpad"), directional(@"joy")])
		[device setElement:[MALOutputElement boolElement] forPath:path];
#undef directional
	
	[device setElement:[MALOutputElement joyElement] forPath:@"joy.x"];
	[device setElement:[MALOutputElement joyElement] forPath:@"joy.y"];
	
	return device;
}

-(MALInputDevice*) selectedDevice {
	return selectedDevice;
}
-(void) setSelectedDevice:(MALInputDevice *)sd {
	if(sd == selectedDevice) return;
	
	selectedDevice = sd;
	[currentProfile release];
	for(id key in redDefaultKeys) {
		[bindingKeys[key] setAttributedTitle:redDefaultKeys[key]];
	}
	
	currentProfile = [[MALInputProfile profileWithOutputDevice:[self n64Controller]] retain];
	[currentProfile loadBindings:bindingProfiles[sd.name]];
	
#define titleForKey(key) [MALInputElement elementIDFromFullID:[currentProfile inputIDForKey:key]]
	
	for(NSString * key in [currentProfile boundKeys]) {
		[bindingKeys[[NSString stringWithFormat:@"controller.%@",key]]
		 setTitle:titleForKey(key)];
	}
	
	for(NSArray * joy in @[@[@"joy.x", @"controller.joy.up", @"controller.joy.down"], @[@"joy.y", @"controller.joy.left", @"controller.joy.right"]]) {
		if([[currentProfile boundKeys] containsObject:joy[0]]) {
			[bindingKeys[joy[1]] setTitle:titleForKey(joy[0])];
			[bindingKeys[joy[2]] setHidden:YES];
		} else {
			[bindingKeys[joy[2]] setHidden:NO];
		}
	}
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
	
	[self bind:@"selectedDevice" toObject:connectedDevicesController withKeyPath:@"selection.self" options:nil];
}


-(IBAction) changeKeyBinding:(NSButton*)sender {
	[currentKeyBinder setState:0];
	
	if(currentKeyBinder != sender) {
		currentKeyBinder = sender;
		[sender setState:1];
		
		[[MALInputCenter shared] setInputListener:^(MALInputElement* el) {
			if(el.generalDevice != selectedDevice) return;
			if(! [el boolValue]) return;
			
			NSString * inputKey = [currentKeyBinder.identifier stringByReplacingOccurrencesOfString:@"controller." withString:@""];
			
			// Handle the joystick binders
			if([currentKeyBinder.identifier rangeOfString:@"joy"].location != NSNotFound) {
				BOOL hidden = [el isBoolean] ? NO : YES;
				NSString * dominantKey, * subKey, *floatKey;
				if([currentKeyBinder.identifier hasSuffix:@"up"] || [currentKeyBinder.identifier hasSuffix:@"down"]) {
					dominantKey = @"controller.joy.up";
					subKey = @"controller.joy.down";
					floatKey = @"joy.y";
				} else {
					dominantKey = @"controller.joy.left";
					subKey = @"controller.joy.right";
					floatKey = @"joy.x";
				}
				[bindingKeys[subKey] setHidden:hidden];
				if(hidden == YES) {
					currentKeyBinder = bindingKeys[dominantKey];
					inputKey = floatKey;
				} else {
					[currentProfile setInput:nil forKey:floatKey];
				}
			}
			
			[currentKeyBinder setTitle:[el elementID]];
			[currentKeyBinder setState:0];
			[currentProfile setInput:el forKey:inputKey];
			
			bindingProfiles[selectedDevice.name] = [currentProfile bindingsByID];
			[bindingProfiles writeToURL:[self bindingProfilesURL] atomically:YES];
			
			currentKeyBinder = nil;
			[[MALInputCenter shared] setInputListener:nil];
		}];
	} else { // Wrong behaviour. Clicking again should cancel, and clicking another should start that.
		currentKeyBinder = nil;
	}
}

@end
