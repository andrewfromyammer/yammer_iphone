//
//  DirectoryUserProfile.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryUserDataSource.h"
#import "SpinnerViewController.h"

@interface DirectoryUserProfile : SpinnerViewController <UITableViewDelegate> {
	UITableView *theTableView;
  DirectoryUserDataSource *dataSource;
  UIButton *follow;
  NSMutableDictionary *user;
  NSString *theUserId;
  BOOL isFollowed;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DirectoryUserDataSource *dataSource;
@property (nonatomic,retain) UIButton *follow;
@property (nonatomic,retain) NSMutableDictionary *user;
@property (nonatomic,retain) NSString *theUserId;
@property BOOL isFollowed;

- (id)initWithUserId:(NSString *)string tabs:(BOOL)tabs;

@end
