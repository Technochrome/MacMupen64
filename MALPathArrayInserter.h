//
//  MALPathArrayController.h
//  mupen
//
//  Created by Rovolo on 9/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MALPathArrayInserter : NSObject {
	IBOutlet NSArrayController * array;
	
	BOOL canRemove;
}
@property (readwrite) BOOL canRemove;
@property (readwrite,retain) id selection;
-(IBAction) add:(id)sender;
-(IBAction) remove:(id)sender;
@end
