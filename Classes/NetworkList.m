#import "NetworkList.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "YammerAppDelegate.h"
#import "LocalStorage.h"
#import "APIGateway.h"


@interface NetworkListStyleSheet : TTStyleSheet {
}
@end

@implementation NetworkListStyleSheet
- (TTStyle*)badge {
  return
  [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
     [TTSolidFillStyle styleWithColor:RGBCOLOR(140, 153, 180) next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
       [TTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
        [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(1, 12, 2, 12) next:
         [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:17.0]
                              color:[UIColor whiteColor] next:nil]]]]]];
}

@end


@interface NetworkListItem : TTTableTextItem {
  NSMutableDictionary* _network;
  BOOL showSpinner;
}
@property (nonatomic, retain) NSMutableDictionary* network;
@property BOOL showSpinner;

+ (NetworkListItem*)itemWithNetwork:(NSMutableDictionary*)network;
@end

@implementation NetworkListItem

@synthesize network = _network, showSpinner;
+ (NetworkListItem*)itemWithNetwork:(NSMutableDictionary*)network {
  NetworkListItem* nli = [NetworkListItem itemWithText:@""];
  nli.network = network;
  nli.showSpinner = NO;
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
  UIActivityIndicatorView* _spinner;
}
@property (nonatomic, retain) UILabel *leftSide;
@property (nonatomic, retain) TTLabel *badge;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@end

@implementation NetworkListCell

@synthesize leftSide = _leftSide, badge = _badge, spinner = _spinner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 210, 30)];
    _leftSide.text = @"Testing";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];
    
    _badge = [[TTLabel alloc] initWithFrame:CGRectMake(245, 10, 25, 25)];
    _badge.style = [[NetworkListStyleSheet alloc] badge];
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    _badge.text = @"60+";
    
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(260, 10, 20, 20)];
    _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_spinner startAnimating];
    
    [self.contentView addSubview:_leftSide];
    [self.contentView addSubview:_badge];
    [self.contentView addSubview:_spinner];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_leftSide);
  TT_RELEASE_SAFELY(_badge);
  TT_RELEASE_SAFELY(_spinner);
  [super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NetworkListItem* nli = (NetworkListItem*)object;
    _leftSide.text = [nli.network objectForKey:@"name"];
    
    if (nli.showSpinner) {
      _badge.hidden = YES;
      [_badge removeFromSuperview];
      [_spinner startAnimating];
    } else {
      _badge.hidden = NO;
      [_spinner stopAnimating];
    }
    
    int count = [[nli.network objectForKey:@"unseen_message_count"] intValue];

    if (count == 0)
      _badge.hidden = YES;
    else {
      _badge.text = [NetworkList badgeFromIntToString:count];

      int x = 255;
      if ([_badge.text length] == 3)
        x = 236;
      else if ([_badge.text length] == 2)
        x = 246;
      _badge.frame = CGRectMake(x, 10, 25, 25);
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
  if (networkList.alreadySelected)
    return;
  networkList.alreadySelected = YES;

  NetworkListItem* nli = (NetworkListItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  [NetworkList subtractFromBadgeCount:nli.network];
  
  [nli.network setObject:[NSNumber numberWithInt:0] forKey:@"unseen_message_count"];
  nli.showSpinner = YES;
  [networkList showModel:YES];
  [networkList madeSelection:nli.network];
}

@end

@implementation NetworkList

@synthesize alreadySelected;

- (id)init {
  if (self = [super init]) {
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Networks";
    self.variableHeightRows = YES;
    self.alreadySelected = false;
    
    // ilya likes this but adam doesn't
    //_tableViewStyle = UITableViewStyleGrouped;    
    [self createNetworkListDataSource];
  }  
  return self;
}

+ (void)subtractFromBadgeCount:(NSMutableDictionary*)network {
  NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];
  int sum = 0;
  for (NSMutableDictionary* n in networks) {
    if ([[n objectForKey:@"id"] longValue] == [[network objectForKey:@"id"] longValue])
      [n setObject:[NSNumber numberWithInt:0] forKey:@"unseen_message_count"];
    sum += [[n objectForKey:@"unseen_message_count"] intValue];
  }
  
  [LocalStorage saveFile:NETWORKS_CURRENT data:[networks JSONRepresentation]];
  
  if (sum > 99)
    sum = 99;
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:sum];
}

- (void)createNetworkListDataSource {
  NSMutableArray* sections = [NSMutableArray array];
  NSMutableArray* items = [NSMutableArray array];
  NSMutableArray* section = [NSMutableArray array];
  
  NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];
  
  for (NSMutableDictionary *network in networks)
    [section addObject:[NetworkListItem itemWithNetwork:network]];
  
  [sections addObject:@""];
  [items addObject:section];
  self.dataSource = [[NetworkListDataSource alloc] initWithItems:items sections:sections]; 
}

- (id<UITableViewDelegate>)createDelegate {
  return [[NetworkListDelegate alloc] initWithController:self];
}

- (void)madeSelection:(NSMutableDictionary*)network {
  [NSThread detachNewThreadSelector:@selector(doTheSwitch:) toTarget:self withObject:network];
}

- (void)doTheSwitch:(NSMutableDictionary*)network {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
  NetworkListDataSource* source = (NetworkListDataSource*)self.dataSource;
  for (NetworkListItem* item in [source.items objectAtIndex:0]) {
    item.showSpinner = NO;
  }

  long network_id = [[network objectForKey:@"id"] longValue];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  if ([yammer.network_id longValue] == network_id)
    [self performSelectorOnMainThread:@selector(doShowModelAndPushTabs:) withObject:network waitUntilDone:NO];  
  else {
    [self handleReplaceToken:network];
  }
  [autoreleasepool release];
}

- (void)handleReplaceToken:(NSMutableDictionary*)network {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  long network_id = [[network objectForKey:@"id"] longValue];
 
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
    
    if ([LocalStorage getFile:[APIGateway push_file]] == nil)
      [APIGateway pushSettings:@"silent"];
    
    NSString* previous = [LocalStorage getAccessToken];
    
    [LocalStorage saveAccessToken:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [token objectForKey:@"token"], [token objectForKey:@"secret"]]];
    
    NSString* pushSettingsJSON = [LocalStorage getFile:[APIGateway push_file_with_id:network_id]];
    
    if ([LocalStorage getFile:[APIGateway user_file_with_id:network_id]] == nil)
      [APIGateway usersCurrent:@"silent"];
    
    if ([LocalStorage getFile:[APIGateway user_file_with_id:network_id]] == nil) {
      errorCode = @"NO_USERS_CURRENT";
      [LocalStorage saveAccessToken:previous];
    } else {
      yammer.network_id = [network objectForKey:@"id"];
      [LocalStorage saveSetting:@"current_network_id" value:yammer.network_id];
      [LocalStorage removeFile:[APIGateway push_file]];
      
      [LocalStorage removeFile:DIRECTORY_CACHE];
      
      if (yammer.pushToken && [APIGateway sendPushToken:yammer.pushToken] && pushSettingsJSON != nil) {
        // send existing push settings (if any) to server
        NSMutableDictionary* pushSettings = [pushSettingsJSON JSONValue];
        NSMutableDictionary* existingPushSettings = [APIGateway pushSettings:@"silent"];
        if (existingPushSettings)
          [APIGateway updatePushSettingsInBulk:[existingPushSettings objectForKey:@"id"] pushSettings:pushSettings];
        [LocalStorage removeFile:[APIGateway push_file]];
      }
    }
  }
  
  if (errorCode != nil) {
    [NSThread detachNewThreadSelector:@selector(errorThread:) toTarget:self withObject:errorCode];
  } else {  
    [self performSelectorOnMainThread:@selector(doShowModelAndPushTabs:) withObject:network waitUntilDone:NO];  
  }
  
}


- (void)doShowModelAndPushTabs:(NSMutableDictionary*)network {
  [self showModel:YES];
  
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  yammer.network_name = [network objectForKey:@"name"];

  TTNavigator* navigator = [TTNavigator navigator];
  [navigator openURL:@"yammer://tabs" animated:YES];
  self.alreadySelected = NO;
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
  self.alreadySelected = NO;
  [autoreleasepool release];
}

- (void)clearBadgeForNetwork:(NSNumber*)network_id {
  NetworkListDataSource* source = (NetworkListDataSource*)self.dataSource;
  for (NetworkListItem* item in [source.items objectAtIndex:0]) {
    if ([[item.network objectForKey:@"id"] longValue] == [network_id longValue]) {
      [item.network setObject:[NSNumber numberWithInt:0] forKey:@"unseen_message_count"];  
      break;
    }
  }
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
