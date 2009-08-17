
#import <Foundation/Foundation.h>

@interface DataSettingsPush : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
  NSMutableDictionary *notificationDict;
  NSMutableDictionary *pushSettings;
}

@property (nonatomic,retain) NSMutableArray *feeds;
@property (nonatomic,retain) NSMutableDictionary *notificationDict;
@property (nonatomic,retain) NSMutableDictionary *pushSettings;

- (id)initWithArray:(NSMutableArray *)theFeeds notificationDict:(NSMutableDictionary *)theNotificationDict pushSettings:(NSMutableDictionary *)thePushSettings;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
