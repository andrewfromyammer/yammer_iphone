
#import "TypeAheadDemo.h"
#import "APIGateway.h"

@implementation TypeAheadDemo

@synthesize isSearching;

- (id)init {
  if (self = [super init]) {
    self.variableHeightRows = YES;

    self.isSearching = NO;
    self.title = @"Demo";
    //searchController.searchResultsDataSource = self;
    //searchController.searchResultsDelegate = self;
    
    TTListDataSource* list = [[TTListDataSource alloc] init];
    self.dataSource = list;
    
  }  
  return self;
}


- (void)loadView {
  [super loadView];

  UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
  searchBar.delegate = self;
  searchBar.showsCancelButton = YES;
  //UISearchDisplayController* searchController = [[UISearchDisplayController alloc]
    //                                             initWithSearchBar:searchBar contentsController:self];

  //[self.view addSubview:searchBar];
  //self.searchViewController = self;
  //self.tableView.tableHeaderView = _searchController.searchBar;
  self.tableView.tableHeaderView = searchBar;
  
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  searchBar.text = @"";
  [searchBar resignFirstResponder];
  TTListDataSource* list = [[TTListDataSource alloc] init];
  self.dataSource = list;
}


- (void)doSearch:(UISearchBar *)searchBar {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSString* trimmed = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([trimmed length] > 0) {
    NSMutableDictionary* results = [APIGateway autocomplete:trimmed];
    NSArray* users = [results objectForKey:@"users"];
    
    TTListDataSource* list = [[TTListDataSource alloc] init];
    
    if ([users count] == 0)
      [list.items addObject:[TTTableTextItem itemWithText:@"-- no results --"]];
    
    for (NSMutableDictionary* user in users) {
      [list.items addObject:[TTTableTextItem itemWithText:[user objectForKey:@"full_name"] URL:@"http://www.cnn.com/"]];
    }
    self.dataSource = list;
  }
  
  self.isSearching = NO;
  [autoreleasepool release];
}
  
  
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

  if (self.isSearching)
    return;
  
  [searchBar resignFirstResponder];
  TTListDataSource* list = [[TTListDataSource alloc] init];  
  [list.items addObject:[TTTableTextItem itemWithText:@"Searching..."]];
  self.dataSource = list;
  
  self.isSearching = YES;
  [NSThread detachNewThreadSelector:@selector(doSearch:) toTarget:self withObject:searchBar];
}

- (void)dealloc {
  [super dealloc];
}

@end
