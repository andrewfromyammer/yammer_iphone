
#import "LoginPanel.h"
#import "MainTabBar.h"
#import "YammerAppDelegate.h"
#import "OAuthGateway.h"
#import "LocalStorage.h"
#import "APIGateway.h"

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
    _myField = [[UITextField alloc] initWithFrame:CGRectMake(8, 8, 290, 32)];
		[_myField setKeyboardType:UIKeyboardTypeEmailAddress];
		[_myField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_myField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_myField setEnablesReturnKeyAutomatically:YES];
    _myField.font = [UIFont systemFontOfSize:16];
		_myField.delegate = self;
//		_myField.backgroundColor = [UIColor greenColor];
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
		
		[LoginPanel handleLogin];
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
			[_myField setKeyboardType:UIKeyboardTypeAlphabet];
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
  
  TTTableTextItem* item = (TTTableTextItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	
  if (![item isKindOfClass:[LoginCenterButtonItem class]])
		return;
		
	if ([item.text isEqualToString:@"Log In"]) {
		[LoginPanel handleLogin];
	} else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
																							 [NSString stringWithFormat:@"%@/", 
																							 [OAuthGateway baseURL]]]];
		
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
		//self.title = @"Welcome to Yammer!";
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
		
    _tableViewStyle = UITableViewStyleGrouped;
		[self.tableView setScrollEnabled:NO];
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		
		[self createDataSource];
	}  
  return self;
}

- (void)createDataSource {
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

+ (void)handleLogin {	
	if ([theEmail.text length] < 1 || [thePassword.text length] < 1)
		return;

  TTNavigator* navigator = [TTNavigator navigator];
	LoginPanel* panel = (LoginPanel*)[navigator visibleViewController];
	panel.dataSource = nil;
	[panel showModel:YES];
	
	[NSThread detachNewThreadSelector:@selector(startLoginThread) toTarget:panel withObject:nil];	
}

- (void)startLoginThread {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString* body = [OAuthGateway getWrapToken:theEmail.text password:thePassword.text];	
	BOOL error = NO;

	// "Your network requires that you authenticate via single sign-on. To get your temporary password, please log in to Yammer on your computer and go to yammer.com/iphone."

	if (body) {		
		@try {
			NSArray* pairs = [body componentsSeparatedByString:@"&"];
			NSMutableDictionary* map = [NSMutableDictionary dictionary];
			for (NSString* value in pairs) {
				NSArray* tokens = [value componentsSeparatedByString:@"="];
				[map setObject:[tokens objectAtIndex:1] forKey:[tokens objectAtIndex:0]];
			}
			
			NSString* token = [map objectForKey:@"wrap_access_token"];
			NSString* secret = [map objectForKey:@"wrap_refresh_token"];
			
			[LocalStorage saveAccessToken:[NSString stringWithFormat:@"t=%@&s=%@", token, secret]];
		} @catch (NSException *e) {}
		
		if ([APIGateway usersCurrent:@"silent"] && [APIGateway networksCurrent:@"silent"])
			[self performSelectorOnMainThread:@selector(goAheadWithLogin) withObject:nil waitUntilDone:NO];		
		else {
			[YammerAppDelegate showError:@"There was a network error during login, please try again." style:nil];
			error = YES;
		}
	} else {
		error = YES;
		if (yammer.lastStatusCode == 403)
		  [YammerAppDelegate showError:@"Your network requires that you authenticate via single sign-on. To get your temporary password, please log in to Yammer on your computer and go to account/applications." style:nil];
  	else if (yammer.lastStatusCode == 401)
	  	[YammerAppDelegate showError:@"Invalid email or password." style:nil];
		else
		  [YammerAppDelegate showError:@"An error occurred and we have been notified.  Please try again later." style:nil];
	}
	
	if (error)
		[self performSelectorOnMainThread:@selector(resetDataSource) withObject:nil waitUntilDone:NO];
	
  [autoreleasepool release];
}

- (void)resetDataSource {
	[self createDataSource];
}

- (void)goAheadWithLogin {
	YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[yammer enterAppWithAccess];
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
