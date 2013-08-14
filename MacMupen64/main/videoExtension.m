/*
 *  videoExtension.c
 *  mupen
 *
 *  Created by Rovolo on 8/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#include "videoExtension.h"
#import "MALGameWindow.h"
#import "OpenGL/OpenGL.h"

NSOpenGLContext * offscreenContext;
NSOpenGLView * vidExtOpenGL;
NSMutableArray * pixelAttributes;
MALGameWindow * malwin;
GLuint renderBuffer,renderTexture;

#pragma mark Startup/Shutdown

/* video extension functions to be called by the video plugin */
m64p_error VidExt_Init(void) {
	pixelAttributes = [[NSMutableArray alloc] init];
	[[[malwin openGLview] openGLContext] flushBuffer];
    return M64ERR_SUCCESS;
}

m64p_error VidExt_Quit(void) {
	[malwin close];
    return M64ERR_SUCCESS;
}

#pragma mark Screen Handling

m64p_error VidExt_ListFullscreenModes(m64p_2d_size *SizeArray, int *NumSizes) {
	SizeArray[0].uiWidth  = 640;
	SizeArray[0].uiHeight = 480;
	*NumSizes = 1;
	
	return M64ERR_SUCCESS;
}

//creates window
m64p_error VidExt_SetVideoMode(int Width, int Height, int BitsPerPixel, m64p_video_mode screenMode, m64p_video_flags flags) {
	
#define addVal(value,array) {int val=value; [array addObject:[NSValue valueWithBytes:&val objCType:@encode(NSOpenGLPixelFormatAttribute)]];}
	addVal(NSOpenGLPFAColorSize,pixelAttributes);
	addVal((BitsPerPixel*3)/4, pixelAttributes);
	addVal(NSOpenGLPFAAlphaSize,pixelAttributes);
	addVal(BitsPerPixel/4, pixelAttributes);
#undef addVal

	[malwin setFramebufferSize:NSMakeSize(Width, Height) attributes:pixelAttributes];
	
	return M64ERR_SUCCESS;
}

m64p_error VidExt_SetCaption(const char *Title) {
	[malwin performSelector:@selector(setTitle:) onThread:[NSThread mainThread] withObject:[NSString stringWithUTF8String:Title] waitUntilDone:NO];
    return M64ERR_SUCCESS;
}

m64p_error VidExt_ToggleFullScreen(void) {
    NSLog(@"%s: Video extension doesn't yet support fullscreen", __PRETTY_FUNCTION__);
	
    return M64ERR_SYSTEM_FAIL;
}

m64p_error VidExt_ResizeWindow(int Width, int Height) {
    NSLog(@"%s: Video extension doesn't yet support changing size", __PRETTY_FUNCTION__);
    return M64ERR_SYSTEM_FAIL;
}

#pragma mark OpenGL

void * VidExt_GL_GetProcAddress(const char* Proc) {
	CFBundleRef bundle = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.opengl"));
    assert(bundle != NULL);
	
    CFStringRef functionName = CFStringCreateWithCString(kCFAllocatorDefault, Proc, kCFStringEncodingUTF8);
    void *function = CFBundleGetFunctionPointerForName(bundle, functionName);
	
    CFRelease(functionName);
	
	return function;
}


typedef struct {
    m64p_GLattr m64Attr;
    NSOpenGLPixelFormatAttribute nsoglAttr;
} GLAttrMapNode;

m64p_error VidExt_GL_SetAttribute(m64p_GLattr Attr, int Value) {
	NSOpenGLPixelFormatAttribute val[2]={0,0};
	switch (Attr) {
		// ignore
		case M64P_GL_SWAP_CONTROL:
			break;
		
		case M64P_GL_DOUBLEBUFFER:
			val[0]=NSOpenGLPFADoubleBuffer;
			break;
		case M64P_GL_DEPTH_SIZE:
			val[0]=NSOpenGLPFADepthSize;
			val[1]=Value;
			break;
		case M64P_GL_BUFFER_SIZE:
		default:
			NSLog(@"%s: Don't know how to handle video setting: %i %i", __PRETTY_FUNCTION__, Attr,Value);
			break;
	}
	
	for(int i=0; i<2; i++)
		if(val[i]!=0) [pixelAttributes addObject:[NSValue valueWithBytes:&val[i] objCType:@encode(NSOpenGLPixelFormatAttribute)]];
	return M64ERR_SUCCESS;
}

m64p_error VidExt_GL_GetAttribute(m64p_GLattr Attr, int *pValue) {
	GLAttrMapNode GLAttrMap[] = {
	 { M64P_GL_DOUBLEBUFFER, NSOpenGLPFADoubleBuffer },
//	 { M64P_GL_BUFFER_SIZE,  SDL_GL_BUFFER_SIZE },
	 { M64P_GL_DEPTH_SIZE,   NSOpenGLPFADepthSize },
	 { M64P_GL_ALPHA_SIZE,   NSOpenGLPFAAlphaSize },
	 { M64P_GL_SWAP_CONTROL, NSOpenGLCPSwapInterval },
	 { M64P_GL_MULTISAMPLEBUFFERS, NSOpenGLPFASampleBuffers },
	 { M64P_GL_MULTISAMPLESAMPLES, NSOpenGLPFASamples }
	};
	const int mapSize = sizeof(GLAttrMap) / sizeof(GLAttrMapNode);
	
	NSOpenGLPixelFormat *format = vidExtOpenGL.pixelFormat;
	
	switch (Attr) {
		case M64P_GL_RED_SIZE:
		case M64P_GL_BLUE_SIZE:
		case M64P_GL_GREEN_SIZE:
			[format getValues:pValue forAttribute:NSOpenGLPFAColorSize forVirtualScreen:0];
			*pValue = *pValue/3;
			return M64ERR_SUCCESS;
			break;
			
		default:
			for (int i = 0; i < mapSize; i++) {
				if (GLAttrMap[i].m64Attr == Attr) {
					[format getValues:pValue forAttribute:GLAttrMap[i].nsoglAttr forVirtualScreen:0];
					return M64ERR_SUCCESS;
				}
			}
			NSLog(@"%s: Don't know attribute %x", __PRETTY_FUNCTION__, Attr);
			return M64ERR_INPUT_INVALID;
			break;
	}
	
	
	
}

m64p_error VidExt_GL_SwapBuffers(void) {
	[malwin drawFramebuffer];
    return M64ERR_SUCCESS;
}



m64p_video_extension_functions videoExtensionFunctions = {
	.Functions = 11,
	.VidExtFuncInit = VidExt_Init,
	.VidExtFuncQuit = VidExt_Quit,
	.VidExtFuncListModes = VidExt_ListFullscreenModes,
	.VidExtFuncSetMode = VidExt_SetVideoMode,
	.VidExtFuncGLGetProc = VidExt_GL_GetProcAddress,
	.VidExtFuncGLSetAttr = VidExt_GL_SetAttribute,
	.VidExtFuncGLGetAttr = VidExt_GL_GetAttribute,
	.VidExtFuncGLSwapBuf = VidExt_GL_SwapBuffers,
	.VidExtFuncSetCaption = VidExt_SetCaption,
	.VidExtFuncToggleFS = VidExt_ToggleFullScreen,
	.VidExtFuncResizeWindow = VidExt_ResizeWindow
};