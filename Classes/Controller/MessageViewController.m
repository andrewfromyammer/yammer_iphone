//
//  MessageViewController.m
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageWebView.h"
#import "MainTabBarController.h"
#import "ReplyViewController.h"
#import "DirectoryUserProfile.h"
#import "FeedMessageList.h"
#import "ComposeMessageController.h"

@implementation MessageViewController

@synthesize theList;
@synthesize theIndex;
@synthesize webView;
@synthesize upDownArrows;
@synthesize fromLine;
@synthesize timeLine;
@synthesize image;
@synthesize lockImage;
@synthesize toolbar;
@synthesize threadIcon;

- (void)displayMessage {
  self.title = [NSString stringWithFormat:@"%d of %d", theIndex+1, [theList count]];
  NSMutableDictionary *message = [theList objectAtIndex:theIndex];
  
  if ([[message objectForKey:@"sender_type"] isEqualToString:@"user"])
    [self setupToolbar:true];
  else
    [self setupToolbar:false];
  
  fromLine.text = [message objectForKey:@"fromLine"];
  timeLine.text = [message objectForKey:@"timeLine"];
  image.image = [[UIImage alloc] initWithData:[message objectForKey:@"imageData"]];
  lockImage.image = nil;
  if ([message objectForKey:@"lock"])
    lockImage.image = [UIImage imageNamed:@"lock.png"];
  
  if ([message objectForKey:@"lockColor"])  
    [webView setHTML:message bgcolor:@"#DEDEDE"];
  else
    [webView setHTML:message bgcolor:@"#FFFFFF"];
}

- (void)setupToolbar:(BOOL)showUserIcon {
  if (!toolbar) {
    toolbar = [UIToolbar new];
	  toolbar.barStyle = UIBarStyleDefault;
    [toolbar setTintColor:[MainTabBarController yammerGray]];

    // size up the toolbar and set its frame
    [toolbar sizeToFit];
    CGFloat toolbarHeight = [toolbar frame].size.height;
    CGRect mainViewBounds = self.view.bounds;
    [toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
                                 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
                                 CGRectGetWidth(mainViewBounds),
                                 toolbarHeight)];
    [self.view addSubview:toolbar];
	} else {
    int i=0;
    for (i=0; i<[[toolbar items] count]; i++)
      [[[toolbar items] objectAtIndex:i] release];
  }
    
  UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                         target:self
                                                                         action:@selector(reply)];
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
  UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
  
  
  UIBarButtonItem *thread = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thread_gray.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(threadView)];
  
  UIBarButtonItem *user = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_gray.png"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self //[[UIApplication sharedApplication] delegate]
                                                          action:@selector(userView)];
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: reply, flexItem, user, nil];
  if (self.threadIcon)
    items = [NSMutableArray arrayWithObjects: reply, flexItem, thread, flexItem2, user, nil];
  if (!showUserIcon)
    [user setEnabled:false];
  [toolbar setItems:items animated:NO];
}

- (id)initWithBooleanForThreadIcon:(BOOL)showThreadIcon list:(NSMutableArray *)list index:(int)index {
  self.theList = list;
  self.theIndex = index;
  self.threadIcon = showThreadIcon;
  
  [MainTabBarController setBackButton:self];
  
  self.webView = [[MessageWebView alloc] init];
  [self.view addSubview:webView];
  
  self.hidesBottomBarWhenPushed = YES;
  
  self.upDownArrows = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"arrow_up.png"], 
                                                   [UIImage imageNamed:@"arrow_down.png"], nil]];
  upDownArrows.momentary = true;
  [upDownArrows setTintColor:[MainTabBarController yammerGray]];
  upDownArrows.segmentedControlStyle = UISegmentedControlStyleBar;
  UIBarButtonItem *localUIBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:upDownArrows];
  [upDownArrows addTarget:self action:@selector(upDownClicked) forControlEvents:UIControlEventValueChanged];
  self.navigationItem.rightBarButtonItem = localUIBarButtonItem;
  [localUIBarButtonItem release];
  
  self.fromLine = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 260, 20)];
  [fromLine setFont:[UIFont boldSystemFontOfSize:16]];
  [self.view addSubview:fromLine];
  self.timeLine = [[UILabel alloc] initWithFrame:CGRectMake(75, 25, 240, 15)];
  [timeLine setFont:[UIFont systemFontOfSize:12]];
  [self.view addSubview:timeLine];  
  self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
  [self.view addSubview:image];
  self.lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, 25, 16, 16)];
  [self.view addSubview:lockImage];
    
  [self displayMessage];
  return self;
}

- (void)upDownClicked {
  if ([upDownArrows selectedSegmentIndex] == 1)
    theIndex++;
  else
    theIndex--;
  
  if (theIndex == -1)
    theIndex = 0;
  
  if (theIndex == [theList count])
    theIndex = [theList count] -1;
  
  [self displayMessage];
}

- (void)threadView {
  NSMutableDictionary *message = [theList objectAtIndex:theIndex];
  NSMutableDictionary *feed = [NSMutableDictionary dictionary];
  [feed setObject:[NSString stringWithFormat:@"/api/v1/messages/in_thread/%@", [message objectForKey:@"thread_id"]] forKey:@"url"];
  
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] initWithDict:feed threadIcon:false homeTab:false];
  localFeedMessageList.title = @"Thread";
  [localFeedMessageList disableCompose];
  [self.navigationController pushViewController:localFeedMessageList animated:YES];
  [localFeedMessageList release];
}

- (void)userView {
  NSMutableDictionary *message = [theList objectAtIndex:theIndex];
  DirectoryUserProfile *localDirectoryUserProfile = [[DirectoryUserProfile alloc] 
                                                     initWithUserId:[[message objectForKey:@"sender_id"] description]
                                                     tabs:false];
  [self.navigationController pushViewController:localDirectoryUserProfile animated:YES];
  [localDirectoryUserProfile release];
}

- (void)reply {
  NSMutableDictionary *message = [theList objectAtIndex:theIndex];
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  
  [meta setObject:[message objectForKey:@"id"] forKey:@"replied_to_id"];
  [meta setObject:[NSString stringWithFormat:@"Replying to %@", [message objectForKey:@"sender"]] forKey:@"display"];
  
  ComposeMessageController *compose = [[ComposeMessageController alloc] initWithMeta:meta];
  UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:compose];
  [modal.navigationBar setTintColor:[MainTabBarController yammerGray]];
  
  [self presentModalViewController:modal animated:YES];
}

- (void)dealloc {
  [theList release];
  [webView release];
  [upDownArrows release];
  [fromLine release];
  [timeLine release];
  [image release];
  [lockImage release];
  [toolbar release];
  [super dealloc];
}


@end
