//
//  SpinnerViewController.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpinnerViewController : UIViewController {
  UIView *wrapper;
  UIActivityIndicatorView *spinner;
  UILabel *loading;
}

@property (nonatomic,retain) UIView *wrapper;
@property (nonatomic,retain) UIActivityIndicatorView *spinner;
@property (nonatomic,retain) UILabel *loading;

- (void)getData;
- (void)refresh;
- (void)addRefreshButton;
- (void)addComposeButton;

@end
