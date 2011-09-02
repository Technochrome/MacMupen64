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
#include "vidext.h"



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

/* Big Bug
 
 This really screws up the experience, and I have no Idea how to fix it
 because I don't know enough about OpenGL and how OS X works with buffers
 and such. If you move the window with the Emulation Video then a picture
 of the current screen gets saved somewhere and flickers in and out with
 the actual video. It's as if something is being saved in some buffer or
 somesuch; I have no idea. This happens even using the command-line program
 with SDL popping up a window, so I don't think that it's because I embeded
 the video into a Cocoa App. This may be a red herring, but using the OpenGL
 Driver Monitor shows that the buffers are being swapped more frequently
 when you move the window. That could be innocuous, but it could be the root
 cause of the problem. I would really appreciate if someone familiar with
 OpenGL could take a look at it because it really ruins the game. Thanks.
 
 P.S. It also occurs when a Semi-Transparent Growl Window appears over the screen.
 */