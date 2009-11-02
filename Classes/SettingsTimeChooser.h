#import <Three20/Three20.h>

@interface SettingsTimeChooser : TTViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	UIPickerView	*myPickerView;
	NSArray				*pickerViewArray;	
	NSString			*key;
}

@property (nonatomic, retain) UIPickerView *myPickerView;
@property (nonatomic, retain) NSArray *pickerViewArray;
@property (nonatomic, retain) NSString *key;


@end
