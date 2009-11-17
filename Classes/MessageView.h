#import <Three20/Three20.h>
#import "TTTableYammerItem.h"

@interface MessageView: UIView {
  UILabel* _fromLine;
  UILabel* _timeLine;
  UILabel* _messageText;
  TTImageView* _mugshot;

  TTImageView* _iconClip;
  TTImageView* _iconLock;
  TTImageView* _iconPhoto;
  TTImageView* _iconLike;
}

@property (nonatomic, retain) UILabel* fromLine;
@property (nonatomic, retain) UILabel* timeLine;
@property (nonatomic, retain) UILabel* messageText;

@property (nonatomic, retain) TTImageView* mugshot;

@property (nonatomic, retain) TTImageView* iconClip;
@property (nonatomic, retain) TTImageView* iconLock;
@property (nonatomic, retain) TTImageView* iconPhoto;
@property (nonatomic, retain) TTImageView* iconLike;

- (void)adjustWidthsAndHeights:(TTTableYammerItem*)item;
- (void)timeLineToOriginalPosition;
- (void)adjustFromLineIcons:(TTTableYammerItem*)item;
- (void)setMultipleBackgrounds:(UIColor*)color;
+ (CGFloat)previewFontSize;
- (CGFloat)fromLineFontSize;
- (CGFloat)timeLineFontSize;

@end
