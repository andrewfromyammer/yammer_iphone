//
//  FeedMessageList.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedMessageList.h"
#import "FeedDataSource.h"
#import "MessageTableCell.h"
#import "MainTabBarController.h"
#import "APIGateway.h"
#import "MessageViewController.h"
#import "LocalStorage.h"
#import "SpinnerCell.h"

@implementation FeedMessageList

@synthesize theTableView;
@synthesize dataSource;
@synthesize feed;
@synthesize tableAndInput;
@synthesize input;
@synthesize textInput;
@synthesize threadIcon;
@synthesize homeTab;
@synthesize topSpinner;
@synthesize displayText;

- (id)initWithDict:(NSMutableDictionary *)dict textInput:(BOOL)showTextInput threadIcon:(BOOL)showThreadIcon homeTab:(BOOL)isHomeTab {
  self.feed = dict;
  self.title = [feed objectForKey:@"name"];
  self.textInput = showTextInput;
  self.threadIcon = showThreadIcon;
  self.homeTab = isHomeTab;
  [self addRefreshButton];
	return self;
}

- (NSString *)gray_text {
  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
    return [NSString stringWithFormat:@"Update %@", [feed objectForKey:@"name"]];
  return @"What are you working on?";
}

- (void)showTable {  
  self.topSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(80, 4, 20, 20)];
  self.topSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

  self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(110, 4, 200, 20)];
  self.displayText.textColor = [UIColor blueColor];
  self.displayText.font = [UIFont systemFontOfSize:12];
  
  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
  [line setBackgroundColor:[UIColor lightGrayColor]];
  [tableAndInput addSubview:self.displayText];
  [tableAndInput addSubview:line];
  [tableAndInput addSubview:theTableView];
  self.view = tableAndInput;
  
  [self topSpinnerShow];
}

- (void)topSpinnerShow {
  [self.displayText setText:@"Checking for new yams..."];
  [tableAndInput addSubview:self.topSpinner];
  [self.topSpinner startAnimating];
}
- (void)topSpinnerHide {
  [self.displayText setText:@"Updated 12:36 PM"];
  [self.topSpinner stopAnimating];
  [self.topSpinner removeFromSuperview];
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  self.tableAndInput = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  tableAndInput.backgroundColor = [UIColor whiteColor];
    
  theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 337) style:UITableViewStylePlain];  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [FeedDataSource getMessages:feed];  
	theTableView.dataSource = self.dataSource;
  [self showTable];
  [super getData];
  
  [NSThread detachNewThreadSelector:@selector(setStatus) toTarget:self withObject:nil];

  [autoreleasepool release];
}

- (void)setStatus {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if (self.dataSource.statusMessage == nil) {
    NSMutableDictionary *message = [dataSource.messages objectAtIndex:0];
    NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] newerThan:[message objectForKey:@"id"]];
    if (dict) {
      BOOL previousValue = dataSource.olderAvailable;
      NSMutableArray *messages = [dataSource proccesMessages:dict feed:feed];            
      dataSource.olderAvailable = previousValue;
      
      [dataSource processImages:messages];
      [messages addObjectsFromArray:dataSource.messages];
      dataSource.messages = messages;
      [theTableView reloadData];
    }
  }
  [self topSpinnerHide];  
  [autoreleasepool release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  theTableView.alpha = 0.15;
  input.textColor = [UIColor blackColor];
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Cancel";
  temporaryBarButtonItem.action = @selector(cleanUpInput);
  temporaryBarButtonItem.target = self;
  self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];  
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)cleanUpInput {
  [input setText:@""];
  [input resignFirstResponder];
  theTableView.alpha = 1.0;
  input.textColor = [MainTabBarController yammerGray];
  [input setText:[self gray_text]];
  [self addRefreshButton];  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  self.view = wrapper;
  self.navigationItem.leftBarButtonItem = nil;
  [spinner startAnimating];  
  [NSThread detachNewThreadSelector:@selector(sendUpdate) toTarget:self withObject:nil];
  return NO;
}

- (void)sendUpdate {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSDecimalNumber *groupId = nil;
  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
    groupId = [feed objectForKey:@"group_id"];
  [APIGateway createMessage:input.text repliedToId:nil groupId:groupId];
  [self cleanUpInput];
  [self getData];
  [autoreleasepool release];
}

- (void)refresh {
  if (homeTab) 
    self.feed = [LocalStorage getFeedInfo];
  [super refresh];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1)
    return 50.0;

  MessageTableCell *cell = (MessageTableCell *)[dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  if ([cell length] > 50)
    return 65.0;
  return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    MessageViewController *localMessageViewController = [[MessageViewController alloc] 
                                                         initWithBooleanForThreadIcon:threadIcon 
                                                         list:[dataSource messages] 
                                                         index:indexPath.row];
    [self.navigationController pushViewController:localMessageViewController animated:YES];
    [localMessageViewController release];
  } else {
    if ([dataSource.messages count] < 999) {
      SpinnerCell *cell = (SpinnerCell *)[tableView cellForRowAtIndexPath:indexPath];
      [cell showSpinner];
      [cell.displayText setText:@"Loading More..."];
      [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:self withObject:nil];
    }
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *message = [dataSource.messages objectAtIndex:[dataSource.messages count]-1];
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:[message objectForKey:@"id"]];
  if (dict) {
    NSMutableArray *messages = [dataSource proccesMessages:dict feed:feed];
    [dataSource processImages:messages];
    [dataSource.messages addObjectsFromArray:messages];
  }
  
  NSUInteger newIndex[] = {1, 0};
  NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
  SpinnerCell *cell = (SpinnerCell *)[theTableView cellForRowAtIndexPath:newPath];
  [newPath release];
  
  [cell hideSpinner];
  [cell displayMore];

  [theTableView reloadData];
  [autoreleasepool release];
}


- (void)dealloc {
  [theTableView release];
  [dataSource release];
  [feed release];
  [tableAndInput release];
  [input release];
  [super dealloc];
  
}

@end
