#import <Three20/Three20.h>

@interface FeedList : TTTableViewController { }

- (void)resetForNetworkSwitch;
- (void)refreshFeeds;

@end

@interface FeedTableImageItem : TTTableImageItem {}
@end

@interface FeedTableImageItemCell : TTTableImageItemCell {}
@end