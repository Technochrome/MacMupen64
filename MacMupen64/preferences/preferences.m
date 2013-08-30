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
NSString * const MALDefaultVolumeKey = @"volume";

NSString * const MALDefaultPluginPathsKey = @"PluginPaths";
NSString * const MALDefaultPluginIconPathsKey = @"Plugin icon paths";
NSString * const MALDefaultKeyBindings = @"KeyBindings";

NSString * const MALApplicationName = @"MacMupen64 Plus";

NSURL * MALKeybindingsFile;
NSURL * MALRecentlyOpenedRomsFile;
NSURL * MALFreezesFolder;
NSURL * MALSRAMFolder;
NSURL * MALConfigFolder;
NSURL * MALRandomDataFolder;
NSURL * MALScreenshotFolder;

NSString * const RSPString = @"RSP";
NSString * const VideoString = @"Video";
NSString * const AudioString = @"Audio";
NSString * const InputString = @"Input";
NSString * const CoreString = @"Core";

static NSURL * getSubfolder(NSFileManager * fileManager, NSURL * parentFolder, NSString * pathComponent) {
	NSURL * subfolder = [parentFolder URLByAppendingPathComponent:pathComponent];
	NSString * folderPath = [subfolder relativePath];
	if ([fileManager fileExistsAtPath:folderPath] == NO) {
		[fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return [subfolder retain];
}

void initializePaths(void) {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSURL * supportFolder = getSubfolder(fileManager,[fileManager URLForDirectory:NSApplicationSupportDirectory
																		 inDomain:NSUserDomainMask
																appropriateForURL:nil create:YES error:NULL], MALApplicationName);

#define subFolder(pathComponent) getSubfolder(fileManager,supportFolder,pathComponent)
	
	MALKeybindingsFile = subFolder(@"keyBindings.plist");
	MALRecentlyOpenedRomsFile = subFolder(@"Recently Opened ROMs.plist");
	MALFreezesFolder = subFolder(@"Freezes");
	MALSRAMFolder = subFolder(@"SRAM");
	MALConfigFolder = subFolder(@"config");
	MALRandomDataFolder = subFolder(@"data");
	MALScreenshotFolder = subFolder(@".screenshot");
}
