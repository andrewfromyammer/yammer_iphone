
#import "SettingsSwitchNetwork.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"

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

- (TTListDataSource*)sourceFromArray:(NSMutableArray*)array {
  TTListDataSource* list = [[TTListDataSource alloc] init];
  
  for (NSMutableDictionary* dict in array)
    [list.items addObject:[TTTableTextItem itemWithText:[dict objectForKey:@"network_name"] URL:@"1"]];  
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
  
  sleep(1);
  
  [self performSelectorOnMainThread:@selector(setDataSource:)
                         withObject:nil
                      waitUntilDone:YES];
  
  NSMutableArray* tokens = (NSMutableArray *)[[LocalStorage getFile:TOKENS] JSONValue];
  NSMutableDictionary* token = [tokens objectAtIndex:[index intValue]];

  NSString* previous = [LocalStorage getAccessToken];
  
  [LocalStorage saveAccessToken:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [token objectForKey:@"token"], [token objectForKey:@"secret"]]];
  
  NSMutableDictionary* usersCurrent = [APIGateway usersCurrent:nil];
  if (usersCurrent) {
    long nid = [[usersCurrent objectForKey:@"network_id"] longValue];
    YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
    yammer.network_id = [[NSNumber alloc] initWithLong:nid];
    [_settingsReference gatherData];
    [yammer resetForNewNetwork];
  } else
    [LocalStorage saveAccessToken:previous];

  [self dismissModalViewControllerAnimated:YES];
  [autoreleasepool release];
}

@end
