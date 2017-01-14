//
//  ODWebBookmarksOutlineViewController.h
//  Bookmarks-Playground
//
//  Created by Terminator on 10/11/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODWebBookmarksOutlineViewController : NSViewController

- (instancetype)initWithData:(NSDictionary *)data;

-(NSDictionary *)saveAtPath:(NSString *)path;
-(NSDictionary *)newData;

@end
