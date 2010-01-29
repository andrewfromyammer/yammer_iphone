#import <Three20/Three20.h>

@interface AutoCompleteCache : NSObject {

}

+ (void)save:(NSString*)prefix data:(NSString*)data;
+ (NSString*)filename:(NSString*)prefix;

@end
