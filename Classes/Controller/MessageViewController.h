//
//  MessageViewController.h
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageWebView.h"

@interface MessageViewController : UIViewController {
  NSArray *theList;
  BOOL threadIcon;
  int theIndex;  
  MessageWebView *webView;
  UISegmentedControl *upDownArrows;
  
  UIImageView *image;
  UIImageView *lockImage;
  UILabel *fromLine;
  UILabel *timeLine;  
  UIToolbar *toolbar;
}

@property (nonatomic,retain) NSArray *theList;
@property (nonatomic,retain) MessageWebView *webView;
@property (nonatomic,retain) UISegmentedControl *upDownArrows;
@property int theIndex;
@property BOOL threadIcon;
@property (nonatomic,retain) UIImageView *image;
@property (nonatomic,retain) UIImageView *lockImage;
@property (nonatomic,retain) UILabel *fromLine;
@property (nonatomic,retain) UILabel *timeLine;
@property (nonatomic,retain) UIToolbar *toolbar;

- (id)initWithBooleanForThreadIcon:(BOOL)showThreadIcon list:(NSArray *)list index:(int)index;
- (void)setupToolbar:(BOOL)showUserIcon;

@end
