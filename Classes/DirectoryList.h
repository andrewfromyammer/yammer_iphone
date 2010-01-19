#import <Three20/Three20.h>

@interface DirectoryList : TTTableViewController <UISearchBarDelegate> {
  int page;
}

@property int page;

- (void)handleUsers:(NSArray*)list source:(TTListDataSource*)source;
- (void)resetForNetworkSwitch;
- (void)refreshDirectory;
- (void)typeAheadThreadUpdate;

@end
