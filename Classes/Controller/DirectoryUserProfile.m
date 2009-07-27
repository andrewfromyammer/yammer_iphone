//
//  DirectoryUserProfile.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "DirectoryUserProfile.h"
#import "DirectoryUserDataSource.h"
#import "APIGateway.h";
#import "ImageCache.h"
#import "FeedMessageList.h"
#import "YammerAppDelegate.h"

@implementation DirectoryUserProfile

@synthesize theTableView;
@synthesize dataSource;
@synthesize follow;
@synthesize user;
@synthesize isFollowed;
@synthesize theUserId;

- (id)initWithUserId:(NSString *)string tabs:(BOOL)tabs {
  
  self.title = @"User";
  self.theUserId = string;
  int height = 340;
  if (tabs)
    height = 290;
	theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 78, 320, height)
                                              style:UITableViewStyleGrouped];
  
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Feed";
  temporaryBarButtonItem.target = self;
  if (tabs)
    temporaryBarButtonItem.action = @selector(showFeed);
  else
    temporaryBarButtonItem.action = @selector(showFeedByTeleport);
  self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
  
  return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableDictionary *userCurrent = [APIGateway usersCurrent];
  NSString *loggedInId = [[userCurrent objectForKey:@"id"] description];  
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  
  self.user = [APIGateway userById:theUserId];
  self.dataSource = [[DirectoryUserDataSource alloc] initWithDict:self.user];
	theTableView.dataSource = self.dataSource;
  
  UIView *topLayer = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  [topLayer addSubview:theTableView];
  
  UILabel *fullname = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 260, 30)];
  [fullname setFont:[UIFont boldSystemFontOfSize:16]];
  fullname.text = [user objectForKey:@"full_name"];
  [topLayer addSubview:fullname];
  [fullname release];
  
  UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
  [topLayer addSubview:image];
  image.image = [[UIImage alloc] initWithData:[ImageCache getImageAndSave:[user objectForKey:@"mugshot_url"] user_id:theUserId type:@"user"]];
  [image release];
    
  if (![loggedInId isEqualToString:theUserId]) {
    follow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    follow.frame = CGRectMake(55, 40, 100, 30);
    [follow addTarget:self action:@selector(handleFollow) forControlEvents:UIControlEventTouchUpInside];
    
    isFollowed = [APIGateway followingUser:theUserId];
    if (isFollowed)
      [follow setTitle:@"Unfollow" forState:UIControlStateNormal];
    else
      [follow setTitle:@"Follow" forState:UIControlStateNormal];
    [topLayer addSubview:follow];    
  }
  
  self.view = topLayer;
  [topLayer release];  
  
  [super getData];
  [autoreleasepool release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  if (indexPath.row == 0)
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  else {
    UITableViewCell *cell = [dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    NSRange range = [cell.textLabel.text rangeOfString:@"@"];
    if (range.length == 0)
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cell.textLabel.text]]];
    else
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", cell.textLabel.text]]];
  }  
}

- (void)handleFollow {
  [follow setTitle:@"Sending..." forState:UIControlStateNormal];
  [NSThread detachNewThreadSelector:@selector(sendFollow) toTarget:self withObject:nil];
}

- (void)sendFollow {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSString *thisUserId = [[user objectForKey:@"id"] description]; 
  if (isFollowed) {
    [APIGateway removeFollow:thisUserId];
    [follow setTitle:@"Follow" forState:UIControlStateNormal];
  }
  else {
    [APIGateway addFollow:thisUserId];  
    [follow setTitle:@"Unfollow" forState:UIControlStateNormal];  
  }
  isFollowed = !isFollowed;
  [autoreleasepool release];
}

- (FeedMessageList *)getUserFeed {
  NSMutableDictionary *feed = [NSMutableDictionary dictionary];
  [feed setObject:[NSString stringWithFormat:@"/api/v1/messages/from_user/%@", theUserId] forKey:@"url"];
  
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] initWithDict:feed threadIcon:true homeTab:false];
  localFeedMessageList.title = @"User Feed";
  return localFeedMessageList;
}

- (void)showFeed {
  FeedMessageList *localFeedMessageList = [self getUserFeed];
  [self.navigationController pushViewController:localFeedMessageList animated:YES];
  [localFeedMessageList release];
}

- (void)showFeedByTeleport {
  FeedMessageList *localFeedMessageList = [self getUserFeed];  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  [yam teleportToUserFeed:localFeedMessageList];
}

- (void)dealloc {
  [dataSource dealloc];
//  [theUserId dealloc];
//  [user dealloc];
//  [follow dealloc];
//  [theTableView dealloc];  must not dealloc for some reason
  [super dealloc];
}


@end
