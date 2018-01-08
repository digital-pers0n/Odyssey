//
//  ODBookmarks.h
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;

#define BOOKMARKS_TAB_TAG 1001

@interface ODBookmarks : NSObject

-(void)showFavorites:(id)sender;

-(void)updateMenu;
@property NSDictionary *bookmarksTreeData;


@end
