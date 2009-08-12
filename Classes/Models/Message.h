#import <CoreData/CoreData.h>

@interface Message: NSManagedObject {
}

@property (nonatomic, retain) NSNumber *message_id;
@property (nonatomic, retain) NSNumber *latest_reply_id;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *plain_body;
@property (nonatomic, retain) NSNumber *privacy;
@property (nonatomic, retain) NSString *feed;

@property (nonatomic, retain) NSDate *created_at;
@property (nonatomic, retain) NSNumber *network_id;


@property (nonatomic, retain) NSString *actor_mugshot_url;
@property (nonatomic, retain) NSNumber *actor_id;
@property (nonatomic, retain) NSString *actor_type;

@end
