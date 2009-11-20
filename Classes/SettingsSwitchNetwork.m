
#import "SettingsSwitchNetwork.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"
#import "CheckMarkCell.h"

@interface SwitchNetworkDelegate : TTTableViewVarHeightDelegate;
@end

@implementation SwitchNetworkDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  //NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

  SettingsSwitchNetwork* switchView = (SettingsSwitchNetwork*)[_controller.navigationController visibleViewController];
  
  //[[_controller.navigationController visibleViewController] dismissModalViewControllerAnimated:YES];

  [switchView madeSelection:indexPath.row];
}

@end

// SettingsSwitchNetwork
@implementation SettingsSwitchNetwork

@synthesize settingsReference = _settingsReference;

- (id)initWithControllerReference:(Settings*)settings {
  if (self = [super init]) {
    self.settingsReference = settings;
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Switch Network";
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(refreshClick)];  
    self.navigationItem.rightBarButtonItem = refresh;
    
    _tableViewStyle = UITableViewStyleGrouped;
    
    NSString* json = [LocalStorage getFile:TOKENS];
    if (json) {
       NSMutableArray* tokens = (NSMutableArray *)[json JSONValue];
      self.dataSource = [self sourceFromArray:tokens];
    } else
      [NSThread detachNewThreadSelector:@selector(loadTokens) toTarget:self withObject:nil];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_settingsReference);
  [super dealloc];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[SwitchNetworkDelegate alloc] initWithController:self];
}

- (TTSectionedDataSource*)sourceFromArray:(NSMutableArray*)array {
  NSMutableArray* sections = [NSMutableArray array];
  NSMutableArray* items = [NSMutableArray array];
  NSMutableArray* section = [NSMutableArray array];

  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  for (NSMutableDictionary* dict in array) {
    long nid = [[dict objectForKey:@"network_id"] longValue];
    [section addObject:[CheckMarkTTTableTextItem text:[dict objectForKey:@"network_name"] isChecked:[yammer.network_id longValue] == nid]];  
  }

  [sections addObject:@"You can link multiple yammer accounts on the website.  Accounts you have linked will appear here."];
  [items addObject:section];
  CheckMarkDataSource* list = [[CheckMarkDataSource alloc] initWithItems:items sections:sections];  
  return list;
}

- (void)loadTokens {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
  [self performSelectorOnMainThread:@selector(setDataSource:)
                         withObject:[self sourceFromArray:[APIGateway getTokens]]
                      waitUntilDone:NO];
  
  [autoreleasepool release];
}

- (void)refreshClick {
  [NSThread detachNewThreadSelector:@selector(refreshClickThread) toTarget:self withObject:nil];
}

- (void)refreshClickThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  
  [self performSelectorOnMainThread:@selector(setDataSource:)
                         withObject:[self sourceFromArray:[APIGateway getTokens]]
                      waitUntilDone:NO];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

  [autoreleasepool release];
}

- (void)cancel {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)madeSelection:(int)row {
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = nil;
  [NSThread detachNewThreadSelector:@selector(doTheSwitch:) toTarget:self withObject:[NSNumber numberWithInt:row]];
}

- (void)doTheSwitch:(NSNumber*)index {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  usleep(500000);

  NSMutableArray* tokens = (NSMutableArray *)[[LocalStorage getFile:TOKENS] JSONValue];
  NSMutableDictionary* token = [tokens objectAtIndex:[index intValue]];
  
  long nid = [[token objectForKey:@"network_id"] longValue];
  
  if (nid != [yammer.network_id longValue]) {
    [self performSelectorOnMainThread:@selector(setDataSource:)
                           withObject:nil
                        waitUntilDone:YES];

    if ([LocalStorage getFile:[APIGateway push_file]] == nil)
      [APIGateway pushSettings:nil];
    
    NSString* previous = [LocalStorage getAccessToken];
    
    [LocalStorage saveAccessToken:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [token objectForKey:@"token"], [token objectForKey:@"secret"]]];
    
    // important to get first because usersCurrent call has to delete this file
    NSString* pushSettingsJSON = [LocalStorage getFile:[APIGateway push_file_with_id:nid]];
    
    NSMutableDictionary* usersCurrent = [APIGateway usersCurrent:nil];

    if (usersCurrent) {
      [_settingsReference gatherData];
      
      if (yammer.pushToken && [APIGateway sendPushToken:yammer.pushToken] && pushSettingsJSON != nil) {
        // send existing push settings (if any) to server
        NSMutableDictionary* pushSettings = [pushSettingsJSON JSONValue];
        NSMutableDictionary* existingPushSettings = [APIGateway pushSettings:nil];
        [APIGateway updatePushSettingsInBulk:[existingPushSettings objectForKey:@"id"] pushSettings:pushSettings];
        [LocalStorage removeFile:[APIGateway push_file]];
      }
            
      [yammer resetForNewNetwork];
    } else
      [LocalStorage saveAccessToken:previous];
  }
  
  [yammer settingsToRootView];
  [autoreleasepool release];
}

@end
