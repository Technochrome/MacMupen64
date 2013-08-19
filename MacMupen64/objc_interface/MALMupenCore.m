//
//  MALMupenCore.m
//  mupen64plus
//
//  Created by Rovolo on 8/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//  lots of stuff taken from core_interface.c
//

#include "m64p_common.h"
#include "m64p_frontend.h"
#include "m64p_config.h"
#include "m64p_debugger.h"

//#include "osal_preproc.h"
#include "osal_dynamiclib.h"

#include "version.h"

#import "MALMupenCore.h"
#import "MALMupenEngine.h"
#import "preferences.h"

#import "core_interface.h"
#import "version.h"
#import "main.h"

NSString * MALNotificationCoreLoaded = @"MALMupenCore Loaded";
NSString * MALNotificationCoreUnloaded = @"MALMupenCore Unloaded";
NSString * MALNotificationMupenSaveComplete = @"MALMupenCore Save Complete";
MALMupenCore * lastMade=nil;

void CoreStateCallback(void *Context, m64p_core_param param_type, int new_value);

@implementation MALMupenCore
@synthesize engine;
#pragma mark dealloc & init
-(id) init {
	if(self=[super init]) lastMade=self;
	return self;
}
void CoreStateCallback(void *Context, m64p_core_param param_type, int new_value) {
	MALMupenCore * core = Context;
	
	switch (param_type) {
		case M64CORE_EMU_STATE:
			switch (new_value) {
				case 1: [core.engine emulationStopped]; break;
				case 2: [core.engine emulationStarted]; break;
				case 3: [core.engine emulationPaused];  break;
			}
			break;
		case M64CORE_SAVESTATE_SLOT:
		case M64CORE_SPEED_FACTOR:
		case M64CORE_SPEED_LIMITER:
		case M64CORE_VIDEO_MODE:
		case M64CORE_STATE_SAVECOMPLETE:
			[[NSNotificationCenter defaultCenter] postNotificationName:MALNotificationMupenSaveComplete object:core];
			break;
		default:
			break;
	}
}
-(BOOL) loadPluginWithPath:(NSString*)libraryPath {
	if([super loadPluginWithPath:libraryPath] == NO) return NO;
	
	//check compatibility
	BOOL Compatible = NO;
    if (pluginType != M64PLUGIN_CORE)
        fprintf(stderr, "AttachCoreLib() Error: Shared library '' invalid; wrong plugin type %i.\n", (int) pluginType);
    else if (pluginVersion < MINIMUM_CORE_VERSION)
        fprintf(stderr, "AttachCoreLib() Error: Shared library '' invalid; core version %i.%i.%i is below minimum supported %i.%i.%i\n",
				VERSION_PRINTF_SPLIT(pluginVersion), VERSION_PRINTF_SPLIT(MINIMUM_CORE_VERSION));
    else if (APIVersion < MINIMUM_API_VERSION)
        fprintf(stderr, "AttachCoreLib() Error: Shared library '' invalid; core API version %i.%i.%i is below minimum supported %i.%i.%i\n",
				VERSION_PRINTF_SPLIT(APIVersion), VERSION_PRINTF_SPLIT(MINIMUM_API_VERSION));
    else
        Compatible = YES;
    if (Compatible == NO) {
		[self removePlugin];
        return isUsable=NO;
    }
	
    /* print some information about the core library */
    printf("UI-console: attached to core library '%s' version %i.%i.%i\n", [pluginName UTF8String], VERSION_PRINTF_SPLIT(pluginVersion));
    if (g_CoreCapabilities & M64CAPS_DYNAREC)
        printf("            Includes support for Dynamic Recompiler.\n");
    if (g_CoreCapabilities & M64CAPS_DEBUGGER)
        printf("            Includes support for MIPS r4300 Debugger.\n");
    if (g_CoreCapabilities & M64CAPS_CORE_COMPARE)
        printf("            Includes support for r4300 Core Comparison.\n");
	
	if(getCoreFunctionPointers(pluginHandle) != M64ERR_SUCCESS) return isUsable = NO;
	if((*CoreStartup)(CONSOLE_UI_VERSION, NULL, NULL, [self typeString], DebugCallback, self, CoreStateCallback) != M64ERR_SUCCESS) {
		[self removePlugin];
		return isUsable = NO;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:MALNotificationCoreLoaded object:self];
	
	return YES;
}
-(void) testCompatibility:(MALMupenCore*)core {
	// we don't want a core to try and load itself
	isCompatible=YES;
}
-(BOOL) loadDefaultCore {
	NSString * libraryPath = [[[NSUserDefaults standardUserDefaults] 
							   objectForKey:MALDefaultPluginPathsKey] 
							  objectForKey:CoreString];
	return [self loadPluginWithName:libraryPath];
}
+(MALMupenCore*) defaultCore {
	MALMupenCore * defaultCore = [[MALMupenCore alloc] init];
	[defaultCore loadDefaultCore];
	return [defaultCore autorelease];
}
+(MALMupenCore*) lastMadeCore {
	return lastMade;
}
-(void) removePlugin {
	if(pluginHandle!=NULL) {
		if(CoreShutdown!=NULL) (*CoreShutdown)();
		zeroCoreFunctionPointers();
		[super removePlugin];
	}
}
@end
