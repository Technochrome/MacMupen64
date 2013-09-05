//
//  MALAdditions.m
//  mupen
//
//  Created by Rovolo on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALAdditions.h"
#import <sys/xattr.h>

NSSize expandSizeToAspectRatio(NSSize size, NSSize ratio) {
	return NSMakeSize(MAX(size.width ,size.height * ( ratio.width/ratio.height)),
					  MAX(size.height,size.width  * (ratio.height/ ratio.width)));
}
NSSize shrinkSizeToAspectRatio(NSSize size, NSSize ratio) {
	return NSMakeSize(MIN(size.width ,size.height * ( ratio.width/ratio.height)),
					  MIN(size.height,size.width  * (ratio.height/ ratio.width)));
}


@implementation  NSMutableAttributedString (MALAdditions)
-(void) appendString:(NSString*)str withAttributes:(NSDictionary*)attr {
	if(!str) return;
	
	NSAttributedString * string = [[NSAttributedString alloc] initWithString:str attributes:attr];
	[self appendAttributedString:string];
	[string release];
}
-(void) addBoldString:(NSString*)s {
	[self appendString:s withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}];
}
-(void) addRegularString:(NSString*)s {
	[self appendString:s withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]}];
}
-(void) addSmallString:(NSString*)s {
	[self appendString:s withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont smallSystemFontSize]]}];
}
-(void) addRedString:(NSString*)s {
	[self appendString:s withAttributes:@{NSForegroundColorAttributeName: [NSColor redColor]}];
}
-(void) addReturn {
	NSAttributedString * _return = [[NSAttributedString alloc] initWithString:@"\n"];
	[self appendAttributedString:_return];
	[_return release];
}
@end

//http://www.cocoabuilder.com/archive/cocoa/232974-hexvalue-for-nsstring.html
@implementation NSString (HexIntValue)
- (NSUInteger)hexIntegerValue{	
	NSScanner *scanner = [NSScanner scannerWithString: self];
	unsigned long long result;
//	unsigned int res;
//	NSLog(@"%d",sizeof(long long));
	[scanner scanHexLongLong: &result];
//	[scanner scanHexInt:&res];

	return result;
}
@end

@implementation NSOpenGLPixelFormat (initFromArray)
+(NSOpenGLPixelFormat*) pixelFormatFromArrayOfAttributes:(NSArray*)attrs {
	NSOpenGLPixelFormatAttribute * pixelAttrs = malloc(sizeof(NSOpenGLPixelFormatAttribute) * (1 +[attrs count]));
	for(int i=0; i<[attrs count]; i++)
		[[attrs objectAtIndex:i] getValue:&pixelAttrs[i]];
	pixelAttrs[[attrs count]]=0;
	
	NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelAttrs];
	free(pixelAttrs);
	
	return [pixelFormat autorelease];
}
@end

@implementation NSImage (imageFormats)
+(NSImage*) imageWithRep:(NSImageRep*)rep {
	NSImage * image = [[NSImage alloc] initWithSize:[rep size]];
	[image addRepresentation: rep];
	return [image autorelease];
}
-(NSData*) imageInFormat:(NSBitmapImageFileType)format {
	NSData *imageData = [self TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	return [imageRep representationUsingType:format properties:@{NSImageCompressionFactor:@1.0}];
}
-(NSImage*) croppedImage:(NSRect)bounds {
	NSImage * canvas = [[NSImage alloc] initWithSize:bounds.size];
	
	@try {
		[canvas lockFocus];
		NSRect dest = {.size=bounds.size, .origin=NSZeroPoint};
		[self drawInRect:dest fromRect:bounds operation:NSCompositeCopy fraction:1];
		[canvas unlockFocus];
	}@catch (NSException * e) {
		
	}
	
	return [canvas autorelease];
}
-(NSImage*) imageRotatedByDegrees:(CGFloat)degrees {
    NSSize rotatedSize = fabsf(degrees) > 125 ? self.size :
		NSMakeSize(self.size.height, self.size.width);
    NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedSize] ;
	
    NSAffineTransform* transform = [NSAffineTransform transform];
	
    // In order to avoid clipping the image, translate
    // the coordinate system to its center
    [transform translateXBy:+rotatedSize.width/2
                        yBy:+rotatedSize.height/2];
    [transform rotateByDegrees:degrees];
    [transform translateXBy:-self.size.width/2
                        yBy:-self.size.height/2];
	
	@try {
		[rotatedImage lockFocus];
		[transform concat];
		[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
		
		[rotatedImage unlockFocus];
		
	}@catch (NSException * e) {
		
	}

    return [rotatedImage autorelease] ;
}
-(NSImage*) scaledImage:(NSSize)scale {
	NSSize newSize = NSMakeSize(self.size.width * scale.width, self.size.height * scale.height);
	NSImage * canvas = [[NSImage alloc] initWithSize:newSize];
	
	@try {
		[canvas lockFocus];
		NSRect dest = {.size=newSize, .origin=NSZeroPoint};
		[self drawInRect:dest fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
		[canvas unlockFocus];
	}@catch (NSException * e) {
		
	}
	
	return [canvas autorelease];
}
@end


@implementation NSData (xattr)
+(NSData*) dataWithContentsOfFile:(NSURL*)file xattr:(const char *)xattr {
	int fd = [[NSFileHandle fileHandleForReadingFromURL:file error:NULL] fileDescriptor];
	ssize_t size = fgetxattr(fd, xattr, NULL, 0, 0, 0);
	if(size == -1) return nil;
	
	NSMutableData * data = [NSMutableData dataWithCapacity:size];
	[data resetBytesInRange:NSMakeRange(0, size)];
	fgetxattr(fd, xattr, [data mutableBytes], size, 0, 0);
	return data;
}
@end