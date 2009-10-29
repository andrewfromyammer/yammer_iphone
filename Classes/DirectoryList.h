#import <Three20/Three20.h>

@interface DirectoryList : TTTableViewController <TTSearchTextFieldDelegate> {
  int page;
}

@property int page;

- (void)handleUsers:(NSArray*)list source:(TTListDataSource*)source;
- (void)resetForNetworkSwitch;

@end
