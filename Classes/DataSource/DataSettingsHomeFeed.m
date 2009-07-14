
#import "DataSettingsHomeFeed.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "FeedsTableDataSource.h"

@implementation DataSettingsHomeFeed

@synthesize feeds;

+ (DataSettingsHomeFeed *)getFeeds:(NSMutableDictionary *)dict {
  if (dict) {
    dict = [dict objectForKey:@"web_preferences"];
    return [[DataSettingsHomeFeed alloc] initWithArray:[dict objectForKey:@"home_tabs"]];
  }
  return [[DataSettingsHomeFeed alloc] initWithArray:[NSMutableArray array]];
}

- (id)initWithArray:(NSMutableArray *)array {
  self.feeds = array;
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  [FeedsTableDataSource setupCell:cell dict:[feeds objectAtIndex:indexPath.row]];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  NSString *currentURL = [[LocalStorage getFeedInfo] objectForKey:@"url"];
  
  NSString *rowURL = [[feeds objectAtIndex:indexPath.row] objectForKey:@"url"];
  
  if ([rowURL isEqualToString:currentURL])
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

	return cell;
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
