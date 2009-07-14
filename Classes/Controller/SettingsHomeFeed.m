#import "SettingsHomeFeed.h"
#import "DataSettingsHomeFeed.h"
#import "LocalStorage.h"

@implementation SettingsHomeFeed

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;

- (id)initWithDict:(NSMutableDictionary *)dict parent:(SettingsViewController *)view {
  self.title = @"Choose Feed";
  self.parent = view;
	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];  
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;  
  self.dataSource = [DataSettingsHomeFeed getFeeds:dict];
	theTableView.dataSource = self.dataSource;
  self.view = theTableView;
  
  return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  [LocalStorage saveFeedInfo:[dataSource feedAtIndex:indexPath.row]];
  [parent.theTableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 40.0;
}

- (void)dealloc {
  [dataSource release];
  [theTableView release];
  [parent release];
  [super dealloc];
}


@end
