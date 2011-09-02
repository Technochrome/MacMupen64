//
//  MALJoystiqView.m
//  mupen
//
//  Created by Rovolo on 9/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALKeyGrabber.h"
/*
[Keyboard]
plugged = True
plugin = 2
mouse = False
DPad R = key(100)
DPad L = key(97)
DPad D = key(115)
DPad U = key(119)
Start = key(13)
Z Trig = key(122)
B Button = key(306)
A Button = key(304)
C Button R = key(108)
C Button L = key(106)
C Button D = key(107)
C Button U = key(105)
R Trig = key(99)
L Trig = key(120)
Mempak switch = key(44)
Rumblepak switch = key(46)
X Axis = key(276,275)
Y Axis = key(273,274)
*/
@implementation MALKeyGrabber
+ (Class)transformedValueClass{
	return [NSDictionary class];
}
+ (BOOL) allowsReverseTransformation {
	return YES;
}
- (id)reverseTransformedValue:(id)value {
	NSString * newVal = [NSString stringWithFormat:@"key(%i)",[[value objectForKey:@"keyCode"] intValue]];
	NSLog(@"set %@",value);
	return newVal;
}
- (id)transformedValue:(id)value {
	if (value == nil) return nil;
	
	if ([value isKindOfClass:[NSString class]]) {
		NSArray * array = [value componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,"]];
		NSLog(@"get %@",value);
		for(int i=1; i<[array count]; i++) {
			int keycode = [[array objectAtIndex:i] intValue];
//			NSLog(@"%i,%@",keycode,LiDTS_CopyTranslateHotKey(keycode));
			return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:keycode],@"keyCode",[NSNumber numberWithInt:0],@"modifierFlags",nil];
		}
	} else {
		[NSException raise: NSInternalInconsistencyException
						format: @"Value (%@) is not a string.",
		[value class]];
	}
	
	return @"placeholder";
}
@end
