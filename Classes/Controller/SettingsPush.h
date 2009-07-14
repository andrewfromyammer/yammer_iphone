//
//  SettingsPush.h
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSettingsPush.h"
#import "SettingsViewController.h"

@interface SettingsPush : SpinnerViewController <UITableViewDelegate> {
  UITableView *theTableView;
  DataSettingsPush *dataSource;
  SettingsViewController *parent;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DataSettingsPush *dataSource;
@property (nonatomic,retain) SettingsViewController *parent;

- (id)init;

@end
