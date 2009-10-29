#import <Three20/Three20.h>
#import "Settings.h"

@interface SettingsSwitchNetwork : TTTableViewController {
  Settings* _settingsReference;
}

@property (nonatomic,retain) Settings* settingsReference;

- (id)initWithControllerReference:(Settings*)settings;
- (TTListDataSource*)sourceFromArray:(NSMutableArray*)array;
- (void)madeSelection:(int)row;

@end
