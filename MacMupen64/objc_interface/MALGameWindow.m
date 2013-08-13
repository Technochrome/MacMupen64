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

static void drawGlRect() {
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0); glVertex3f(0, 0, 0);
	glTexCoord2f(0, 1); glVertex3f(0, 1, 0);
	glTexCoord2f(1, 1); glVertex3f(1, 1, 0);
	glTexCoord2f(1, 0); glVertex3f(1, 0, 0);
	glEnd();
}
static void drawAnObject (float z)
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6 + z, 0.0);
        glVertex3f( -0.2, -0.3 + z, 0.0);
        glVertex3f(  0.2, -0.3 + z, 0.0);
    }
    glEnd();
}

#define splitSize(size) size.width, size.height
#define splitPoint(point) point.x, point.y
#define splitRect(rect) splitPoint(rect.origin), splitSize(rect.size)

@implementation MALGameWindow
-(NSOpenGLView*) openGLview {return openGLview;}
-(void) setOpenGLview:(NSOpenGLView *)glview {
	if(glview != openGLview) {
		[glview retain];
		[openGLview release];
		openGLview = glview;
		[self setContentView:openGLview];
		
		[openGLview prepareOpenGL];
		[openGLview.openGLContext makeCurrentContext];
		
		glClearColor(0, 1, .3, 0);
	}
}

+(NSWindowController*) gameWindow {
	NSWindowController * wc = [[NSWindowController alloc] initWithWindowNibName:@"GameWindow"];
	MALGameWindow * emu = (MALGameWindow*)[wc window];
	[emu setOpenGLview:[[[NSOpenGLView alloc] initWithFrame:[emu frame] pixelFormat:[NSOpenGLView defaultPixelFormat]] autorelease]];
	return [wc autorelease];
}

-(void) switchToFramebuffer {
	glBindFramebuffer(GL_FRAMEBUFFER, renderBuffer);
	glBindTexture(GL_TEXTURE_2D, 0);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
}
-(void) switchToScreen {
	[openGLview.openGLContext makeCurrentContext];
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
//    glClearColor(0, .1, .5, 0);
//    glClear(GL_COLOR_BUFFER_BIT);
}

-(void) drawFramebuffer {
	if(![NSThread isMainThread])
		[self performSelector:_cmd onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];

	[openGLview.openGLContext flushBuffer];
	return;
	
	[self switchToScreen];
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glViewport(0, 0, splitSize(self.frame.size));
	glOrtho(0.0, self.frame.size.width, 0.0, self.frame.size.height, -1.0, 1.0);
	
	glMatrixMode(GL_MODELVIEW);
	
	glDisable(GL_LIGHTING);
	glEnable(GL_TEXTURE_2D);
	
	glPushMatrix(); {
		glScaled(self.frame.size.width, self.frame.size.height, 1);
//		glBindTexture(GL_TEXTURE_2D, renderTexture);
		glColor3f(.5, .5, 0);
		drawGlRect();
	
	} glPopMatrix();
	
	
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glMatrixMode(GL_MODELVIEW);
	[openGLview.openGLContext flushBuffer];
	
//	[self switchToFramebuffer];
}
-(void) setFramebufferSize:(NSSize)size {
	
	[self setContentSize:size];
	[openGLview.openGLContext makeCurrentContext];
	return;
	
	glGenTextures(1, &renderTexture);
	glBindTexture(GL_TEXTURE_2D, renderTexture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	
	glGenFramebuffers(1, &renderBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, renderBuffer);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderTexture, 0);
	
	glGenRenderbuffers(1, &renderDepth);
	glBindRenderbuffer(GL_RENDERBUFFER, renderDepth);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, splitSize(size));
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, renderDepth);
	
//	[self switchToFramebuffer];
	[self switchToScreen];
	
	NSLog(@"%x %x", glCheckFramebufferStatus(GL_FRAMEBUFFER), GL_FRAMEBUFFER_COMPLETE);
}
-(void) setPixelFormatAttributes:(NSArray*)pixelAttributes {
//	if(![NSThread isMainThread])
//		[self performSelector:_cmd onThread:[NSThread mainThread] withObject:pixelAttributes waitUntilDone:YES];
	
	pixelAttributes = [pixelAttributes arrayByAddingObjectsFromArray:@[@(NSOpenGLCPSwapInterval),@1]];
	
	NSOpenGLPixelFormatAttribute * attr = (NSOpenGLPixelFormatAttribute*)malloc(sizeof(NSOpenGLPixelFormatAttribute) * (1 +[pixelAttributes count]));
	for(int i=0; i<[pixelAttributes count]; i++)
		[[pixelAttributes objectAtIndex:i] getValue:&attr[i]];
	attr[[pixelAttributes count]]=0;
	
	[self setOpenGLview:[[NSOpenGLView alloc] initWithFrame:self.frame pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:attr]]];
}
@end
