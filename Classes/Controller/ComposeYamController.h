#import <UIKit/UIKit.h>
#import "SpinnerWithText.h"

@interface ComposeYamController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
  UITextView *input;
  SpinnerWithText *topSpinner;
  SpinnerWithText *previousSpinner;
  NSData *imageData;
  UIToolbar *bar;
  NSString *undoBuffer; 
}

@property (nonatomic,retain) UITextView *input;
@property (nonatomic,retain) SpinnerWithText *topSpinner;
@property (nonatomic,retain) SpinnerWithText *previousSpinner;
@property (nonatomic,retain) NSData *imageData;
@property (nonatomic,retain) UIToolbar *bar;
@property (nonatomic,retain) NSString *undoBuffer;

- (void)sendMessage;
- (id)initWithSpinner:(SpinnerWithText *)spinner;
- (void)sendUpdate:(NSString *)text;
- (void)photoSelect;
- (void)setSendEnabledState;
- (void)trashIt;
- (void)undoIt;
- (void)replaceButton:(UIBarButtonItem*)item index:(int)index;
- (UIBarButtonItem *)trashButton;

@end
