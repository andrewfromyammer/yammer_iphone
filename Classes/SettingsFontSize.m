
#import "SettingsFontSize.h"
#import "MainTabBar.h"
#import "NSString+SBJSON.h"
#import "LocalStorage.h"
#import "YammerAppDelegate.h"
#import "CheckMarkCell.h"

@interface FontSizeDelegate : TTTableViewVarHeightDelegate;
@end

@implementation FontSizeDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  CheckMarkTTTableTextItem* object = (CheckMarkTTTableTextItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

  SettingsFontSize* view = (SettingsFontSize*)[_controller.navigationController visibleViewController];
  CheckMarkDataSource* dataSource = (CheckMarkDataSource*)view.dataSource;
  
  for (CheckMarkTTTableTextItem* item in [dataSource.items objectAtIndex:0])
    item.isChecked = NO;
    
  object.isChecked = YES;
  
  [LocalStorage saveSetting:@"font_size" value:object.text];
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  yammer.fontSize = object.text;
  [view.settingsReference showModel:YES];
  [yammer reloadForFontSizeChange];
  
  [view showModel:YES];
}

@end

@implementation SettingsFontSize

@synthesize settingsReference = _settingsReference;

- (id)initWithControllerReference:(Settings*)settings {
  if (self = [super init]) {
    self.settingsReference = settings;
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Font Size";
    
    _tableViewStyle = UITableViewStyleGrouped;    
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* items = [NSMutableArray array];
    NSMutableArray* section = [NSMutableArray array];
    
    [section addObject:[CheckMarkTTTableTextItem text:@"Small" isChecked:[[LocalStorage fontSize] isEqualToString:@"Small"]]];  
    [section addObject:[CheckMarkTTTableTextItem text:@"Large" isChecked:[[LocalStorage fontSize] isEqualToString:@"Large"]]];  
     
    [sections addObject:@""];
    [items addObject:section];
    self.dataSource = [[CheckMarkDataSource alloc] initWithItems:items sections:sections];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_settingsReference);
  [super dealloc];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[FontSizeDelegate alloc] initWithController:self];
}
  
- (void)madeSelection:(int)row {
  //[NSThread detachNewThreadSelector:@selector(setTheSize:) toTarget:self withObject:[NSNumber numberWithInt:row]];  
}

- (void)setTheSize:(NSNumber*)index {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  usleep(500000);
  
  [yammer settingsToRootView];
  
  
  [autoreleasepool release];
}


@end
