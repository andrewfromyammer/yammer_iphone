#import <CoreData/CoreData.h>

@interface FeedMetaData: NSManagedObject {
}

@property (nonatomic, retain) NSString *feed;
@property (nonatomic, retain) NSNumber *last_message_id;

@property (nonatomic, retain) NSDate *last_update;
@property (nonatomic, retain) NSNumber *network_id;

@end
