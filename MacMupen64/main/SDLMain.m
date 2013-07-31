#import <Cocoa/Cocoa.h>
#import "preferences.h"
#import "MALMupenPlugin.h"
#import <MALInput/MALInput.h>

#ifdef main
  #undef main
#endif
int main (int argc, char **argv) {
	NSAutoreleasePool * pl = [[NSAutoreleasePool alloc] init];
	
	initializePaths();
	
//	LiDTS_CopyTranslateHotKey(0);
	
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
					  forKey:MALDefaultOpenPanelDirectoryKey];
	defaultValues[MALDefaultROMExtensionsKey] = @[@"z64",@"n64",@"v64"];
	
	NSMutableDictionary * pluginPaths = [NSMutableDictionary dictionary];
	[pluginPaths setObject:@"libmupen64plus" forKey:CoreString];
	[pluginPaths setObject:@"mupen64plus-audio-sdl" forKey:AudioString];
	[pluginPaths setObject:@"libmupen64plus-input-MALInput" forKey:InputString];
	[pluginPaths setObject:@"mupen64plus-rsp-hle" forKey:RSPString];
	[pluginPaths setObject:@"mupen64plus-video-glide64" forKey:VideoString];
	[defaultValues setObject:pluginPaths forKey:MALDefaultPluginPathsKey];
	
	[defaultValues setObject:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) forKey:MALDefaultROMFoldersKey];
	
	NSMutableDictionary * iconPaths = [NSMutableDictionary dictionary];
	[iconPaths setObject:@"/Applications/Utilities/Activity Monitor.app/Contents/Resources/ActivityMonitor.icns" forKey:RSPString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Sound.prefPane/Contents/Resources/SoundPref.icns" forKey:AudioString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Displays.prefPane/Contents/Resources/Displays.icns" forKey:VideoString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns" forKey:InputString];
	[iconPaths setObject:@"/Applications/System Preferences.app/Contents/Resources/PrefApp.icns" forKey:CoreString];
	[defaultValues setObject:iconPaths forKey:MALDefaultPluginIconPathsKey];
	
	defaultValues[MALDefaultVolumeKey] = @100;
	

	[[MALInputCenter shared] startListening];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	[pl drain];
    NSApplicationMain (argc, (char const **)argv);
    return 0;
}

