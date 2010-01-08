#import "Settings.h"
#import "MainTabBar.h"
#import "YammerAppDelegate.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"
#import "OAuthCustom.h"
#import "SettingsPush.h"
#import "SettingsAdvancedOptions.h"
#import "SettingsSwitchNetwork.h"
#import "OAuthGateway.h"
#import "SettingsFontSize.h"
#import "APIGateway.h"

@interface TitleWithValueItem : TTTableImageItem {}
@end

@implementation TitleWithValueItem
@end

@interface TitleWithValueCell : TTTableImageItemCell {
  TTImageView* _iconImageView;
  UILabel* _leftSide;
  UILabel* _rightSide;
}
@property (nonatomic, retain) TTImageView *iconImageView;
@property (nonatomic, retain) UILabel *leftSide;
@property (nonatomic, retain) UILabel *rightSide;

@end

@implementation TitleWithValueCell

@synthesize iconImageView = _iconImageView, leftSide = _leftSide, rightSide = _rightSide;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _iconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(10, 10, 24, 24)];
    _iconImageView.image = [UIImage imageNamed:@"font.png"];
    
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(47, 1, 100, 40)];
    _leftSide.text = @"Font Size";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];

    _rightSide = [[UILabel alloc] initWithFrame:CGRectMake(220, 1, 50, 40)];
    _rightSide.font = [UIFont systemFontOfSize:14.0];
    _rightSide.textAlignment = UITextAlignmentRight;
    _rightSide.textColor = [UIColor blueColor];

    [self.contentView addSubview:_iconImageView];
    [self.contentView addSubview:_leftSide];
    [self.contentView addSubview:_rightSide];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_iconImageView);
  TT_RELEASE_SAFELY(_leftSide);
  TT_RELEASE_SAFELY(_rightSide);
  [super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _rightSide.text = [LocalStorage fontSize];

  }
}
@end

@interface SettingDataSource : TTSectionedDataSource;
@end

@implementation SettingDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[TitleWithValueItem class]])
    return [TitleWithValueCell class];
  return [super tableView:tableView cellClassForObject:object];
}
@end



@interface SettingsDelegate : TTTableViewVarHeightDelegate;
@end

@implementation SettingsDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  TTTableImageItem* item = (TTTableImageItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([item.text isEqualToString:@"Switch Networks"]) {
    SettingsSwitchNetwork *switchNetwork = [[SettingsSwitchNetwork alloc] initWithControllerReference:(Settings*)_controller];
    [_controller.navigationController pushViewController:switchNetwork animated:YES];
    [switchNetwork release];    
  } else if ([item.text isEqualToString:@"Push Settings"]) {
    [[TTNavigator navigator] openURL:@"yammer://push" animated:YES];
  } else if ([item.text isEqualToString:@"Font Size"]) {
    SettingsFontSize *fontSize = [[SettingsFontSize alloc] initWithControllerReference:(Settings*)_controller];
    [_controller.navigationController pushViewController:fontSize animated:YES];
    [fontSize release];
  } else if ([item.text isEqualToString:@"Type Ahead Demo"]) {
    [[TTNavigator navigator] openURL:@"yammer://type" animated:YES];
  } else if ([item.text isEqualToString:@"Send Feedback"]) {
    [(Settings*)_controller email];
  } else if ([item.text isEqualToString:@"Advanced Settings"]) {
    SettingsAdvancedOptions *localSettingsAdvancedOptions = [[SettingsAdvancedOptions alloc] init];
    [_controller.navigationController pushViewController:localSettingsAdvancedOptions animated:YES];
    [localSettingsAdvancedOptions release];    
  }

  
}

@end

@implementation Settings

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    _tableViewStyle = UITableViewStyleGrouped;
    [self gatherData];
  }  
  return self;
}

- (id<UITableViewDelegate>)createDelegate {
  return [[SettingsDelegate alloc] initWithController:self];
}

- (void)gatherData {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  NSMutableArray* sections = [NSMutableArray array];
  NSMutableArray* items = [NSMutableArray array];

  [sections addObject:@"You are logged in as:"];
  [sections addObject:@""];
  [sections addObject:@""];
  [sections addObject:@""];

  NSMutableDictionary *dict = (NSMutableDictionary*)[[LocalStorage getFile:[APIGateway user_file]] JSONValue];
  NSString* email = [self findEmailFromDict:dict];

  NSMutableArray* section1 = [NSMutableArray array];
  [section1 addObject:[TTTableTextItem itemWithText:email URL:nil]];
  [items addObject:section1];
  
  NSMutableArray* section2 = [NSMutableArray array];
//  [section2 addObject:[TTTableImageItem itemWithText:@"Switch Networks" imageURL:@"bundle://network.png" URL:@"1"]];
  [section2 addObject:[TTTableImageItem itemWithText:@"Push Settings" imageURL:@"bundle://push.png" URL:@"1"]];
  [section2 addObject:[TitleWithValueItem itemWithText:@"Font Size" imageURL:@"bundle://font.png" URL:@"1"]];
  if ([self emailQualifiesForAdvanced:email])
    [section2 addObject:[TTTableImageItem itemWithText:@"Advanced Settings" imageURL:@"bundle://advanced.png" URL:@"1"]];
  //[section2 addObject:[TTTableImageItem itemWithText:@"Type Ahead Demo" imageURL:@"bundle://advanced.png" URL:@"1"]];
  [items addObject:section2];

  NSMutableArray* section3 = [NSMutableArray array];
  [section3 addObject:[TTTableTextItem itemWithText:@"Send Feedback" URL:@"1"]];
  [items addObject:section3];

  NSMutableArray* section4 = [NSMutableArray array];
  [section4 addObject:[TTTableTextItem itemWithText:[NSString stringWithFormat:@"Version: %@", [yammer version]] URL:nil]];
  [items addObject:section4];
  
  self.dataSource = [[SettingDataSource alloc] initWithItems:items sections:sections];
}

- (BOOL)emailQualifiesForAdvanced:(NSString*)email {
  NSArray *array = [[OAuthCustom devNetworks] componentsSeparatedByString:@" "];
  int i=0;
  for (; i<[array count]; i++) {
    if ([email hasSuffix:[array objectAtIndex:i]])
      return YES;
  }
  return NO;
}

- (NSString*)findEmailFromDict:(NSMutableDictionary*)dict {
    
  NSMutableDictionary *contact = [dict objectForKey:@"contact"];
  NSArray *addresses = [contact objectForKey:@"email_addresses"];
  int i=0;
  for (; i< [addresses count]; i++) {
    NSDictionary *emailDict = [addresses objectAtIndex:i];
    if ([emailDict objectForKey:@"type"])
      if ([[emailDict objectForKey:@"type"] isEqualToString:@"primary"]) {
        return [emailDict objectForKey:@"address"];
      }
  }
  
  return @"";
}


@end
