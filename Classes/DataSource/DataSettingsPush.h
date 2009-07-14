
#import <Foundation/Foundation.h>

@interface DataSettingsPush : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
}

@property (nonatomic,retain) NSMutableArray *feeds;

- (id)initWithArray:(NSMutableArray *)array;
+ (DataSettingsPush *)getFeeds:(NSMutableDictionary *)dict;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
