//
//  MALArrayController.m
//  mupen
//
//  Created by Rovolo on 10/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALArrayController.h"


@implementation MALArrayController
-(id) arrangedObjects {
	id i;
	@try { // sometimes the program crashes by enumating while adding
		i = [super arrangedObjects];
	} @catch (NSException * e) {
		NSLog(@"%@",e);
	}
	return i;
}
@end
