#import <Three20/Three20.h>
#import "FeedMessageList.h"

@interface UserProfile : TTTableViewController {

  NSString* _userId;  
  UIButton *follow;
  NSString *theUserId;
  BOOL isFollowed;
}

@property (nonatomic,retain) NSString *userId;

@property (nonatomic,retain) UIButton *follow;
@property (nonatomic,retain) NSString *theUserId;
@property BOOL isFollowed;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;
- (void)loadUser;
- (FeedMessageList *)getUserFeed;
+ (NSString*)safeName:(NSMutableDictionary*)dict;

@end
