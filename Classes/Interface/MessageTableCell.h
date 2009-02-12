//
//  MessageTableCell.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageTableCell : UITableViewCell {
  UILabel *fromLabel;
  UILabel *previewLabel;
  UILabel *timeLabel;
  UIImageView *paperclip_image;
  UIImageView *lock_image;
  bool paperclip;
  bool priv_lock;
  int length;
}

@property (nonatomic, retain) UILabel *fromLabel;
@property (nonatomic, retain) UILabel *previewLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIImageView *paperclip_image;
@property (nonatomic, retain) UIImageView *lock_image;
@property bool paperclip;
@property bool priv_lock;
@property int length;


- (void)setMessage:(NSMutableDictionary *)message;

@end
