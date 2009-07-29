//
//  SpinnerViewController.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ComposeMessageController.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"


@implementation ComposeMessageController

@synthesize input;
@synthesize topSpinner;
@synthesize previousSpinner;
@synthesize imageData;
@synthesize bar;
@synthesize undoBuffer;
@synthesize meta;
@synthesize sendingBuffer;

- (id)initWithSpinner:(SpinnerWithText *)spinner meta:(NSMutableDictionary *)metaInfo {
  self.meta = metaInfo;
  self.previousSpinner = spinner;
  return self;
}

- (void)loadView {
  UIView *wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  wrapper.backgroundColor = [UIColor whiteColor];
  
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
  
  UIBarButtonItem *draft=[[UIBarButtonItem alloc] init];
  draft.title=@"Close";
  draft.target = self;
  draft.action = @selector(dismissModalViewControllerAnimated:);
  
  UIBarButtonItem *send=[[UIBarButtonItem alloc] init];
  send.title=@"Send";
  send.target = self;
  send.action = @selector(sendMessage);
  
  
  self.navigationItem.rightBarButtonItem = send;  
  self.navigationItem.leftBarButtonItem = draft;
  
  
  self.topSpinner = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];  
  [self.topSpinner.displayText setText:[meta objectForKey:@"display"]];
  
  self.input = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, 320, 125)];
  [self.input setFont:[UIFont systemFontOfSize:16]];
  self.input.text = [LocalStorage getDraft];
  [self setSendEnabledState];
  [self.input setDelegate:self];
  
  self.bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 166, 320, 35)];
    
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];  
  
  NSMutableArray *items = [NSMutableArray arrayWithObjects: [self trashButton], flexItem, [self cameraButton], nil];
  [bar setItems:items animated:NO];

  [wrapper addSubview:self.topSpinner];
  [wrapper addSubview:self.input];
  [wrapper addSubview:bar];
  
  self.view = wrapper;
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
    
    [self.topSpinner showTheSpinner:@"Sending message..."];
    [NSThread detachNewThreadSelector:@selector(sendUpdate) toTarget:self withObject:nil];
  }
}

- (void)closeIt {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendUpdate {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if ([APIGateway createMessage:self.sendingBuffer repliedToId:[meta objectForKey:@"replied_to_id"] 
                        groupId:[meta objectForKey:@"group_id"] 
                        imageData:self.imageData]) {
    [LocalStorage saveDraft:@""];
    self.sendingBuffer = nil;
    [self performSelectorOnMainThread:@selector(closeIt) withObject:nil waitUntilDone:NO];
    //[self.previousSpinner hideTheSpinner:@"Message sent."];
  } else {
    [self.topSpinner hideTheSpinner:@"Message not sent."];
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
  YammerAppDelegate *yad = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  [actionSheet showInView:yad.window];
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

    YammerAppDelegate *yad = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
    [yad.window addSubview:picker.view];
  } @catch (NSException *theErr) {
    [input becomeFirstResponder];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker.view removeFromSuperview];
  [input becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
  self.imageData = UIImageJPEGRepresentation(image, 90);
  [picker.view removeFromSuperview];
  UIBarButtonItem *removePhoto = [[UIBarButtonItem alloc] initWithTitle:@"Remove Photo" style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(removePhoto)];
  [self replaceButton:removePhoto index:2];
  [input becomeFirstResponder];
}

- (void)removePhoto {
  self.imageData = nil;
  [self replaceButton:[self cameraButton] index:2];
}


- (void)dealloc {
  [input release];
  [topSpinner release];
  [previousSpinner release];
  [imageData release];
  [bar release];
  [undoBuffer release];
  [meta release];
  [sendingBuffer release];
  [super dealloc];
}


@end
