//
//  MALMupenRom.h
//  mupen
//
//  Created by Rovolo on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "m64p_types.h"

extern NSString * const MALMupenRomNewROMOpened;

@interface MALMupenRom : NSObject <NSCoding, NSURLConnectionDelegate> {
	NSURL * path;
	NSDate * lastOpened;
	
	NSData * contents;
	
	NSString * gameTitle, *MD5;
	NSAttributedString *formattedInfo;
	NSImage * image;
	int status,players;
	BOOL rumble, netplay,isUsable;
	
	long long expectedCoverLength;
	NSMutableData * coverDownload;
}
@property (readonly) NSData * contents;
@property (readwrite, retain) NSImage * image;
@property (readwrite, copy) NSURL * path;
@property (readonly) NSURL * freezesPath;
@property (readwrite, retain) NSString *gameTitle, *MD5;
@property (readwrite, retain) NSAttributedString * formattedInfo;
@property (readwrite) int status,players;
@property (readwrite) BOOL rumble,netplay,isUsable;
@property (readonly) NSDate * lastOpened;


+(MALMupenRom*) mupenROMAtPath:(NSString*)rompath;
+(MALMupenRom*) mupenROMAtURL:(NSURL*)url;

+(NSArray*) recentlyOpenedROMs;
//-(IBAction) loadImageFromAmazon:(id)sender;
@end


@interface MALMupenRom (cover)

@property (readonly) float coverDownloadProgress;
@property (readonly) NSImage * frontCover, *edgeCover, * backCover;

+(NSArray*) coverProjectGamesMatchingSearch:(NSString*)searchString;
+(NSArray*) coverProjectCoversAtHref:(NSString*)href;
+(NSDictionary*) coverProjectDownloadsAtHref:(NSString*)href;

-(void) getCoverProjectCover:(NSString*)href;
@end