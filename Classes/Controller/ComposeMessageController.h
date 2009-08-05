#import <UIKit/UIKit.h>
#import "SpinnerWithText.h"

@interface ComposeMessageController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
  UITextView *input;
  NSData *imageData;
  UIToolbar *bar;
  NSString *undoBuffer; 
  NSString *sendingBuffer; 
  NSMutableDictionary *meta;
  UILabel *topLabel;
}

@property (nonatomic,retain) IBOutlet UITextView *input;
@property (nonatomic,retain) IBOutlet UILabel *topLabel;
@property (nonatomic,retain) NSData *imageData;
@property (nonatomic,retain) IBOutlet UIToolbar *bar;
@property (nonatomic,retain) NSString *undoBuffer;
@property (nonatomic,retain) NSString *sendingBuffer;
@property (nonatomic,retain) NSMutableDictionary *meta;

+ (UINavigationController *)getNav:(NSMutableDictionary *)metaInfo;
- (void)sendMessage;
- (id)initWithMeta:(NSMutableDictionary *)metaInfo;
- (void)sendUpdate;
- (void)photoSelect;
- (void)setSendEnabledState;
- (void)trashIt;
- (void)undoIt;
- (void)removePhoto;
- (void)replaceButton:(UIBarButtonItem*)item index:(int)index;
- (UIBarButtonItem *)trashButton;
- (UIBarButtonItem *)cameraButton;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;
- (UIImage *)resizeImage:(UIImage *)image;
- (void)setBarY;

@end
