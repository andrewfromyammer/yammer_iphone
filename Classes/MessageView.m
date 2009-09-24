
#import "MessageView.h"

static const CGFloat middleWidth = 230;
static const CGFloat timeLineY = 33;
static const CGFloat leftX = 55;

@implementation MessageView

@synthesize fromLine = _fromLine, timeLine = _timeLine, messageText = _messageText;
@synthesize mugshot = _mugshot, iconPhoto = _iconPhoto, iconLock = _iconLock, iconClip = _iconClip;

- (id)init {
  if (self = [super initWithFrame:CGRectMake(0, 0, 320, 100)]) {
    
    self.fromLine = [[UILabel alloc] initWithFrame:CGRectMake(leftX, 0, middleWidth, 20)];
    _fromLine.textColor = [UIColor blackColor];
    _fromLine.font = [UIFont boldSystemFontOfSize:12];

    self.messageText = [[UILabel alloc] initWithFrame:CGRectMake(leftX, 20, middleWidth, 40)];
    _messageText.textColor = [UIColor blackColor];
    _messageText.font = [UIFont systemFontOfSize:11];
    _messageText.hidden = YES;
    _messageText.numberOfLines = 0;
    
    self.timeLine = [[UILabel alloc] initWithFrame:CGRectMake(leftX, timeLineY, middleWidth, 20)];
    _timeLine.textColor = [UIColor darkGrayColor];
    _timeLine.font = [UIFont systemFontOfSize:10];

    self.mugshot = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    _mugshot.defaultImage = [UIImage imageNamed:@"no_photo_small.png"];

    self.iconClip = [[TTImageView alloc] initWithFrame:CGRectMake(0, 4, 6, 12)];
    _iconClip.image = [UIImage imageNamed:@"paperclip.png"];
    _iconClip.hidden = YES;

    self.iconLock = [[TTImageView alloc] initWithFrame:CGRectMake(0, 4, 12, 12)];
    _iconLock.image = [UIImage imageNamed:@"lock.png"];
    _iconLock.hidden = YES;

    self.iconPhoto = [[TTImageView alloc] initWithFrame:CGRectMake(0, 4, 15, 14)];
    _iconPhoto.image = [UIImage imageNamed:@"photos15x14.png"];
    _iconPhoto.hidden = YES;
    
		[self addSubview:_fromLine];
		[self addSubview:_messageText];
		[self addSubview:_timeLine];
    [self addSubview:_mugshot];

    [self addSubview:_iconClip];
    [self addSubview:_iconLock];
    [self addSubview:_iconPhoto];
  }
  
  return self;
}

- (void)adjustWidthsAndHeights:(TTTableYammerItem*)item {
  CGSize size = [_messageText.text sizeWithFont:[UIFont systemFontOfSize:11]
                 constrainedToSize:CGSizeMake(middleWidth, [item maxPreviewHeight])
                 lineBreakMode:UILineBreakModeTailTruncation];
  _timeLine.frame = CGRectMake(leftX, 20+size.height, middleWidth, 20);
  _messageText.frame = CGRectMake(leftX, 20, middleWidth, size.height);
  
}

- (void)timeLineToOriginalPosition {
  _timeLine.frame = CGRectMake(leftX, timeLineY, middleWidth, 20);
}

- (void)setMultipleBackgrounds:(UIColor*)color {
  _fromLine.backgroundColor = color;
  _messageText.backgroundColor = color;
  _timeLine.backgroundColor = color;
}

- (void)adjustFromLineIcons:(TTTableYammerItem*)item {
  int icon_width = [item lockWidth] + [item clipWidth] + [item photosWidth];
  
  _iconClip.hidden = YES;
  _iconLock.hidden = YES;
  _iconPhoto.hidden = YES;
  _fromLine.frame = CGRectMake(leftX, 0, middleWidth, 20);
  
  if (icon_width > 0) {
    _fromLine.frame = CGRectMake(leftX, 0, middleWidth - icon_width, 20);
    
    CGSize size = [_fromLine.text sizeWithFont:[UIFont boldSystemFontOfSize:12]
            constrainedToSize:CGSizeMake(middleWidth - icon_width, 20)
            lineBreakMode:UILineBreakModeTailTruncation];  
    
    int offset = size.width + 65;
    if ([item lockWidth] > 0) {
      _iconLock.frame = CGRectMake(offset, 4, [item lockWidth], 12);
      _iconLock.hidden = NO;
      offset += [item lockWidth] + 3;
    }
    if ([item clipWidth] > 0) {
      _iconClip.frame  = CGRectMake(offset, 4, [item clipWidth], 12);
      _iconClip.hidden = NO;
      offset += [item clipWidth] + 3;
    }
    if ([item photosWidth] > 0) {
      _iconPhoto.frame = CGRectMake(offset, 4, [item photosWidth], 14);
      _iconPhoto.hidden = NO;
    }
  }
}
  
- (void)dealloc {
  TT_RELEASE_SAFELY(_fromLine);
  TT_RELEASE_SAFELY(_mugshot);
  TT_RELEASE_SAFELY(_timeLine);
  TT_RELEASE_SAFELY(_messageText);
  
  TT_RELEASE_SAFELY(_iconPhoto);
  TT_RELEASE_SAFELY(_iconClip);
  TT_RELEASE_SAFELY(_iconLock);  
  [super dealloc];
}

@end
