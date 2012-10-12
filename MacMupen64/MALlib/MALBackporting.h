//
//  MALBackporting.h
//  mupen
//
//  Created by Rovolo on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSSortDescriptor (MALBackporting)
+(NSSortDescriptor*) sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;
@end

@interface NSURL (MALBackporting)
-(NSURL*) URLByAppendingPathComponent:(NSString*)component;
@end

/*
@interface NSFileManager (MALBackporting)
-(NSArray*)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask;
//haven't implemented error, shouldCreate, or appropriateForURL
-(NSURL *)URLForDirectory:(NSSearchPathDirectory)directory inDomain:(NSSearchPathDomainMask)domain appropriateForURL:(NSURL *)url create:(BOOL)shouldCreate error:(NSError **)error;
@end
*/