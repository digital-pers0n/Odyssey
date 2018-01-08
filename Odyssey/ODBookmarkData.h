//
//  ODBookmarkData.h
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;

/* Dictionary Keys */

#define TITLE_KEY @"Title"
#define ADDRESS_KEY @"URLString"
#define CHILDREN_KEY @"Children"

/*  */
#define TYPE_KEY @"BookmarkType"
#define LEAF @"BookmarkTypeLeaf"
#define LIST @"BookmarkTypeList"

#define ICON_KEY @"Icon"

#define DIRECTORY_KEY @"Directory"

/* Save Path */
#define BOOKMARKS_SAVE_PATH [@"~/Library/Application Support/Odyssey/WebBookmarks.plist" stringByExpandingTildeInPath]


@interface ODBookmarkData : NSObject <NSPasteboardWriting, NSPasteboardReading>

-(id)initLeafWithTitle:(NSString *)title address:(NSString *)address;
-(id)initListWithTitle:(NSString *)title content:(NSArray *)content;
-(id)initWithData:(NSDictionary *)bookmarkData;


@property NSDictionary *data;

@property NSString *title;
@property NSString *address;
@property NSArray *children;

@property (readonly, getter=isList) BOOL list;

@end
