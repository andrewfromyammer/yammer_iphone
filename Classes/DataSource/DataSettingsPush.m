
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
    return 2;

  if (section == 1)
    return 3;
  
  if (section == 2)
  	return [feeds count]+1;
  
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
  cell.textLabel.numberOfLines = 1;
  cell.accessoryView = nil;
  
  if (indexPath.section == 2) {
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageNamed:@"push_feeds.png"];
      cell.textLabel.font = [UIFont systemFontOfSize:12];
      cell.textLabel.text = @"You can choose which messages are pushed.  Select any or all of your feeds.";
      cell.textLabel.numberOfLines = 2;
    } else {      
      [FeedsTableDataSource setupCell:cell dict:[feeds objectAtIndex:indexPath.row-1]];
      
      UISwitch *switchView = [[UISwitch alloc] init];
      cell.accessoryView = switchView;
      [switchView setOn:NO animated:NO];
      if ([(NSString *)[[notificationDict objectForKey:cell.textLabel.text] objectForKey:@"status"] isEqualToString:@"enabled"])
        [switchView setOn:YES animated:NO];
      [switchView setTag:indexPath.row-1];
      [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
      [switchView release];   
    }
  } else if (indexPath.section == 1) {
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageNamed:@"sleep.png"];
      cell.textLabel.font = [UIFont systemFontOfSize:12];
      cell.textLabel.text = @"Push messages will stop during the night.  Timezone can be set on yammer.com.";
      cell.textLabel.numberOfLines = 2;
      cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == 1)
      cell.textLabel.text = [NSString stringWithFormat:@"Stop %@", [DataSettingsPush timeToAMPM:[pushSettings objectForKey:@"sleep_hour_start"]]];
    else
      cell.textLabel.text = [NSString stringWithFormat:@"Resume %@", [DataSettingsPush timeToAMPM:[pushSettings objectForKey:@"sleep_hour_end"]]];
  } else if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageNamed:@"note.png"];
      cell.textLabel.font = [UIFont systemFontOfSize:12];
      cell.textLabel.text = @"You can choose to have an audio sound alert play for each push message.";
      cell.textLabel.numberOfLines = 2;
    } else {
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
  }
  
	return cell;
}

+ (NSString *)timeToAMPM:(NSNumber *)time {
  int value = [time intValue];
  
  if (value == 0)
    return @"12:00 AM";
  if (value > 12) {
    value -= 12;
    return [NSString stringWithFormat:@"%d:00 PM", value];
  }
  
  return [NSString stringWithFormat:@"%d:00 AM", value];
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
    [APIGateway updatePushField:@"protocol" value:@"sound" theId:[pushSettings objectForKey:@"id"]];
  }
  else {
    [pushSettings setObject:@"text" forKey:@"protocol"];
    [APIGateway updatePushField:@"protocol" value:@"text" theId:[pushSettings objectForKey:@"id"]];
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
