
#import "DataSettingsPush.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "FeedsTableDataSource.h"

@implementation DataSettingsPush

@synthesize feeds;

+ (DataSettingsPush *)getFeeds:(NSMutableDictionary *)dict {
  if (dict) {
    dict = [dict objectForKey:@"web_preferences"];
    return [[DataSettingsPush alloc] initWithArray:[dict objectForKey:@"home_tabs"]];
  }
  return [[DataSettingsPush alloc] initWithArray:[NSMutableArray array]];
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
  
  UISwitch *switchView = [[UISwitch alloc] init];
  cell.accessoryView = switchView;
  [switchView setOn:NO animated:NO];
  [switchView setTag:[indexPath row]];
  [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
  [switchView release];   
  
	return cell;
}

- (void)switchWasChanged:(id)sender {
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Switch Changed."
                        message:@"Wefwef"
                        delegate:nil
                        cancelButtonTitle:@"Thanks!"
                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
