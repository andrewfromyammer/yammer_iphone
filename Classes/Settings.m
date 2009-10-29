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
    SettingsPush *localSettingPush = [[SettingsPush alloc] init];
    [_controller.navigationController pushViewController:localSettingPush animated:YES];
    [localSettingPush release];
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
    
    UIBarButtonItem *logout=[[UIBarButtonItem alloc] init];
    logout.title=@"Log Out";
    logout.target = self;
    logout.action = @selector(logout);
    self.navigationItem.rightBarButtonItem = logout;
    [logout release];

    _tableViewStyle = UITableViewStyleGrouped;
    [self gatherData];
  }  
  return self;
}

- (void)logout {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                  message:@"Click the confirm button below to log out from this account and exit the Yammer Application." delegate:self 
                                        cancelButtonTitle:nil otherButtonTitles: @"Cancel", @"Confirm", nil];
  [alert show];
  [alert release];  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1)
    [OAuthGateway logout];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[SettingsDelegate alloc] initWithController:self];
}

- (void)gatherData {

  NSMutableDictionary *dict = (NSMutableDictionary*)[[LocalStorage getFile:USER_CURRENT] JSONValue];
  NSString* email = [self findEmailFromDict:dict];
  NSString* name  = [dict objectForKey:@"network_name"];
  
  if ([self emailQualifiesForAdvanced:email])
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
       U_R_LOGGED_IN_AS,
       [TTTableTextItem itemWithText:email URL:nil],
       [self network:name],
       @"",
       [self switchNetworks],
       [self pushSettings],
       [TTTableImageItem itemWithText:@"Advanced Settings" imageURL:@"bundle://advanced.png" URL:@"1"],
       @"",
       [self version],
       nil];
  else
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       U_R_LOGGED_IN_AS,
                       [TTTableTextItem itemWithText:email URL:nil],
                       [self network:name],
                       @"",
                       [self switchNetworks],
                       [self pushSettings],
                       @"",
                       [self version],
                       nil];
  
}

- (TTTableImageItem*)switchNetworks {
  return [TTTableImageItem itemWithText:@"Switch Networks" imageURL:@"bundle://network.png" URL:@"1"];
}

- (TTTableImageItem*)pushSettings {
  return [TTTableImageItem itemWithText:@"Push Settings" imageURL:@"bundle://push.png" URL:@"1"];
}

- (TTTableTextItem*)version {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  return [TTTableTextItem itemWithText:[NSString stringWithFormat:@"Version: %@", [yammer version]] URL:nil];
}

- (TTTableTextItem*)network:(NSString*)name {
  return [TTTableTextItem itemWithText:[NSString stringWithFormat:@"Network: %@", name] URL:nil];
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
