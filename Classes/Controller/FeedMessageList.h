//
//  FeedMessageList.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpinnerViewController.h"
#import "FeedDataSource.h"
#import "SpinnerWithText.h"

@interface FeedMessageList : UIViewController <UITableViewDelegate>  {
  UIView *tableAndSpinner;
	UITableView *theTableView;
  FeedDataSource *dataSource;
  NSMutableDictionary *feed;
  BOOL threadIcon;
  BOOL homeTab;
  SpinnerWithText *spinnerWithText;
  int curOffset;
  BOOL isChecking;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) FeedDataSource *dataSource;
@property (nonatomic,retain) NSMutableDictionary *feed;
@property (nonatomic,retain) UIView *tableAndSpinner;
@property (nonatomic,retain) SpinnerWithText *spinnerWithText;
@property BOOL threadIcon;
@property BOOL homeTab;
@property int curOffset;
@property BOOL isChecking;

- (id)initWithDict:(NSMutableDictionary *)dict threadIcon:(BOOL)showThreadIcon
                                                  refresh:(BOOL)showRefresh
                                                  compose:(BOOL)showCompose;

- (void)checkForNewMessages:(NSString *)style;
- (void)displayLastUpdated;
- (void)refresh;
- (void)loadFromCache;

@end
