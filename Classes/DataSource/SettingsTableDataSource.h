//
//  FeedsTableDataSource.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsTableDataSource : NSObject <UITableViewDataSource> {
  NSString *email;
}

@property (nonatomic,retain) NSString *email;

- (id)initWithDict:(NSMutableDictionary *)dict;


@end
