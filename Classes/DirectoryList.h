#import <Three20/Three20.h>

@interface DirectoryList : TTTableViewController <UISearchBarDelegate> {
  int page;
  NSString* _currentString;
  NSString* _lastString;
  NSThread* _searchThread;
}

@property int page;
@property (nonatomic,retain) NSString* lastString;
@property (nonatomic,retain) NSThread* searchThread;
@property (nonatomic,retain) NSString* currentString;

- (void)handleUsers:(NSArray*)list source:(TTListDataSource*)source;
- (void)resetForNetworkSwitch;
- (void)refreshDirectory;
- (void)typeAheadThreadUpdate;

@end
