#import <Three20/Three20.h>
#import "Settings.h"

@interface SettingsFontSize : TTTableViewController {
  Settings* _settingsReference;
}

@property (nonatomic,retain) Settings* settingsReference;

- (id)initWithControllerReference:(Settings*)settings;

@end
