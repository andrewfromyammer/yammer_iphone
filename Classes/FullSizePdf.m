#import "FullSizePdf.h"
#import "MainTabBar.h"
#import "ImageCache.h"
#import "LocalStorage.h"

@implementation FullSizePdf

@synthesize pdfView = _pdfView;

- (id)initWithAttachment:(NSDictionary*)attachment {
  if (self = [super init]) {
    self.pdfView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.title = @"PDF View";
    self.navigationBarTintColor = [MainTabBar yammerGray];
    UILabel* loading = [[UILabel alloc] initWithFrame:CGRectMake(100, 170, 250, 30)];
    loading.text = @"Loading PDF...";
    [self.view addSubview:loading];
    [NSThread detachNewThreadSelector:@selector(loadPdf:) toTarget:self withObject:attachment];
  }
  return self;
}

- (void)doLoadURL:(NSString*)filename {
  [[self.view.subviews objectAtIndex:0] removeFromSuperview];
  [self.view addSubview:_pdfView];
  [_pdfView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filename]]];
}

- (void)loadPdf:(NSDictionary*)attachment {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSData* data;
  @synchronized ([UIApplication sharedApplication]) {
    data = [ImageCache getOrLoadImage:attachment atype:@"file" key:@"url" path:ATTACHMENTS];
  }
  if (data) {
    NSString* filename = [ImageCache getOrLoadImagePath:attachment path:ATTACHMENTS];
    [self performSelectorOnMainThread:@selector(doLoadURL:) withObject:filename waitUntilDone:NO];
  }
  [autoreleasepool release];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_pdfView);
  [super dealloc];
}


@end
