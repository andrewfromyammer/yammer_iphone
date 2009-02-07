//
//  ReplyViewController.h
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReplyViewController : UIViewController <UITextFieldDelegate> {
  UITextField *input;
  NSMutableDictionary *message;
}

@property (nonatomic,retain) UITextField *input;
@property (nonatomic,retain) NSMutableDictionary *message;

- (id)initWithMessage:(NSMutableDictionary *)dict;

@end
