#import <Three20/Three20.h>
#import "SpinnerWithTextCell.h"
#import "FeedDictionary.h"

@interface FeedMessageData : TTSectionedDataSource {
  NSString* feed;
  FeedDictionary* _feedDictionary;
  NSString* _nameField;
  NSMutableDictionary* _colorTheseMessageIDs;
}

@property(nonatomic,retain) NSString* feed;
@property(nonatomic,retain) NSString* nameField;
@property(nonatomic,retain) NSMutableDictionary* colorTheseMessageIDs;
@property(nonatomic,retain) FeedDictionary* feedDictionary;


+ (FeedMessageData*)feed:(FeedDictionary *)theFeed;
- (id)initWithFeed:(FeedDictionary *)theFeed items:(NSArray*)items;  

- (NSMutableDictionary*)proccesMessages:(NSMutableDictionary *)dict checkNew:(BOOL)checkNew newerThan:(NSNumber *)newerThan;
- (int)count;
- (void)fetch:(NSNumber *)offset;
- (NSMutableDictionary*)firstItem;
- (NSMutableDictionary*)lastObject;
- (NSMutableDictionary*)objectAtIndex:(int)index;
- (SpinnerWithTextItem*)spinnerItem;
- (void)removeAllColor;

@end
