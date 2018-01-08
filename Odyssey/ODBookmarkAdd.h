//
//  ODBookmarkAdd.h
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODBookmarkData;

@interface ODBookmarkAdd : NSViewController

-(void)addBookmark:(ODBookmarkData *)bookmark bookmarksTreeData:(NSDictionary *)treeData withReply:(void (^)(NSDictionary *newTreeData))respond;

@end
