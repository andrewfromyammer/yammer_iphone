
#import "DataSettingsPush.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "FeedData.h"

@implementation DataSettingsPush

@synthesize feeds;
@synthesize pushSettings;
@synthesize notificationDict;

- (id)initWithArray:(NSMutableArray *)theFeeds notificationDict:(NSMutableDictionary *)theNotificationDict pushSettings:(NSMutableDictionary *)thePushSettings {
  self.feeds = theFeeds;
  self.pushSettings = thePushSettings;
  //sleep_enabled
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
    return 3;
  
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
  cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
  cell.textLabel.numberOfLines = 1;
  cell.accessoryView = nil;
  [cell.contentView removeAllSubviews];
  
  if (indexPath.section == 2) {
    [FeedData setupCell:cell dict:[feeds objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    if ([(NSString *)[[notificationDict objectForKey:cell.textLabel.text] objectForKey:@"status"] isEqualToString:@"enabled"])
      [switchView setOn:YES animated:NO];
    [switchView setTag:indexPath.row];
    [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView release];   
  } else if (indexPath.section == 1) {
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = @"Quiet Hours";
      cell.imageView.image = [UIImage imageNamed:@"sleep.png"];
      cell.accessoryType = UITableViewCellAccessoryNone;

      UISwitch *switchView = [[UISwitch alloc] init];
      cell.accessoryView = switchView;
      [switchView setOn:NO animated:NO];
      if ([[pushSettings objectForKey:@"sleep_enabled"] boolValue])
        [switchView setOn:YES animated:NO];
      [switchView addTarget:self action:@selector(quietSwitchWasChanged:) forControlEvents:UIControlEventValueChanged];
      [switchView release];
    }
    else {
      UILabel* mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6.0, 260.0, 25.0)] autorelease];
      mainLabel.font = [UIFont boldSystemFontOfSize:16.0];
      mainLabel.textAlignment = UITextAlignmentLeft;
      mainLabel.textColor = [UIColor blackColor];

      mainLabel.text = @"Stop Notifications";
      if (indexPath.row == 2)
        mainLabel.text = @"Resume Notifications";        

      [cell.contentView addSubview:mainLabel];
      
      UILabel* secondLabel = [[[UILabel alloc] initWithFrame:CGRectMake(190.0, 6.0, 80.0, 25.0)] autorelease];
      secondLabel.font = [UIFont systemFontOfSize:14.0];
      secondLabel.textAlignment = UITextAlignmentRight;
      secondLabel.textColor = [UIColor blueColor];
      secondLabel.text = [DataSettingsPush timeToAMPM:[pushSettings objectForKey:@"sleep_hour_start"]];
      if (indexPath.row == 2)
        secondLabel.text = [DataSettingsPush timeToAMPM:[pushSettings objectForKey:@"sleep_hour_end"]];
      [cell.contentView addSubview:secondLabel];
      cell.textLabel.text = nil;
    }
  } else if (indexPath.section == 0) {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"note.png"];
    cell.textLabel.text = @"Sounds";
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0)
    return @"Play notification sounds:";
  if (section == 1)
    return @"Quiet notifications:";
  if (section == 2)
    return @"Select which feeds:";
  
  return nil;
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

- (void)quietSwitchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updateQuietPushSettingsThread:) toTarget:self withObject:switchView];  
}
- (void)soundSwitchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updateSoundPushSettingsThread:) toTarget:self withObject:switchView];  
}

- (void)switchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  [NSThread detachNewThreadSelector:@selector(updatePushSettingsThread:) toTarget:self withObject:switchView];  
}

- (void)updateQuietPushSettingsThread:(UISwitch *)switchView {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if (switchView.on) {
    [pushSettings setObject:[NSNumber numberWithBool:YES] forKey:@"sleep_enabled"];
    [APIGateway updatePushField:@"sleep_enabled" value:@"1" theId:[pushSettings objectForKey:@"id"]];
  }
  else {
    [pushSettings setObject:[NSNumber numberWithBool:NO] forKey:@"sleep_enabled"];
    [APIGateway updatePushField:@"sleep_enabled" value:@"0" theId:[pushSettings objectForKey:@"id"]];
  }
  
  [autoreleasepool release];
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
