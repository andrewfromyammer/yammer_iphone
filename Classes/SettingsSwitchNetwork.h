#import <Three20/Three20.h>

@interface SettingsSwitchNetwork : TTTableViewController {

}

- (TTListDataSource*)sourceFromArray:(NSMutableArray*)array;
- (void)madeSelection:(int)row;

@end
