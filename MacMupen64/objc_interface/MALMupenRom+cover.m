//
//  MALMupenRom+cover.m
//  MacMupen64
//
//  Created by Rovolo on 9/5/13.
//
//

#import "MALMupenRom.h"
#import "MALAdditions.h"
#import "preferences.h"
#import "TFHpple.h"

const char * const xattrCoverKey = "Mupen64plus Cover";
const char * const xattrCoverSectionsKey = "Mupen64plus Cover Sections";

extern NSImage * MALDefaultRomImage;

@implementation MALMupenRom (cover)

#pragma mark Accessing Cover

-(NSImage*) cover {
	NSData * xattrImg = [NSData dataWithContentsOfFile:path xattr:xattrCoverKey];
	if(!xattrImg) return nil;
	NSBitmapImageRep * bitImage = [NSBitmapImageRep imageRepWithData:xattrImg];
	
	return [NSImage imageWithRep:bitImage];
}
-(void) setCover:(NSData*)cover {
	[self willChangeValueForKey:@"cover"];
	[cover writeDataToFile:path xattr:xattrCoverKey];
	[self didChangeValueForKey:@"cover"];
}

-(NSArray*) coverSections {
	NSData * coverSections = [NSData dataWithContentsOfFile:path xattr:xattrCoverSectionsKey];
	if(!coverSections) { // default cover sections
		float a[] = {0, 1546.0 / 3366.0, 1830.0 / 3366.0, 1};
#define range(n) @[@(a[n]), @(a[n+1]-a[n])]
		return @[range(0), range(1), range(2)];
#undef range
	}
	return [NSKeyedUnarchiver unarchiveObjectWithData:coverSections];
}
-(void) setCoverSections:(NSArray*)cs {
	NSData * data = [NSKeyedArchiver archivedDataWithRootObject:cs];
	[self willChangeValueForKey:@"coverSections"];
	[data writeDataToFile:path xattr:xattrCoverSectionsKey];
	[self didChangeValueForKey:@"coverSections"];
}

-(NSURL*) coverImageURL {return [[MALCoversFolder URLByAppendingPathComponent:self.gameTitle] URLByAppendingPathExtension:@"jpg"];}
-(NSImage*) coverSection:(int)section {
	NSImage * cover = [self cover];
	NSArray * range = [self coverSections][section];
	return [cover croppedImage:NSMakeRect([range[0] floatValue], 0, [range[1] floatValue], 1)];
}

#define keyDependsOnCover(key) +(NSSet*) keyPathsForValuesAffecting##key { return [NSSet setWithObjects:@"cover",@"coverSections",nil];}
keyDependsOnCover(FrontCover)
keyDependsOnCover(EdgeCover)
keyDependsOnCover(BackCover)

-(NSImage*) frontCover {
	NSImage * cover = [[self coverSection:2] imageRotatedByDegrees:90];
	return cover ? cover : MALDefaultRomImage;
}
-(NSImage*) edgeCover  {return [self coverSection:1];}
-(NSImage*) backCover  {return [self coverSection:0];}

#pragma mark Downloading Cover

-(NSString*) gameTitleForSearch {
	NSString * ret = gameTitle;
	// Remove Rom Attrs; I don't think any names have ()[] in the title
	NSRange range = [gameTitle rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"()[]"]];
	if(range.location != NSNotFound) {
		ret = [ret substringToIndex:range.location - 1];
	}
	
	// Remove apostraphes, because the search function can't handle it
	return [ret stringByReplacingOccurrencesOfString:@"'" withString:@" "];
}
+(NSURL*) coverProjectURL:(NSString*)path {
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thecoverproject.net/%@",path]];
}
+(NSData*) contentsOfCoverProjectPageAtPath:(NSString*)path {
	return [NSData dataWithContentsOfURL:[self coverProjectURL:path]];
}
+(NSArray*) coverProjectGamesMatchingSearch:(NSString*)searchString {
	searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSMutableArray * ret = [NSMutableArray array];
	for(int i=1; i<1000; i++) {
		TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[MALMupenRom contentsOfCoverProjectPageAtPath:
														  [NSString stringWithFormat:@"view.php?page=%d&searchstring=%@",i,searchString]]];
		NSArray *results = [htmlParser searchWithXPathQuery:@"//td[@class='pageBody']//a"];
		if ([results count] == 0) break;
		for (TFHppleElement *element in results) {
			NSString * text = [element text], *href = [element objectForKey:@"href"];
			NSRange textIndex = [text rangeOfString:@"(n64)" options:NSCaseInsensitiveSearch];
			if(textIndex.location != NSNotFound) {
				[ret addObject:@{@"title":[text substringToIndex:textIndex.location],@"href":href}];
			}
		}
	}
	return ret;
}
+(NSArray*) coverProjectCoversAtHref:(NSString*)href {
	TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[self contentsOfCoverProjectPageAtPath:href]];
	NSMutableArray * ret = [NSMutableArray array];
	for (TFHppleElement * element in [htmlParser searchWithXPathQuery:@"//div[@id='covers']//a"])  {
		NSString * text = [element text], *href = [element objectForKey:@"href"];
		NSRange equalsIndex = [href rangeOfString:@"=" options:NSBackwardsSearch];
		if(equalsIndex.location != NSNotFound && [text rangeOfString:@"cover" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[ret addObject:@{@"title":text, @"href":href}];
		}
	}
	return ret;
}
+(NSDictionary*) coverProjectDownloadsAtHref:(NSString*)href {
	TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[self contentsOfCoverProjectPageAtPath:href]];
	NSMutableDictionary * ret = [NSMutableDictionary dictionaryWithCapacity:2];
	for (TFHppleElement * element in [htmlParser searchWithXPathQuery:@"//td[@class='pageBody']//a"]) {
		NSString * href = [element objectForKey:@"href"];
		if([href rangeOfString:@"download_cover.php"].location != NSNotFound) {
			ret[@"fullSize"] = href;
			break;
		}
	}
	for (TFHppleElement * element in [htmlParser searchWithXPathQuery:@"//td[@class='pageBody']//img"]) {
		NSString * href = [element objectForKey:@"src"];
		if([href rangeOfString:@"images/covers"].location != NSNotFound) {
			ret[@"thumb"] = href;
			break;
		}
	}
	return ret;
}
-(void) getCoverProjectCover:(NSString *)href {
	if(href == nil) {
		NSArray * games = [MALMupenRom coverProjectGamesMatchingSearch:[self gameTitleForSearch]];
		if([games count] == 0) {
			NSLog(@"FIXME: handle no cover results %s", __PRETTY_FUNCTION__); return;
		} else if ([games count] > 1) {
			NSLog(@"FIXME: handle multiple cover results %s", __PRETTY_FUNCTION__);
		}
		href = [MALMupenRom coverProjectDownloadsAtHref:games[0][@"href"]][@"thumb"];
	}
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[MALMupenRom coverProjectURL:href] ] delegate:self];
}
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedCoverLength=[response expectedContentLength];
	coverDownload = [[NSMutableData alloc] initWithCapacity:expectedCoverLength];
}
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
	[self willChangeValueForKey:@"coverDownloadProgress"];
	[coverDownload appendData:data];
	NSLog(@"%.2f%%",100* self.coverDownloadProgress);
	[self didChangeValueForKey:@"coverDownloadProgress"];
}
-(float) coverDownloadProgress { return [coverDownload length]/(float)expectedCoverLength;}
-(void) connectionDidFinishLoading:(NSURLConnection*)connection {
	[coverDownload writeDataToFile:path xattr:xattrCoverKey];
	[self setCover:coverDownload];
	[coverDownload release]; coverDownload = nil;
}
@end
