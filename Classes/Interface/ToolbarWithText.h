#import <Foundation/Foundation.h>

@interface ToolbarWithText : UIToolbar {
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
  NSObject *target;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;
@property (nonatomic, retain) NSObject *target;

- (id)initWithFrame:(CGRect)frame parent:(NSObject *)list;

- (void)displayCheckingNew;

@end
