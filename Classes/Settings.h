#import <Three20/Three20.h>

#define U_R_LOGGED_IN_AS    @"You are logged in as:"

@interface Settings : TTTableViewController <UIAlertViewDelegate> {

}

- (void)gatherData;
- (NSString*)findEmailFromDict:(NSMutableDictionary*)dict;
- (TTTableImageItem*)switchNetworks;
- (TTTableImageItem*)pushSettings;
- (TTTableTextItem*)version;
- (TTTableTextItem*)network:(NSString*)name;
- (BOOL)emailQualifiesForAdvanced:(NSString*)email;

@end
