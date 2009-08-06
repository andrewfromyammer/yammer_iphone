#import <Foundation/Foundation.h>


@interface MessageCell : UITableViewCell {
  UILabel *from;

  UILabel *preview;
  
  UILabel *time;
  UILabel *theWordIn;
  UILabel *group;
  
  UIView *pictureHolder;
  UIView *footer;
  UIView *rightSide;
  
  UIImageView *tabRight;
}

@property (nonatomic, retain) IBOutlet UILabel *from;

@property (nonatomic, retain) IBOutlet UILabel *preview;

@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *theWordIn;
@property (nonatomic, retain) IBOutlet UILabel *group;

@property (nonatomic, retain) IBOutlet UIView *pictureHolder;
@property (nonatomic, retain) IBOutlet UIView *footer;
@property (nonatomic, retain) IBOutlet UIView *rightSide;

@property (nonatomic, retain) IBOutlet  UIImageView *tabRight;

- (void)setMessage:(NSMutableDictionary *)message;
- (void)setFooterSizes:(NSMutableDictionary *)message;

@end
