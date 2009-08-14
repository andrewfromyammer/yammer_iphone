
#import "MessageCell.h"
#import "LocalStorage.h"
#import "ImageCache.h"
#import "NSDate-Ago.h"

#define ACTOR_IMAGE_X  5
#define ACTOR_IMAGE_Y  5
#define LEFT_MARGIN    60
#define MIDDLE_WIDTH   219
#define DISCLOSURE_X   300
#define MIN_HEIGHT 48 + (ACTOR_IMAGE_Y * 2)
#define MAX_HEIGHT 74
#define ACTOR_IMAGE_W 48
#define ACTOR_IMAGE_H 48

#define FONT_12_HEIGHT 20


@implementation MessageCell

@synthesize from;
@synthesize time;
@synthesize group;
@synthesize theWordIn;
@synthesize preview;
@synthesize actorPhoto;
@synthesize footer;
@synthesize lockImage;
@synthesize replyCount;

- (id)init {
  if (self = [super initWithFrame:CGRectMake(0,0,320,MIN_HEIGHT) reuseIdentifier:@"MessageCell"]) {  
    self.bounds = CGRectMake(0,0,320,MIN_HEIGHT);
    self.actorPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(ACTOR_IMAGE_X,ACTOR_IMAGE_Y,ACTOR_IMAGE_W,ACTOR_IMAGE_H)];

    self.from = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN,0,MIDDLE_WIDTH,FONT_12_HEIGHT)];
    self.from.font = [UIFont boldSystemFontOfSize:12];

    self.preview = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN,FONT_12_HEIGHT,MIDDLE_WIDTH,30)];
    self.preview.numberOfLines = 5;
    self.preview.font = [UIFont systemFontOfSize:11];

    self.footer = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN,0,MIDDLE_WIDTH,FONT_12_HEIGHT)];
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(0,0,50,FONT_12_HEIGHT)];
    self.time.font = [UIFont systemFontOfSize:10];
    self.theWordIn = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,FONT_12_HEIGHT)];
    self.theWordIn.font = [UIFont systemFontOfSize:10];
    self.theWordIn.text = @"in";
    self.group = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,FONT_12_HEIGHT)];
    self.group.font = [UIFont boldSystemFontOfSize:10];
    
    self.lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(MIDDLE_WIDTH+LEFT_MARGIN-12,4,12,12)];
    self.lockImage.image = [UIImage imageNamed:@"lock.png"];
    self.lockImage.hidden = true;

    self.replyCount = [[UILabel alloc] initWithFrame:CGRectMake(320-40,20,16,FONT_12_HEIGHT)];
    self.replyCount.font = [UIFont boldSystemFontOfSize:14];
    self.replyCount.text = @"99";
    self.replyCount.textAlignment = UITextAlignmentRight;
    
    [self.footer addSubview:time];
    [self.footer addSubview:theWordIn];
    [self.footer addSubview:group];
    
    [self.contentView addSubview:actorPhoto];
    [self.contentView addSubview:from];
    [self.contentView addSubview:lockImage];
    [self.contentView addSubview:preview];
    
    [self.contentView addSubview:footer];
    [self.contentView addSubview:replyCount];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  return self;
}

- (void)loadThatImage:(Message *)message {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  @synchronized ([UIApplication sharedApplication]) {  
    NSData *imageData = [ImageCache getImageAndSave:message.actor_mugshot_url actor_id:[message.actor_id description] type:message.actor_type];
    self.actorPhoto.image = [[UIImage alloc] initWithData:imageData];
  }
  [autoreleasepool release];
}

- (void)setMessage:(Message *)message showReplyCounts:(BOOL)showReplyCounts {
  NSData *imageData = [ImageCache getImage:[message.actor_id description] type:message.actor_type];
  if (imageData)
    self.actorPhoto.image = [[UIImage alloc] initWithData:imageData];
  else
    [NSThread detachNewThreadSelector:@selector(loadThatImage:) toTarget:self withObject:message];
  self.from.text = message.from;

  self.preview.text = message.plain_body;
  
  if (message.group_full_name) {
    self.group.text = message.group_full_name;
    self.theWordIn.text = @"in";
  }
  else {
    self.group.text = @"";
    self.theWordIn.text = @"";
  }
  
  if (showReplyCounts) {
    int rcount = [message.thread_updates intValue] - 1;
    if (rcount > 99)
      self.replyCount.text = @"99";
    else if (rcount <= 0)
      self.replyCount.text = @"";
    else
      self.replyCount.text = [NSString stringWithFormat:@"%d", rcount];
  }
  else
    self.replyCount.text = @"";
  
  [self setHeightByPreview];
  
  if (showReplyCounts && message.latest_reply_at != nil)
    self.time.text = [message.latest_reply_at agoDate];  
  else
    self.time.text = [message.created_at agoDate];
  
  [self setTimeLength];
  if ([message.privacy boolValue]) {
    [self setFromLengthForLock];
    self.lockImage.hidden = false;
  } else {
    self.lockImage.hidden = true;
    self.from.frame = CGRectMake(from.frame.origin.x, from.frame.origin.y, 
                                 MIDDLE_WIDTH, from.frame.size.height);    
  }
}

- (void)setFromLengthForLock {
  CGSize stringSize = [from.text sizeWithFont:from.font 
                       constrainedToSize: CGSizeMake(MIDDLE_WIDTH-15, from.frame.size.height)
                       lineBreakMode:from.lineBreakMode];
  
  self.from.frame = CGRectMake(from.frame.origin.x, from.frame.origin.y,
                               stringSize.width, from.frame.size.height);
  
  self.lockImage.frame = CGRectMake(LEFT_MARGIN+stringSize.width+2,4,12,12); 
  
}

- (void)setHeightByPreview {
  CGSize stringSize = [preview.text sizeWithFont:preview.font 
                                    constrainedToSize:CGSizeMake(MIDDLE_WIDTH, MAX_HEIGHT) 
                                    lineBreakMode:preview.lineBreakMode];
  self.preview.frame = CGRectMake(preview.frame.origin.x, preview.frame.origin.y, 
                                  preview.frame.size.width, stringSize.height);
  
  int newHeight = stringSize.height + FONT_12_HEIGHT + FONT_12_HEIGHT;
  if (newHeight < MIN_HEIGHT)
    newHeight = MIN_HEIGHT;
  
  self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 
                           self.bounds.size.width, newHeight);
  
  self.footer.frame = CGRectMake(footer.frame.origin.x, newHeight - FONT_12_HEIGHT,
                                 footer.frame.size.width, footer.frame.size.height);
  
  self.replyCount.frame = CGRectMake(replyCount.frame.origin.x, (self.bounds.size.height / 2) - 11,
                                     replyCount.frame.size.width, replyCount.frame.size.height);
  
  
}

- (void)setTimeLength {
  CGSize stringSize = [time.text sizeWithFont:time.font 
                                 constrainedToSize: CGSizeMake(80, time.frame.size.height)
                                 lineBreakMode:time.lineBreakMode];
  
  self.time.frame = CGRectMake(time.frame.origin.x, time.frame.origin.y,
                               stringSize.width, time.frame.size.height);
  
  self.theWordIn.frame = CGRectMake(stringSize.width+3, theWordIn.frame.origin.y,
                                    theWordIn.frame.size.width, theWordIn.frame.size.height);
  
  self.group.frame = CGRectMake(theWordIn.frame.origin.x + 12, group.frame.origin.y,
                                200 - theWordIn.frame.origin.x + 12, group.frame.size.height);
  
}

/*
- (void)setMessage2:(NSMutableDictionary *)message {
  
  self.actorPhoto.image = [[UIImage alloc] initWithData:[message objectForKey:@"imageData"]];
    
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
  
  int newHeight = stringSize.height + 37;
  if (newHeight < 58)
    newHeight = 58;
 
  //self.private_footer.hidden = true;
  //self.attachment_footer.hidden = true;
  self.lockImage.hidden = true;
  
  if ([message objectForKey:@"lock"]) {
    self.lockImage.hidden = false;
  }

  //if ([[message objectForKey:@"attachments"] count] > 0) {
  if (false) {
    newHeight += 19;
    self.attachment_footer.frame = CGRectMake(self.attachment_footer.frame.origin.x, newHeight - 34,
                                              self.attachment_footer.frame.size.width, self.attachment_footer.frame.size.height);
    self.attachment_footer.hidden = false;
    self.attachment_text.text = [NSString stringWithFormat:@"%d attachment(s)", [[message objectForKey:@"attachments"] count]];
  }
    
  self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 
                           self.bounds.size.width, newHeight);
  
  self.footer.frame = CGRectMake(self.footer.frame.origin.x, newHeight - 24,
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
    
}
 */



- (void)layoutSubviews {
  [super layoutSubviews];
}
  
- (void)dealloc {
  [from release];
  [preview release];
  [time release];
  [theWordIn release];
  [group release];  
  [actorPhoto release];
  [footer release];
  [lockImage release];
  [replyCount release];
  [super dealloc];
}

@end
