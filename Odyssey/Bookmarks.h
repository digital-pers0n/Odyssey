//
//  Bookmarks.h
//  Bookmarks-Playground
//
//  Created by Terminator on 10/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#ifndef Bookmarks_h
#define Bookmarks_h

#define TITLE_KEY @"Title"
#define ADDRESS_KEY @"URLString"
#define CHILDREN_KEY @"Children"
#define TYPE_KEY @"BookmarkType"
#define LEAF @"BookmarkTypeLeaf"
#define LIST @"BookmarkTypeList"

#define ICON_KEY @"Icon"

#define DIRECTORY_KEY @"Directory"

#define APPLICATION_SUPPORT_PATH [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] 

#define BOOKMARKS_SAVE_PATH [@"~/Library/Application Support/void.digital-person.Odyssey/WebBookmarks.plist" stringByExpandingTildeInPath]
#define SESSION_SAVE_PATH   [@"~/Library/Application Support/void.digital-person.Odyssey/WebSession.plist" stringByExpandingTildeInPath]

//#define BOOKMARKS_SAVE_PATH [@"~/WebBookmarksNew.plist" stringByExpandingTildeInPath]
//#define SESSION_SAVE_PATH   [@"~/WebSession.plist" stringByExpandingTildeInPath]

#endif /* Bookmarks_h */
