#import <Three20/Three20.h>
#import "MessageView.h"

@interface TTTableYammerItemCell : TTTableLinkedItemCell {
  MessageView* _messageView;  
}

@property(nonatomic,retain) MessageView* messageView;

@end
