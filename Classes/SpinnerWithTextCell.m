
#import "SpinnerWithTextCell.h"
#import "FeedList.h"
#import "TTTableYammerItem.h"
#import "TTTableYammerItemCell.h"

@implementation SpinnerWithTextItem

@synthesize isSpinning;

+ (id)item {
  SpinnerWithTextItem* swti = [SpinnerWithTextItem itemWithText:@"Loading"];
  swti.isSpinning = YES;
  return swti;
}

+ (id)itemWithYammer {
  SpinnerWithTextItem* swti = [SpinnerWithTextItem itemWithText:@"Contacting yammer.com"];
  swti.isSpinning = YES;
  return swti;
}

@end

@implementation SpinnerWithTextCell

@synthesize display = _display, spinner = _spinner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    _display = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 210, 30)];
    _display.text = @"Testing";
    _display.textAlignment = UITextAlignmentLeft;
    _display.textColor = [UIColor darkGrayColor];
    _display.font = [UIFont systemFontOfSize:12];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 9, 20, 20)];
    _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_spinner startAnimating];

    [self.contentView addSubview:_display];
    [self.contentView addSubview:_spinner];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_display);
  TT_RELEASE_SAFELY(_spinner);
  [super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    SpinnerWithTextItem* swti = (SpinnerWithTextItem*)object;
    _display.text = swti.text;
    
    if (swti.isSpinning) {
      [self.spinner startAnimating];
    }
    else {
      [self.spinner stopAnimating];      
    }
    
  }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 40.0;
}

@end

/*
@implementation SpinnerWithTextItem

@synthesize display = _display;
@synthesize isSpinning;

+ (id)item {
  SpinnerWithTextItem* item = [[[self alloc] init] autorelease];
  item.isSpinning = YES;
  return item;
}

+ (id)itemWithYammer {
  SpinnerWithTextItem* item = [[[self alloc] init] autorelease];
  item.display = @"Contacting yammer.com";
  item.isSpinning = YES;
  return item;
}

+ (id)itemWithText:(NSString*)text {
  SpinnerWithTextItem* item = [[[self alloc] init] autorelease];
  item.display = text;
  item.isSpinning = NO;
  return item;
}

- (id)init {
  if (self = [super init]) {
    _display = @"Loading from cache...";
    _URL = nil;
    _text = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_display);
  [super dealloc];
}

@end

@implementation SpinnerWithTextCell

@synthesize display = _display, spinner = _spinner, refreshImage = _refreshImage;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 40.0;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.display.frame = CGRectMake(0, 5, 320, 30);
  _refreshImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 13, 10, 12)];
  _refreshImage.image = [UIImage imageNamed:@"refresh.png"];
  
  _refreshImage.hidden = YES;
  [self.contentView addSubview:_refreshImage];

}

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];
    
    SpinnerWithTextItem* item = object;
    
    self.display.text = item.display;
    if (item.isSpinning) {
      _refreshImage.hidden = YES;
      [self.spinner startAnimating];
    }
    else {
      _refreshImage.hidden = NO;
      [self.spinner stopAnimating];
      
    }
  }
}

- (UILabel*)display {
  if (!_display) {
    _display = [[UILabel alloc] init];
    _display.textAlignment = UITextAlignmentCenter;
    _display.textColor = [UIColor darkGrayColor];
    _display.font = [UIFont systemFontOfSize:12];
    
    [self.contentView addSubview:_display];
  }
  return _display;
}

- (UIActivityIndicatorView*)spinner {
  if (!_spinner) {
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 9, 20, 20)];
    _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_spinner startAnimating];
    [self.contentView addSubview:_spinner];
  }
  return _spinner;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_display);
  TT_RELEASE_SAFELY(_spinner);
  TT_RELEASE_SAFELY(_refreshImage);
  [super dealloc];
}

@end
*/

@implementation SpinnerListDataSource

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[SpinnerWithTextItem class]])
    return [SpinnerWithTextCell class];
  else if ([object isKindOfClass:[FeedTableImageItem class]])
    return [FeedTableImageItemCell class];
  else if ([object isKindOfClass:[TTTableYammerItem class]])
    return [TTTableYammerItemCell class];
  return [super tableView:tableView cellClassForObject:object];
}
@end
