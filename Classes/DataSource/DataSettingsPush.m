
#import "DataSettingsPush.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "FeedsTableDataSource.h"

@implementation DataSettingsPush

@synthesize feeds;
@synthesize pushSettings;

- (id)initWithArray:(NSMutableArray *)array pushSettings:(NSMutableDictionary *)pushSettingsDict {
  self.feeds = array;
  self.pushSettings = pushSettingsDict;
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
  if ([(NSString *)[[pushSettings objectForKey:cell.textLabel.text] objectForKey:@"status"] isEqualToString:@"enabled"])
    [switchView setOn:YES animated:NO];
  [switchView setTag:[indexPath row]];
  [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
  [switchView release];   
  
	return cell;
}

- (void)switchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updatePushSettingsThread:) toTarget:self withObject:switchView];  
}

- (void)updatePushSettingsThread:(UISwitch *)switchView {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableDictionary *feed = [feeds objectAtIndex:switchView.tag];
  NSString *name = [feed objectForKey:@"name"];

  NSString *feed_key = [[pushSettings objectForKey:name] objectForKey:@"feed_key"];

  
  if (switchView.on) {
    NSMutableDictionary *tab = [pushSettings objectForKey:name];
    [tab setObject:@"enabled" forKey:@"status"];
    [pushSettings setObject:tab forKey:name];

    [APIGateway updatePushSetting:feed_key status:@"enabled"];
  }
  else {
    NSMutableDictionary *tab = [pushSettings objectForKey:name];
    [tab setObject:@"disabled" forKey:@"status"];
    [pushSettings setObject:tab forKey:name];
    
    [APIGateway updatePushSetting:feed_key status:@"disabled"];
  }
  
  [autoreleasepool release];
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
