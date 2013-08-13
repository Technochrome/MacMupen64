//
//  MALMupenOpenGLView.m
//  MacMupen64
//
//  Created by Rovolo on 8/12/13.
//
//

#import "MALMupenOpenGLView.h"

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

GLuint renderBuffer,renderTexture;

@implementation MALMupenOpenGLView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) prepareOpenGL {
	
	glGenTextures(1, &renderTexture);
	glBindTexture(GL_TEXTURE_2D, renderTexture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	NSSize size = self.frame.size;
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	
	glGenFramebuffers(1, &renderBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, renderBuffer);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderTexture, 0);
	
	NSLog(@"%x %x", glCheckFramebufferStatus(GL_FRAMEBUFFER), GL_FRAMEBUFFER_COMPLETE);
	[super prepareOpenGL];
}

- (void)drawRect:(NSRect)dirtyRect {
	glBindFramebuffer(GL_FRAMEBUFFER, renderBuffer);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    drawAnObject(0.0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	drawAnObject(0.5);
    glFlush();
}

@end
