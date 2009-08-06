
#import "MessageCell.h"

@implementation MessageCell

@synthesize from;
@synthesize time;
@synthesize group;
@synthesize theWordIn;
@synthesize preview;
@synthesize pictureHolder;
@synthesize footer;
@synthesize tabRight;
@synthesize rightSide;

- (void)setMessage:(NSMutableDictionary *)message {
  
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithData:[message objectForKey:@"imageData"]]];
  imageView.frame = CGRectMake(0, 0, 48, 48);
  [self.pictureHolder addSubview:imageView];
  [imageView release];
    
  self.from.text = [message objectForKey:@"fromLine"];
  self.time.text = [message objectForKey:@"timeLine"];
  NSString *group_name = [message objectForKey:@"group_full_name"];
  if (group_name) {
    self.group.text = group_name;
    self.theWordIn.text = @"in";
  }
  else {
    self.group.text = @"";
    self.theWordIn.text = @"";
  }
  NSMutableDictionary *body = [message objectForKey:@"body"];
  
  CGSize maximumSize = CGSizeMake(self.preview.frame.size.width, 74);
  UIFont *previewFont = [UIFont fontWithName:@"Helvetica" size:11];
  CGSize stringSize = [[body objectForKey:@"plain"] sizeWithFont:previewFont 
                                               constrainedToSize:maximumSize 
                                                   lineBreakMode:self.preview.lineBreakMode];
  self.preview.frame = CGRectMake(self.preview.frame.origin.x, self.preview.frame.origin.y, 
                                  self.preview.frame.size.width, stringSize.height);
  
  self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 
                           self.bounds.size.width, stringSize.height + 35);
  
  self.footer.frame = CGRectMake(self.footer.frame.origin.x, 16 + stringSize.height,
                                 self.footer.frame.size.width, self.footer.frame.size.height);

  float offset = 0;
  if (stringSize.height > 20 && stringSize.height <= 40)
    offset = 10;
  else if (stringSize.height > 40 && stringSize.height <= 60)
    offset = 15;
  else if (stringSize.height > 60 && stringSize.height <= 80)
    offset = 25;
  
  self.rightSide.frame = CGRectMake(self.rightSide.frame.origin.x, (self.bounds.size.height / 2) - 10,
                                 self.rightSide.frame.size.width, self.rightSide.frame.size.height);
  
  
  self.preview.text = [body objectForKey:@"plain"];
  
  
  [self setFooterSizes:message];
}

- (void)setFooterSizes:(NSMutableDictionary *)message {
  CGSize maximumSize = CGSizeMake(80, self.time.frame.size.height);
  UIFont *footerFont = [UIFont fontWithName:@"Helvetica" size:10];
  CGSize stringSize = [[message objectForKey:@"timeLine"] sizeWithFont:footerFont 
                                               constrainedToSize:maximumSize
                                                   lineBreakMode:self.time.lineBreakMode];

  self.time.frame = CGRectMake(self.time.frame.origin.x, self.time.frame.origin.y,
                               stringSize.width, self.time.frame.size.height);
  
  self.theWordIn.frame = CGRectMake(stringSize.width+3, self.theWordIn.frame.origin.y,
                                    self.theWordIn.frame.size.width, self.theWordIn.frame.size.height);

  self.group.frame = CGRectMake(self.theWordIn.frame.origin.x + 12, self.group.frame.origin.y,
                                200 - self.theWordIn.frame.origin.x + 12, self.group.frame.size.height);

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
  [tabRight release];
  [rightSide release];
  [super dealloc];
}

@end
