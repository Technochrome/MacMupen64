//
//  MALEmulationScreen.m
//  mupen
//
//  Created by Rovolo on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MALGameWindow.h"
#import "MALMupenOpenGLView.h"
#import <OpenGL/OpenGL.h>
#import "MALAdditions.h"

static void drawGlRect() {
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0); glVertex3f(0, 0, 0);
	glTexCoord2f(0, 1); glVertex3f(0, 1, 0);
	glTexCoord2f(1, 1); glVertex3f(1, 1, 0);
	glTexCoord2f(1, 0); glVertex3f(1, 0, 0);
	glEnd();
}
static void drawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.2, -0.3, 0.0);
        glVertex3f(  0.2, -0.3, 0.0);
    }
    glEnd();
}

#define REPORTGLERROR() { GLenum tGLErr; while((tGLErr = glGetError()) != GL_NO_ERROR) { printf("OpenGL error %d : %s\n",tGLErr, __PRETTY_FUNCTION__); } }

#define splitSize(size) size.width, size.height
#define splitPoint(point) point.x, point.y
#define splitRect(rect) splitPoint(rect.origin), splitSize(rect.size)

@implementation MALGameWindow
-(NSOpenGLView*) openGLview {return openGLview;}
-(void) setOpenGLview:(NSOpenGLView *)glview {
	[glview retain];
	[openGLview release];
	openGLview = glview;
	[self setContentView:openGLview];
}

+(NSWindowController*) gameWindow {
	NSWindowController * wc = [[NSWindowController alloc] initWithWindowNibName:@"GameWindow"];
	MALGameWindow * emu = (MALGameWindow*)[wc window];
	[emu setOpenGLview:[[[NSOpenGLView alloc] initWithFrame:[emu frame] pixelFormat:[NSOpenGLView defaultPixelFormat]] autorelease]];
	return [wc autorelease];
}

-(void) setFramebufferSize:(NSSize)size attributes:(NSArray*)pixelAttributes {
	if(![NSThread isMainThread]) {
		NSInvocation * invocation;
		[[NSInvocation invocationWithTarget:self invocationOut:&invocation] setFramebufferSize:size attributes:pixelAttributes];
		[invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
		
		[offscreenGLview.openGLContext makeCurrentContext];
		return;
	}
	
	NSLog(@"set framebuffer");
		
	
	NSOpenGLPixelFormat * onscreenPixFormat = [NSOpenGLPixelFormat pixelFormatFromArrayOfAttributes:pixelAttributes],
	*offscreenPixFormat = [NSOpenGLPixelFormat pixelFormatFromArrayOfAttributes:[pixelAttributes arrayByAddingObject:@(NSOpenGLPFAOffScreen)]];
	
	[self setContentSize:size];
	self.openGLview = [[NSOpenGLView alloc] initWithFrame:self.frame pixelFormat:onscreenPixFormat];
	
	[openGLview.openGLContext makeCurrentContext];
	
	glGenTextures(1, &renderTexture);
	glBindTexture(GL_TEXTURE_2D, renderTexture);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0, 1, 0.0, 1, -1.0, 1.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glEnable(GL_TEXTURE_2D);
	
	// Setup offscreen buffer
	NSRect frame = NSMakeRect(100, 100, splitSize(size));
	hiddenWindow  = [[NSWindow alloc] initWithContentRect:frame
												styleMask:NSBorderlessWindowMask
												  backing:NSBackingStoreBuffered
													defer:NO];
	
	offscreenGLview = [[NSOpenGLView alloc] initWithFrame:hiddenWindow.frame pixelFormat:offscreenPixFormat];
	[hiddenWindow setContentView:offscreenGLview];
	
	[offscreenGLview.openGLContext makeCurrentContext];
}

-(void) close {
	[hiddenWindow close];
	[super close];
}

-(void) drawFramebuffer {
	[offscreenGLview.openGLContext flushBuffer];
	
	// read from the offscreen buffer
	NSSize texSize = hiddenWindow.frame.size;
	GLubyte * pixels = malloc(sizeof(GLubyte) * texSize.width * texSize.height * 3);
	glReadPixels(0, 0, splitSize(texSize), GL_RGB, GL_UNSIGNED_BYTE, pixels);
	
	[openGLview.openGLContext makeCurrentContext];
	glViewport(0, 0, splitSize(self.frame.size));
	glClearColor(0, 0, 1, 0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, splitSize(texSize), 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
	glColor3f(1, 1, 1);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0); glVertex3f(0, 0, 0);
	glTexCoord2f(0, 1); glVertex3f(0, 1, 0);
	glTexCoord2f(1, 1); glVertex3f(1, 1, 0);
	glTexCoord2f(1, 0); glVertex3f(1, 0, 0);
	glEnd();
	
	free(pixels);
	glFlush();
#define REPORTGLERROR() { GLenum tGLErr; while((tGLErr = glGetError()) != GL_NO_ERROR) { printf("OpenGL error %d : %s\n",tGLErr, __PRETTY_FUNCTION__); } }
	
	REPORTGLERROR();
	[openGLview.openGLContext flushBuffer];
	[offscreenGLview.openGLContext makeCurrentContext];
}
@end

