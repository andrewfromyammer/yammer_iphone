#import "FeedData.h"
#import "APIGateway.h"
#import "LocalStorage.h"

@implementation FeedData

@synthesize feeds;

+ (FeedData *)getFeeds:(NSMutableDictionary *)dict {
  if (dict) {
    dict = [dict objectForKey:@"web_preferences"];
    NSArray* homeTabs = [dict objectForKey:@"home_tabs"];
    NSMutableArray* tabs = [NSMutableArray array];
    for (int i=0; i<[homeTabs count]; i++) {
      dict = [homeTabs objectAtIndex:i];
      if (![[dict objectForKey:@"url"] hasSuffix:@"/following"] && ![[dict objectForKey:@"url"] hasSuffix:@"/receive"])
        [tabs addObject:dict];
    }
    
    return [[FeedData alloc] initWithArray:tabs];
  }
  return [[FeedData alloc] initWithArray:[NSMutableArray array]];
}

- (id)initWithArray:(NSMutableArray *)array {
  self.feeds = array;
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  [FeedData setupCell:cell dict:[feeds objectAtIndex:indexPath.row]];
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

+ (void)setupCell:(UITableViewCell *)cell dict:(NSMutableDictionary *)dict {
  cell.textLabel.text = [dict objectForKey:@"name"];
  cell.imageView.image = nil;
  if ([[dict objectForKey:@"private"] intValue] == 1)
    cell.imageView.image = [UIImage imageNamed:@"lock.png"];  
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
