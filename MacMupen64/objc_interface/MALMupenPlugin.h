//
//  MALMupenPlugin.h
//  mupen
//
//  Created by Rovolo on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "m64p_types.h"

NSString * pluginStringForType(m64p_plugin_type type);

@interface MALMupenPlugin : NSObject {
	NSString * pluginName;
	NSString * pluginPath;
	NSImage * pluginImage;
	
	m64p_dynlib_handle pluginHandle;
	m64p_plugin_type pluginType;
	int pluginVersion;
	int APIVersion;
	BOOL isUsable,isCompatible,isOutdated;
}
@property (readonly) NSString *name,*pluginVersion,*apiVersion,*path,*typeString;
@property (readonly) NSImage * image;
@property (readonly) NSAttributedString * infoBlock;
@property (readwrite) BOOL isUsable,isCompatible,isOutdated;
@property (readonly) m64p_dynlib_handle handle;
@property (readonly) m64p_plugin_type type;

-(void) unloadPlugin;
-(BOOL) loadPluginWithPath:(NSString*)libraryPath;
-(BOOL) loadPluginWithName:(NSString*)libraryName;
-(void) removePlugin;
@end
