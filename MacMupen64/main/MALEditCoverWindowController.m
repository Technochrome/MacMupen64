//
//  MALEditCoverWindowController.m
//  MacMupen64
//
//  Created by Rovolo on 9/3/13.
//
//

#import "MALEditCoverWindowController.h"
#import "MALMupenRom.h"

@implementation MALEditCoverView
@synthesize srcImg;
-(void) drawRect:(NSRect)dirtyRect {
	if(!srcImg) return;
	
	[self lockFocus];
	NSSize imgSize = srcImg.size;
	float imgTop = imgSize.height, imgMidTop = imgSize.height * edgeTop, imgMidBottom = imgSize.height * edgeBottom,
		sizeFront = imgTop - imgMidTop, sizeEdge = imgMidTop - imgMidBottom, sizeBack = imgMidBottom;
	
	NSImage * imgFront = [srcImg croppedImage:NSMakeRect(0, imgMidTop, imgSize.width, sizeFront)],
	* imgEdge = [srcImg croppedImage:NSMakeRect(0, imgMidBottom, imgSize.width, sizeEdge)],
	* imgBack = [[srcImg croppedImage:NSMakeRect(0, 0, imgSize.width, sizeBack)] imageRotatedByDegrees:180];
	
#define gripHeight 10
	
	NSSize rasterSize = self.frame.size;
	rasterSize.height -= 2*gripHeight;
	rasterSize = shrinkSizeToAspectRatio(rasterSize, imgSize);
	
	[imgFront drawInRect:NSMakeRect(0, rasterSize.height*edgeTop + gripHeight*2, rasterSize.width, rasterSize.height*(1-edgeTop))
				fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	
	[imgEdge  drawInRect:NSMakeRect(0, rasterSize.height*edgeBottom + gripHeight, rasterSize.width, rasterSize.height*(edgeTop-edgeBottom))
				fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	
	[imgBack  drawInRect:NSMakeRect(0, 0, rasterSize.width, rasterSize.height*edgeBottom)
				fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	
	[self unlockFocus];
}

-(float) edgeTop { return edgeTop; }
-(float) edgeBottom { return edgeBottom; }
-(void) setEdgeTop:(float)t {
	[self willChangeValueForKey:@"edgeTop"];
	edgeTop = t > edgeBottom ? t : edgeBottom+1;
	[self setNeedsDisplay:YES];
	[self didChangeValueForKey:@"edgeTop"];
}
-(void) setEdgeBottom:(float)b {
	[self willChangeValueForKey:@"edgeBottom"];
	edgeBottom = b < edgeTop ? b : edgeTop - 1;
	[self setNeedsDisplay:YES];
	[self didChangeValueForKey:@"edgeBottom"];
}

-(MALEditCoverView*) initWithFrame:(NSRect)frame {
	if((self = [super initWithFrame:frame])) {
	}
	return self;
}
-(void) awakeFromNib {
	edgeTop = .545;
	edgeBottom = .455;
}
@end

@implementation MALEditCoverWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setContentView:[[[MALEditCoverView alloc] init] autorelease]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void) cover {
	NSImage * img = [[NSImage alloc] initWithContentsOfFile:@"/Users/rovolo/Desktop/n64_mariokart64gold.jpg"];
	srcImg = [[img imageRotatedByDegrees:90] retain];
	id scaledImg = [srcImg scaledImage:NSMakeSize(.5, .5)];
	[img release];
	editView.srcImg = srcImg;
	[editView setNeedsDisplay:YES];
}

-(void) loadCover:(NSString*)coverHref {
//	[progressIndicator startAnimation:nil];
	NSDictionary * downloads = [MALMupenRom coverProjectDownloadsAtHref:coverHref];
	NSURL * coverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thecoverproject.net/%@", downloads[@"thumb"]]];
	NSData *htmlData = [NSData dataWithContentsOfURL:coverURL];
	srcImg = [[NSImage alloc] initWithData:htmlData];
//	[progressIndicator stopAnimation:nil];
}

- (IBAction) showWindow:(id)href {
	[super showWindow:nil];
	[self cover];
//	[self performSelectorInBackground:@selector(loadCover:) withObject:href];
}
@end
