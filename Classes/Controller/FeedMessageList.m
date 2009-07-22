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

  if (textInput) {
    UIView *topLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 327)];
    [topLayer setBackgroundColor:[UIColor whiteColor]];
    [topLayer addSubview:theTableView];
    [tableAndInput addSubview:topLayer];
    self.view = tableAndInput;
  } else {
    self.view = theTableView;
  }
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  self.tableAndInput = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  tableAndInput.backgroundColor = [UIColor whiteColor];
  
  CGRect frame = [[UIScreen mainScreen] applicationFrame]; 
  if (textInput) {
    frame = CGRectMake(0, 0, 320, 327);
    input = [[UITextField alloc] initWithFrame:CGRectMake(5, 6, 310, 27)];
    input.backgroundColor = [MainTabBarController yammerBlue];
    tableAndInput.backgroundColor = [MainTabBarController yammerBlue];
    input.borderStyle = UITextBorderStyleRoundedRect;
    input.textColor = [MainTabBarController yammerGray];
    input.clearsOnBeginEditing = YES;
    input.returnKeyType = UIReturnKeySend;
    [input setText:[self gray_text]];
    input.delegate = self;    
    [tableAndInput addSubview:input];
  }
  
  theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [FeedDataSource getMessages:feed];
	theTableView.dataSource = self.dataSource;
  
  [self showTable];
  [super getData];
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
      [cell.spinner startAnimating];
      [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:self withObject:nil];
    }
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *message = [dataSource.messages objectAtIndex:[dataSource.messages count]-1];
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:[message objectForKey:@"id"]];
  //if (dict)
  //  [dataSource proccesMessages:dict feed:[feed objectForKey:@"url"] cache:false];
  //[theTableView reloadData];
  
  self.dataSource.fetchingMore = false;
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
