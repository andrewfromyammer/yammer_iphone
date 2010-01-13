#import "FullSizeDoc.h"
#import "MainTabBar.h"
#import "ImageCache.h"
#import "LocalStorage.h"

@implementation FullSizeDoc

@synthesize docView = _docView;

- (id)initWithAttachment:(NSDictionary*)attachment {
  if (self = [super init]) {
    self.docView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.title = @"Document View";
    self.navigationBarTintColor = [MainTabBar yammerGray];
    UILabel* loading = [[UILabel alloc] initWithFrame:CGRectMake(110, 170, 250, 30)];
    loading.text = @"Loading...";
    [self.view addSubview:loading];
    [NSThread detachNewThreadSelector:@selector(loadDoc:) toTarget:self withObject:attachment];
  }
  return self;
}

- (void)doLoadURL:(NSString*)filename {
  [[self.view.subviews objectAtIndex:0] removeFromSuperview];
  [self.view addSubview:_docView];
  [_docView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filename]]];
}

- (void)loadDoc:(NSDictionary*)attachment {
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
  TT_RELEASE_SAFELY(_docView);
  [super dealloc];
}


@end
