#import <Three20/Three20.h>
#import "FeedDictionary.h"

@interface FeedMessageList : TTTableViewController {
  FeedDictionary* feed;
  int curOffset;
  BOOL isChecking;
  BOOL isThread;
  int lastNumMessages;  
}

@property(nonatomic,retain) FeedDictionary* feed;
@property int curOffset;
@property int lastNumMessages;
@property BOOL isChecking;
@property BOOL isThread;

- (id)initWithFeed:(FeedDictionary*)theFeed refresh:(BOOL)refresh compose:(BOOL)compose thread:(BOOL)thread;
- (void)refreshFeed;
- (void)replaceFeed;
- (void)refreshFeedClick;

@end