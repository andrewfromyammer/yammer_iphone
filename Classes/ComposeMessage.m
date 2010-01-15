//
//  SpinnerViewController.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ComposeMessage.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"
#import "MainTabBar.h"


@implementation ComposeMessage

@synthesize input;
@synthesize imageData;
@synthesize bar;
@synthesize undoBuffer;
@synthesize meta;
@synthesize sendingBuffer;
@synthesize topLabel;

+ (UINavigationController *)getNav:(NSMutableDictionary *)metaInfo {
  ComposeMessage *compose = [[ComposeMessage alloc] initWithMeta:metaInfo];
  UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:compose];
  [modal.navigationBar setTintColor:[MainTabBar yammerGray]];
  return modal;
}

- (id)initWithMeta:(NSMutableDictionary *)metaInfo {
  [super initWithNibName:@"ComposeMessage" bundle:nil];
  //self.title = [metaInfo objectForKey:@"display"];
  self.meta = metaInfo;
  return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)handleClose {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
  //[self.topLabel setText:[meta objectForKey:@"display"]];
  //self.navigationItem.titleView = self.topLabel;
  self.title = [meta objectForKey:@"display"];

  UIBarButtonItem *draft=[[UIBarButtonItem alloc] init];
  draft.title=@"Close";
  draft.target = self;
  draft.action = @selector(handleClose);
  
  UIBarButtonItem *send=[[UIBarButtonItem alloc] init];
  send.title=@"Send";
  send.target = self;
  send.action = @selector(sendMessage);

  self.navigationItem.rightBarButtonItem = send;  
  self.navigationItem.leftBarButtonItem = draft;
  
  self.input.text = [LocalStorage getDraft];
  [self setSendEnabledState];
  [self.input setDelegate:self];

  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];  
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: [self trashButton], flexItem, [self cameraButton], nil];
  [bar setItems:items animated:NO];
  
  [self setBarY];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self setBarY];
}

- (void)setBarY {
  // 71
  if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    self.bar.frame = CGRectMake(self.bar.frame.origin.x, 200, self.bar.frame.size.width, self.bar.frame.size.height);  
  else
    self.bar.frame = CGRectMake(self.bar.frame.origin.x, 156, self.bar.frame.size.width, self.bar.frame.size.height);
}

- (void)replaceButton:(UIBarButtonItem*)item index:(int)index {
  NSMutableArray *items = [bar.items mutableCopy];
  [items replaceObjectAtIndex:index withObject:item];
  [bar setItems:items animated:false];
  [items release];
}

- (void)trashIt {
  self.undoBuffer = [NSString stringWithString:input.text];
  input.text = @"";
  UIBarButtonItem *undo = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(undoIt)];
  [self replaceButton:undo index:0];
}

- (UIBarButtonItem *)trashButton {
  UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                         target:self
                                                                         action:@selector(trashIt)];
  trash.style = UIBarButtonItemStyleBordered;
  return trash;
}

- (UIBarButtonItem *)cameraButton {
  UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                         target:self
                                                                         action:@selector(photoSelect)];
  camera.style = UIBarButtonItemStyleBordered;  
  return camera;
}

- (void)undoIt {
  [self.input setText:self.undoBuffer];
  self.undoBuffer = nil;
  [self replaceButton:[self trashButton] index:0];
}

- (void)setSendEnabledState {
  if ([[self.input.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0)
    self.navigationItem.rightBarButtonItem.enabled = true;
  else
    self.navigationItem.rightBarButtonItem.enabled = false;
}

- (void)viewDidAppear:(BOOL)animated {
  [input becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
  if (self.sendingBuffer) {
    [self.input setText:self.sendingBuffer];
    return;
  }
  [LocalStorage saveDraft:textView.text];
  [self setSendEnabledState];
  if (self.undoBuffer != nil && [textView hasText]) {
    self.undoBuffer = nil;
    [self replaceButton:[self trashButton] index:0];
  }
}

- (void)sendMessage {
  self.input.text = [self.input.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([self.input hasText]) {
    self.sendingBuffer = [NSString stringWithString:self.input.text];
    
    self.navigationItem.leftBarButtonItem.enabled = false;
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    UIBarButtonItem *button = (UIBarButtonItem *)[bar.items objectAtIndex:0];
    button.enabled = false;
    button = (UIBarButtonItem *)[bar.items objectAtIndex:2];
    button.enabled = false;
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  
    [NSThread detachNewThreadSelector:@selector(sendUpdate) toTarget:self withObject:nil];
  }
}

- (void)closeIt {
  [self dismissModalViewControllerAnimated:YES];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                  message:@"Message sent to yammer." delegate:nil 
                                        cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
  [alert release];
}

- (void)sendUpdate {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if ([APIGateway createMessage:self.sendingBuffer repliedToId:[meta objectForKey:@"replied_to_id"] 
                        groupId:[meta objectForKey:@"group_id"] 
                        imageData:self.imageData]) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    [LocalStorage saveDraft:@""];
    self.sendingBuffer = nil;
    [self performSelectorOnMainThread:@selector(closeIt) withObject:nil waitUntilDone:NO];
  } else {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.sendingBuffer = nil;    
    self.navigationItem.leftBarButtonItem.enabled = true;
    self.navigationItem.rightBarButtonItem.enabled = true;
    
    UIBarButtonItem *button = (UIBarButtonItem *)[bar.items objectAtIndex:0];
    button.enabled = true;
    button = (UIBarButtonItem *)[bar.items objectAtIndex:2];
    button.enabled = true;    
  }

  [autoreleasepool release];
}

- (void)photoSelect {  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [input resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;      
    [[[UIApplication sharedApplication] keyWindow] addSubview:picker.view];
    return;
  }
    
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
  [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 2)
    return;
  
  [input resignFirstResponder];
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  
  @try {
    if (buttonIndex == 0)
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [[[UIApplication sharedApplication] keyWindow] addSubview:picker.view];
  } @catch (NSException *theErr) {
    [input becomeFirstResponder];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker.view removeFromSuperview];
  [input becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
  [picker.view removeFromSuperview];
  self.imageData = UIImageJPEGRepresentation([self scaleAndRotateImage:image], 90);
  UIBarButtonItem *removePhoto = [[UIBarButtonItem alloc] initWithTitle:@"Remove Photo" style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(removePhoto)];
  [self replaceButton:removePhoto index:2];
  [input becomeFirstResponder];
}

- (UIImage *)resizeImage:(UIImage *)image {
	int w = image.size.width;
  int h = image.size.height; 
	
	CGImageRef imageRef = [image CGImage];
	
	int width, height;
	
	int destWidth = 640;
	int destHeight = 480;
	if(w > h){
		width = destWidth;
		height = h*destWidth/w;
	} else {
		height = destHeight;
		width = w*destHeight/h;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
	CGContextRef bitmap;
	bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, M_PI/2);
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, -M_PI/2);
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, -M_PI);
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;	
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
  int kMaxResolution = 640; // Or whatever
  
  CGImageRef imgRef = image.CGImage;
  
  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  CGRect bounds = CGRectMake(0, 0, width, height);
  if (width > kMaxResolution || height > kMaxResolution) {
    CGFloat ratio = width/height;
    if (ratio > 1) {
      bounds.size.width = kMaxResolution;
      bounds.size.height = bounds.size.width / ratio;
    }
    else {
      bounds.size.height = kMaxResolution;
      bounds.size.width = bounds.size.height * ratio;
    }
  }
  
  CGFloat scaleRatio = bounds.size.width / width;
  CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
  CGFloat boundHeight;
  UIImageOrientation orient = image.imageOrientation;
  switch(orient) {
      
    case UIImageOrientationUp: //EXIF = 1
      transform = CGAffineTransformIdentity;
      break;
      
    case UIImageOrientationUpMirrored: //EXIF = 2
      transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      break;
      
    case UIImageOrientationDown: //EXIF = 3
      transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationDownMirrored: //EXIF = 4
      transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
      transform = CGAffineTransformScale(transform, 1.0, -1.0);
      break;
      
    case UIImageOrientationLeftMirrored: //EXIF = 5
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;
      
    case UIImageOrientationLeft: //EXIF = 6
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;
      
    case UIImageOrientationRightMirrored: //EXIF = 7
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeScale(-1.0, 1.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;
      
    case UIImageOrientationRight: //EXIF = 8
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;
      
    default:
      [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
      
  }
  
  UIGraphicsBeginImageContext(bounds.size);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
    CGContextScaleCTM(context, -scaleRatio, scaleRatio);
    CGContextTranslateCTM(context, -height, 0);
  }
  else {
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
  }
  
  CGContextConcatCTM(context, transform);
  
  CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
  UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return imageCopy;
}

- (void)removePhoto {
  self.imageData = nil;
  [self replaceButton:[self cameraButton] index:2];
}


- (void)dealloc {
  [input release];
  [imageData release];
  [bar release];
  [undoBuffer release];
  [meta release];
  [sendingBuffer release];
  [topLabel release];
  [super dealloc];
}


@end
