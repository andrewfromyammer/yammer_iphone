
#import "DataSettingsPush.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "FeedsTableDataSource.h"

@implementation DataSettingsPush

@synthesize feeds;
@synthesize pushSettings;
@synthesize notificationDict;

- (id)initWithArray:(NSMutableArray *)theFeeds notificationDict:(NSMutableDictionary *)theNotificationDict pushSettings:(NSMutableDictionary *)thePushSettings {
  self.feeds = theFeeds;
  self.pushSettings = thePushSettings;
  self.notificationDict = theNotificationDict;
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return 1;

  if (section == 1)
    return 2;
  
  if (section == 2)
  	return [feeds count];
  
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  cell.accessoryType = UITableViewCellAccessoryNone;

  if (indexPath.section == 2) {
    [FeedsTableDataSource setupCell:cell dict:[feeds objectAtIndex:indexPath.row]];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    if ([(NSString *)[[notificationDict objectForKey:cell.textLabel.text] objectForKey:@"status"] isEqualToString:@"enabled"])
      [switchView setOn:YES animated:NO];
    [switchView setTag:[indexPath row]];
    [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView release];   
  } else if (indexPath.section == 1) {
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0)
      cell.textLabel.text = @"Turn off at:";
    else
      cell.textLabel.text = @"Turn back on at:";
  } else if (indexPath.section == 0) {
    cell.imageView.image = nil;
    cell.textLabel.text = @"Sound";
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    NSObject *protocol = [pushSettings objectForKey:@"protocol"];
    if ([protocol isKindOfClass:[NSNull class]] == false && [(NSString *)protocol isEqualToString:@"sound"])
      [switchView setOn:YES animated:NO];
    [switchView addTarget:self action:@selector(soundSwitchWasChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView release];
  }
  
	return cell;
}

- (void)soundSwitchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updateSoundPushSettingsThread:) toTarget:self withObject:switchView];  
}

- (void)switchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updatePushSettingsThread:) toTarget:self withObject:switchView];  
}

- (void)updateSoundPushSettingsThread:(UISwitch *)switchView {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if (switchView.on) {
    [pushSettings setObject:@"sound" forKey:@"protocol"];
    [APIGateway updatePushProtocol:@"sound" theId:[pushSettings objectForKey:@"id"]];
  }
  else {
    [pushSettings setObject:@"text" forKey:@"protocol"];
    [APIGateway updatePushProtocol:@"text" theId:[pushSettings objectForKey:@"id"]];
  }
  
  [autoreleasepool release];
}

- (void)updatePushSettingsThread:(UISwitch *)switchView {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableDictionary *feed = [feeds objectAtIndex:switchView.tag];
  NSString *name = [feed objectForKey:@"name"];

  NSString *feed_key = [[notificationDict objectForKey:name] objectForKey:@"feed_key"];

  
  if (switchView.on) {
    NSMutableDictionary *tab = [notificationDict objectForKey:name];
    [tab setObject:@"enabled" forKey:@"status"];
    [notificationDict setObject:tab forKey:name];

    [APIGateway updatePushSetting:feed_key status:@"enabled" theId:[pushSettings objectForKey:@"id"]];
  }
  else {
    NSMutableDictionary *tab = [notificationDict objectForKey:name];
    [tab setObject:@"disabled" forKey:@"status"];
    [notificationDict setObject:tab forKey:name];
    
    [APIGateway updatePushSetting:feed_key status:@"disabled" theId:[pushSettings objectForKey:@"id"]];
  }
  
  [autoreleasepool release];
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [notificationDict release];
  [pushSettings release];
  [super dealloc];
}

@end
