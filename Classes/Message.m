#import "Message.h"
#import "NSDate-Ago.h"

@implementation Message 

@dynamic message_id;
@dynamic latest_reply_id;
@dynamic from;
@dynamic plain_body;
@dynamic privacy;
@dynamic feed;

@dynamic created_at;
@dynamic latest_reply_at;
@dynamic network_id;

@dynamic actor_mugshot_url;
@dynamic actor_id;
@dynamic actor_type;
@dynamic group_full_name;
@dynamic attachments_json;

@dynamic sender;
@dynamic thread_url;
@dynamic thread_updates;
@dynamic likes;
@dynamic liked_by_me;

- (NSMutableDictionary*)safeMessage {
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];

  [dict setObject:[NSNumber numberWithInt:[self.thread_updates intValue]-1] forKey:@"thread_updates"];
  [dict setObject:[NSNumber numberWithInt:[self.privacy intValue]] forKey:@"privacy"];
  [dict setObject:[NSNumber numberWithInt:[self.likes intValue]] forKey:@"likes"];
  [dict setObject:[NSNumber numberWithInt:[self.liked_by_me intValue]] forKey:@"liked_by_me"];
  [dict setObject:[NSNumber numberWithLong:[self.message_id longValue]] forKey:@"message_id"];
  [dict setObject:[NSNumber numberWithLong:[self.latest_reply_id longValue]] forKey:@"latest_reply_id"];  
  [dict setObject:[NSNumber numberWithLong:[self.actor_id longValue]] forKey:@"actor_id"];
  [dict setObject:[NSString stringWithString:self.actor_mugshot_url] forKey:@"actor_mugshot_url"];
  [dict setObject:[NSString stringWithString:self.plain_body] forKey:@"plain_body"];
  [dict setObject:[NSString stringWithString:self.from] forKey:@"from"];
  [dict setObject:[NSString stringWithString:self.thread_url] forKey:@"thread_url"];
  [dict setObject:[NSString stringWithString:self.actor_type] forKey:@"actor_type"];
  [dict setObject:[NSString stringWithString:self.sender] forKey:@"sender"];
  
  [dict setObject:[NSString stringWithString:self.attachments_json] forKey:@"attachments_json"];
  
  [dict setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:[self.created_at timeIntervalSinceReferenceDate]] forKey:@"created_at"];
  [dict setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:[self.latest_reply_at timeIntervalSinceReferenceDate]] forKey:@"latest_reply_at"];
  if (self.group_full_name)
    [dict setObject:[NSString stringWithString:self.group_full_name] forKey:@"group_full_name"];
  return dict;
}

+ (NSString*)timeString:(TTTableYammerItem*)item {
  NSDate* date = [item.message objectForKey:@"created_at"];
  if (item.threading)
    date = [item.message objectForKey:@"latest_reply_at"];
  NSString* gfn = [item.message objectForKey:@"group_full_name"];
  NSString* suffix = @"";
  if (gfn)
    suffix = [NSString stringWithFormat:@" in %@", gfn];
  
  return [NSString stringWithFormat:@"%@%@", [date agoDate], suffix];
  
}

@end

