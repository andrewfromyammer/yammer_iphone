#import <UIKit/UIKit.h>
#import "SpinnerWithText.h"

@interface ComposeMessageController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
  UITextView *input;
  SpinnerWithText *topSpinner;
  SpinnerWithText *previousSpinner;
  NSData *imageData;
  UIToolbar *bar;
  NSString *undoBuffer; 
  NSMutableDictionary *meta;
}

@property (nonatomic,retain) UITextView *input;
@property (nonatomic,retain) SpinnerWithText *topSpinner;
@property (nonatomic,retain) SpinnerWithText *previousSpinner;
@property (nonatomic,retain) NSData *imageData;
@property (nonatomic,retain) UIToolbar *bar;
@property (nonatomic,retain) NSString *undoBuffer;
@property (nonatomic,retain) NSMutableDictionary *meta;

- (void)sendMessage;
- (id)initWithSpinner:(SpinnerWithText *)spinner meta:(NSMutableDictionary *)metaInfo;
- (void)sendUpdate:(NSString *)text;
- (void)photoSelect;
- (void)setSendEnabledState;
- (void)trashIt;
- (void)undoIt;
- (void)removePhoto;
- (void)replaceButton:(UIBarButtonItem*)item index:(int)index;
- (UIBarButtonItem *)trashButton;
- (UIBarButtonItem *)cameraButton;

@end
