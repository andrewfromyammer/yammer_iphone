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

@property (nonatomic, retain) IBOutlet UILabel *from;

@property (nonatomic, retain) IBOutlet UILabel *preview;

@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *theWordIn;
@property (nonatomic, retain) IBOutlet UILabel *group;
@property (nonatomic, retain) IBOutlet UILabel *attachment_text;

@property (nonatomic, retain) IBOutlet UIView *footer;
@property (nonatomic, retain) IBOutlet UIView *rightSide;

@property (nonatomic, retain) IBOutlet  UIImageView *tabRight;
@property (nonatomic, retain) IBOutlet  UIImageView *actorPhoto;

@property (nonatomic, retain) IBOutlet UIView *attachment_footer;
@property (nonatomic, retain) IBOutlet UIImageView *lockImage;

- (void)setMessage:(NSMutableDictionary *)message;
- (void)setFooterSizes:(NSMutableDictionary *)message;

@end
