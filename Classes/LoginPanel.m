
#import "LoginPanel.h"
#import "MainTabBar.h"
#import "YammerAppDelegate.h"

@interface LoginPanelDelegate : TTTableViewVarHeightDelegate;
@end

@implementation LoginPanelDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  //NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[yammer enterAppWithAccess];
}

@end

@implementation LoginPanel

- (id)init {
  if (self = [super init]) {
    self.variableHeightRows = YES;		
    self.navigationBarTintColor = [MainTabBar yammerGray];
		self.title = @"Welcome to Yammer!";
    _tableViewStyle = UITableViewStyleGrouped;
		[self.tableView setScrollEnabled:NO];
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		
		NSMutableArray* sections = [NSMutableArray array];
		NSMutableArray* items = [NSMutableArray array];
		
		[sections addObject:@""];
		[sections addObject:@""];
		[sections addObject:@""];
		
		NSMutableArray* section1 = [NSMutableArray array];
		[section1 addObject:[TTTableTextItem itemWithText:@"1" URL:nil]];
		[section1 addObject:[TTTableTextItem itemWithText:@"2" URL:nil]];
		[items addObject:section1];
				
		NSMutableArray* section2 = [NSMutableArray array];
		[section2 addObject:[TTTableTextItem itemWithText:@"Log in" URL:@"1"]];
		[items addObject:section2];
		
		NSMutableArray* section3 = [NSMutableArray array];
		[section3 addObject:[TTTableTextItem itemWithText:@"Create new Account" URL:@"1"]];
		[items addObject:section3];
				
		self.dataSource = [[TTSectionedDataSource alloc] initWithItems:items sections:sections];

  	self.tableView.frame = CGRectMake(0, 150, 320, 330);

	}  
  return self;
}


- (void)loadView {
  [super loadView];
	
	UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
	image.frame = CGRectMake(0, 0, 320, 460);
	[self.view addSubview:image];
	
	
}

- (id<UITableViewDelegate>)createDelegate {
  return [[LoginPanelDelegate alloc] initWithController:self];
}

@end
