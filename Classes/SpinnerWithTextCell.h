#import <Three20/Three20.h>

@interface SpinnerWithTextItem : TTTableTextItem {
  NSString* _display;
  BOOL isSpinning;
}

@property(nonatomic,retain) NSString* display;
@property BOOL isSpinning;

+ (id)item;
+ (id)itemWithYammer;

@end


@interface SpinnerWithTextCell : TTTableTextItemCell {
  UILabel* _display;
  UIActivityIndicatorView* _spinner;
}

@property(nonatomic,retain) UILabel* display;
@property(nonatomic,retain) UIActivityIndicatorView* spinner;

@end

@interface SpinnerListDataSource : TTListDataSource {}
@end