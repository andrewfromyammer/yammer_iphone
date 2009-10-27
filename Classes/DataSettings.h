#import <Foundation/Foundation.h>


@interface DataSettings : NSObject <UITableViewDataSource> {
  NSString *email;
  NSString *network;
}

@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *network;

- (void)findEmailFromDict:(NSMutableDictionary *)dict;

@end
