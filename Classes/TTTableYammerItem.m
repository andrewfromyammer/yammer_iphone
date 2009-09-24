#import "TTTableYammerItem.h"
#import "NSString+SBJSON.h"

@implementation TTTableYammerItem

@synthesize message = _message, isDetail, threading, feedIsThread;

+ (id)itemWithMessage:(NSMutableDictionary*)message {
  TTTableYammerItem* item = [[[self alloc] init] autorelease];
  item.message = message;
  item.isDetail = NO;
  item.threading = NO;
  item.feedIsThread = NO;
  return item;
}

- (id)init {
  if (self = [super init]) {
    _message = nil;
    _URL = nil; //@"1";
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_message);
  [super dealloc];
}

- (int)middleWidth {
  if (self.threading)
    return 240;
  return 240;
}

- (int)maxPreviewHeight {
  if (self.feedIsThread)
    return 2000;
  return 100;
}

- (int)lockWidth {
  if ([[_message objectForKey:@"privacy"] boolValue])
    return 12;
  return 0;
}

- (BOOL)isThereOneAttachmentOfType:(NSString*)type {
  NSMutableArray *attachments = (NSMutableArray *)[[_message objectForKey:@"attachments_json"] JSONValue];
  
  for (int i=0; i<[attachments count]; i++) {
    NSMutableDictionary *attachment = [attachments objectAtIndex:i];
    
    if ([[attachment objectForKey:@"type"] isEqualToString:type])
      return YES;
  }
  return NO;
}

- (int)clipWidth {  
  if ([self isThereOneAttachmentOfType:@"file"])
    return 6;
  return 0;
}

- (int)photosWidth {
  if ([self isThereOneAttachmentOfType:@"image"])
    return 15;
  return 0;
}

@end
