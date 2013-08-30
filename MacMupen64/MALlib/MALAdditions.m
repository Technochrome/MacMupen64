//
//  MALAdditions.m
//  mupen
//
//  Created by Rovolo on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALAdditions.h"


@implementation NSString (MALAdditions)
-(NSURL*) MALURLValue {
	return [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
@end

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
-(NSData*) imageInFormat:(NSBitmapImageFileType)format {
	NSData *imageData = [self TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	return [imageRep representationUsingType:format properties:@{NSImageCompressionFactor:@1.0}];
}
@end
