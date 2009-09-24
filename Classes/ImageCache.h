
#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {

}

+ (void)deleteOldestFile:(NSString *)path;
+ (NSData*)getOrLoadImage:(NSDictionary*)attachment key:(NSString*)key path:(NSString*)path;

@end
