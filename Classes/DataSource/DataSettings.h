#import <Foundation/Foundation.h>


@interface DataSettings : NSObject <UITableViewDataSource> {
  NSString *email;
}

@property (nonatomic,retain) NSString *email;

- (id)initWithDict:(NSMutableDictionary *)dict;


@end
