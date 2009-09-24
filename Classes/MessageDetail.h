#import <Three20/Three20.h>
#import "FeedMessageData.h"

@interface MessageDetail : TTTableViewController {
  FeedMessageData* _messageData;
  UISegmentedControl* _upDown;
  UIToolbar* _toolbar;
  UIBarButtonItem* _user;
  UIBarButtonItem* _thread;
  int index;
  BOOL isThread;
}

@property(nonatomic,retain) FeedMessageData* messageData;
@property(nonatomic,retain) UISegmentedControl* upDown;
@property(nonatomic,retain) UIToolbar* toolbar;
@property(nonatomic,retain) UIBarButtonItem* user;
@property(nonatomic,retain) UIBarButtonItem* thread;
@property int index;
@property BOOL isThread;

- (id)initWithDataSource:(FeedMessageData*)theDataSource index:(int)theIndex thread:(BOOL)thread;
- (void)loadMessage;
- (void)loadImage:(NSDictionary*)attachment;

@end
