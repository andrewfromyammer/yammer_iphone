//
//  ReplyViewController.m
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ReplyViewController.h"
#import "APIGateway.h"


@implementation ReplyViewController

@synthesize input;
@synthesize message;

- (id)initWithMessage:(NSMutableDictionary *)dict {
  self.title = @"Reply";
  self.message = dict;
  input = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 310, 30)];
  input.backgroundColor = [UIColor whiteColor];
  input.font = [UIFont fontWithName:@"Arial" size:18.0];
  input.returnKeyType = UIReturnKeySend;
  input.delegate = self;  
  [self.view addSubview:input];

  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Cancel";
  temporaryBarButtonItem.target = self;
  temporaryBarButtonItem.action = @selector(cancel);
  self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
  
  return self;
}

- (void)cancel {
  [input resignFirstResponder];
  [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  [self.navigationController popViewControllerAnimated:NO];
  [NSThread detachNewThreadSelector:@selector(sendReply) toTarget:self withObject:nil];
  return NO;
}

- (void)sendReply {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [APIGateway createMessage:input.text repliedToId:[message objectForKey:@"id"] groupId:[message objectForKey:@"group_id"]];
  [autoreleasepool release];
}

- (void)viewDidAppear:(BOOL)animated {
  [input becomeFirstResponder];
}

- (void)dealloc {
  [input release];
  [message release];
  [super dealloc];
}


@end
