//
//  YammerAppDelegate.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedMessageList.h"

@interface YammerAppDelegate : NSObject <UIApplicationDelegate,
                                         UIActionSheetDelegate> {
  UIWindow *window;
  UIViewController *mainView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *mainView;

+ (void)showError:(NSString *)error;
- (void)teleportToUserFeed:(FeedMessageList *)feed;

@end

