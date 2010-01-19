
#import <Three20/Three20.h>
#import "FeedMessageList.h"

@interface YammerAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate> {
  NSManagedObjectModel* managedObjectModel;
  NSManagedObjectContext* managedObjectContext;	    
  NSPersistentStoreCoordinator* persistentStoreCoordinator;  
  
  NSNumber* showFullNames;
  NSString* launchURL;
  NSNumber* network_id;
  NSString* network_name;
  NSString* pushToken;
  NSString* fontSize;
  NSString* dateOfSelection;
  BOOL threading;
  BOOL createNewAccount;
  int unseen_message_count_following;
  int unseen_message_count_received;
  long last_seen_message_id;
  NSDate* lastAutocomplete;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) NSNumber* showFullNames;
@property (nonatomic, retain) NSNumber* network_id;
@property (nonatomic, retain) NSString* network_name;
@property (nonatomic, retain) NSString* launchURL;
@property (nonatomic, retain) NSString* pushToken;
@property (nonatomic, retain) NSString* fontSize;
@property (nonatomic, retain) NSString* dateOfSelection;
@property (nonatomic, retain) NSDate* lastAutocomplete;
@property BOOL threading;
@property BOOL createNewAccount;

@property int unseen_message_count_following;
@property int unseen_message_count_received;
@property long last_seen_message_id;


+ (void)showError:(NSString *)error style:(NSString *)style;
- (void)setupNavigator;
- (void)setBadges:(NSString*)style;
- (void)setBadge:(FeedMessageList*)fml count:(int)count;
- (void)refreshMyFeed;
- (NSString*)version;
- (void)showEnterCallbackTokenScreen;
- (void)setupNavigator;
- (void)reloadForFontSizeChange;
- (int)countViewControllers;

@end

