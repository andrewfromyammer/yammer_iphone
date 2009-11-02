
#import "SettingsTimeChooser.h"
#import "MainTabBar.h"
#import "SettingsPush.h"

@implementation SettingsTimeChooser

@synthesize myPickerView, pickerViewArray, key;


- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [super initWithNavigatorURL:URL query:query]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    int hour = [[query objectForKey:@"hour"] intValue];
    self.key = [query objectForKey:@"key"];
    
    self.title = @"Resume Time";
    if ([key isEqualToString:@"sleep_hour_start"])
      self.title = @"Stop Time";
      
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    pickerViewArray = [[NSArray arrayWithObjects:
                        @"1:00", 
                        @"2:00",
                        @"3:00", 
                        @"4:00", 
                        @"5:00", 
                        @"6:00",
                        @"7:00",
                        @"8:00",
                        @"9:00",
                        @"10:00",
                        @"11:00",
                        @"12:00", 
                        nil] retain];
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
    myPickerView.frame = CGRectMake(	0.0, 0.0, pickerSize.width, pickerSize.height);
    
    myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    myPickerView.showsSelectionIndicator = YES;
    
    myPickerView.delegate = self;
    myPickerView.dataSource = self;	
    
    if (hour == 0) {
      [myPickerView selectRow:11 inComponent:0 animated:NO];
      [myPickerView selectRow:0 inComponent:1 animated:NO];
    } else if (hour < 13) {
      [myPickerView selectRow:hour-1 inComponent:0 animated:NO];
      [myPickerView selectRow:0 inComponent:1 animated:NO];
    } else if (hour > 12) {
      [myPickerView selectRow:hour-13 inComponent:0 animated:NO];
      [myPickerView selectRow:1 inComponent:1 animated:NO];
    }
    
    [self.view addSubview:myPickerView];

  }
  return self;
}

- (void)viewDidLoad {		
	[super viewDidLoad];	
}

- (void)showPicker:(UIView *)picker {
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  UINavigationController* nav = (UINavigationController*)[self parentViewController];
  SettingsPush* sp = (SettingsPush*)[[nav viewControllers] objectAtIndex:1];
  [sp updateTime:[pickerView selectedRowInComponent:0] ampm:[pickerView selectedRowInComponent:1] key:self.key];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *returnStr = @"";
	
	if (pickerView == myPickerView)	{
		if (component == 0) {
			returnStr = [pickerViewArray objectAtIndex:row];
		}
		else {
      if (row == 0)
        return @"AM";
      return @"PM";
		}
	}
	
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	CGFloat componentWidth = 0.0;
  
	if (component == 0)
		componentWidth = 200.0;	// first column size is wider to hold names
	else
		componentWidth = 70.0;	// second column is narrower to show numbers
  
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  if (component == 0)
    return [pickerViewArray count];
  return 2;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(pickerViewArray);
  TT_RELEASE_SAFELY(myPickerView);
  TT_RELEASE_SAFELY(key);
	[super dealloc];
}

@end
