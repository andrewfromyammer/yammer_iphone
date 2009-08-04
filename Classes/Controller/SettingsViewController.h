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
#import "DataSettings.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate> {
	UITableView *theTableView;
  NSMutableDictionary *usersCurrent;
  DataSettings *dataSource;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *usersCurrent;
@property (nonatomic,retain) DataSettings *dataSource;

@end
