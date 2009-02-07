//
//  SettingsChooseFeed.h
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedsTableDataSource.h"
#import "SettingsViewController.h"

@interface SettingsChooseFeed : UIViewController <UITableViewDelegate> {
  UITableView *theTableView;
  FeedsTableDataSource *dataSource;
  SettingsViewController *parent;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) FeedsTableDataSource *dataSource;
@property (nonatomic,retain) SettingsViewController *parent;

- (id)initWithDict:(NSMutableDictionary *)dict parent:(SettingsViewController *)view;

@end
