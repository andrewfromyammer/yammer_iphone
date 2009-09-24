#import "FullSizePhoto.h"
#import "MainTabBar.h"
#import "ImageCache.h"
#import "LocalStorage.h"

@implementation FullSizePhoto

@synthesize imageView = _imageView;

- (id)initWithAttachment:(NSDictionary*)attachment {
  if (self = [super init]) {
    self.title = @"Full Size Photo";
    self.navigationBarTintColor = [MainTabBar yammerGray];
    UILabel* loading = [[UILabel alloc] initWithFrame:CGRectMake(80, 170, 300, 30)];
    loading.text = @"Loading full size...";
    [self.view addSubview:loading];
    [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:attachment];
  }
  return self;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (void)loadImage:(NSDictionary*)attachment {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSData* data;
  @synchronized ([UIApplication sharedApplication]) {
    data = [ImageCache getOrLoadImage:attachment key:@"url" path:ATTACHMENTS];
  }
  if (data) {
    UIImage* image = [UIImage imageWithData:data];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    UIScrollView* scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    scroll.contentSize = CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height);
    scroll.maximumZoomScale = 4.0;
    scroll.minimumZoomScale = 0.75;
    scroll.clipsToBounds = YES;
    scroll.delegate = self;
    
    [scroll addSubview:_imageView];
    
    [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    [self.view addSubview:scroll];    
  }
  [autoreleasepool release];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_imageView);
  [super dealloc];
}


@end
