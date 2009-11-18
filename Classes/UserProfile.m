#import "UserProfile.h"
#import "APIGateway.h";
#import "FeedMessageList.h"
#import "YammerAppDelegate.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "FeedDictionary.h"

@interface UserProfileDelegate : TTTableViewVarHeightDelegate;
@end

@implementation UserProfileDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  UserProfile* profile = (UserProfile*)_controller;
  
  if ([object isKindOfClass:[TTTableButton class]]) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    TTTableButton* button = (TTTableButton*)object;
    if ([button.text isEqualToString:@"Follow"]) {
      [APIGateway addFollow:profile.userId];
    } else {
      [APIGateway removeFollow:profile.userId];
    }
    [profile loadUser];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  } else {
    TTTableSubtextItem* item = (TTTableSubtextItem*)object;
    if ([item.text hasPrefix:@"Phone"]) {
      
      NSMutableString *strippedString = [NSMutableString stringWithCapacity:20];
      NSString* phoneNumber = item.caption;
      
      for (int i=0; i<[phoneNumber length]; i++) {
        if (isdigit([phoneNumber characterAtIndex:i])) {
          [strippedString appendFormat:@"%c",[phoneNumber characterAtIndex:i]];
        }
      }
      
      NSURL* theURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", strippedString]];
      if ([[UIApplication sharedApplication] canOpenURL:theURL])
        [[UIApplication sharedApplication] openURL:theURL];
    }
    else if ([item.text hasPrefix:@"Email"]) {
      NSURL* theURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", item.caption]];
      if ([[UIApplication sharedApplication] canOpenURL:theURL])
        [[UIApplication sharedApplication] openURL:theURL];
    }
  }
}

@end


@implementation UserProfile

@synthesize userId = _userId;
@synthesize follow;
@synthesize isFollowed;
@synthesize theUserId;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [super initWithNavigatorURL:URL query:query]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.variableHeightRows = YES;
    self.title = @"User Profile";
    
    UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title=@"Feed";
    temporaryBarButtonItem.target = self;
    if ([query objectForKey:@"feed"])
      temporaryBarButtonItem.action = @selector(showFeedByTeleport);
    else
      temporaryBarButtonItem.action = @selector(showFeed);
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];

    self.userId = [query objectForKey:@"id"];
    
    [NSThread detachNewThreadSelector:@selector(loadUser) toTarget:self withObject:nil];
  }
  return self;
}

+ (NSString*)safeName:(NSMutableDictionary*)dict {
  NSString* name = @"";
  if ([[dict objectForKey:[LocalStorage getNameField]] isKindOfClass:[NSString class]])
    name = [dict objectForKey:[LocalStorage getNameField]];  
  return name;
}

- (void)loadUser {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  TTListDataSource* source = [[[TTListDataSource alloc] init] autorelease];
  
  NSMutableDictionary* user = [APIGateway userById:_userId];
  TTTableImageItem* item = [TTTableImageItem itemWithText:[UserProfile safeName:user] imageURL:[user objectForKey:@"mugshot_url"] 
                                             defaultImage:[UIImage imageNamed:@"no_photo_small.png"] URL:nil];
  
  [source.items addObject:item];
  
  
  NSString *cached = [LocalStorage getFile:USERS_CURRENT];
  if (cached) {
    NSMutableDictionary* dict = (NSMutableDictionary *)[cached JSONValue];
    NSString *loggedInId = [[dict objectForKey:@"id"] description];  
    
    if (![_userId isEqualToString:loggedInId]) {
      if ([APIGateway followingUser:_userId])
        [source.items addObject:[TTTableButton itemWithText:@"Unfollow"]];
      else
        [source.items addObject:[TTTableButton itemWithText:@"Follow"]];
    }
  }
  
  NSMutableDictionary *contact = [user objectForKey:@"contact"];
  NSMutableArray *email_addresses = [contact objectForKey:@"email_addresses"];
  NSMutableArray *phone_numbers = [contact objectForKey:@"phone_numbers"];
  
  int i=0;
  for (; i<[email_addresses count]; i++) {
    NSMutableDictionary *email = [email_addresses objectAtIndex:i];

    TTTableSubtextItem* item = [TTTableSubtextItem itemWithText:[NSString stringWithFormat:@"Email %@", [email objectForKey:@"type"]]
                                                        caption:[email objectForKey:@"address"] URL:@"1"];
    [source.items addObject:item];
  }
  
  i=0;
  for (; i<[phone_numbers count]; i++) {
    NSMutableDictionary *phone = [phone_numbers objectAtIndex:i];    
    TTTableSubtextItem* item = [TTTableSubtextItem itemWithText:[NSString stringWithFormat:@"Phone %@", [phone objectForKey:@"type"]]
                                                        caption:[phone objectForKey:@"number"] URL:@"1"];
    [source.items addObject:item];
  }
  
  self.dataSource = source;
  [self showModel:YES];
  [autoreleasepool release];
}

- (void)showFeed {
  [self.navigationController pushViewController:[self getUserFeed] animated:YES];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[UserProfileDelegate alloc] initWithController:self];
}

- (FeedMessageList *)getUserFeed {
  FeedDictionary *feed = [FeedDictionary dictionary];
  [feed setObject:[NSString stringWithFormat:@"/api/v1/messages/from_user/%@", _userId] forKey:@"url"];
  
  FeedMessageList *localFeedMessageList = [[[FeedMessageList alloc] initWithFeed:feed refresh:false compose:false thread:false] autorelease];
  localFeedMessageList.title = @"User Feed";
  return localFeedMessageList;
}

- (void)showFeedByTeleport {
  TTNavigator* navigator = [TTNavigator navigator];
  MainTabBar* mainTabs = (MainTabBar*)[navigator rootViewController];
  
  UINavigationController *nav = (UINavigationController *)[mainTabs selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  mainTabs.selectedIndex = 2;
  nav = (UINavigationController *)[mainTabs selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  [nav pushViewController:[self getUserFeed] animated:NO];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_userId);
  [super dealloc];
}


@end
