
#import "SettingsSwitchNetwork.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"

@implementation SettingsSwitchNetwork

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Switch Network";
    
    NSString* json = [LocalStorage getFile:TOKENS];
    if (json) {
       NSMutableArray* tokens = (NSMutableArray *)[json JSONValue];
      self.dataSource = [self sourceFromArray:tokens];
    } else
      [NSThread detachNewThreadSelector:@selector(loadTokens) toTarget:self withObject:nil];
  }
  return self;
}

- (TTListDataSource*)sourceFromArray:(NSMutableArray*)array {
  TTListDataSource* list = [[TTListDataSource alloc] init];
  
  [list.items addObject:[TTTableTextItem itemWithText:@"test" URL:nil]];  
  return list;
}

- (void)loadTokens {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
  [self performSelectorOnMainThread:@selector(setDataSource:)
                         withObject:[self sourceFromArray:nil]
                      waitUntilDone:NO];
  
  [autoreleasepool release];
}


@end
