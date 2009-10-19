
#import "MessageDetail.h"
#import "MainTabBar.h"
#import "NSString+SBJSON.h"
#import "ComposeMessage.h"
#import "Message.h"
#import "FeedMessageList.h"
#import "TTTableYammerItem.h"
#import "SpinnerWithTextCell.h"
#import "FullSizePhoto.h"
#import "ImageCache.h"
#import "LocalStorage.h"
#import "APIGateway.h"

@interface MessageDetailDelegate : TTTableViewVarHeightDelegate;
@end

@implementation MessageDetailDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  
  if ([object isKindOfClass:[TTTableYammerItem class]])
    return;
  
  if ([object isKindOfClass:[TTTableImageItem class]]) {
    TTTableImageItem* item = (TTTableImageItem*)object;
    FullSizePhoto* view = [[[FullSizePhoto alloc] initWithAttachment:item.userInfo] autorelease];
    [_controller.navigationController pushViewController:view animated:YES];
  } else if ([object isKindOfClass:[TTTableTextItem class]]) {
    TTTableTextItem* item = (TTTableTextItem*)object;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.URL]];  
  }   
}

@end

@implementation MessageDetail

@synthesize messageData = _messageData, index, upDown = _upDown, toolbar = _toolbar, user = _user, thread = _thread, like = _like;
@synthesize isThread;

- (id<UITableViewDelegate>)createDelegate {
  return [[MessageDetailDelegate alloc] initWithController:self];
}

- (id)initWithDataSource:(FeedMessageData*)theDataSource index:(int)theIndex thread:(BOOL)thread {
  if (self = [super init]) {
    self.title = @"1 of 10";
    self.variableHeightRows = YES;
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.hidesBottomBarWhenPushed = YES;
    self.index = theIndex;
    self.isThread = thread;
    
    self.toolbar = [UIToolbar new];
    self.upDown = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"arrow_up.png"], 
                                                                   [UIImage imageNamed:@"arrow_down.png"], nil]];
    _upDown.momentary = true;
    [_upDown setTintColor:[MainTabBar yammerGray]];
    _upDown.segmentedControlStyle = UISegmentedControlStyleBar;
    UIBarButtonItem *localUIBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_upDown];
    [_upDown addTarget:self action:@selector(upDownClicked) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = localUIBarButtonItem;
    [localUIBarButtonItem release];
    
    self.messageData = theDataSource;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.frame = CGRectMake(0, 0, 320, 359);

    [self loadMessage];
  }
  return self;
}

- (void)loadMessage {
  NSMutableDictionary* m = [_messageData objectAtIndex:index];
  
  NSString *safeText = [[[[m objectForKey:@"plain_body"] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                         stringByReplacingOccurrencesOfString:@">" withString:@""] 
                        stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
  TTStyledText* fullText = [TTStyledText textFromXHTML:safeText lineBreaks:YES URLs:YES];    
  TTTableStyledTextItem* fullTextItem = [TTTableStyledTextItem itemWithText:fullText URL:nil];
  
  SpinnerListDataSource* list = [[[SpinnerListDataSource alloc] init] autorelease];
    
  TTTableYammerItem* item = [TTTableYammerItem itemWithMessage:m];
  item.isDetail = YES;
  item.threading = NO;
  item.URL = nil;
  [list.items addObject: item];  
  [list.items addObject:fullTextItem];

  NSMutableArray *attachments = (NSMutableArray *)[[m objectForKey:@"attachments_json"] JSONValue];

  int i=0;
  
  if ([attachments count] > 0) 
    [list.items addObject:[TTTableTextItem itemWithText:@"Attachment(s)" URL:nil]];

  for (i=0; i<[attachments count]; i++) {
    NSMutableDictionary *attachment = [attachments objectAtIndex:i];
    
    if ([[attachment objectForKey:@"type"] isEqualToString:@"image"]) {
      TTTableImageItem* image = [TTTableImageItem itemWithText:[attachment objectForKey:@"name"] imageURL:@"bundle://thumbnail_loading.png" URL:@"1"];
      image.userInfo = attachment;
      [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:attachment];  

      [list.items addObject:image];
    } else {
      
      TTTableTextItem* file = [TTTableTextItem itemWithText:[attachment objectForKey:@"name"] URL:[attachment objectForKey:@"web_url"]];
      [list.items addObject:file];
    }
    
    /*    [buff appendString:@"<p>"];
     [buff appendString:@"<img src=\""];
     [buff appendString:[OAuthGateway baseURL]];
     [buff appendString:@"/images/paperclip.gif\"> <a href=\""];
     [buff appendString:[attachment objectForKey:@"web_url"]];
     [buff appendString:@"\">"];
     [buff appendString:[attachment objectForKey:@"name"]];
     [buff appendString:@"</a></p>"]; */
  }
  
  self.dataSource = list;
  self.title = [NSString stringWithFormat:@"%d of %d", index, [_messageData count]];
  
  if ([[m objectForKey:@"actor_type"] isEqualToString:@"user"])
    [_user setEnabled:YES];
  else
    [_user setEnabled:NO];
  if (isThread)
    [_thread setEnabled:NO];
  else
    [_thread setEnabled:YES];
}

- (void)loadImage:(NSDictionary*)attachment {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  NSData* data;
  @synchronized ([UIApplication sharedApplication]) {
    sleep(1);
    data = [ImageCache getOrLoadImage:attachment key:@"thumbnail_url" path:ATTACHMENT_THUMBNAILS];
  }
  if (data) {
    UIImage* image = [UIImage imageWithData:data];
    
    SpinnerListDataSource* source = (SpinnerListDataSource*)self.dataSource;
    for (int i=0; i<[source.items count]; i++) {
      NSObject* object = [source.items objectAtIndex:i];
      if (![object isKindOfClass:[TTTableImageItem class]])
        continue;
      TTTableImageItem* item = (TTTableImageItem*)object;
      if ([[item.userInfo objectForKey:@"id"] longValue] == [[attachment objectForKey:@"id"] longValue]) {
        item.defaultImage = image;
        item.imageURL = @"";        
        break;
      }
    }
  }

  [self performSelectorOnMainThread:@selector(doShowModel)
                         withObject:nil
                      waitUntilDone:YES];
  [autoreleasepool release];
}

- (void)doShowModel {
  [self showModel:YES];
}

- (void)upDownClicked {
  if ([_upDown selectedSegmentIndex] == 1)
    index++;
  else
    index--;
  
  if (index == 0)
    index = 1;
  
  if (index == [_messageData count] + 1)
    index = [_messageData count];
  [self loadMessage];
}

- (void)loadView {
  [super loadView];
  
  _toolbar.barStyle = UIBarStyleDefault;
  [_toolbar setTintColor:[MainTabBar yammerGray]];
  
  [_toolbar sizeToFit];
  [_toolbar setFrame:CGRectMake(0, 372, 320, 45)];
  
  UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                         target:self
                                                                         action:@selector(reply)];
  
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];  
  
  self.like = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"smile_gray.png"]
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(toggleLike)];

  self.thread = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thread_gray.png"]
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(threadView)];  
  
  self.user = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_gray.png"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self //[[UIApplication sharedApplication] delegate]
                                                          action:@selector(userView)];
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: reply, flexItem, _like, flexItem, _thread, flexItem, _user, nil];

  [_user setEnabled:false];
  [_thread setEnabled:false];
  [_toolbar setItems:items animated:NO];
  
  [self.view addSubview:_toolbar];
  
}

- (void)reply {
  NSMutableDictionary *m = [_messageData objectAtIndex:index];
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  
  [meta setObject:[m objectForKey:@"message_id"] forKey:@"replied_to_id"];
  [meta setObject:[NSString stringWithFormat:@"Re: %@", [m objectForKey:@"sender"]] forKey:@"display"];
  
  [self presentModalViewController:[ComposeMessage getNav:meta] animated:YES];
}

- (void)toggleLike {
  NSMutableDictionary *m = [_messageData objectAtIndex:index];
  int likes = [[m objectForKey:@"likes"] intValue];
  BOOL liked_by_me;
  
  if ([[m objectForKey:@"liked_by_me"] boolValue]) {
    if ([APIGateway unlikeMessage:[m objectForKey:@"message_id"]]) {
      likes--;
      liked_by_me = NO;
    }
  }
  else {
    if ([APIGateway likeMessage:[m objectForKey:@"message_id"]]) {
      likes++;
      liked_by_me = YES;
    }
  }
  
  [m setObject:[NSNumber numberWithBool:liked_by_me] forKey:@"liked_by_me"];  
  [m setObject:[NSNumber numberWithInt:likes] forKey:@"likes"];
  [FeedCache fetchAndUpdateMessage:m];
  [self loadMessage];
}

- (void)threadView {
  NSMutableDictionary *m = [_messageData objectAtIndex:index];
  FeedDictionary *feed = [FeedDictionary dictionary];

  [feed setObject:[m objectForKey:@"thread_url"] forKey:@"url"];
  [feed setObject:@"true" forKey:@"isThread"];
  
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] initWithFeed:feed refresh:NO compose:NO thread:YES];
  localFeedMessageList.title = @"Thread";
  
  TTNavigator* nav = [TTNavigator navigator];
  [nav.visibleViewController.navigationController pushViewController:localFeedMessageList animated:YES];
  [localFeedMessageList release];
}

- (void)userView {
  NSMutableDictionary *m = [_messageData objectAtIndex:index];
  
  NSString* url = [NSString stringWithFormat:@"yammer://user?id=%@&feed=true", [[m objectForKey:@"actor_id"] description]];
  [[TTNavigator navigator] openURL:url animated:YES];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_messageData);
  TT_RELEASE_SAFELY(_upDown);
  TT_RELEASE_SAFELY(_toolbar);
  TT_RELEASE_SAFELY(_user);
  TT_RELEASE_SAFELY(_thread);
  TT_RELEASE_SAFELY(_like);  
  [super dealloc];
}


@end
