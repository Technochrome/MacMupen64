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

m64p_error VidExt_Init(void);
m64p_error VidExt_Quit(void);

m64p_error VidExt_ListFullscreenModes(m64p_2d_size * size, int * numSizes);
m64p_error VidExt_SetVideoMode(int Width, int Height, int BitsPerPixel, m64p_video_mode screenMode, m64p_video_flags flags);
m64p_error VidExt_SetCaption(const char *Title);
m64p_error VidExt_ToggleFullScreen(void);
m64p_error VidExt_ResizeWindow(int Width, int Height);

void * VidExt_GL_GetProcAddress(const char* Proc);
m64p_error VidExt_GL_SetAttribute(m64p_GLattr Attr, int Value);
m64p_error VidExt_GL_GetAttribute(m64p_GLattr Attr, int *pValue);
m64p_error VidExt_GL_SwapBuffers(void);


extern m64p_video_extension_functions videoExtensionFunctions;

extern NSOpenGLView * vidExtOpenGL;
extern NSOpenGLView * goodGLView;
extern NSMutableArray * pixelAttributes;
@class MALGameWindow;
extern MALGameWindow * malwin;

#endif