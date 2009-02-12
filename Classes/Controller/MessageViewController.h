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
  NSMutableArray *theList;
  int theIndex;  
  MessageWebView *webView;
  UISegmentedControl *upDownArrows;
  
  UIImageView *image;
  UIImageView *lockImage;
  UILabel *fromLine;
  UILabel *timeLine;  
}

@property (nonatomic,retain) NSMutableArray *theList;
@property (nonatomic,retain) MessageWebView *webView;
@property (nonatomic,retain) UISegmentedControl *upDownArrows;
@property int theIndex;
@property (nonatomic,retain) UIImageView *image;
@property (nonatomic,retain) UIImageView *lockImage;
@property (nonatomic,retain) UILabel *fromLine;
@property (nonatomic,retain) UILabel *timeLine;

- (id)initWithBooleanForThreadIcon:(BOOL)showTheadIcon list:(NSMutableArray *)list index:(int)index;


@end
