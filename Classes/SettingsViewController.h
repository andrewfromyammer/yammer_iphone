#import <Three20/Three20.h>

#import "SpinnerViewController.h"
#import "DataSettings.h"

@interface SettingsViewController : TTViewController <UITableViewDelegate> {
	UITableView *theTableView;
  NSMutableDictionary *usersCurrent;
  DataSettings *dataSource;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *usersCurrent;
@property (nonatomic,retain) DataSettings *dataSource;

@end
