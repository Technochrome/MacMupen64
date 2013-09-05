//
//  MALAdditions.h
//  mupen
//
//  Created by Rovolo on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSInvocation(ForwardedConstruction).h"
#import "OBJprintf.h"

NSSize expandSizeToAspectRatio(NSSize size, NSSize ratio);
NSSize shrinkSizeToAspectRatio(NSSize size, NSSize ratio);

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

@interface NSOpenGLPixelFormat (initFromArray)
+(NSOpenGLPixelFormat*) pixelFormatFromArrayOfAttributes:(NSArray*)attributes;
@end

@interface NSImage (imageFormats)
+(NSImage*) imageWithRep:(NSImageRep*)rep;
-(NSData*) imageInFormat:(NSBitmapImageFileType)format;
-(NSImage*) croppedImage:(NSRect)bounds;
-(NSImage*) imageRotatedByDegrees:(CGFloat)degrees;
-(NSImage*) scaledImage:(NSSize)scale;
@end

@interface NSData (xattr)
+(NSData*) dataWithContentsOfFile:(NSURL*)file xattr:(const char *)xattr;
-(void) writeDataToFile:(NSURL*)file xattr:(const char *)xattr;
@end