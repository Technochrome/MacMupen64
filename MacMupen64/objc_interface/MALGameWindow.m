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

#if 0
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
#endif

-(void) setFramebufferSize:(NSSize)size attributes:(NSArray*)pixelAttributes {
	NSOpenGLPixelFormatAttribute * form = (NSOpenGLPixelFormatAttribute*)malloc(sizeof(NSOpenGLPixelFormatAttribute) * (1 +[pixelAttributes count]));
	for(int i=0; i<[pixelAttributes count]; i++)
		[[pixelAttributes objectAtIndex:i] getValue:&form[i]];
	form[[pixelAttributes count]]=0;
	
	[self setContentSize:size];
	[self setOpenGLview:[[NSOpenGLView alloc] initWithFrame:self.frame pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:form]]];
	[openGLview.openGLContext makeCurrentContext];
	
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
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Framebuffer creation failure");
	}
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

-(void) drawFramebuffer {
//	[[openGLview openGLContext] performSelectorOnMainThread:@selector(flushBuffer) withObject:nil waitUntilDone:YES];
//	if(![NSThread isMainThread])
//		[self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix(); {
		glLoadIdentity();
		glViewport(0, 0, splitSize(self.frame.size));
		glOrtho(0.0, self.frame.size.width, 0.0, self.frame.size.height, -1.0, 1.0);
		
		glMatrixMode(GL_MODELVIEW);
		
		BOOL lighting = glIsEnabled(GL_LIGHTING), textured = glIsEnabled(GL_TEXTURE_2D), depth = glIsEnabled(GL_DEPTH_TEST);
		glDisable(GL_LIGHTING); glDisable(GL_TEXTURE_2D); glDisable(GL_DEPTH_TEST);
		
		glPushMatrix(); {
			//		glBindTexture(GL_TEXTURE_2D, renderTexture);
			glColor3f(.1, .5, 0);
			glTranslated(.1, .1, 0);
			
			glScaled(splitSize(self.frame.size), 1);
			glScaled(.5, .5, 1);
			drawGlRect();
		} glPopMatrix();
		
		
		if(lighting) glEnable(GL_LIGHTING);
		if(textured) glEnable(GL_TEXTURE_2D);
		if(depth) glEnable(GL_DEPTH_TEST);
		
		glMatrixMode(GL_PROJECTION);
	} glPopMatrix();
	
	glMatrixMode(GL_MODELVIEW);
	

	[openGLview.openGLContext flushBuffer];
}
@end

