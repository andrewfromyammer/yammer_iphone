
#import <Foundation/Foundation.h>

@interface DataSettingsPush : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
  NSMutableDictionary *pushSettings;
}

@property (nonatomic,retain) NSMutableArray *feeds;
@property (nonatomic,retain) NSMutableDictionary *pushSettings;

- (id)initWithArray:(NSMutableArray *)array pushSettings:(NSMutableDictionary *)pushSettingsDict;
+ (DataSettingsPush *)getFeeds:(NSMutableDictionary *)dict pushSettings:(NSMutableDictionary *)pushSettingsDict;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
