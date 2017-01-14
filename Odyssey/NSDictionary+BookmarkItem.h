//
//  NSDictionary+BookmarkItem.h
//  Bookmarks-Playground
//
//  Created by Terminator on 10/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BookmarkItem)

-(NSString *)title;
-(NSString *)address;
-(BOOL)isDirectory;
-(NSArray *)directoryContent;


@end
