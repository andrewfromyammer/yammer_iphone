#import <Foundation/Foundation.h>


@interface DataSettings : NSObject <UITableViewDataSource> {
  NSString *email;
}

@property (nonatomic,retain) NSString *email;

- (void)findEmailFromDict:(NSMutableDictionary *)dict;
- (id)init;

@end
