
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

// CheckMarkTTTableTextItem
@interface CheckMarkTTTableTextItem : TTTableTextItem {
  BOOL isChecked;
}
@property BOOL isChecked;
@end

@implementation CheckMarkTTTableTextItem
@synthesize isChecked;
+ (CheckMarkTTTableTextItem*)text:(NSString*)text isChecked:(BOOL)isChecked {
  CheckMarkTTTableTextItem* item = [CheckMarkTTTableTextItem itemWithText:text URL:@"1"];
  item.isChecked = isChecked;
  return item;
}
@end

@interface CheckMarkCell : TTTableTextItemCell;
@end

@implementation CheckMarkCell
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];
    
    CheckMarkTTTableTextItem* item = object;

    if (item.isChecked)
      self.accessoryType = UITableViewCellAccessoryCheckmark;
    else
      self.accessoryType = UITableViewCellAccessoryNone;
  }
}
@end

@interface CheckMarkDataSource : TTListDataSource;
@end

@implementation CheckMarkDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  return [CheckMarkCell class];
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

- (TTListDataSource*)sourceFromArray:(NSMutableArray*)array {
  CheckMarkDataSource* list = [[CheckMarkDataSource alloc] init];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  for (NSMutableDictionary* dict in array) {
    long nid = [[dict objectForKey:@"network_id"] longValue];
    [list.items addObject:[CheckMarkTTTableTextItem text:[dict objectForKey:@"network_name"] isChecked:[yammer.network_id longValue] == nid]];  
  }
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

    NSString* previous = [LocalStorage getAccessToken];
    
    [LocalStorage saveAccessToken:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [token objectForKey:@"token"], [token objectForKey:@"secret"]]];
    
    NSMutableDictionary* usersCurrent = [APIGateway usersCurrent:nil];

    if (usersCurrent) {
      long nid = [[usersCurrent objectForKey:@"network_id"] longValue];
      yammer.network_id = [[NSNumber alloc] initWithLong:nid];
      [_settingsReference gatherData];
      [yammer resetForNewNetwork];
    } else
      [LocalStorage saveAccessToken:previous];
  }
  
  [yammer settingsToRootView];
  [autoreleasepool release];
}

@end
