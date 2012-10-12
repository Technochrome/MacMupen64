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
#include "callbacks.h"
#import "MALGameWindow.h"
#include <SDL/SDL.h>
#import "OpenGL/OpenGL.h"

/*
 typedef struct {
 unsigned int uiWidth;
 unsigned int uiHeight;
 } m64p_2d_size;
 
 typedef enum {
 M64P_GL_DOUBLEBUFFER = 1,
 M64P_GL_BUFFER_SIZE,
 M64P_GL_DEPTH_SIZE,
 M64P_GL_RED_SIZE,
 M64P_GL_GREEN_SIZE,
 M64P_GL_BLUE_SIZE,
 M64P_GL_ALPHA_SIZE,
 M64P_GL_SWAP_CONTROL,
 M64P_GL_MULTISAMPLEBUFFERS,
 M64P_GL_MULTISAMPLESAMPLES
 } m64p_GLattr;
 */

#define KILL_SDL

static m64p_video_extension_functions l_ExternalVideoFuncTable = {9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
static int l_VideoExtensionActive = 0;
static int l_VideoOutputActive = 0;
static int l_Fullscreen = 0;
static SDL_Surface *l_pScreen = NULL;

NSOpenGLView * vidExtOpenGL;
NSMutableArray * pixelAttributes;
NSOpenGLView * goodGLView;
MALGameWindow * malwin;
GLuint TV_FBO;

/* video extension functions to be called by the video plugin */
m64p_error VidExt_Init(void) {
	pixelAttributes = [[NSMutableArray alloc] init];
	[[[malwin openGLview] openGLContext] flushBuffer];
    return M64ERR_SUCCESS;
}

m64p_error VidExt_Quit(void)
{
    /* call video extension override if necessary */
    if (l_VideoExtensionActive)
    {
        m64p_error rval = (*l_ExternalVideoFuncTable.VidExtFuncQuit)();
        if (rval == M64ERR_SUCCESS)
        {
            l_VideoOutputActive = 0;
            StateChanged(M64CORE_VIDEO_MODE, M64VIDEO_NONE);
        }
        return rval;
    }
	
    SDL_ShowCursor(SDL_ENABLE);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    l_pScreen = NULL;
    l_VideoOutputActive = 0;
    StateChanged(M64CORE_VIDEO_MODE, M64VIDEO_NONE);
	
    return M64ERR_SUCCESS;
}

m64p_error VidExt_ListFullscreenModes(m64p_2d_size *SizeArray, int *NumSizes)
{
    const SDL_VideoInfo *videoInfo;
    unsigned int videoFlags;
    SDL_Rect **modes;
    int i;
	
    /* call video extension override if necessary */
    if (l_VideoExtensionActive)
        return (*l_ExternalVideoFuncTable.VidExtFuncListModes)(SizeArray, NumSizes);
	
    /* get a list of SDL video modes */
    videoFlags = SDL_OPENGL | SDL_FULLSCREEN;
	
    if ((videoInfo = SDL_GetVideoInfo()) == NULL)
    {
        DebugMessage(M64MSG_ERROR, "SDL_GetVideoInfo query failed: %s", SDL_GetError());
        return M64ERR_SYSTEM_FAIL;
    }
	
    if(videoInfo->hw_available)
        videoFlags |= SDL_HWSURFACE;
    else
        videoFlags |= SDL_SWSURFACE;
	
    modes = SDL_ListModes(NULL, videoFlags);
	
    if (modes == (SDL_Rect **) 0 || modes == (SDL_Rect **) -1)
    {
        DebugMessage(M64MSG_WARNING, "No fullscreen SDL video modes available");
        *NumSizes = 0;
        return M64ERR_SUCCESS;
    }
	
    i = 0;
    while (i < *NumSizes && modes[i] != NULL)
    {
        SizeArray[i].uiWidth  = modes[i]->w;
        SizeArray[i].uiHeight = modes[i]->h;
        i++;
    }
	
    *NumSizes = i;
	
    return M64ERR_SUCCESS;
}

//creates window
m64p_error VidExt_SetVideoMode(int Width, int Height, int BitsPerPixel, int screenMode) {
	m64p_video_mode ScreenMode;
    const SDL_VideoInfo *videoInfo;
    int videoFlags = 0;
	
#define addVal(value,array) {int val=value; [array addObject:[NSValue valueWithBytes:&val objCType:@encode(NSOpenGLPixelFormatAttribute)]];}
	
	addVal(NSOpenGLPFAColorSize,pixelAttributes);
	addVal((BitsPerPixel*3)/4, pixelAttributes);
	addVal(NSOpenGLPFAAlphaSize,pixelAttributes);
	addVal(BitsPerPixel/4, pixelAttributes);
#undef addVal
		
#ifdef KILL_SDL
//	NSLog(@"%@",pixelAttributes);
	
	NSOpenGLPixelFormatAttribute * form = (NSOpenGLPixelFormatAttribute*)malloc(sizeof(NSOpenGLPixelFormatAttribute) * (1 +[pixelAttributes count]));
	for(int i=0; i<[pixelAttributes count]; i++)
		[[pixelAttributes objectAtIndex:i] getValue:&form[i]];
	form[[pixelAttributes count]]=0;
	
	NSRect frame = NSMakeRect(0, 0, Width, Height);
	[malwin setContentSize:frame.size];
	vidExtOpenGL = [[[NSOpenGLView alloc] initWithFrame:frame pixelFormat:[[[NSOpenGLPixelFormat alloc] initWithAttributes:form] autorelease]] autorelease];
	[malwin setOpenGLview:vidExtOpenGL];
	NSOpenGLContext * ogc = [vidExtOpenGL openGLContext];
	[ogc makeCurrentContext];
//	GLint swap=1;
//	[ogc setValues:&swap forParameter:NSOpenGLCPSwapInterval];
	
	return M64ERR_SUCCESS;
#endif
	
    /* call video extension override if necessary */
    if (l_VideoExtensionActive)
    {
        m64p_error rval = (*l_ExternalVideoFuncTable.VidExtFuncSetMode)(Width, Height, BitsPerPixel, ScreenMode);
        l_Fullscreen = (rval == M64ERR_SUCCESS && ScreenMode == M64VIDEO_FULLSCREEN);
        l_VideoOutputActive = (rval == M64ERR_SUCCESS);
        if (l_VideoOutputActive)
            StateChanged(M64CORE_VIDEO_MODE, ScreenMode);
        return rval;
    }
	
    /* Get SDL video flags to use */
    if (ScreenMode == M64VIDEO_WINDOWED)
        videoFlags = SDL_OPENGL;
    else if (ScreenMode == M64VIDEO_FULLSCREEN)
        videoFlags = SDL_OPENGL | SDL_FULLSCREEN;
    else
        return M64ERR_INPUT_INVALID;
	
    if ((videoInfo = SDL_GetVideoInfo()) == NULL)
    {
        DebugMessage(M64MSG_ERROR, "SDL_GetVideoInfo query failed: %s", SDL_GetError());
        return M64ERR_SYSTEM_FAIL;
    }
    if (videoInfo->hw_available)
        videoFlags |= SDL_HWSURFACE;
    else
        videoFlags |= SDL_SWSURFACE;
	
    /* set the mode */
    if (BitsPerPixel > 0)
        DebugMessage(M64MSG_INFO, "Setting %i-bit video mode: %ix%i", BitsPerPixel, Width, Height);
    else
        DebugMessage(M64MSG_INFO, "Setting video mode: %ix%i", Width, Height);
	
    l_pScreen = SDL_SetVideoMode(Width, Height, BitsPerPixel, videoFlags);
    if (l_pScreen == NULL)
    {
        DebugMessage(M64MSG_ERROR, "SDL_SetVideoMode failed: %s", SDL_GetError());
        return M64ERR_SYSTEM_FAIL;
    }
	
    SDL_ShowCursor(SDL_DISABLE);
	
    l_Fullscreen = (ScreenMode == M64VIDEO_FULLSCREEN);
    l_VideoOutputActive = 1;
    StateChanged(M64CORE_VIDEO_MODE, ScreenMode);
    return M64ERR_SUCCESS;
}

m64p_error VidExt_SetCaption(const char *Title)
{
    /* call video extension override if necessary */
    if (l_VideoExtensionActive)
        return (*l_ExternalVideoFuncTable.VidExtFuncSetCaption)(Title);
	
//    SDL_WM_SetCaption(Title, "M64+ Video");
	
    return M64ERR_SUCCESS;
}

m64p_error VidExt_ToggleFullScreen(void)
{
    /* call video extension override if necessary */
    if (l_VideoExtensionActive)
    {
        m64p_error rval = (*l_ExternalVideoFuncTable.VidExtFuncToggleFS)();
        if (rval == M64ERR_SUCCESS)
        {
            l_Fullscreen = !l_Fullscreen;
            StateChanged(M64CORE_VIDEO_MODE, l_Fullscreen ? M64VIDEO_FULLSCREEN : M64VIDEO_WINDOWED);
        }
        return rval;
    }
	
    if (SDL_WM_ToggleFullScreen(l_pScreen) == 1)
    {
        l_Fullscreen = !l_Fullscreen;
        StateChanged(M64CORE_VIDEO_MODE, l_Fullscreen ? M64VIDEO_FULLSCREEN : M64VIDEO_WINDOWED);
        return M64ERR_SUCCESS;
    }
	
    return M64ERR_SYSTEM_FAIL;
}

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
    SDL_GLattr sdlAttr;
} GLAttrMapNode;

m64p_error VidExt_GL_SetAttribute(m64p_GLattr Attr, int Value)
{
/*	GLAttrMapNode GLAttrMap[] = {
        { M64P_GL_DOUBLEBUFFER, SDL_GL_DOUBLEBUFFER },
        { M64P_GL_BUFFER_SIZE,  SDL_GL_BUFFER_SIZE },
        { M64P_GL_DEPTH_SIZE,   SDL_GL_DEPTH_SIZE },
        { M64P_GL_RED_SIZE,     SDL_GL_RED_SIZE },
        { M64P_GL_GREEN_SIZE,   SDL_GL_GREEN_SIZE },
        { M64P_GL_BLUE_SIZE,    SDL_GL_BLUE_SIZE },
        { M64P_GL_ALPHA_SIZE,   SDL_GL_ALPHA_SIZE },
        { M64P_GL_SWAP_CONTROL, SDL_GL_SWAP_CONTROL },
        { M64P_GL_MULTISAMPLEBUFFERS, SDL_GL_MULTISAMPLEBUFFERS },
        { M64P_GL_MULTISAMPLESAMPLES, SDL_GL_MULTISAMPLESAMPLES }};*/
//    const int mapSize = sizeof(GLAttrMap) / sizeof(GLAttrMapNode);
	
	NSOpenGLPixelFormatAttribute val[2]={0,0};
	switch (Attr) {
		case M64P_GL_DOUBLEBUFFER:
			val[0]=NSOpenGLPFADoubleBuffer;
			break;
		case M64P_GL_DEPTH_SIZE:
			val[0]=NSOpenGLPFADepthSize;
			val[1]=Value;
			break;
		case M64P_GL_BUFFER_SIZE:
		default:
			printf("don't know how to handle video setting: %i %i\n",Attr,Value);
			break;
	}
	
	for(int i=0; i<2; i++)
		if(val[i]!=0) [pixelAttributes addObject:[NSValue valueWithBytes:&val[i] objCType:@encode(NSOpenGLPixelFormatAttribute)]];
	return M64ERR_SUCCESS;
}

m64p_error VidExt_GL_SwapBuffers(void) {
	[[vidExtOpenGL openGLContext] performSelectorOnMainThread:@selector(flushBuffer) withObject:nil waitUntilDone:YES];
//	glClear(GL_COLOR_BUFFER_BIT);
    return M64ERR_SUCCESS;
}

m64p_video_extension_functions extensionFunctions = {
	.Functions = 9,
	.VidExtFuncInit = VidExt_Init,
	.VidExtFuncQuit = VidExt_Quit,
	.VidExtFuncListModes = VidExt_ListFullscreenModes,
	.VidExtFuncSetMode = VidExt_SetVideoMode,
	.VidExtFuncGLGetProc = VidExt_GL_GetProcAddress,
	.VidExtFuncGLSetAttr = VidExt_GL_SetAttribute,
	.VidExtFuncGLSwapBuf = VidExt_GL_SwapBuffers,
	.VidExtFuncSetCaption = VidExt_SetCaption,
	.VidExtFuncToggleFS = VidExt_ToggleFullScreen
};