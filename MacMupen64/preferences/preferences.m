/*
 *  preferences.m
 *  mupen64plus
 *
 *  Created by Rovolo on 8/22/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "Foundation/Foundation.h"
#import "MALBackporting.h"
#import "preferences.h"

NSString * const MALDefaultOpenPanelDirectoryKey = @"OpenPanel Directory";
NSString * const MALDefaultROMExtensionsKey = @"Valid ROM Extensions";

NSString * const MALDefaultROMFoldersKey = @"ROMFolders";

NSString * const MALDefaultPluginPathsKey = @"PluginPaths";
NSString * const MALDefaultPluginIconPathsKey = @"Plugin icon paths";
NSString * const MALDefaultKeyBindings = @"KeyBindings";

NSString * const MALApplicationName = @"MacMupen64 Plus";

NSURL * getApplicationSupportFolder(void) {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL * supportFolder = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
	supportFolder = [supportFolder URLByAppendingPathComponent:MALApplicationName];
	NSString * folderPath = [supportFolder relativePath];
	if ([fileManager fileExistsAtPath:folderPath] == NO) {
		[fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return supportFolder;
}

@implementation MALPreferences : NSObject

+(NSURL*) applicationSupportFolder {
	static NSURL * supportFolder = nil;
	if(supportFolder) return supportFolder;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	supportFolder = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
	supportFolder = [supportFolder URLByAppendingPathComponent:MALApplicationName];
	NSString * folderPath = [supportFolder relativePath];
	if ([fileManager fileExistsAtPath:folderPath] == NO) {
		[fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return [supportFolder retain];
}

@end