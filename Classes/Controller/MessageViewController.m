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

@implementation MessageViewController

@synthesize theList;
@synthesize theIndex;
@synthesize webView;
@synthesize upDownArrows;
@synthesize fromLine;
@synthesize timeLine;
@synthesize image;

- (void)displayMessage {
  self.title = [NSString stringWithFormat:@"%d of %d", theIndex+1, [theList count]];
  NSMutableDictionary *message = [theList objectAtIndex:theIndex];
  [webView setHTML:message];
  
  fromLine.text = [message objectForKey:@"fromLine"];
  timeLine.text = [message objectForKey:@"timeLine"];
  image.image = [[UIImage alloc] initWithData:[message objectForKey:@"imageData"]];
}

- (void)setupToolbar:(BOOL)showTheadIcon {
  UIToolbar *toolbar = [UIToolbar new];
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
  
  NSArray *items = [NSArray arrayWithObjects: reply, flexItem, user, nil];
  if (showTheadIcon)
    items = [NSArray arrayWithObjects: reply, flexItem, thread, flexItem2, user, nil];;
  [toolbar setItems:items animated:NO];
  [self.view addSubview:toolbar];
  [toolbar release];
}

- (id)initWithBooleanForThreadIcon:(BOOL)showTheadIcon list:(NSMutableArray *)list index:(int)index {
  self.theList = list;
  self.theIndex = index;
  
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
  self.timeLine = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 260, 15)];
  [timeLine setFont:[UIFont systemFontOfSize:12]];
  [self.view addSubview:timeLine];  
  self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
  [self.view addSubview:image];
    
  [self setupToolbar:showTheadIcon]; 
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
  
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] initWithDict:feed textInput:false threadIcon:false homeTab:false];
  localFeedMessageList.title = @"Thread";
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
  ReplyViewController *localReplyViewController = [[ReplyViewController alloc] initWithMessage:[theList objectAtIndex:theIndex]];
	[self.navigationController pushViewController:localReplyViewController animated:NO];
  [localReplyViewController release];
}

- (void)dealloc {
  [theList release];
  [webView release];
  [upDownArrows release];
  [fromLine release];
  [timeLine release];
  [image release];
  [super dealloc];
}


@end
