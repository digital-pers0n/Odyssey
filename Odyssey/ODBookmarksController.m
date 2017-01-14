//
//  ODBookmarksController.m
//  Odyssey
//
//  Created by Terminator on 10/21/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODBookmarksController.h"
#import "ODWebBookmarkData.h"
#import "ODAddBookmarkDialogController.h"
#import "ODWebBookmarksOutlineViewController.h"
#import "ODController.h"
#import "ODWindowController.h"
#import "AppDelegate.h"
#import "Bookmarks.h"

#import <WebKit/WebKit.h>

@interface ODBookmarksController ()
{
    NSMenu *_menu;
    ODWebBookmarksOutlineViewController *_editor;
    ODController *_controller;
    NSDictionary *_bookmarks;
    
}

@end

@implementation ODBookmarksController


- (instancetype)init
{
    self = [super init];
    if (self) {
        
       self->_bookmarks = [NSDictionary dictionaryWithContentsOfFile:BOOKMARKS_SAVE_PATH];
        
        if (!self->_bookmarks) {
            self->_bookmarks = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"WebBookmarks"
                                                               ofType: @"plist"]];
        }
        
        self->_menu = [[NSMenu alloc] initWithTitle:@"Bookmarks"];
        
        [self->_menu insertItem:[NSMenuItem separatorItem] atIndex:0];
        [[self->_menu itemAtIndex:0] setTag:1004];
        

        
        [self->_menu insertItemWithTitle:@"Add Bookmarks for Open Tabs..." action:@selector(addBookmark:) keyEquivalent:@"" atIndex:0];
        [[self->_menu itemAtIndex:0] setTag:1003];
        [self->_menu itemAtIndex:0].target = self;
        
        [self->_menu insertItemWithTitle:@"Add Bookmark Folder..." action:@selector(addBookmark:) keyEquivalent:@"" atIndex:0];
        [[self->_menu itemAtIndex:0] setTag:1002];
        [self->_menu itemAtIndex:0].target = self;
        
        [self->_menu insertItemWithTitle:@"Edit Bookmarks" action:@selector(bookmarksEditor:) keyEquivalent:@"E" atIndex:0];
        [[self->_menu itemAtIndex:0] setTag:1001];
        [self->_menu itemAtIndex:0].target = self;
        [self->_menu insertItemWithTitle:@"Add Bookmark..." action:@selector(addBookmark:) keyEquivalent:@"B" atIndex:0];
        [[self->_menu itemAtIndex:0] setTag:1000];
        [self->_menu itemAtIndex:0].target = self;
        
        [self updateMenu];
        
        self->_controller = [[NSApp delegate] performSelector:@selector(controller)];
        
        
    }
    return self;
}

#pragma mark - Editor
-(void)bookmarksEditor:(id)sender
{
    if (_editor) {
        NSDictionary *dict = [_editor saveAtPath:BOOKMARKS_SAVE_PATH];
        if (dict) {
            _bookmarks = dict;
        }
        [_editor.view removeFromSuperview];
        _editor = nil;
        [self updateMenu];
        
        return;
    }
    
//    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:BOOKMARKS_SAVE_PATH];
//    
//    if (!data) {
//        data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
//                                                           pathForResource:@"WebBookmarks"
//                                                           ofType: @"plist"]];
//    }
    _editor = [[ODWebBookmarksOutlineViewController alloc] initWithData:_bookmarks];
    [_editor loadView];
    [[NSApp mainWindow].contentView addSubview:_editor.view];
    [_editor.view setFrameSize:NSMakeSize(NSWidth([NSApp mainWindow].contentView.frame), NSHeight([NSApp mainWindow].contentView.frame))];
    [_editor.view setNeedsDisplay:YES];
    [[NSApp mainWindow] makeFirstResponder:_editor];   
}

#pragma mark - Add Bookmark
-(void)addBookmark:(id)sender
{

    
//    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:BOOKMARKS_SAVE_PATH];
//    
//    if (!data) {
//        data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
//                                                           pathForResource:@"WebBookmarks"
//                                                           ofType: @"plist"]];
//    }
    
    ODAddBookmarkDialogController *dialog; 
    //ODWebBookmarkData *bookmark;

    
    BOOL addBookmark = NO;
    BOOL addBookmarks = NO;
    BOOL addFolder = NO;
  
    
    NSUInteger tag = [sender tag];
    switch (tag) {
        case 1000:
            addBookmark = YES;
            break;
            
        case 1002:
            addFolder = YES;
            break;
            
        case 1003:
            addBookmarks = YES;

            break;
            
        default:
            break;
    }
    
    if (addBookmark) {
        WebView *web = [_controller webView];
        NSDictionary *bookmark = @{TITLE_KEY: [web mainFrameTitle], ADDRESS_KEY: [web mainFrameURL]};
        ODWebBookmarkData *item =  [[ODWebBookmarkData alloc] initWithData:bookmark];
        
          dialog = [[ODAddBookmarkDialogController alloc] initWithBookmark:item andDirectories:_bookmarks];
    }
    
    if (addBookmarks) {
        
        ODWindowController *ctl = [[NSApp mainWindow] windowController];
        
        NSArray *tabs = [ctl tabsList];
        NSMutableArray *bookmarks = [NSMutableArray new];
        for (NSDictionary *dict in tabs) {
            ODWebBookmarkData *item = [[ODWebBookmarkData alloc] initWithTitle:dict[@"TabTitle"] address:dict[@"TabURL"]];
            [bookmarks addObject:item];
        }
        
        
        NSDate *date = [NSDate date];
        NSString *name = [NSString stringWithFormat:@"Saved Tabs - %@", 
                          [NSDateFormatter localizedStringFromDate:date 
                                                         dateStyle:NSDateFormatterLongStyle 
                                                         timeStyle:NSDateFormatterMediumStyle]];
        
        ODWebBookmarkData *folder = [[ODWebBookmarkData alloc] initListWithTitle:name content:bookmarks];
        
        dialog = [ODAddBookmarkDialogController new];
        [dialog setDirectories:_bookmarks];
        [dialog addBookmarkFolder:folder];
        
        
        
//        dialog = [[ODAddBookmarkDialogController alloc] initWithBookmarks:bookmark andDirectories:_bookmarks];
    }
    
    if (addFolder) {
        
        ODWebBookmarkData *folder = [[ODWebBookmarkData alloc] initListWithTitle:@"Folder" content:@[]];
        
        dialog = [ODAddBookmarkDialogController new];
        [dialog setDirectories:_bookmarks];
        [dialog addBookmarkFolder:folder];
    }
    
    
    if (![dialog wasCancelled]) {
        NSDictionary *data = dialog.bookmarkData;
        

        if (data) {
            _bookmarks = data;
        }
        
        [self updateMenu];
    }
    
}

#pragma mark - Load Bookmarks
-(void)loadBookmark:(id)sender
{
       WebView *web = [_controller webView];
    [web setMainFrameURL:[sender toolTip]];
}

-(void)openInTabs:(id)sender
{
    BOOL newWindow = NO;
    if ([NSEvent modifierFlags] == NSAlternateKeyMask) {
        newWindow = YES;
    }
    NSMenu *menu = [sender menu];
    NSMutableArray *addressList = [NSMutableArray new];
    for (NSMenuItem *item in menu.itemArray) {
        if (item.tag == 150) {
            [addressList addObject:[item toolTip]];
        }
        
    }
    
    if (newWindow) {
        [_controller newWindowWithTabs:addressList];
    } else {
        [_controller openTabsInExistingWindow:addressList];
    }
}

#pragma mark - Bookmark menu

-(NSMenu *)menuFromData:(NSDictionary *)data
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:data[TITLE_KEY]];
    NSArray *children = data[CHILDREN_KEY];
   
    
    
    for (NSDictionary *a in children) {
        NSMenuItem *item = [NSMenuItem new];
        
        if ([a[TYPE_KEY] isEqualToString:LIST]) {
            
            item.title = a[TITLE_KEY];
            item.submenu = [self menuFromData:a];
            item.tag = 100;
            [menu addItem:item];
            //            NSMenuItem *openAll = [[NSMenuItem alloc] initWithTitle:@"Open All In Tabs" action:@selector(showWindow:) keyEquivalent:@""];
            //            [openAll setTarget:self];
            //            //[menu addItem:openAll];
        } else {
            item.title = a[TITLE_KEY];
            item.action = @selector(loadBookmark:);
            item.target = self;
            item.toolTip = a[ADDRESS_KEY];
            item.tag = 150;
            [menu addItem:item];
        }
    }
    
    if (![data[TITLE_KEY] isEqualToString:@"BookmarksRoot"] && children.count > 0) {
        NSMenuItem *item = [NSMenuItem separatorItem];
        [menu addItem:item];
        item = [[NSMenuItem alloc] initWithTitle:@"Open In Tabs" action:@selector(openInTabs:) keyEquivalent:@""];
        [item setTarget:self];
        [item setTag:100];
        [item setToolTip:@"Hold 'Option' to open in a new window"];
        [menu addItem:item];
        //[menu addItemWithTitle:@"Open All" action:@selector(openAllBookmarksInFolder:) keyEquivalent:@""];
        
    }
    
    return menu;
    
}

-(void)updateMenu
{
    
//    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:BOOKMARKS_SAVE_PATH];
//    
//    if (!data) {
//        data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
//                                                           pathForResource:@"WebBookmarks"
//                                                           ofType: @"plist"]];
//    }
    
    NSArray *items = _menu.itemArray;
    
    for (NSMenuItem *a in items) {
        if (a.tag == 100 || a.tag == 150) {
            [_menu removeItem:a];
        }
    }
    
    NSMenu *bookmarks = [self menuFromData:_bookmarks];
    
    items = bookmarks.itemArray;
    for (NSMenuItem *a in items) {
        
        [bookmarks removeItem:a];
        [_menu addItem:a];
    }
    
 
//    self->_menu.title = @"Bookmarks";
//    [self->_menu insertItem:[NSMenuItem separatorItem] atIndex:0];
//    [self->_menu insertItemWithTitle:@"Edit Bookmarks" action:@selector(bookmarksEditor) keyEquivalent:@"E" atIndex:0];
//    [self->_menu itemAtIndex:0].target = self;
//    [self->_menu insertItemWithTitle:@"Bookmark Page" action:@selector(bookmarkForWebView:) keyEquivalent:@"B" atIndex:0];
//    [self->_menu itemAtIndex:0].target = self;
//  
    [[[NSApp mainMenu] itemWithTag:100] setSubmenu:_menu];
}

@end
