#import "TTTableYammerViewDelegate.h"
#import "MessageDetail.h"
#import "MainTabBar.h"
#import "FeedMessageList.h"
#import "SpinnerWithTextCell.h"
#import "TTTableYammerItem.h"

@implementation TTTableYammerViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

  if ([object isKindOfClass:[SpinnerWithTextItem class]])
    return;

  if (indexPath.section == 0) {
    
    if (indexPath.row > 20 && ((FeedMessageList*)_controller).isChecking)
      return;
    
    TTTableYammerItem* item = (TTTableYammerItem*)object;
    
    if (item.threading) {
      
      FeedDictionary *feed = [FeedDictionary dictionary];
      
      [feed setObject:[item.message objectForKey:@"thread_url"] forKey:@"url"];
      [feed setObject:@"true" forKey:@"isThread"];
      
      FeedMessageList *view = [[FeedMessageList alloc] initWithFeed:feed refresh:NO compose:NO thread:YES];
      view.title = @"Thread";
      [_controller.navigationController pushViewController:view animated:YES];      
    } else {      
      BOOL isThread = (((FeedMessageList*)_controller).isThread);
      MessageDetail* md = [[[MessageDetail alloc] initWithDataSource:_controller.dataSource index:indexPath.row thread:isThread] autorelease];
      [_controller.navigationController pushViewController:md animated:YES];
    }
    
  } else {
    TTTableMoreButton *more = (TTTableMoreButton *)object;
    more.isLoading = YES;
    TTTableMoreButtonCell* cell = (TTTableMoreButtonCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.animating = YES;    
    
    [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:_controller withObject:nil];
  }
}
  
@end
