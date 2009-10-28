
#import "SettingsSwitchNetwork.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "APIGateway.h"

@interface SwitchNetworkDelegate : TTTableViewVarHeightDelegate;
@end

@implementation SwitchNetworkDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  //NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

  [[_controller.navigationController visibleViewController] dismissModalViewControllerAnimated:YES];

}

@end


@implementation SettingsSwitchNetwork

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Switch Network";
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(refreshClick)];  
    self.navigationItem.leftBarButtonItem = refresh;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self
                                                                             action:@selector(cancel)];  
    self.navigationItem.rightBarButtonItem = cancel;
    
    
    NSString* json = [LocalStorage getFile:TOKENS];
    if (json) {
       NSMutableArray* tokens = (NSMutableArray *)[json JSONValue];
      self.dataSource = [self sourceFromArray:tokens];
    } else
      [NSThread detachNewThreadSelector:@selector(loadTokens) toTarget:self withObject:nil];
  }
  return self;
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

@end
