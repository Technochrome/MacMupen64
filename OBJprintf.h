/*
 *  OBJprintf.h
 *  ImageFun
 *
 *  Created by Rovolo on 6/8/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define OBJprintf(format,args...) printf("%s",[[NSString stringWithFormat:format , ##args] UTF8String])