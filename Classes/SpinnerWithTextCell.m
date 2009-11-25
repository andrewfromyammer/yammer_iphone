
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

@synthesize display = _display, spinner = _spinner, refreshImage = _refreshImage;

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

    _refreshImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 10, 12)];
    _refreshImage.image = [UIImage imageNamed:@"refresh.png"];
    
    _refreshImage.hidden = YES;

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:_refreshImage];
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
      _refreshImage.hidden = YES;
    }
    else {
      [self.spinner stopAnimating];      
      _refreshImage.hidden = NO;
    }
    
  }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 40.0;
}

@end
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
