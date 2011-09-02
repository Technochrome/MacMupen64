#import <Cocoa/Cocoa.h>
#import "preferences.h"
#import "MALMupenPlugin.h"

#ifdef main
  #undef main
#endif
int main (int argc, char **argv) {
	NSAutoreleasePool * pl = [[NSAutoreleasePool alloc] init];
	
//	LiDTS_CopyTranslateHotKey(0);
	
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
					  forKey:MALDefaultOpenPanelDirectoryKey];
	[defaultValues setObject:[NSArray arrayWithObjects:@"z64",@"n64",@"v64",nil]
					  forKey:MALDefaultROMExtensionsKey];
	
	NSMutableDictionary * pluginPaths = [NSMutableDictionary dictionary];
	[pluginPaths setObject:@"libmupen64plus" forKey:CoreString];
	[pluginPaths setObject:@"mupen64plus-audio-sdl" forKey:AudioString];
	[pluginPaths setObject:@"mupen64plus-input-sdl" forKey:InputString];
	[pluginPaths setObject:@"mupen64plus-rsp-hle" forKey:RSPString];
	[pluginPaths setObject:@"mupen64plus-video-rice" forKey:VideoString];
	[defaultValues setObject:pluginPaths forKey:MALDefaultPluginPathsKey];
	
	[defaultValues setObject:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) forKey:MALDefaultROMFoldersKey];
	
	NSMutableDictionary * iconPaths = [NSMutableDictionary dictionary];
	[iconPaths setObject:@"/Applications/Utilities/Activity Monitor.app/Contents/Resources/ActivityMonitor.icns" forKey:RSPString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Sound.prefPane/Contents/Resources/SoundPref.icns" forKey:AudioString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Displays.prefPane/Contents/Resources/Displays.icns" forKey:VideoString];
	[iconPaths setObject:@"/System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns" forKey:InputString];
	[iconPaths setObject:@"/Applications/System Preferences.app/Contents/Resources/PrefApp.icns" forKey:CoreString];
	[defaultValues setObject:iconPaths forKey:MALDefaultPluginIconPathsKey];
	
#define KEY(n) [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(n)],@"keyCode",[NSNumber numberWithInt:0],@"modifierFlags",nil]
	NSDictionary * keyBindings = [NSDictionary dictionaryWithObjectsAndKeys:
											KEY(17),@"DPad R",
											KEY(125),@"DPad L",
											KEY(115),@"DPad D",
											KEY(119),@"DPad U",nil];
	[defaultValues setObject:keyBindings forKey:MALDefaultKeyBindings];


	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	[pl drain];
    NSApplicationMain (argc, (char const **)argv);
    return 0;
}

