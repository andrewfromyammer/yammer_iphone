#import <Three20/Three20.h>

@interface SpinnerWithTextItem : TTTableTextItem {
  BOOL isSpinning;
}

@property BOOL isSpinning;

+ (id)item;
+ (id)itemWithYammer;

@end


@interface SpinnerWithTextCell : TTTableTextItemCell {
  UILabel* _display;
  UIActivityIndicatorView* _spinner;
  UIImageView* _refreshImage;

}
@property (nonatomic, retain) UILabel *display;
@property(nonatomic,retain) UIActivityIndicatorView* spinner;
@property(nonatomic,retain) UIImageView* refreshImage;

@end

@interface SpinnerListDataSource : TTListDataSource {}
@end