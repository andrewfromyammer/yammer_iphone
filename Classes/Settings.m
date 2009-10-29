#import "Settings.h"
#import "MainTabBar.h"
#import "YammerAppDelegate.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"

@implementation Settings

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    
    UIBarButtonItem *logout=[[UIBarButtonItem alloc] init];
    logout.title=@"Log Out";
    logout.target = self;
    logout.action = @selector(logout);
    self.navigationItem.rightBarButtonItem = logout;
    [logout release];

    _tableViewStyle = UITableViewStyleGrouped;
    [self gatherData];
  }  
  return self;
}

- (void)gatherData {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  NSMutableDictionary *dict = (NSMutableDictionary *)[[LocalStorage getFile:USER_CURRENT] JSONValue];
  
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
     @"You are logged in as:",
     [TTTableTextItem itemWithText:[self findEmailFromDict:dict] URL:nil],
     [TTTableTextItem itemWithText:[NSString stringWithFormat:@"Network: %@", [dict objectForKey:@"network_name"]] URL:nil],
     @"",
     [TTTableImageItem itemWithText:@"Switch Networks" imageURL:@"bundle://network.png" URL:@"1"],
     [TTTableImageItem itemWithText:@"Push Settings" imageURL:@"bundle://push.png" URL:@"1"],
     [TTTableImageItem itemWithText:@"Advanced Settings" imageURL:@"bundle://advanced.png" URL:@"1"],
     @"",
     [TTTableTextItem itemWithText:[NSString stringWithFormat:@"Version: %@", [yammer version]] URL:nil],
     nil];
}

- (NSString*)findEmailFromDict:(NSMutableDictionary *)dict {
    
  NSMutableDictionary *contact = [dict objectForKey:@"contact"];
  NSArray *addresses = [contact objectForKey:@"email_addresses"];
  int i=0;
  for (; i< [addresses count]; i++) {
    NSDictionary *emailDict = [addresses objectAtIndex:i];
    if ([emailDict objectForKey:@"type"])
      if ([[emailDict objectForKey:@"type"] isEqualToString:@"primary"]) {
        return [emailDict objectForKey:@"address"];
      }
  }
  
  return @"";
}


@end
