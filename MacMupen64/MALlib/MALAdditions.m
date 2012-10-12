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
-(void) addBoldString:(NSString*)s {
	NSDictionary * boldAttr = [NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];
	NSAttributedString * string = [[NSAttributedString alloc] initWithString:s attributes:boldAttr];
	[self appendAttributedString:string];
	[string release];
}
-(void) addRegularString:(NSString*)s {
	NSDictionary * regAttr =  [NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];
	NSAttributedString * string = [[NSAttributedString alloc] initWithString:s attributes:regAttr];
	[self appendAttributedString:string];
	[string release];
}
-(void) addSmallString:(NSString*)s {
	NSDictionary * smallAttr = [NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
	NSAttributedString * string = [[NSAttributedString alloc] initWithString:s attributes:smallAttr];
	[self appendAttributedString:string];
	[string release];
}
-(void) addRedString:(NSString*)s {
	NSDictionary * redAttr = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	NSAttributedString * string = [[NSAttributedString alloc] initWithString:s attributes:redAttr];
	[self appendAttributedString:string];
	[string release];
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