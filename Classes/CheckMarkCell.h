
#import <Three20/Three20.h>

@interface CheckMarkTTTableTextItem : TTTableTextItem {
  BOOL isChecked;
}
@property BOOL isChecked;

+ (CheckMarkTTTableTextItem*)text:(NSString*)text isChecked:(BOOL)isChecked;

@end

@interface CheckMarkCell : TTTableTextItemCell;
@end

@interface CheckMarkDataSource : TTSectionedDataSource;
@end
