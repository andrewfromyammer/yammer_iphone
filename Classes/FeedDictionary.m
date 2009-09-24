#import "FeedDictionary.h"
#import "LocalStorage.h"

@implementation FeedDictionary

@synthesize dict = _dict;

- (BOOL)threading {
  if ([LocalStorage threading] && [_dict objectForKey:@"isThread"] == nil)
    return true;
  return false;
}

- (id)objectForKey:(id)key {
  return [_dict objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
  [_dict setObject:object forKey:key];
}

+ (FeedDictionary*)dictionary {
  return [[[FeedDictionary alloc] init] autorelease];
}

+ (FeedDictionary*)feedWithDictionary:(NSMutableDictionary*)dict {
  FeedDictionary* fd = [[[FeedDictionary alloc] init] autorelease];
  fd.dict = dict;
  return fd;
}

- (id)init {
  if (self = [super init]) {
    self.dict = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_dict);
  [super dealloc];
}

@end
