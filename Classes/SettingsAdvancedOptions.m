//
//  HomeViewController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer Inc. All rights reserved.
//

#import "SettingsAdvancedOptions.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"
#import "OAuthCustom.h"
#import "YammerAppDelegate.h"

@implementation SettingsAdvancedOptions

@synthesize toggle;

- (void)setButtonTitle {
  NSString *url = [LocalStorage getBaseURL];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  self.title = [yammer version];
  
  if (url)
    [toggle setTitle:[NSString stringWithFormat:@"Use Live"] forState:UIControlStateNormal];
  else 
    [toggle setTitle:[NSString stringWithFormat:@"Use Development"] forState:UIControlStateNormal];
}

- (void)handleClick {
  NSString *url = [LocalStorage getBaseURL];
  
  if (url)
    [LocalStorage removeBaseURL];
  else 
    [LocalStorage saveBaseURL:[OAuthCustom devServer]];
  
  [OAuthGateway logout];
}


- (void)loadView {
	[super loadView];
  //self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  
  toggle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  toggle.frame = CGRectMake(20, 20, 200, 30);

  [self setButtonTitle];
  
  [toggle addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
    
  [self.view addSubview:toggle];
}


- (void)dealloc {
  [toggle release];
  [super dealloc];
}

@end
