#import <Foundation/Foundation.h>


@interface MessageCell : UITableViewCell {
  UILabel *from;

  UILabel *preview;
  
  UILabel *time;
  UILabel *theWordIn;
  UILabel *group;
  
  UIView *footer;
  UIView *rightSide;

  UIImageView *actorPhoto;
  UIImageView *tabRight;
  UIImageView *lockImage;
  
  UIView *attachment_footer;
  UILabel *attachment_text;
}

@property (nonatomic, retain) UILabel *from;

@property (nonatomic, retain) UILabel *preview;

@property (nonatomic, retain) UILabel *time;
@property (nonatomic, retain) UILabel *theWordIn;
@property (nonatomic, retain) UILabel *group;
@property (nonatomic, retain) UILabel *attachment_text;

@property (nonatomic, retain) UIView *footer;
@property (nonatomic, retain) UIView *rightSide;

@property (nonatomic, retain) UIImageView *tabRight;
@property (nonatomic, retain) UIImageView *actorPhoto;

@property (nonatomic, retain) UIView *attachment_footer;
@property (nonatomic, retain) UIImageView *lockImage;

- (void)setMessage:(NSMutableDictionary *)message;
- (void)setHeightByPreview;
- (void)setTimeLength;

@end
