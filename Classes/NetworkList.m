#import "NetworkList.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "YammerAppDelegate.h"
#import "LocalStorage.h"
#import "APIGateway.h"

@interface NetworkListItem : TTTableTextItem {
  NSMutableDictionary* _network;
}
@property (nonatomic, retain) NSMutableDictionary* network;

+ (NetworkListItem*)itemWithNetwork:(NSMutableDictionary*)network;
@end

@implementation NetworkListItem

@synthesize network = _network;
+ (NetworkListItem*)itemWithNetwork:(NSMutableDictionary*)network {
  NetworkListItem* nli = [NetworkListItem itemWithText:@""];
  nli.network = network;
  return nli;
}
- (void)dealloc {
  TT_RELEASE_SAFELY(_network);
  [super dealloc];
}

@end

@interface NetworkListCell : TTTableTextItemCell {
  UILabel* _leftSide;
  TTLabel* _badge;
}
@property (nonatomic, retain) UILabel *leftSide;
@property (nonatomic, retain) TTLabel *badge;

@end

@implementation NetworkListCell

@synthesize leftSide = _leftSide, badge = _badge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 210, 30)];
    _leftSide.text = @"Testing";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];
    
    _badge = [[TTLabel alloc] initWithFrame:CGRectMake(225, 8, 25, 25)];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    _badge.text = @"60+";
    
    [self.contentView addSubview:_leftSide];
    [self.contentView addSubview:_badge];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_leftSide);
  TT_RELEASE_SAFELY(_badge);
  [super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NetworkListItem* nli = (NetworkListItem*)object;
    _leftSide.text = [nli.network objectForKey:@"name"];
    
    int count = [[nli.network objectForKey:@"unseen_message_count"] intValue];
        
    if (count == 0)
      _badge.hidden = YES;
    else {
      _badge.text = [NetworkList badgeFromIntToString:count];
      [_badge sizeToFit];
      _badge.hidden = NO;
    }
  }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 45.0;
}

@end

@interface NetworkListDataSource : TTSectionedDataSource;
@end

@implementation NetworkListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[NetworkListItem class]])
    return [NetworkListCell class];
  return [super tableView:tableView cellClassForObject:object];
}
@end

@interface NetworkListDelegate : TTTableViewVarHeightDelegate;
@end

@implementation NetworkListDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  NetworkList* networkList = (NetworkList*)_controller;
  NetworkListItem* nli = (NetworkListItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  int unseen_message_count = [[nli.network objectForKey:@"unseen_message_count"] intValue];
  int current_badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
  
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:current_badge - unseen_message_count];  
  
  [nli.network setObject:[NSNumber numberWithInt:0] forKey:@"unseen_message_count"];
  [networkList showModel:YES];
  [networkList madeSelection:nli.network];
}

@end

@implementation NetworkList

- (id)init {
  if (self = [super init]) {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Networks";
    self.variableHeightRows = YES;
    
    _tableViewStyle = UITableViewStyleGrouped;    
    [self createNetworkListDataSource];
  }  
  return self;
}

- (void)createNetworkListDataSource {
  NSMutableArray* sections = [NSMutableArray array];
  NSMutableArray* items = [NSMutableArray array];
  NSMutableArray* section = [NSMutableArray array];
  
  NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];
  
  for (NSMutableDictionary *network in networks) 
    [section addObject:[NetworkListItem itemWithNetwork:network]];
  
  [sections addObject:@"Select a network:"];
  [items addObject:section];
  self.dataSource = [[NetworkListDataSource alloc] initWithItems:items sections:sections]; 
}

- (id<UITableViewDelegate>)createDelegate {
  return [[NetworkListDelegate alloc] initWithController:self];
}

- (void)oldMadeSelection:(NSMutableDictionary*)network {
  //self.dataSource = nil;
  //[self showModel:YES];
  [NSThread detachNewThreadSelector:@selector(doTheSwitch:) toTarget:self withObject:network];
}


- (void)madeSelection:(NSMutableDictionary*)network {

  long network_id = [[network objectForKey:@"id"] longValue];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  if ([yammer.network_id longValue] == network_id) {
    MainTabBar* tabs = [[MainTabBar alloc] init];
    [self.navigationController pushViewController:tabs animated:YES];
    return;
  }
 
  NSString* errorCode = nil;
  
  if ([LocalStorage getFile:TOKENS] == nil) {
    if ([APIGateway getTokens] == nil)
      errorCode = @"NO_TOKENS";
  }
  
  NSMutableDictionary* token;
  if (errorCode == nil) {
    token = [self findTokenByNetworkId:network_id];
    if (token == nil)
      [APIGateway getTokens];
    token = [self findTokenByNetworkId:network_id];
    if (token == nil)
      errorCode = @"TOKEN_MISSING";
  }
  
  if (errorCode == nil) {
    
    //if ([LocalStorage getFile:[APIGateway push_file]] == nil)
    //  [APIGateway pushSettings:@"silent"];
    
    NSString* previous = [LocalStorage getAccessToken];
    
    [LocalStorage saveAccessToken:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [token objectForKey:@"token"], [token objectForKey:@"secret"]]];
    
    //NSString* pushSettingsJSON = [LocalStorage getFile:[APIGateway push_file_with_id:network_id]];
    
    if ([LocalStorage getFile:[APIGateway user_file_with_id:network_id]] == nil)
      [APIGateway usersCurrent:@"silent"];
    
    if ([LocalStorage getFile:[APIGateway user_file_with_id:network_id]] == nil) {
      errorCode = @"NO_USERS_CURRENT";
      [LocalStorage saveAccessToken:previous];
    } else {    
      yammer.network_id = [network objectForKey:@"id"];
      [LocalStorage saveSetting:@"current_network_id" value:yammer.network_id];
      //[LocalStorage removeFile:[APIGateway push_file]];
      
      [LocalStorage removeFile:DIRECTORY_CACHE];
      
//      if (yammer.pushToken && [APIGateway sendPushToken:yammer.pushToken] && pushSettingsJSON != nil) {
      if (yammer.pushToken && [APIGateway sendPushToken:yammer.pushToken]) {
        // send existing push settings (if any) to server
        //NSMutableDictionary* pushSettings = [pushSettingsJSON JSONValue];
        //NSMutableDictionary* existingPushSettings = [APIGateway pushSettings:@"silent"];
        //if (existingPushSettings)
          //[APIGateway updatePushSettingsInBulk:[existingPushSettings objectForKey:@"id"] pushSettings:pushSettings];
        //[LocalStorage removeFile:[APIGateway push_file]];
      }
    }
  }
  
  if (errorCode != nil) {
    [NSThread detachNewThreadSelector:@selector(errorThread:) toTarget:self withObject:errorCode];
  } else {  
    MainTabBar* tabs = [[MainTabBar alloc] init];
    [self.navigationController pushViewController:tabs animated:YES];
  }
  
}


- (void)doShowModel {
  [self showModel:YES];
}

- (NSMutableDictionary*)findTokenByNetworkId:(long)network_id {
  NSMutableArray* tokens = (NSMutableArray *)[[LocalStorage getFile:TOKENS] JSONValue];
  for (NSMutableDictionary* token in tokens) {
    long iteration_network_id = [[token objectForKey:@"network_id"] longValue];
    if (network_id == iteration_network_id)
      return token;
  }
  return nil;
}

- (void)errorThread:(NSString*)errorCode {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  usleep(500000);
  [YammerAppDelegate showError:[NSString stringWithFormat:@"There was a network error, please try again in a few minutes. Error Code: %@", errorCode] style:nil];
  [autoreleasepool release];
}

+ (NSString*)badgeFromIntToString:(int)count {
  if (count > 0) {
    if (count > 60)
      return @"60+";
    else
      return [NSString stringWithFormat:@"%d", count];   
  }
  return nil;
}


@end
