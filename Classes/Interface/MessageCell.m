
#import "MessageCell.h"

@implementation MessageCell

@synthesize from;
@synthesize time;
@synthesize group;
@synthesize theWordIn;
@synthesize preview;
@synthesize pictureHolder;
@synthesize footer;

- (void)setMessage:(NSMutableDictionary *)message {  

}

- (void)layoutSubviews {
  [super layoutSubviews];
}
  
- (void)dealloc {
  [from release];
  
  [preview release];
  
  [time release];
  [theWordIn release];
  [group release];
  
  [pictureHolder release];
  [footer release];
  [super dealloc];
}

@end
