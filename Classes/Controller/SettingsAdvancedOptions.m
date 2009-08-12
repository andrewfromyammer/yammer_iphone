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

@implementation SettingsAdvancedOptions

@synthesize toggle;

- (void)setButtonTitle {
  NSString *url = [LocalStorage getBaseURL];
  
  if (url)
    [toggle setTitle:@"Use Live" forState:UIControlStateNormal];
  else 
    [toggle setTitle:@"Use Development" forState:UIControlStateNormal];
}

- (void)handleClick {
  NSString *url = [LocalStorage getBaseURL];
  
  if (url)
    [LocalStorage removeBaseURL];
  else 
    [LocalStorage saveBaseURL:DEV_SERVER];
  
  [OAuthGateway logout];
}


- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  
  toggle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  toggle.frame = CGRectMake(20, 20, 200, 30);

  [self setButtonTitle];
  
  [toggle addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
    
  [self.view addSubview:toggle];
  
  [LocalStorage removeFile:@"yammer.sqlite"];
}


- (void)dealloc {
  [toggle release];
  [super dealloc];
}

@end
