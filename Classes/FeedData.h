#import <Foundation/Foundation.h>

@interface FeedData : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
}

@property (nonatomic,retain) NSMutableArray *feeds;

- (id)initWithArray:(NSMutableArray *)array;
+ (FeedData *)getFeeds:(NSMutableDictionary *)dict;

+ (void)setupCell:(UITableViewCell *)cell dict:(NSMutableDictionary *)dict;
- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
