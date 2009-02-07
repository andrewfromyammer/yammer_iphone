//
//  DirectoryUserDataSource.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirectoryUserDataSource : NSObject <UITableViewDataSource> {
  NSMutableDictionary *userData;
}

@property (nonatomic,retain) NSMutableDictionary *userData;

- (id)initWithDict:(NSMutableDictionary *)dict;


@end



