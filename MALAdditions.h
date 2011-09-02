//
//  MALAdditions.h
//  mupen
//
//  Created by Rovolo on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OBJprintf.h"

@interface NSString (MALAdditions)
-(NSURL*) MALURLValue;
@end

@interface NSMutableAttributedString (MALAdditions)
-(void) addBoldString:(NSString*)s;
-(void) addRegularString:(NSString*)s;
-(void) addSmallString:(NSString*)s;
-(void) addRedString:(NSString*)s;
-(void) addReturn;
@end


@interface NSString (HexIntValue)
- (NSUInteger)hexIntegerValue ;
@end