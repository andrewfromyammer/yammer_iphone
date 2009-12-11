#import <UIKit/UIKit.h>

@interface MainTabBar : UITabBarController <UITabBarControllerDelegate,UIAlertViewDelegate> {

}

- (void)setupView:(UIViewController *)view title:(NSString *)title image:(NSString *)image;
+ (UIColor *)yammerGray;
- (void)addCompose;
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;
- (void)addLogout;

@end
