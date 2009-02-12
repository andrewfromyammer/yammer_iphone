//
//  MessageWebView.h
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageWebView : UIWebView <UIWebViewDelegate> {

}

- (id)init;
- (void)setHTML:(NSMutableDictionary *)message bgcolor:(NSString *)bgcolor;


@end
