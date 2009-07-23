//
//  FeedMessageList.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpinnerViewController.h"
#import "FeedDataSource.h"

@interface FeedMessageList : SpinnerViewController <UITableViewDelegate, UITextFieldDelegate>  {
  UIView *tableAndInput;
	UITableView *theTableView;
  UITextField *input;
  FeedDataSource *dataSource;
  NSMutableDictionary *feed;
  BOOL textInput;
  BOOL threadIcon;
  BOOL homeTab;
  
  UIActivityIndicatorView *topSpinner;
  UILabel *displayText;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) FeedDataSource *dataSource;
@property (nonatomic,retain) NSMutableDictionary *feed;
@property (nonatomic,retain) UITextField *input;
@property (nonatomic,retain) UIView *tableAndInput;
@property (nonatomic,retain) UIActivityIndicatorView *topSpinner;
@property (nonatomic,retain) UILabel *displayText;
@property BOOL textInput;
@property BOOL threadIcon;
@property BOOL homeTab;

- (id)initWithDict:(NSMutableDictionary *)dict textInput:(BOOL)showTextInput 
                                               threadIcon:(BOOL)showThreadIcon
                                                  homeTab:(BOOL)isHomeTab;

@end
