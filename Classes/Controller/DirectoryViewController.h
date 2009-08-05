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
#import "DirectoryTableDataSource.h"
#import "SpinnerWithText.h"

@interface DirectoryViewController : UIViewController <UITableViewDelegate> {
	UITableView *theTableView;
  DirectoryTableDataSource *dataSource;
  SpinnerWithText *spinnerWithText;
  UIView *wrapper;
}

@property (nonatomic,retain) SpinnerWithText *spinnerWithText;
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DirectoryTableDataSource *dataSource;
@property (nonatomic,retain) UIView *wrapper;

@end
