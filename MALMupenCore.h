//
//  MALMupenCore.h
//  mupen64plus
//
//  Created by Rovolo on 8/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MALMupenPlugin.h"

extern NSString * MALNotificationCoreLoaded;
extern NSString * MALNotificationCoreUnloaded; 

@interface MALMupenCore : MALMupenPlugin {
}
+(MALMupenCore*) lastMadeCore;
+(MALMupenCore*) defaultCore;
-(BOOL) loadDefaultCore;
@end
