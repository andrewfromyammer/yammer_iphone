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
#import "ToolbarWithText.h"

@interface DirectoryViewController : UIViewController <UITableViewDelegate> {
	UITableView *theTableView;
  DirectoryTableDataSource *dataSource;
  ToolbarWithText *toolbar;
}

@property (nonatomic,retain) ToolbarWithText *toolbar;
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DirectoryTableDataSource *dataSource;

@end
