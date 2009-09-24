#import <UIKit/UIKit.h>

@interface MainTabBar : UITabBarController {

}

- (void)setupView:(UIViewController *)view title:(NSString *)title image:(NSString *)image;
+ (UIColor *)yammerGray;

@end
