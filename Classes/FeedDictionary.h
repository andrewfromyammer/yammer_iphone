#import <Three20/Three20.h>

@interface FeedDictionary : NSObject {
  NSMutableDictionary* _dict;
}

@property (nonatomic,retain) NSMutableDictionary *dict;


- (BOOL)threading;
+ (FeedDictionary*)dictionary;
+ (FeedDictionary*)feedWithDictionary:(NSMutableDictionary*)dict;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;

@end
