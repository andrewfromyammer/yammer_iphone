//
//  SpinnerViewController.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ComposeYamController.h"


@implementation ComposeYamController

@synthesize input;
- (void)loadView {
  UIView *wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  wrapper.backgroundColor = [UIColor whiteColor];
  
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(dismissModalViewControllerAnimated:)];  
  
  UIBarButtonItem *send=[[UIBarButtonItem alloc] init];
  send.title=@"Send";
  send.target = self;
  send.action = @selector(sendYam);
  
  
  self.navigationItem.rightBarButtonItem = send;  
  self.navigationItem.leftBarButtonItem = cancel;  
  
  self.input = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
  [self.input setFont:[UIFont systemFontOfSize:16]];
  
  UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 171, 320, 30)];
//  bar.backgroundColor = [UIColor blackColor];

  UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                         target:self
                                                                         action:@selector(sendYam)];
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: flexItem, camera, flexItem, nil];
  [bar setItems:items animated:NO];
  
  [wrapper addSubview:bar];
  [wrapper addSubview:self.input];
  
  self.view = wrapper;
  
}

- (void)viewDidAppear:(BOOL)animated {
  [input becomeFirstResponder];
}


- (void)sendYam {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  [input release];
  [super dealloc];
}


@end
