#import "DirectoryList.h"
#import "APIGateway.h"
#import "NSString+SBJSON.h"
#import "LocalStorage.h"
#import "FeedCache.h"
#import "MainTabBar.h"
#import "UserProfile.h"
#import "SpinnerWithTextCell.h"
#import "DirectorySearchDataSource.h"
#import "AutoCompleteCache.h"

@interface DirectoryListDelegate : TTTableViewVarHeightDelegate;
@end

@implementation DirectoryListDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  DirectoryList* dl = (DirectoryList*)_controller;  
	
  if ([object isKindOfClass:[SpinnerWithTextItem class]]) {
    DirectoryList* dl = (DirectoryList*)_controller;
    [dl refreshDirectory];
    return;
  }
  
  if ([object isKindOfClass:[TTTableMoreButton class]]) {
    TTTableMoreButton *more = (TTTableMoreButton *)object;
    more.isLoading = YES;
    TTTableMoreButtonCell* cell = (TTTableMoreButtonCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.animating = YES;
    
    [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:_controller withObject:nil];    
  } else if (dl.currentString == nil) {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  } else {
	  [dl doCancel];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

@end

@implementation DirectoryList

@synthesize page;
@synthesize lastString = _lastString, currentString = _currentString, searchThread = _searchThread, searchBar = _searchBar;

- (id)init {
  if (self = [super init]) {
    self.variableHeightRows = YES;

    self.page = 1;
    self.navigationBarTintColor = [MainTabBar yammerGray];

    _lastString = @"";
    _currentString = nil;
    _searchThread = nil;
    
    //SpinnerListDataSource* list = [[[SpinnerListDataSource alloc] init] autorelease];
    //[list.items addObject:[SpinnerWithTextItem item]];
    //self.dataSource = [[TTListDataSource alloc] init];
      
    [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:@"silent"];  
  }  
  return self;
}

- (void)resetForNetworkSwitch {
  [LocalStorage removeFile:DIRECTORY_CACHE];
  //SpinnerListDataSource* list = [[[SpinnerListDataSource alloc] init] autorelease];
  //[list.items addObject:[SpinnerWithTextItem item]];
  self.dataSource = nil;
  
  [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:@"silent"];
}

- (void)loadView {
  [super loadView];
  
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
  _searchBar.delegate = self;
  _searchBar.showsCancelButton = YES;
  self.tableView.tableHeaderView = _searchBar;
  
}

- (void)typeAheadThreadUpdate {  
  if (self.currentString != nil && ![self.currentString isEqualToString:self.lastString]) {
    if (self.searchThread != nil) {
      [self.searchThread cancel];
      TT_RELEASE_SAFELY(_searchThread);
    }
    
    
    NSString* trimmed = [self.currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] > 0) {      
			NSString* cached = [LocalStorage getFile:[AutoCompleteCache filename:trimmed]];
			
			if (cached != nil) {
				NSMutableDictionary* results = (NSMutableDictionary*)[cached JSONValue];
				[self performSelectorOnMainThread:@selector(handleResults:) withObject:[results objectForKey:@"users"] waitUntilDone:NO];
			}
			
      self.searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSearch:) object:trimmed];
      [self.searchThread start];
    } else {
      [self performSelectorOnMainThread:@selector(handleEmpty) withObject:nil waitUntilDone:NO];
    }
  }
  
  if (self.currentString != nil)
    self.lastString = [NSString stringWithString:self.currentString];
  
}

- (void)handleEmpty {
  self.dataSource = [[TTListDataSource alloc] init];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if (self.currentString == nil)
    self.dataSource = [[TTListDataSource alloc] init];
  
  self.currentString = [NSString stringWithString:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self doCancel];
}

- (void)doCancel {
  [_searchBar resignFirstResponder];
  _searchBar.text = @"";
  _lastString = @"";
  _currentString = nil;
  [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:@"silent"];	
}

- (void)doSearch:(NSString*)trimmed {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSMutableDictionary* results = [APIGateway autocomplete:trimmed];
  [self performSelectorOnMainThread:@selector(handleResults:) withObject:[results objectForKey:@"users"] waitUntilDone:NO];
  [autoreleasepool release];
}

- (void)handleResults:(NSArray*)users {
  TTListDataSource* list = [[TTListDataSource alloc] init];
  
  if ([users count] == 0)
    [list.items addObject:[TTTableTextItem itemWithText:@"-- no results --"]];
  
  for (NSMutableDictionary* user in users) {
    [list.items addObject:[TTTableTextItem itemWithText:[UserProfile safeName:user] URL:[NSString stringWithFormat:@"yammer://user?id=%@", [user objectForKey:@"id"]]]];
  }
  self.dataSource = list;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}


- (void)refreshDirectory {
  //SpinnerListDataSource* list = [[[SpinnerListDataSource alloc] init] autorelease];
  //[list.items addObject:[SpinnerWithTextItem itemWithYammer]];
  self.dataSource = nil;
  
  [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:nil];  
}

- (void)loadUsers:(NSString *)style {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableArray *list;
  NSString *cached = [LocalStorage getFile:DIRECTORY_CACHE];
  if (cached && style != nil)
    list = (NSMutableArray *)[cached JSONValue];
  else {
    list = [APIGateway users:1 style:style];
    if (list == nil && cached)
      list = (NSMutableArray *)[cached JSONValue];
  }

  TTListDataSource* source = [[TTListDataSource alloc] init];

  //SpinnerListDataSource* source = [[[SpinnerListDataSource alloc] init] autorelease];
  //[source.items addObject:[SpinnerWithTextItem itemWithText:[FeedCache niceDate:[LocalStorage getFileDate:DIRECTORY_CACHE]]]];
  [self handleUsers:list source:source];
  
  if ([list count] == 50)
    [source.items addObject: [TTTableMoreButton itemWithText:@"                       More"]];

  [self performSelectorOnMainThread:@selector(setDataSource:)
                           withObject:source
                        waitUntilDone:YES];
  //self.dataSource = source;
  //[self showModel:YES];
  
  [autoreleasepool release];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[DirectoryListDelegate alloc] initWithController:self];
}

- (void)handleUsers:(NSArray*)list source:(TTListDataSource*)source {
  for (int i=0; i < [list count]; i++) {
    NSMutableDictionary *dict = [list objectAtIndex:i];
    
    TTTableImageItem* item = [TTTableImageItem itemWithText:[UserProfile safeName:dict] imageURL:[dict objectForKey:@"mugshot_url"] 
                                               defaultImage:[UIImage imageNamed:@"no_photo_small.png"] 
                                                URL:[NSString stringWithFormat:@"yammer://user?id=%@", [dict objectForKey:@"id"]]];
    [source.items addObject:item];
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSMutableArray *users = [APIGateway users:2 style:nil];
  if (users) {
    TTListDataSource* source = (TTListDataSource*)self.dataSource;
    [source.items removeLastObject];
    [self handleUsers:users source:source];
  }
//  [self showModel:YES];
  [self performSelectorOnMainThread:@selector(doShowModel)
                         withObject:nil
                      waitUntilDone:YES];
  [autoreleasepool release];
}

- (void)doShowModel {
  [self showModel:YES];
}

- (void)dealloc {
  [super dealloc];
  TT_RELEASE_SAFELY(_lastString);
  TT_RELEASE_SAFELY(_currentString);
  TT_RELEASE_SAFELY(_searchThread);
  TT_RELEASE_SAFELY(_searchBar);
}

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
}

@end
