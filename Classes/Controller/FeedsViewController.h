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
#import "SpinnerWithText.h"

@interface FeedsViewController : UIViewController <UITableViewDelegate> {
	UITableView *theTableView;
  FeedsTableDataSource *dataSource;
  SpinnerWithText *spinnerWithText;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) FeedsTableDataSource *dataSource;
@property (nonatomic,retain)   SpinnerWithText *spinnerWithText;

@end
