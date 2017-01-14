//
//  ODAddBookmarkDialogController.h
//  Bookmarks-Playground
//
//  Created by Terminator on 10/10/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ODWebBookmarkData;

@interface ODAddBookmarkDialogController : NSWindowController

-(id)initWithBookmark:(ODWebBookmarkData *)bookmark andDirectories:(NSDictionary *)data;




-(IBAction)okButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

-(id)editBookmark:(id)bookmark;
-(void)addBookmarkFolder:(ODWebBookmarkData *)data;
-(void)setDirectories:(NSDictionary *)data;
-(NSDictionary *)bookmarkData;

-(BOOL)wasCancelled;

@end
