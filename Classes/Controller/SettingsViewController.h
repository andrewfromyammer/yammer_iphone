//
//  HomeViewController.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SpinnerViewController.h"
#import "FeedsTableDataSource.h"
#import "SettingsTableDataSource.h"

@interface SettingsViewController : SpinnerViewController <UITableViewDelegate> {
	UITableView *theTableView;
  NSMutableDictionary *usersCurrent;
  SettingsTableDataSource *dataSource;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *usersCurrent;
@property (nonatomic,retain) SettingsTableDataSource *dataSource;

@end
