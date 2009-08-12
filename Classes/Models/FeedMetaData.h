#import <CoreData/CoreData.h>

@interface FeedMetaData: NSManagedObject {
}

@property (nonatomic, retain) NSString *feed;
@property (nonatomic, retain) NSNumber *older_available;

@property (nonatomic, retain) NSDate *last_update;
@property (nonatomic, retain) NSNumber *network_id;

@end
