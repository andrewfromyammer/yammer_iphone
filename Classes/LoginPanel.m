
#import "LoginPanel.h"
#import "MainTabBar.h"
#import "YammerAppDelegate.h"

@interface LoginCenterButtonItem : TTTableTextItem;
@end

@implementation LoginCenterButtonItem
@end

@interface LoginCenterButtonCell : TTTableTextItemCell {
  UILabel* _myLabel;
}
@property (nonatomic, retain) UILabel *myLabel;

@end

@implementation LoginCenterButtonCell
@synthesize myLabel = _myLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 275, 30)];
		_myLabel.textAlignment = UITextAlignmentCenter;
    _myLabel.font = [UIFont boldSystemFontOfSize:16];
		
    [self.contentView addSubview:_myLabel];
  }
  return self;
}


- (void)setObject:(id)object {
  if (_item != object) {
    
    LoginCenterButtonItem* item = object;
    
		_myLabel.text = item.text;
	  self.accessoryType = UITableViewCellAccessoryNone;
  }
}

- (void)dealloc {
  [super dealloc];
  TT_RELEASE_SAFELY(_myLabel);
}
@end

@interface LoginTextFieldItem : TTTableTextItem {
	BOOL isSecure;
}
@property BOOL isSecure;

+ (LoginTextFieldItem*)text:(NSString*)text isSecure:(BOOL)isSecure;

@end

@implementation LoginTextFieldItem
@synthesize isSecure;
+ (LoginTextFieldItem*)text:(NSString*)text isSecure:(BOOL)isSecure {
  LoginTextFieldItem* item = [LoginTextFieldItem itemWithText:text URL:nil];
  item.isSecure = isSecure;
  return item;
}
@end

@interface LoginTextFieldCell : TTTableTextItemCell <UITextFieldDelegate> {
	UITextField* _myField;
}
@property (nonatomic, retain) UITextField *myField;

@end

static UITextField* theEmail = nil;
static UITextField* thePassword = nil;

@implementation LoginTextFieldCell
@synthesize myField = _myField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _myField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 275, 30)];
		[_myField setKeyboardType:UIKeyboardTypeEmailAddress];
    _myField.font = [UIFont systemFontOfSize:14];
		_myField.delegate = self;
		_myField.secureTextEntry = NO;
    [self.contentView addSubview:_myField];
  }
  return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([thePassword isFirstResponder]) {
		[thePassword resignFirstResponder];
	}
	else
	  [thePassword becomeFirstResponder];
	
  return NO;
}

- (void)setObject:(id)object {
  if (_item != object) {
    
    LoginTextFieldItem* item = (LoginTextFieldItem*)object;
    
		_myField.placeholder = item.text;
		_myField.secureTextEntry = item.isSecure;
		
		if (item.isSecure) {
			thePassword = _myField;
  		_myField.returnKeyType = UIReturnKeyDone;
		}
	  else {
			theEmail = _myField;
      _myField.returnKeyType = UIReturnKeyNext;
		}
		
	  self.accessoryType = UITableViewCellAccessoryNone;
  }
}

- (void)dealloc {
  [super dealloc];
  TT_RELEASE_SAFELY(_myField);
}
@end


@interface LoginPanelDataSource : TTSectionedDataSource;
@end

@implementation LoginPanelDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[LoginCenterButtonItem class]])
    return [LoginCenterButtonCell class];
  if ([object isKindOfClass:[LoginTextFieldItem class]])
    return [LoginTextFieldCell class];
	
  return [super tableView:tableView cellClassForObject:object];
}
@end


@interface LoginPanelDelegate : TTTableViewVarHeightDelegate;
@end

@implementation LoginPanelDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSObject* object = [_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	
  if ([object isKindOfClass:[LoginCenterButtonItem class]]) {
    YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
	  [yammer enterAppWithAccess];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return 20.0;
	if (section == 1)
		return 0.0;
	return 30.0;
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
		
		[sections addObject:@" "];
		[sections addObject:@" "];
		[sections addObject:@" "];
		
		NSMutableArray* section1 = [NSMutableArray array];
		[section1 addObject:[LoginTextFieldItem text:@"Email" isSecure:NO]];
		[section1 addObject:[LoginTextFieldItem text:@"Password" isSecure:YES]];
		[items addObject:section1];
				
		NSMutableArray* section2 = [NSMutableArray array];
		[section2 addObject:[LoginCenterButtonItem itemWithText:@"Log In" URL:@"1"]];
		[items addObject:section2];
		
		NSMutableArray* section3 = [NSMutableArray array];
		[section3 addObject:[LoginCenterButtonItem itemWithText:@"Create New Account" URL:@"1"]];
		[items addObject:section3];
				
		self.dataSource = [[LoginPanelDataSource alloc] initWithItems:items sections:sections];
	}  
  return self;
}



- (void)loadView {
  [super loadView];
	
	UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
	image.frame = CGRectMake(0, 0, 320, 417);
	[self.view addSubview:image];
	
	
}

- (id<UITableViewDelegate>)createDelegate {
  return [[LoginPanelDelegate alloc] initWithController:self];
}

@end
