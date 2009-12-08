#import "FeedMessageList.h"
#import "FeedMessageData.h"
#import "MainTabBar.h"
#import "Message.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "MessageDetail.h"
#import "TTTableYammerViewDelegate.h"
#import "FeedCache.h"
#import "ComposeMessage.h"
#import "SpinnerWithTextCell.h"
#import "YammerAppDelegate.h"
#import "NetworkList.h"

@implementation FeedMessageList

@synthesize feed;
@synthesize curOffset;
@synthesize isChecking;
@synthesize lastNumMessages;
@synthesize isThread;

- (id)initWithFeed:(FeedDictionary*)theFeed refresh:(BOOL)refresh compose:(BOOL)compose thread:(BOOL)thread {
  if (self = [super init]) {
    self.variableHeightRows = YES;
    self.feed = theFeed;
    self.title = (NSString*)[theFeed objectForKey:@"name"];
    self.isThread = thread;
        
    if (compose) {
      UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                               target:self
                                                                               action:@selector(compose)];
      self.navigationItem.rightBarButtonItem = compose;
    }
        
    self.navigationBarTintColor = [MainTabBar yammerGray];

    self.curOffset = 0;    
    FeedMessageData* feedDataSource = [FeedMessageData feed:self.feed];
    [feedDataSource.items addObject:[SpinnerWithTextItem itemWithYammer]];
    
    [feedDataSource fetch:nil];
    self.dataSource = feedDataSource;
    
    if (![self.title isEqualToString:@"Received"])
      [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:@"silent"];        
  }
  return self;
}

- (id<UITableViewDelegate>)createDelegate {
  return [[TTTableYammerViewDelegate alloc] initWithController:self];
}

- (void)loadView {
  [super loadView];  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillAppear:animated];
  //self.tabBarItem.badgeValue = nil;
  //[NSThread detachNewThreadSelector:@selector(removeColor) toTarget:self withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //[self performSelectorOnMainThread:@selector(doShowModel) withObject:nil waitUntilDone:NO];  
}

- (void)removeColor {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [(FeedMessageData*)self.dataSource removeAllColor];
  [autoreleasepool release];
}

- (void)checkForNewMessages:(NSString *)style {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  self.isChecking = true;
  NSNumber *newerThan=nil;
  @try {
    NSMutableDictionary *m = [(FeedMessageData*)self.dataSource firstItem];  
    if ([feed threading]) 
      newerThan = [m objectForKey:@"latest_reply_id"];
    else
      newerThan = [m objectForKey:@"message_id"];
  } @catch (NSException *theErr) { }

  NSMutableDictionary *dict = [APIGateway messages:feed newerThan:newerThan style:style];
  if ([yammer countViewControllers] == 1) {
    self.isChecking = false;
    [autoreleasepool release];
    return;
  }
  
  if (dict) {
    FeedMessageData* feedDataSource = [FeedMessageData feed:self.feed];

    [feedDataSource proccesMessages:dict checkNew:true newerThan:newerThan];

    if ([self.title isEqualToString:@"My Feed"])
      [yammer performSelectorOnMainThread:@selector(setBadges:)
                             withObject:style
                          waitUntilDone:NO];
    
    NSDate *date = [FeedCache loadFeedDate:feed];
    
    if (date)
      [feedDataSource.items addObject:[SpinnerWithTextItem itemWithText:[FeedCache niceDate:date]]];
    else
      [feedDataSource.items addObject:[SpinnerWithTextItem itemWithText:@"No updates yet."]];
    
    
    self.curOffset = 0;
    @synchronized ([UIApplication sharedApplication]) {
      [feedDataSource fetch:nil];
    }

    [self performSelectorOnMainThread:@selector(setDataSource:)
                           withObject:feedDataSource
                        waitUntilDone:YES];
    
    self.lastNumMessages = [feedDataSource count];    
  } else {
    FeedMessageData* data = (FeedMessageData*)self.dataSource;
    data.spinnerItem.isSpinning = NO;
    NSDate *date = [FeedCache loadFeedDate:feed];
    
    if (date)
      data.spinnerItem.text = [FeedCache niceDate:date];
    else
      data.spinnerItem.text = @"No updates yet.";
    
    if ([self.title isEqualToString:@"My Feed"])
      [yammer performSelectorOnMainThread:@selector(setBadges:) withObject:style waitUntilDone:NO];
    
    [self showModel:YES];
  }

  if ([(FeedMessageData*)self.dataSource count] == 0 && ![self.title isEqualToString:@"Received"]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note"
                                                    message:@"No messages in this feed yet." delegate:self 
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
  }
  
  self.isChecking = false;
  [autoreleasepool release];
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  int before = [(FeedMessageData*)self.dataSource count];
  curOffset += lastNumMessages;
  
  @synchronized ([UIApplication sharedApplication]) {
    [(FeedMessageData*)self.dataSource fetch:[NSNumber numberWithInt:curOffset]];
  }
  
  if (before == [(FeedMessageData*)self.dataSource count]) {
    NSMutableDictionary *m = [(FeedMessageData*)self.dataSource lastObject];
    NSMutableDictionary *dict = [APIGateway messages:feed olderThan:[m objectForKey:@"message_id"] style:nil];
    if (dict) {
      NSMutableDictionary* ids = [(FeedMessageData*)self.dataSource proccesMessages:dict checkNew:false newerThan:nil];
      if ([ids count] > 0)
        self.lastNumMessages = [ids count];
    }
    @synchronized ([UIApplication sharedApplication]) {
      [(FeedMessageData*)self.dataSource fetch:[NSNumber numberWithInt:curOffset]];
    }
  } else
    curOffset -= lastNumMessages - ([(FeedMessageData*)self.dataSource count] - before);
  
  NSUInteger newIndex[] = {1, 0};
  NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
  
  TTTableMoreButton *more = (TTTableMoreButton *)[self.dataSource tableView:_tableView objectForRowAtIndexPath:newPath];
  more.isLoading = NO;
  TTTableMoreButtonCell* cell = (TTTableMoreButtonCell*)[_tableView cellForRowAtIndexPath:newPath];
  cell.animating = NO;
  
  [self performSelectorOnMainThread:@selector(doShowModel)
                         withObject:nil
                      waitUntilDone:YES];
//  [self showModel:YES];
  [autoreleasepool release];
}

- (void)doShowModel {
  [self showModel:YES];
}

- (void)compose {
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  
  NSString *name = [feed objectForKey:@"name"];
  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
    [meta setObject:[feed objectForKey:@"group_id"] forKey:@"group_id"];
  else
    name = @"My Colleagues";
  [meta setObject:[NSString stringWithFormat:@"To: %@", name] forKey:@"display"];
  
  
  [self presentModalViewController:[ComposeMessage getNav:meta] animated:YES];
}

- (void)refreshFeedClick {
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];  

  if ([self.title isEqualToString:@"Received"]) {
    YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSUInteger newIndex[] = {0, 0};
    NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    
    [_tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    
    FeedMessageData* data = (FeedMessageData*)self.dataSource;
    data.spinnerItem.isSpinning = YES;
    data.spinnerItem.text = @"Checking for new messages...";
    [self showModel:YES];
    
    [yammer refreshMyFeed];
  }
  else
    [self refreshFeed:nil];
}

- (void)refreshFeed:(NSString*)silent {
  NSUInteger newIndex[] = {0, 0};
  NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];

  [_tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
  
  FeedMessageData* data = (FeedMessageData*)self.dataSource;
  data.spinnerItem.isSpinning = YES;
  data.spinnerItem.text = @"Checking for new messages...";
  [self showModel:YES];

  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:silent];
}

- (void)replaceFeed {
  self.curOffset = 0;
  FeedMessageData* feedDataSource = [FeedMessageData feed:self.feed];
  [feedDataSource.items addObject:[SpinnerWithTextItem itemWithYammer]];
  
  [feedDataSource fetch:nil];
  self.dataSource = feedDataSource;
}

- (void)showListOfNetworks {
  
  TTNavigator* navigator = [TTNavigator navigator];
  [navigator removeAllViewControllers];
  [navigator openURL:@"yammer://networks" animated:YES];
  
  [NSThread detachNewThreadSelector:@selector(refreshList) toTarget:[navigator visibleViewController] withObject:nil];
}

- (void)dealloc {
  [feed release];
	[super dealloc];
}



@end
