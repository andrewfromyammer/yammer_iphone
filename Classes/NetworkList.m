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
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 100, 40)];
    _leftSide.text = @"Testing";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];
    
    _badge = [[TTLabel alloc] initWithFrame:CGRectMake(230, 8, 25, 25)];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    _badge.text = @"45";
    [_badge sizeToFit];
    
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
    
    if ([nli.URL isEqualToString:@"0"])
      _badge.hidden = YES;
    else 
      _badge.hidden = NO;
  }
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


@implementation NetworkList

- (id)init {
  if (self = [super init]) {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    self.navigationBarTintColor = [MainTabBar yammerGray];

    _tableViewStyle = UITableViewStyleGrouped;    
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* items = [NSMutableArray array];
    NSMutableArray* section = [NSMutableArray array];
    
    NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];

    for (NSMutableDictionary *network in networks) 
      [section addObject:[NetworkListItem itemWithText:[network objectForKey:@"name"] URL:[[network objectForKey:@"unseen_message_count"] description]]];  
    
    [sections addObject:@"Select a network:"];
    [items addObject:section];
    self.dataSource = [[NetworkListDataSource alloc] initWithItems:items sections:sections];    
  }  
  return self;
}


@end
