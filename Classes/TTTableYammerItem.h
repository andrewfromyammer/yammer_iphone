#import <Three20/Three20.h>

@interface TTTableYammerItem : TTTableTextItem {
  NSMutableDictionary* _message;
  BOOL threading;
  BOOL isDetail;
  BOOL feedIsThread;
}

@property(nonatomic,retain) NSMutableDictionary* message;
@property BOOL isDetail;
@property BOOL threading;
@property BOOL feedIsThread;

+ (id)itemWithMessage:(NSMutableDictionary*)message;
- (int)middleWidth;
- (int)maxPreviewHeight;

- (BOOL)isThereOneAttachmentOfType:(NSString*)type;

- (int)lockWidth;
- (int)clipWidth;
- (int)photosWidth;

@end
