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
  NSString *launchURL;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *launchURL;
@property (nonatomic, retain) IBOutlet UIViewController *mainView;

- (void)teleportToUserFeed:(FeedMessageList *)feed;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
+ (void)showError:(NSString *)error style:(NSString *)style;

@end

