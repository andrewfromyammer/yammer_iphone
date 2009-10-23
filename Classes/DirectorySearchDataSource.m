#import "DirectorySearchDataSource.h"

@implementation MockAddressBook

@synthesize names = _names, fakeSearchDuration = _fakeSearchDuration;

+ (NSMutableArray*)fakeNames {
  return [NSMutableArray arrayWithObjects:
          @"Hector Lewis",
          @"Juanita Fredrick",
          @"Richard Raymond",
          @"Marcia Myer",
          @"Shannon Mahoney",
          @"James Steiner",
          @"Daniel Lloyd",
          @"Fredrick Hutchins",
          @"Tracey Smith",
          @"Brandon Rutherford",
          @"Megan Lopez",
          @"Jean Trujillo",
          @"Franklin Diamond",
          @"Mildred Jacobsen",
          @"Sandra Adams",
          @"Debra Pugliese",
          @"Jennifer Myers",
          @"Mary Spurgeon",
          nil];
}

- (void)fakeSearch:(NSString*)text {
  self.names = [NSMutableArray array];
  
  if (text.length) {
    text = [text lowercaseString];
    for (NSString* name in _allNames) {
      if ([[name lowercaseString] rangeOfString:text].location == 0) {
        [_names addObject:name];
      }
    }    
  }
  
  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)fakeSearchReady:(NSTimer*)timer {
  _fakeSearchTimer = nil;
  
  NSString* text = timer.userInfo;
  [self fakeSearch:text];
}

- (id)initWithNames:(NSArray*)names {
  if (self = [super init]) {
    _delegates = nil;
    _allNames = [names copy];
    _names = nil;
    _fakeSearchTimer = nil;
    _fakeSearchDuration = 0;
  }
  return self;
}

- (void)dealloc {
  TT_INVALIDATE_TIMER(_fakeSearchTimer);
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_allNames);
  TT_RELEASE_SAFELY(_names);
  [super dealloc];
}

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (BOOL)isLoaded {
  return !!_names;
}

- (BOOL)isLoading {
  return !!_fakeSearchTimer;
}

- (BOOL)isEmpty {
  return !_names.count;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  if (_fakeSearchTimer) {
    TT_INVALIDATE_TIMER(_fakeSearchTimer);
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
  }
}

- (void)loadNames {
  TT_RELEASE_SAFELY(_names);
  _names = [_allNames mutableCopy];
}

- (void)search:(NSString*)text {
  [self cancel];
  
  if (text.length) {
    if (_fakeSearchDuration) {
      TT_INVALIDATE_TIMER(_fakeSearchTimer);
      _fakeSearchTimer = [NSTimer scheduledTimerWithTimeInterval:_fakeSearchDuration target:self
                                                        selector:@selector(fakeSearchReady:) userInfo:text repeats:NO];
      [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
    } else {
      [self fakeSearch:text];
      [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    }
  } else {
    TT_RELEASE_SAFELY(_names);
    [_delegates perform:@selector(modelDidChange:) withObject:self];
  }
}

@end

@implementation DirectorySearchDataSource

@synthesize addressBook = _addressBook, typedText = _typedText, created_at = _created_at;

- (id)initWithDuration:(NSTimeInterval)duration {
  if (self = [super init]) {
    _addressBook = [[MockAddressBook alloc] initWithNames:[MockAddressBook fakeNames]];
    _addressBook.fakeSearchDuration = duration;
    _typedText = nil;
    _created_at = nil;
    self.model = _addressBook;
    [NSThread detachNewThreadSelector:@selector(scanRequests) toTarget:self withObject:nil];
  }
  return self;
}

- (id)init {
  return [self initWithDuration:0];
}

- (void)scanRequests {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  while (true) {
    //[NSThread sleepForTimeInterval:0.5];
    usleep(5000);
    NSLog(@"1111: %@", _typedText);
    NSLog(@"1112: %@", [_created_at description]);
    if (_typedText != nil && [_created_at timeIntervalSinceNow] < -0.5) {      
      NSString* prefix = [NSString stringWithString:_typedText];
      _typedText = nil;
      
      [self performSelectorOnMainThread:@selector(doSearch:)
                             withObject:prefix
                          waitUntilDone:NO];      
    }
  }
  
  [autoreleasepool release];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_addressBook);
  TT_RELEASE_SAFELY(_typedText);
  TT_RELEASE_SAFELY(_created_at);
  [super dealloc];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  
  for (NSString* name in _addressBook.names) {
    TTTableItem* item = [TTTableTextItem itemWithText:name URL:@"http://google.com"];
    [_items addObject:item];
  }
}

- (void)doSearch:(NSString*)text {
  [_addressBook search:text];
}

- (void)search:(NSString*)text {
  NSLog(@"AAA: %@", text);
  NSString* trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([trimmed length] > 0) {
    NSLog(@"BBB");
    _created_at = [NSDate date];
    _typedText = trimmed;
    NSLog(@"CCC");
  }
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return @"Searching...";
}

- (NSString*)titleForNoData {
  return @"No names found";
}

@end
