#import <Three20/Three20.h>
#import "SendMail.h"

@interface Settings : SendMail <UIAlertViewDelegate> {

}

- (void)gatherData;
- (NSString*)findEmailFromDict:(NSMutableDictionary*)dict;
- (BOOL)emailQualifiesForAdvanced:(NSString*)email;

@end
