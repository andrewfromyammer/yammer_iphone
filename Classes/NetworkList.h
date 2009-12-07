#import <Three20/Three20.h>
  
@interface NetworkList : TTTableViewController {
  BOOL alreadySelected;
}

@property BOOL alreadySelected;

+ (NSString*)badgeFromIntToString:(int)count;
+ (void)subtractFromBadgeCount:(NSMutableDictionary*)network;

- (void)madeSelection:(NSMutableDictionary*)network;
- (void)createNetworkListDataSource;
- (NSMutableDictionary*)findTokenByNetworkId:(long)network_id;
- (void)handleReplaceToken:(NSMutableDictionary*)network;
- (void)clearBadgeForNetwork:(NSNumber*)network_id;

@end
