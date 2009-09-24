#import <Three20/Three20.h>

@interface FullSizePhoto : TTModelViewController <UIScrollViewDelegate> {
  UIImageView* _imageView;
}

@property (nonatomic,retain) UIImageView *imageView;

- (id)initWithAttachment:(NSDictionary*)attachment;

@end
