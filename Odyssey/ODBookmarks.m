//
//  ODBookmarks.m
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODBookmarks.h"
#import "ODDelegate.h"
#import "ODBookmarksOutline.h"
#import "ODBookmarkData.h"
#import "ODBookmarkAdd.h"
#import "ODTabBar.h"
#import "ODTabItem.h"
#import "ODWindow.h"

@import WebKit;

@interface ODBookmarks () 
{
    NSMenu *_menu;
    ODBookmarksOutline *_editor;
    NSDictionary *_bookmarksTreeData;
    ODDelegate *_appDelegate;
}

@end

@implementation ODBookmarks

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _bookmarksTreeData = [NSDictionary dictionaryWithContentsOfFile:BOOKMARKS_SAVE_PATH];
        if(!_bookmarksTreeData) {
            _bookmarksTreeData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                             pathForResource:@"WebBookmarks"
                                                                             ofType: @"plist"]];
        }
        
        _menu = [[NSMenu alloc] initWithTitle:@"Bookmarks"];
        
        NSMenuItem *item = [NSMenuItem separatorItem];
        [_menu insertItem:item atIndex:0];
        [item setTag:1004];
        
        item = [_menu insertItemWithTitle:@"Add Bookmarks for Open Tabs..." action:@selector(addBookmark:) keyEquivalent:@"" atIndex:0];
        [item setTag:1003];
        item.target = self;
        
        item = [_menu insertItemWithTitle:@"Add Bookmark Folder..." action:@selector(addBookmark:) keyEquivalent:@"" atIndex:0];
        [item setTag:1002];
        item.target = self;
        
        item = [_menu insertItemWithTitle:@"Show Favorites" action:@selector(showFavorites:) keyEquivalent:@"B" atIndex:0];
        [item setTag:1005];
        item.target = self;
        item.keyEquivalentModifierMask = NSShiftKeyMask | NSCommandKeyMask;
        
        item = [_menu insertItemWithTitle:@"Edit Bookmarks" action:@selector(bookmarksEditor:) keyEquivalent:@"B" atIndex:0];
        [item setTag:1001];
        item.target = self;
        item.keyEquivalentModifierMask = NSAlternateKeyMask | NSCommandKeyMask;
        
        item = [_menu insertItemWithTitle:@"Add Bookmark..." action:@selector(addBookmark:) keyEquivalent:@"D" atIndex:0];
        [item setTag:1000];
        item.target = self;
        item.keyEquivalentModifierMask = 0;
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        
        [self updateMenu];
        
        _appDelegate = [NSApp delegate];
        
    }
    return self;
}

#pragma mark - Show Favorites

-(void)showFavorites:(id)sender
{
    NSMenuItem *item = [_menu itemWithTitle:@"Favorites"];
    [item.submenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

#pragma mark - Editor
-(void)bookmarksEditor:(id)sender
{
    
    ODBookmarksOutline *outline = [[ODBookmarksOutline alloc] initWithData:_bookmarksTreeData];
    NSView *view = outline.view;
    ODTabItem *tab = [[ODTabItem alloc] initWithView:view];
    tab.label = @"Bookmarks";
    tab.tag = BOOKMARKS_TAB_TAG;
    tab.representedObject = outline;
    ODWindow *window = (ODWindow *)[NSApp mainWindow];
    ODTabBar *tabBar = window.tabBar;
    [tabBar addTabItem:tab relativeToSelectedTab:YES];
    [tabBar selectTabItem:tab];
    NSRect frame = window.contentView.frame;
    [view setFrameSize:NSMakeSize(NSWidth(frame), NSHeight(frame))];
    [view setNeedsDisplay:YES];
    [window makeFirstResponder:outline.outlineView];
    
    
    
//    if (_editor) {
//        NSDictionary *dict = [_editor saveAtPath:BOOKMARKS_SAVE_PATH];
//        if (dict) {
//            _bookmarksTreeData = dict;
//        }
////        [_editor.view removeFromSuperview];
////        _editor = nil;
//        [self updateMenu];
//        
//        return;
//    }
//    
//    _editor = [[ODBookmarksOutline alloc] initWithData:_bookmarksTreeData];
//    [_editor loadView];
//    NSView *view = _editor.view;
//    ODTabItem *tab = [[ODTabItem alloc] initWithView:view];
//    tab.label = @"Bookmarks";
//    ODWindow *window = (ODWindow *)[NSApp mainWindow];
//    ODTabBar *tabBar = window.tabBar;
//    [tabBar addTabItem:tab relativeToSelectedTab:YES];
//    [tabBar selectTabItem:tab];
//    NSRect frame = window.frame;
//    [view setFrameSize:NSMakeSize(NSWidth(frame), NSHeight(frame))];
//    [view setNeedsDisplay:YES];
//    [window makeFirstResponder:view];   
}


#pragma mark - Add Bookmark
-(void)addBookmark:(id)sender
{
    
    
    ODBookmarkAdd *dialog;
    ODBookmarkData *bookmark;
    ODWindow *window = (ODWindow *)[NSApp mainWindow];
    ODTabBar *tabBar = window.tabBar;
    NSUInteger tag = [sender tag];
    
    if (tag == 1000) {
    
        ODTabItem *item = tabBar.selectedTabItem;
        if (item.type == ODTabTypeWebView) {
            WebView *webView = (id)item.view;
            bookmark =  [[ODBookmarkData alloc] initLeafWithTitle:item.label address:webView.mainFrameURL];
        }
      
      
    } else if (tag == 1003) {
        

        
        NSArray *tabs = tabBar.tabItems;
        
        
        NSMutableArray *bookmarks = [NSMutableArray new];
        WebView *webView;
        NSString *address;
        for (ODTabItem *item in tabs) {
            if (item.type == ODTabTypeWebView) {
                webView = (id)item.view;
                address = (item.tag == 100) ? item.representedObject : webView.mainFrameURL;

                ODBookmarkData *obj = [[ODBookmarkData alloc] initLeafWithTitle:item.label address:address];
                [bookmarks addObject:obj];
            }
        }
        
        
        NSDate *date = [NSDate date];
        NSString *name = [NSString stringWithFormat:@"%@", 
                          [NSDateFormatter localizedStringFromDate:date 
                                                         dateStyle:NSDateFormatterLongStyle 
                                                         timeStyle:NSDateFormatterMediumStyle]];
        
        bookmark = [[ODBookmarkData alloc] initListWithTitle:name content:bookmarks];
        
    } else if (tag == 1002) {
        
        bookmark = [[ODBookmarkData alloc] initListWithTitle:@"Folder" content:@[]];
        
    }
    
    dialog = [[ODBookmarkAdd alloc] init];
    
    [dialog addBookmark:bookmark bookmarksTreeData:_bookmarksTreeData withReply:^(NSDictionary *newTreeData) {
       
        if (newTreeData) {
            
            _bookmarksTreeData = newTreeData;
            [self updateMenu];
        }
        
    }];
    
}

#pragma mark - Load Bookmarks

-(void)loadBookmark:(id)sender
{
    [_appDelegate openInMainWindow:[sender toolTip] newTab:NO];
}

-(void)openInTabs:(id)sender
{
    NSMenuItem *item = sender;

    NSMenu *menu = [item menu];
    NSMutableArray *addressList = [NSMutableArray new];
    for (NSMenuItem *i in menu.itemArray) {
        if (i.tag == 150) {
            [addressList addObject:[i toolTip]];
        }
        
    }
    
    [_appDelegate openAddressListInTabs:addressList newWindow:[item isAlternate]];
    
}

#pragma mark - Bookmarks menu

-(NSMenu *)menuFromData:(NSDictionary *)data
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:data[TITLE_KEY]];
    NSArray *children = data[CHILDREN_KEY];
    
    
    
    for (NSDictionary *a in children) {
        NSMenuItem *item = [NSMenuItem new];
        
        if (a[CHILDREN_KEY]) {
            
            item.title = a[TITLE_KEY];
            item.submenu = [self menuFromData:a];
            item.tag = 100;
            [menu addItem:item];

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
        [menu addItem:item];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Open Tabs in New Window" action:@selector(openInTabs:) keyEquivalent:@""];
        item.keyEquivalentModifierMask = NSAlternateKeyMask;
        item.alternate = YES;
        [item setTarget:self];
        [item setTag:100];
        [menu addItem:item];
        //[menu addItemWithTitle:@"Open All" action:@selector(openAllBookmarksInFolder:) keyEquivalent:@""];
        
    }
    
    return menu;
    
}

-(void)updateMenu
{
    
    NSArray *items = _menu.itemArray;
    
    for (NSMenuItem *a in items) {
        if (a.tag == 100 || a.tag == 150) {
            [_menu removeItem:a];
        }
    }
    
    NSMenu *bookmarks = [self menuFromData:_bookmarksTreeData];
    
    items = bookmarks.itemArray;
    for (NSMenuItem *a in items) {
        
        [bookmarks removeItem:a];
        [_menu addItem:a];
    }
    
    //  
    [[[NSApp mainMenu] itemWithTag:100] setSubmenu:_menu];
}



@end
