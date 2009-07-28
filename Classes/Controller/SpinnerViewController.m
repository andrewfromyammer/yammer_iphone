//
//  SpinnerViewController.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "SpinnerViewController.h"


@implementation SpinnerViewController

@synthesize wrapper;
@synthesize spinner;
@synthesize loading;

- (void)loadView {
  self.wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  wrapper.backgroundColor = [UIColor whiteColor];
  
  spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(103, 141, 30, 30)];
  spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  
  loading = [[UILabel alloc] initWithFrame:CGRectMake(145, 140, 100, 30)];
  [loading setText:@"Loading..."];
  [wrapper addSubview:loading];  
  [wrapper addSubview:spinner];
  [spinner startAnimating];
  
  self.view = wrapper;
  
  [NSThread detachNewThreadSelector:@selector(getData) toTarget:self withObject:nil];
}

- (void)getData {
  [spinner stopAnimating];
}

- (void)refresh {
  self.view = wrapper;
  [spinner startAnimating];  
  [NSThread detachNewThreadSelector:@selector(getData) toTarget:self withObject:nil];
}

- (void)addRefreshButton {
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refresh)];  
  self.navigationItem.leftBarButtonItem = refresh;  
}

- (void)addComposeButton {
  UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(compose)];  
  self.navigationItem.rightBarButtonItem = compose;  
}

- (void)dealloc {
  [spinner release];
  [loading release];
  [wrapper release];
  [super dealloc];
}


@end
