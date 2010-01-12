
#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {

}

+ (void)deleteOldestFile:(NSString *)path;
+ (NSString*)getOrLoadImagePath:(NSDictionary*)attachment path:(NSString*)path;
+ (NSData*)getOrLoadImage:(NSDictionary*)attachment atype:(NSString*)atype key:(NSString*)key path:(NSString*)path;
@end
