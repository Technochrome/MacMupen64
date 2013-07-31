//
//  MALMupenPlugin.m
//  mupen
//
//  Created by Rovolo on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALMupenPlugin.h"
#import "MALMupenCore.h"

#include "m64p_common.h"
#include "core_interface.h"
#include "osal_dynamiclib.h"
#include "main.h"  /* for the debug callback function */
#import "version.h"
#import "MALAdditions.h"
#import "preferences.h"
#import "osal_dynamiclib.h"

NSString * pluginStringForType(m64p_plugin_type type) {
	switch(type) {
		case M64PLUGIN_RSP: return RSPString;
		case M64PLUGIN_GFX: return VideoString;
		case M64PLUGIN_AUDIO: return AudioString;
		case M64PLUGIN_INPUT: return InputString;
		case M64PLUGIN_CORE: return CoreString;
		default: return @"Unknown";
	}
}

@interface MALMupenPlugin (private)
//@property (readwrite) BOOL isUsable,isCompatible,isOutdated;
-(void) removePlugin;
@end

@implementation MALMupenPlugin
#pragma mark Getters and Setters
@synthesize isUsable,isCompatible,isOutdated;
@synthesize name=pluginName,path=pluginPath,handle=pluginHandle,type=pluginType,image=pluginImage;
-(NSString *) apiVersion {
	return [NSString stringWithFormat:@"%i.%i.%i", VERSION_PRINTF_SPLIT(APIVersion)];
};
-(NSString *) pluginVersion {
	return [NSString stringWithFormat:@"%i.%i.%i", VERSION_PRINTF_SPLIT(pluginVersion)];
};
-(NSString *) typeString {
	return pluginStringForType(pluginType);
}
-(NSAttributedString*) infoBlock {
	NSMutableAttributedString * _info = [[NSMutableAttributedString alloc] init];
	//	[_info addBoldString:[self typeString]];
	[_info addRegularString:[self name]];
	[_info addRegularString:[NSString stringWithFormat:@"\nVersion:%@",[self pluginVersion]]];
	if([self isUsable] == NO) [_info addRedString:@" Unusable"];
	else if([self isOutdated] == YES) [_info addRedString:@" Outdated"];
	else if([self isCompatible] == NO) [_info addRedString:@" Incompatible"];
//	[_info addReturn];
	return [_info autorelease];
}
+ (NSSet *)keyPathsForValuesAffectingInfoBlock {
	return [NSSet setWithObjects:@"isUsable", @"isOutdated", @"isCompatible", nil];
}

#pragma mark dealloc & init
-(void) dealloc {
	[self removePlugin];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
-(id) init {
	if(self = [super init]) {
		pluginHandle=NULL;
		isUsable = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testCompatibility:) name:MALNotificationCoreLoaded object:nil];
	}
	return self;
}

#pragma mark load and unload
-(void) unloadPlugin {
	if (pluginHandle == NULL) return;
	// call the destructor function for the plugin and release the library
	ptr_PluginShutdown PluginShutdown = (ptr_PluginShutdown) osal_dynlib_getproc(pluginHandle, "PluginShutdown");
	if (PluginShutdown != NULL) (*PluginShutdown)();
	osal_dynlib_close(pluginHandle);
	pluginHandle = NULL;
}
-(void) testCompatibility:(MALMupenCore*)core {
	isCompatible=YES;
}
-(BOOL) loadPluginWithPath:(NSString*)libraryPath {
	//path is relative to the executable
	if([libraryPath isAbsolutePath] == NO) {
		NSURL * url = [NSURL URLWithString:libraryPath relativeToURL:[NSURL URLWithString:[[NSBundle mainBundle] executablePath]]];
		NSString * o = [url absoluteString];
		libraryPath = [o stringByReplacingOccurrencesOfString:@"///" withString:@"/"];
	}
	//make sure there isn't an active plugin
	[self removePlugin];
	
	//try to open the plugin at the given filepath
	if(osal_dynlib_open(&pluginHandle, [libraryPath UTF8String]) != M64ERR_SUCCESS || pluginHandle == NULL) {
		[self setIsUsable:NO];
		NSLog(@"FIXME %s", __PRETTY_FUNCTION__);
		return NO;
	}
	
	//get a function ptr to the getVersion() function
    ptr_PluginGetVersion pluginVersionFunction = (ptr_PluginGetVersion) osal_dynlib_getproc(pluginHandle, "PluginGetVersion");
    if (pluginVersionFunction == NULL) {
		[self removePlugin];
		[self setIsUsable:NO];
        return NO;
    } else {
		isUsable = YES;
	}

	
	// get the plugin info
	const char *pluginNameStr= NULL;
	(*pluginVersionFunction)(&pluginType, &pluginVersion, &APIVersion, &pluginNameStr, &g_CoreCapabilities);
	pluginName = [[NSString alloc] initWithUTF8String:pluginNameStr];
	pluginPath = [libraryPath copy];
	NSDictionary * d = [[NSUserDefaults standardUserDefaults] objectForKey:MALDefaultPluginIconPathsKey];
	NSString * s = [d objectForKey:[self typeString]];
	pluginImage = [[NSImage alloc] initWithContentsOfFile:s];
	if(APIVersion<MINIMUM_API_VERSION) {
		[self setIsOutdated:YES];
		return NO;
	}
	
	[self testCompatibility:[MALMupenCore lastMadeCore]];
	return isCompatible;
}
-(BOOL) loadPluginWithName:(NSString*)libraryName {
	return [self loadPluginWithPath:[NSString stringWithFormat:@"%@/%@.dylib",[[NSBundle mainBundle] builtInPlugInsPath],libraryName]];
}
-(void) removePlugin {
	if(pluginHandle!=NULL) {
		osal_dynlib_close(pluginHandle);
		pluginHandle=NULL;
	}
}
@end
