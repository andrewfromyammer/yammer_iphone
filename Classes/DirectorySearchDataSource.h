#import <Three20/Three20.h>

@interface DirectorySearchDataSource : TTSectionedDataSource {
  BOOL running;
  NSDate* created_at;
  NSString* searchText;
}

@property BOOL running;
@property (nonatomic, retain) NSDate* created_at;
@property (nonatomic, retain) NSString* searchText;

- (void)search:(NSString*)text;

@end
