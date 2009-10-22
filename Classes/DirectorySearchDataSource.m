#import "DirectorySearchDataSource.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"

@implementation DirectorySearchDataSource

@synthesize running;
@synthesize searchText, created_at;

- (id)init {
  if (self = [super init]) {
    self.running = YES;
    self.searchText = nil;
    [NSThread detachNewThreadSelector:@selector(scanRequests) toTarget:self withObject:nil];
  }
  return self;
}

- (void)search:(NSString*)text {
  self.searchText = text;
  self.created_at = [NSDate date];
}

- (void)scanRequests {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  while (self.running == YES) {
    sleep(0.5);
    if (self.searchText != nil && [self.created_at timeIntervalSinceNow] < -0.5) {
      NSString* prefix = [NSString stringWithString:self.searchText];
      self.searchText = nil;
      NSDictionary* autocomplete = [APIGateway autocomplete:[NSString stringWithFormat:@"%@%@", @"@", prefix]];
      NSArray* users = [autocomplete objectForKey:@"users"];
      NSLog(@"%d", [users count]);
    }
  }
  
  [autoreleasepool release];
}

- (void)dealloc {
  self.running = NO;
  [searchText release];
  [created_at release];
  [super dealloc];
}

@end
