//
//  MALBackporting.m
//  mupen
//
//  Created by Rovolo on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALBackporting.h"



@implementation NSSortDescriptor (MALBackporting)
+(NSSortDescriptor*) sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending {
	return [[[NSSortDescriptor alloc] initWithKey:key ascending:ascending] autorelease];
}
@end


@implementation NSURL (MALBackporting)
-(NSURL*) URLByAppendingPathComponent:(NSString*)component {
	NSString * path = [self absoluteString];
	path = [path stringByAppendingFormat:@"/%@",[component stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return [NSURL URLWithString:path];
}
@end


@implementation NSFileManager (MALBackporting)
-(NSArray*)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask {
	NSArray * pathArray = NSSearchPathForDirectoriesInDomains(directory, domainMask, YES);
	NSMutableArray * urlArray = [NSMutableArray array];
	for(NSString * s in pathArray) 
		[urlArray addObject:[NSURL URLWithString:[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	return urlArray;
}
- (NSURL *)URLForDirectory:(NSSearchPathDirectory)directory inDomain:(NSSearchPathDomainMask)domain appropriateForURL:(NSURL *)url create:(BOOL)shouldCreate error:(NSError **)error {
	return [[self URLsForDirectory:directory inDomains:domain] lastObject];
}
@end