/*
 *  videoExtension.h
 *  mupen
 *
 *  Created by Rovolo on 8/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef videoExtension_h
#define videoExtension_h

#include "m64p_types.h"
#include "m64p_vidext.h"

/* global function for use by frontend.c */
extern m64p_error OverrideVideoFunctions(m64p_video_extension_functions *VideoFunctionStruct);

/* these functions are only used by the core */
extern int VidExt_InFullscreenMode(void);
extern int VidExt_VideoRunning(void);


m64p_error VidExt_Init(void);
m64p_error VidExt_Quit(void);
m64p_error VidExt_ListFullscreenModes(m64p_2d_size * size, int * numSizes);
m64p_error VidExt_SetVideoMode(int Width, int Height, int BitsPerPixel, int ScreenMode);

void * VidExt_GL_GetProcAddress(const char* Proc);
m64p_error VidExt_GL_SetAttribute(m64p_GLattr Attr, int Value);
m64p_error VidExt_GL_SwapBuffers(void);

m64p_error VidExt_SetCaption(const char *Title);
m64p_error VidExt_ToggleFullScreen(void);

extern m64p_video_extension_functions extensionFunctions;

extern NSOpenGLView * vidExtOpenGL;
extern NSOpenGLView * goodGLView;
extern NSMutableArray * pixelAttributes;
@class MALGameWindow;
extern MALGameWindow * malwin;

#endif