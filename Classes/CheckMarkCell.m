
#import "CheckMarkCell.h"

@implementation CheckMarkTTTableTextItem
@synthesize isChecked;
+ (CheckMarkTTTableTextItem*)text:(NSString*)text isChecked:(BOOL)isChecked {
  CheckMarkTTTableTextItem* item = [CheckMarkTTTableTextItem itemWithText:text URL:@"1"];
  item.isChecked = isChecked;
  return item;
}
@end

@implementation CheckMarkCell
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];
    
    CheckMarkTTTableTextItem* item = object;
    
    if (item.isChecked)
      self.accessoryType = UITableViewCellAccessoryCheckmark;
    else
      self.accessoryType = UITableViewCellAccessoryNone;
  }
}
@end

@implementation CheckMarkDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  return [CheckMarkCell class];
}
@end