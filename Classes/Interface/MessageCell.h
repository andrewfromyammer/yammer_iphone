#import <Foundation/Foundation.h>
#import "Message.h"

@interface MessageCell : UITableViewCell {
  UILabel *from;

  UILabel *preview;
  
  UILabel *time;
  UILabel *theWordIn;
  UILabel *group;
  
  UIView *footer;

  UIImageView *actorPhoto;
  UIImageView *lockImage;

  UILabel *replyCount;
}

@property (nonatomic, retain) UILabel *from;
@property (nonatomic, retain) UILabel *preview;
@property (nonatomic, retain) UILabel *time;
@property (nonatomic, retain) UILabel *theWordIn;
@property (nonatomic, retain) UILabel *group;
@property (nonatomic, retain) UILabel *replyCount;
@property (nonatomic, retain) UIView *footer;
@property (nonatomic, retain) UIImageView *actorPhoto;
@property (nonatomic, retain) UIImageView *lockImage;

- (void)setMessage:(Message *)message showReplyCounts:(BOOL)showReplyCounts;
- (void)setHeightByPreview;
- (void)setTimeLength;
- (void)setFromLengthForLock;

@end
