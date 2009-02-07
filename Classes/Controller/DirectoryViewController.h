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

@interface DirectoryViewController : SpinnerViewController <UITableViewDelegate> {
	UITableView *theTableView;
  DirectoryTableDataSource *dataSource;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DirectoryTableDataSource *dataSource;

@end
