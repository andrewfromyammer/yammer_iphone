#import <Three20/Three20.h>

@interface MockAddressBook : NSObject <TTModel> {
  NSMutableArray* _delegates;
  NSMutableArray* _names;
  NSArray* _allNames;
  NSTimer* _fakeSearchTimer;
  NSTimeInterval _fakeSearchDuration;
}

@property(nonatomic,retain) NSArray* names;
@property(nonatomic) NSTimeInterval fakeSearchDuration;

+ (NSMutableArray*)fakeNames;

- (id)initWithNames:(NSArray*)names;

- (void)loadNames;
- (void)search:(NSString*)text;

@end

@interface DirectorySearchDataSource : TTSectionedDataSource {
  MockAddressBook* _addressBook;
  NSDate* _created_at;
  NSString* _typedText;
}

@property(nonatomic,readonly) MockAddressBook* addressBook;
@property (nonatomic,retain) NSDate* created_at;
@property (nonatomic,retain) NSString* typedText;

- (id)initWithDuration:(NSTimeInterval)duration;

@end
