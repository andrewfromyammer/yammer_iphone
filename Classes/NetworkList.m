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
}
@property (nonatomic, retain) UILabel *leftSide;

@end

@implementation NetworkListCell

@synthesize leftSide = _leftSide;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {    
    _leftSide = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 100, 40)];
    _leftSide.text = @"Testing";
    _leftSide.font = [UIFont boldSystemFontOfSize:18];
    
    [self.contentView addSubview:_leftSide];
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
      [section addObject:[NetworkListItem itemWithText:[network objectForKey:@"name"]]];  
    
    [sections addObject:@"Select a network:"];
    [items addObject:section];
    self.dataSource = [[NetworkListDataSource alloc] initWithItems:items sections:sections];    
  }  
  return self;
}


@end
