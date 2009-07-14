#import <UIKit/UIKit.h>
#import "DataSettingsHomeFeed.h"
#import "SettingsViewController.h"

@interface SettingsHomeFeed : UIViewController <UITableViewDelegate> {
  UITableView *theTableView;
  DataSettingsHomeFeed *dataSource;
  SettingsViewController *parent;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) DataSettingsHomeFeed *dataSource;
@property (nonatomic,retain) SettingsViewController *parent;

- (id)initWithDict:(NSMutableDictionary *)dict parent:(SettingsViewController *)view;

@end
