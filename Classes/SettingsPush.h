//
//  SettingsPush.h
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSettingsPush.h"
#import "SpinnerViewController.h"
#import "Settings.h"


@interface SettingsPush : SpinnerViewController <UITableViewDelegate> {
  UITableView* theTableView;
  DataSettingsPush* dataSource;
  Settings* parent;
  UIViewController* timeChooser;
  UIDatePicker* picker;
}

@property (nonatomic,retain) UITableView* theTableView;
@property (nonatomic,retain) DataSettingsPush* dataSource;
@property (nonatomic,retain) Settings* parent;
@property (nonatomic,retain) UIViewController* timeChooser;
@property (nonatomic,retain) UIDatePicker* picker;

- (id)init;
- (void)setStopTime;
- (void)setResumeTime;
- (void)updateTime:(NSInteger)hour ampm:(NSInteger)ampm key:(NSString*)key;

@end
