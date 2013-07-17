//
//  MALPreferencesInputController.m
//  MacMupen64
//
//  Created by Rovolo on 3/14/13.
//
//

#import "MALPreferencesInputController.h"
#import <MALInput/MALInput.h>
#import <MacMupen/MALMupenEngine.h>
#import "preferences.h"

BOOL (^isAvailableDevice)(MALInputDevice* );

@implementation MALPreferencesInputController
-(id) init {
	if ((self = [super init])) {
		redDefaultKeys = [[NSMutableDictionary alloc] init];
		bindingKeys = [[NSMutableDictionary alloc] init];
		bindingProfiles = [[NSMutableDictionary alloc] initWithContentsOfURL:MALKeybindingsFile];
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
	
	currentProfile = [[MALInputProfile profileWithOutputDevice:[MALMupenEngine n64Controller]] retain];
	[currentProfile loadBindings:bindingProfiles[sd.name]];
	
#define titleForKey(key) [MALInputElement elementIDFromFullID:[currentProfile inputIDForKey:key]]
	
	for(NSString * key in [currentProfile boundKeys]) {
		[bindingKeys[[NSString stringWithFormat:@"controller.%@",key]]
		 setTitle:titleForKey(key)];
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
			
			[currentKeyBinder setTitle:[el elementID]];
			[currentKeyBinder setState:0];
			[currentProfile setInput:el forKey:inputKey];
			
			bindingProfiles[selectedDevice.name] = [currentProfile bindingsByID];
			[bindingProfiles writeToURL:MALKeybindingsFile atomically:YES];
			
			currentKeyBinder = nil;
			[[MALInputCenter shared] setInputListener:nil];
		}];
	} else { // Wrong behaviour. Clicking again should cancel, and clicking another should start that.
		currentKeyBinder = nil;
	}
}

@end
