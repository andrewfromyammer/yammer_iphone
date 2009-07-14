
#import <Foundation/Foundation.h>

@interface DataSettingsHomeFeed : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
}

@property (nonatomic,retain) NSMutableArray *feeds;

- (id)initWithArray:(NSMutableArray *)array;
+ (DataSettingsHomeFeed *)getFeeds:(NSMutableDictionary *)dict;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
