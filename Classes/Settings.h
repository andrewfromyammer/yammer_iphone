#import <Three20/Three20.h>

@interface Settings : TTTableViewController <UIAlertViewDelegate> {

}

- (void)gatherData;
- (NSString*)findEmailFromDict:(NSMutableDictionary*)dict;
- (BOOL)emailQualifiesForAdvanced:(NSString*)email;

@end
