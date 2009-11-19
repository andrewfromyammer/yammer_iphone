#import "NetworkList.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "NSString+SBJSON.h"

@interface NetworkListItem : TTTableTextItem {}
@end

@implementation NetworkListItem
@end

@interface NetworkListCell : TTTableTextItemCell {
  UILabel* _leftSide;
  TTLabel* _badge;
}
@property (nonatomic, retain) UILabel *leftSide;
@property (nonatomic, retain) TTLabel *badge;

@end

@implementation NetworkListCell

@synthesize leftSide = _leftSide, badge = _badge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 100, 30)];
    _leftSide.text = @"Testing";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];
    
    _badge = [[TTLabel alloc] initWithFrame:CGRectMake(225, 8, 25, 25)];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    _badge.text = @"60+";
    
    [self.contentView addSubview:_leftSide];
    [self.contentView addSubview:_badge];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_leftSide);
  [super dealloc];
}

- (void)setObject:(id)object {
  if (_item != object) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NetworkListItem* nli = (NetworkListItem*)object;
    _leftSide.text = nli.text;
    
    _badge.text = nli.URL;
    [_badge sizeToFit];
    
    if (nli.URL == nil)
      _badge.hidden = YES;
    else 
      _badge.hidden = NO;
  }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 45.0;
}

@end

@interface NetworkListDataSource : TTSectionedDataSource;
@end

@implementation NetworkListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[NetworkListItem class]])
    return [NetworkListCell class];
  return [super tableView:tableView cellClassForObject:object];
}
@end

@interface NetworkListDelegate : TTTableViewVarHeightDelegate;
@end

@implementation NetworkListDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NetworkListItem* nli = (NetworkListItem*)[_controller.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  
}

@end



@implementation NetworkList

- (id)init {
  if (self = [super init]) {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.variableHeightRows = YES;
    
    _tableViewStyle = UITableViewStyleGrouped;    
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* items = [NSMutableArray array];
    NSMutableArray* section = [NSMutableArray array];
    
    NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];

    for (NSMutableDictionary *network in networks) 
      [section addObject:[NetworkListItem itemWithText:[network objectForKey:@"name"] URL:[NetworkList badgeFromIntToString:[[network objectForKey:@"unseen_message_count"] intValue]]]];  
    
    [sections addObject:@"Select a network:"];
    [items addObject:section];
    self.dataSource = [[NetworkListDataSource alloc] initWithItems:items sections:sections];    
  }  
  return self;
}

- (id<UITableViewDelegate>)createDelegate {
  return [[NetworkListDelegate alloc] initWithController:self];
}

+ (NSString*)badgeFromIntToString:(int)count {
  if (count > 0) {
    if (count > 60)
      return @"60+";
    else
      return [NSString stringWithFormat:@"%d", count];   
  }
  return nil;
}


@end
