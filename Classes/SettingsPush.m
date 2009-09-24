//
//  SettingsPush.m
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "SettingsPush.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "MainTabBar.h"

@implementation SettingsPush

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;
@synthesize timeChooser;
@synthesize picker;

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Push Settings";
    
    UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title=@"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
  }
  return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
	theTableView.delegate = self;  
  NSMutableArray *homeTabs = [APIGateway homeTabs];
  NSMutableArray *filteredHomeTabs = [NSMutableArray array];
  NSMutableDictionary *pushSettings = [APIGateway pushSettings];
    
  NSMutableArray *notifications = [pushSettings objectForKey:@"notifications"];
  NSMutableDictionary *notificationDict = [NSMutableDictionary dictionary];
  int i=0;
  for (i=0; i<[notifications count]; i++) {
    NSMutableDictionary *tab = [notifications objectAtIndex:i];
    [notificationDict setObject:tab forKey:[tab objectForKey:@"name"]];
  }
  for (i=0; i<[homeTabs count]; i++) {
    NSMutableDictionary *tab = (NSMutableDictionary *)[homeTabs objectAtIndex:i];
    if ([notificationDict objectForKey:[tab objectForKey:@"name"]])
      [filteredHomeTabs addObject:tab];
  }
  
  self.dataSource = [[DataSettingsPush alloc] initWithArray:filteredHomeTabs notificationDict:notificationDict pushSettings:pushSettings];
	theTableView.dataSource = self.dataSource;  
  self.view = theTableView;
  
  [super getData];
  [autoreleasepool release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (indexPath.section == 1 && indexPath.row > 0) {
    self.timeChooser = [UIViewController alloc];
    timeChooser.view.backgroundColor = [UIColor groupTableViewBackgroundColor];    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title=@"Save";
    back.target = self;
    timeChooser.navigationItem.rightBarButtonItem = back;
    
    self.picker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    picker.datePickerMode = UIDatePickerModeTime;
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    [matter setDateFormat:@"HH"];

    [timeChooser.view addSubview:picker];

    if (indexPath.row == 1) {
      timeChooser.title = @"Stop Time";
      [picker setDate:[matter dateFromString:[[dataSource.pushSettings objectForKey:@"sleep_hour_start"] description]] animated:false];
      back.action = @selector(setStopTime);
    }
    else {
      timeChooser.title = @"Resume Time";
      [picker setDate:[matter dateFromString:[[dataSource.pushSettings objectForKey:@"sleep_hour_end"] description]] animated:false];
      back.action = @selector(setResumeTime);
    }

    UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:timeChooser];
    [modal.navigationBar setTintColor:[MainTabBar yammerGray]];

    [self presentModalViewController:modal animated:YES];
  }
}

- (void)setStopTime {
  NSDateFormatter *matter = [[NSDateFormatter alloc] init];
  [matter setDateFormat:@"HH"];  
  int hour = [[matter stringFromDate:[picker date]] intValue];
  [dataSource.pushSettings setObject:[[[NSNumber alloc] initWithInt:hour] autorelease] forKey:@"sleep_hour_start"];
  
  NSMutableArray *array = [NSMutableArray array];
  [array addObject:@"sleep_hour_start"];
  [array addObject:[matter stringFromDate:[picker date]]];
  [matter release];
  [NSThread detachNewThreadSelector:@selector(updateTime:) toTarget:self withObject:array]; 
  [timeChooser dismissModalViewControllerAnimated:YES];
  [timeChooser release];
  [picker release];
  [theTableView reloadData];
}

- (void)setResumeTime {
  NSDateFormatter *matter = [[NSDateFormatter alloc] init];
  [matter setDateFormat:@"HH"];  
  int hour = [[matter stringFromDate:[picker date]] intValue];
  [dataSource.pushSettings setObject:[[[NSNumber alloc] initWithInt:hour] autorelease] forKey:@"sleep_hour_end"];

  NSMutableArray *array = [NSMutableArray array];
  [array addObject:@"sleep_hour_end"];
  [array addObject:[matter stringFromDate:[picker date]]];
  
  [NSThread detachNewThreadSelector:@selector(updateTime:) toTarget:self withObject:array];
  [timeChooser dismissModalViewControllerAnimated:YES];
  [timeChooser release];
  [picker release];
  [theTableView reloadData];
}

- (void)updateTime:(NSMutableArray *)array {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [APIGateway updatePushField:[array objectAtIndex:0] value:[array objectAtIndex:1] theId:[dataSource.pushSettings objectForKey:@"id"]];  
  [autoreleasepool release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 40.0;
}

- (void)dealloc {
  [dataSource release];
  [theTableView release];
  [parent release];
  [timeChooser release];
  [picker release];
  [super dealloc];
}


@end
