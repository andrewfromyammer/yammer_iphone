#import <Three20/Three20.h>

@interface FullSizePdf : TTModelViewController {
  UIWebView* _pdfView;
}

@property (nonatomic,retain) UIWebView *pdfView;

- (id)initWithAttachment:(NSDictionary*)attachment;

@end
