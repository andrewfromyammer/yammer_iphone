//
//  SpinnerViewController.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ComposeYamController.h"
#import "LocalStorage.h"
#import "APIGateway.h"

@implementation ComposeYamController

@synthesize input;
@synthesize topSpinner;
@synthesize previousSpinner;

- (id)initWithSpinner:(SpinnerWithText *)spinner {
  self.previousSpinner = spinner;
  return self;
}

- (void)loadView {
  UIView *wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  wrapper.backgroundColor = [UIColor whiteColor];
  
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
  
  UIBarButtonItem *draft=[[UIBarButtonItem alloc] init];
  draft.title=@"Close";
  draft.target = self;
  draft.action = @selector(dismissModalViewControllerAnimated:);
  
  UIBarButtonItem *send=[[UIBarButtonItem alloc] init];
  send.title=@"Send";
  send.target = self;
  send.action = @selector(sendYam);
  
  
  self.navigationItem.rightBarButtonItem = send;  
  self.navigationItem.leftBarButtonItem = draft;
  
  
  self.topSpinner = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  [self.topSpinner.displayText setText:@"Share with My Colleagues"];
  
  self.input = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, 320, 130)];
  [self.input setFont:[UIFont systemFontOfSize:16]];
  self.input.text = [LocalStorage getDraft];
  [self.input setDelegate:self];
  
  UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 171, 320, 30)];

  UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                         target:self
                                                                         action:@selector(sendYam)];
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: flexItem, camera, flexItem, nil];
  [bar setItems:items animated:NO];

  [wrapper addSubview:self.topSpinner];
  [wrapper addSubview:self.input];
  [wrapper addSubview:bar];
  
  self.view = wrapper;
  
}

- (void)viewDidAppear:(BOOL)animated {
  [input becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
  [LocalStorage saveDraft:textView.text];
}


- (void)sendYam {
  self.input.text = [self.input.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([self.input hasText]) {
    [NSThread detachNewThreadSelector:@selector(sendUpdate:) toTarget:self withObject:[NSString stringWithString:self.input.text]];
    [self dismissModalViewControllerAnimated:YES];
    [self.previousSpinner showTheSpinner:@"Sending message..."];
  }
}

- (void)sendUpdate:(NSString *)text {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSDecimalNumber *groupId = nil;
//  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
//    groupId = [feed objectForKey:@"group_id"];
  if ([APIGateway createMessage:text repliedToId:nil groupId:groupId])
    [LocalStorage saveDraft:@""];
  [self.previousSpinner hideTheSpinner:@"Updated 12:34 PM"];
  [autoreleasepool release];  
}

- (void)dealloc {
  [input release];
  [topSpinner release];
  [previousSpinner release];
  [super dealloc];
}


@end
