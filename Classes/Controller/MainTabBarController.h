//
//  MainTabsController.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainTabBarController : UITabBarController {

}

+ (UIColor *)yammerGray;
+ (UIColor *)yammerBlue;

+ (void)setBackButton:(UIViewController *)view;

@end
