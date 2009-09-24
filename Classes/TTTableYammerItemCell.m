#import "TTTableYammerItemCell.h"
#import "TTTableYammerItem.h"
#import "Message.h"
#import "ColorBackground.h"

@implementation TTTableYammerItemCell

@synthesize messageView = _messageView;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableYammerItem* item = object;
  
  CGSize size = [[item.message objectForKey:@"plain_body"] sizeWithFont:[UIFont systemFontOfSize:11]
                 constrainedToSize:CGSizeMake(230, [item maxPreviewHeight])
                 lineBreakMode:UILineBreakModeTailTruncation];

  int h = size.height + 40;
  
  if (item.isDetail)
    return 60.0;
  
  return h;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    self.messageView = [[MessageView alloc] init];
    [self.contentView addSubview:_messageView];
	}
  
	return self;
}

- (void)dealloc {  
  TT_RELEASE_SAFELY(_messageView);
	[super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];
    
    TTTableYammerItem* item = object;

    _messageView.fromLine.text = [item.message objectForKey:@"from"];
    _messageView.timeLine.text = [Message timeString:item];
    _messageView.mugshot.URL   = [item.message objectForKey:@"actor_mugshot_url"];
    
    if (item.isDetail == YES) {
      [_messageView timeLineToOriginalPosition];
      [_messageView adjustFromLineIcons:item];
      return;
    }

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    _messageView.messageText.text = [item.message objectForKey:@"plain_body"];
    _messageView.messageText.hidden = NO;
    [_messageView adjustWidthsAndHeights:item];
    [_messageView adjustFromLineIcons:item];
        
    if ([item.message objectForKey:@"fill"]) {
      self.backgroundView = [[ColorBackground alloc] initWithColor:[item.message objectForKey:@"fill"]];     
      [_messageView setMultipleBackgrounds:[item.message objectForKey:@"fill"]];
    } else {
      self.backgroundView = [[ColorBackground alloc] initWithColor:[UIColor whiteColor]];     
      [_messageView setMultipleBackgrounds:[UIColor whiteColor]];
    }
    
  }
}


@end
