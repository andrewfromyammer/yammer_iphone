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
#import "ComposeYamController.h"

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

- (id)initWithDict:(NSMutableDictionary *)dict textInput:(BOOL)showTextInput threadIcon:(BOOL)showThreadIcon homeTab:(BOOL)isHomeTab {
  self.feed = dict;
  self.title = [feed objectForKey:@"name"];
  self.textInput = showTextInput;
  self.threadIcon = showThreadIcon;
  self.homeTab = isHomeTab;
  [self addComposeButton];
	return self;
}

- (NSString *)gray_text {
  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
    return [NSString stringWithFormat:@"Update %@", [feed objectForKey:@"name"]];
  return @"What are you working on?";
}

- (void)showTable {  
  self.topSpinner = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    
  [tableAndInput addSubview:self.topSpinner];
  [tableAndInput addSubview:theTableView];
  self.view = tableAndInput;
  
  [topSpinner showTheSpinner:@"Checking for new messages..."];
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
  [self.topSpinner hideTheSpinner:@"Updated 12:34 PM"];
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
  [self addComposeButton];  
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

- (void)compose {
  ComposeYamController *compose = [[ComposeYamController alloc] initWithSpinner:self.topSpinner];
  UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:compose];
  [modal.navigationBar setTintColor:[MainTabBarController yammerGray]];

  [self presentModalViewController:modal animated:YES];
  
  // MyViewController *modalViewController = [[[MyModalViewController alloc] initWithNibName:nil bundle:nil] autorelease];
  //[[self firstNavigationController] presentModalViewController:secondNavigationController animated:YES];
  
//  [NTLNTweetPostViewController dismiss];
//	NTLNTweetPostViewController *vc = [[[NTLNTweetPostViewController alloc] init] autorelease];
//	[parentViewController presentModalViewController:vc animated:NO];
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
