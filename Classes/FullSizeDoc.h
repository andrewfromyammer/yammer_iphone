#import <Three20/Three20.h>

@interface FullSizeDoc : TTModelViewController {
  UIWebView* _docView;
}

@property (nonatomic,retain) UIWebView *docView;

- (id)initWithAttachment:(NSDictionary*)attachment;

@end
