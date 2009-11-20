#import <Three20/Three20.h>
  
@interface NetworkList : TTTableViewController {

}

+ (NSString*)badgeFromIntToString:(int)count;
- (void)madeSelection:(NSMutableDictionary*)network;
- (void)createNetworkListDataSource;
- (NSMutableDictionary*)findTokenByNetworkId:(long)network_id;

@end
