//
//  ODAddBookmarkDialogController.m
//  Bookmarks-Playground
//
//  Created by Terminator on 10/10/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODAddBookmarkDialogController.h"
//#import "ODWebBookmarks.h"
#import "NSDictionary+BookmarkItem.h"
#import "ODWebBookmarkData.h"
#import "Bookmarks.h"

@interface ODAddBookmarkDialogController ()
{
    IBOutlet NSTextField *_nameField;
    IBOutlet NSTextField *_addressField;
    
    IBOutlet NSPopUpButton *_directoriesPopUp;
    

    NSTreeNode *_rootTreeNode;
    NSDictionary *_data;

    
    BOOL _cancelled;
    BOOL _shouldAddFolder;
    ODWebBookmarkData *_bookmark;
//    NSInteger _indLevel;
    NSMutableArray *_items;
    
}

@end

@implementation ODAddBookmarkDialogController


- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        _shouldAddFolder = NO;
    }
    return self;
}

- (instancetype)initWithBookmark:(ODWebBookmarkData *)bookmark andDirectories:(NSDictionary *)data
{
    self = [self init];
    if (self) {
        
        [self setDirectories:data];
        [self editBookmark:bookmark];
     
    }
    return self;
}

-(NSString *)windowNibName
{
    return @"ODAddBookmarkDialogController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    

    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)addBookmarkFolder:(ODWebBookmarkData *)data
{
    _shouldAddFolder = YES;
    _bookmark = data;
    [self editBookmark:data];
}

-(NSDictionary *)bookmarkData
{
    return _data;
}

-(void)setDirectories:(NSDictionary *)data
{
    
    [self window];
    //_indLevel = 0;
    _rootTreeNode = [self treeNodeFromData2:data];
    
    for (NSMenuItem *a in _items) {
        //NSTreeNode *parentNode = [a representedObject];
        if (a.tag == 200) {
            [a setIndentationLevel:1];
            [_directoriesPopUp.menu addItem:a];
            
        } else {
            NSTreeNode *parentNode = [a representedObject];
            NSArray *childNodes = [parentNode childNodes];
            NSTreeNode *childNode = [childNodes firstObject];
            NSUInteger idx = -1;
            idx = [_directoriesPopUp.menu indexOfItemWithRepresentedObject:childNode];
            if (idx != -1) {
                 [_directoriesPopUp.menu insertItem:a atIndex:idx];
            } else {
                 [_directoriesPopUp.menu addItem:a];
            }
           
            
        }
        
        
    }
        
    [_directoriesPopUp.menu insertItem:[NSMenuItem separatorItem] atIndex:0];
        NSMenuItem *menuItem = [NSMenuItem new];
        [menuItem setTitle:@"Bookmarks"];
        [menuItem setRepresentedObject:_rootTreeNode];
        [_directoriesPopUp.menu insertItem:menuItem atIndex:0];
    
//    NSArray *items = [self itemsFromData:data];
//    for (NSMenuItem *item in items) {
//        [_directoriesPopUp.menu addItem:item];
//    }
}

-(ODWebBookmarkData *)editBookmark:(ODWebBookmarkData *)bookmark
{
    NSWindow *window = self.window;
     _cancelled = NO;
    
    if (_shouldAddFolder) {
        if (bookmark) {
            
            [_nameField setStringValue:[_bookmark title]];
            [_addressField setEnabled:NO];
        }
        
        
    } else {
        
        if (bookmark) {
            
            _bookmark = bookmark;
            
            [_nameField setStringValue:[bookmark title]];
            [_addressField setStringValue:[bookmark address]];
        }
    }
    
    [NSApp beginSheet:window modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:window];
    // sheet is up here...
    
    [NSApp endSheet:window];
    [self.window orderOut:self];
    
    return bookmark;
}


//-(NSDictionary *)editBookmark2:(NSDictionary *)bookmark
//{
//    NSWindow *window = self.window;
//    
//    _cancelled = NO;
//    
//    if (bookmark) {
//        
//        //_bookmark = bookmark;
//        
//        [_nameField setStringValue:[bookmark title]];
//        [_addressField setStringValue:[bookmark address]];
//    } else {
//        
//        [_nameField setStringValue:@""];
//        [_addressField setStringValue:@""];
//    }
//    
//    [NSApp beginSheet:window modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
//    [NSApp runModalForWindow:window];
//    // sheet is up here...
//    
//    [NSApp endSheet:window];
//    [self.window orderOut:self];
//    
//    return bookmark;
//
//    
//}

-(void)okButtonClicked:(id)sender
{
    if ([[_nameField stringValue] length] == 0) {
        NSBeep();
        return;
    }
    
    [_bookmark setTitle:[_nameField stringValue]];
    
    if (!_shouldAddFolder) {
        
        NSString *url = [_addressField stringValue];
        
        if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"file:///"] ) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        
        [_bookmark setAddress:url];
        
    }
    
      [self addNewDataToSelection:_bookmark];
    NSDictionary *saveData = [self dictionaryFromTreeNode:_rootTreeNode];
    [saveData writeToFile:BOOKMARKS_SAVE_PATH atomically:YES];
    _data = saveData;
    
    [NSApp stopModal];
}

//-(void)okButtonClicked2:(id)sender
//{
//
//    if ([[_nameField stringValue] length] == 0 || [[_addressField stringValue] length] == 0) {
//        NSBeep();
//        return;
//    }
//    NSString *url = [_addressField stringValue];
//    
//    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"file:///"] ) {
//        url = [NSString stringWithFormat:@"http://%@", url];
//    } 
//    
//    ODWebBookmarkData *bookmarkData = [[ODWebBookmarkData alloc] initWithTitle:[_nameField stringValue] address:url];
//
//    [self addNewDataToSelection:bookmarkData];
//    NSDictionary *saveData = [self dictionaryFromTreeNode:_rootTreeNode];
//    [saveData writeToFile:BOOKMARKS_SAVE_PATH atomically:YES];
//    
//    [NSApp stopModal];
//    
//}

-(void)cancelButtonClicked:(id)sender
{
    _cancelled = YES;
    [NSApp stopModal];
    
}

-(BOOL)wasCancelled
{
    return _cancelled;
}

-(NSTreeNode *)treeNodeFromData2:(NSDictionary *)data
{
    NSString *nodeName = data[TITLE_KEY];
    NSArray *nodeArray = data[CHILDREN_KEY];
    ODWebBookmarkData *nodeData = [[ODWebBookmarkData alloc] initListWithTitle:nodeName content:nodeArray];
    // The image for the nodeData is lazily filled in, for performance.
    
    // Create a NSTreeNode to wrap our model object. It will hold a cache of things such as the children.
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:nodeData];
    //    NSMenuItem *menuItem = [NSMenuItem new];
    //    [menuItem setTitle:@"/"];
    //    [menuItem setRepresentedObject:childTreeNode];
    //    [_directoriesPopUp.menu addItem:menuItem];
    // Walk the dictionary and create NSTreeNodes for each child.
    //NSArray *children = dictionary[CHILDREN_KEY];
    
    for (id item in nodeArray) {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        if ([item[TYPE_KEY] isEqualToString:LIST]) {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self treeNodeFromData2:item];
            NSMenuItem *menuItem = [NSMenuItem new];
            [menuItem setTitle:item[TITLE_KEY]];
            [menuItem setRepresentedObject:childTreeNode];
            if ([nodeName isEqualToString:@"BookmarksRoot"]) {
                
                [menuItem setTag:100];
                
            } else {
                [menuItem setTag:200];
            }
            [_items addObject:menuItem];
            //[_directoriesPopUp.menu addItem:menuItem];
            //[_directoriesPopUp.menu insertItem:menuItem atIndex:0];
            //NSInteger ind = 1;
            //            if (![nodeName isEqualToString:@"BookmarksRoot"]) {
            //                _indLevel++;
            //                [menuItem setIndentationLevel:_indLevel];
            //                
            //            } else {
            //                _indLevel = 0;
            //            }
            
            
            
            
        } else {
            // It is a regular leaf item with just the name
            ODWebBookmarkData *childNodeData = [[ODWebBookmarkData alloc] initWithTitle:item[TITLE_KEY] address:item[ADDRESS_KEY]];
            //childNodeData.container = NO;
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    
    return result;
}

- (void)addNewDataToSelection:(ODWebBookmarkData *)newChildData {
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    selectedNode = [[_directoriesPopUp selectedItem] representedObject];
    
    // If the selected node is a container, use its parent. We access the underlying model object to find this out.
    // In addition, keep track of where we want the child.
    
    // NSInteger childIndex = 0;
    
    
    
    // Use the new 10.7 API to update the tree directly in an animated fashion
    
    
    // Now, create a tree node for the data and insert it as a child and tell the outlineview about our new insertion
    NSTreeNode *childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:newChildData];
    if ([newChildData isList]) {
        for (ODWebBookmarkData *data in newChildData.children) {
            NSTreeNode *newNode = [NSTreeNode treeNodeWithRepresentedObject:data];
            [[childTreeNode mutableChildNodes] addObject:newNode];
        }
    }
    //[[selectedNode mutableChildNodes] insertObject:childTreeNode atIndex:childIndex];
    [[selectedNode mutableChildNodes] addObject:childTreeNode];
    // NSOutlineView uses 'nil' as the root parent
    
}

-(NSDictionary *)dictionaryFromTreeNode:(NSTreeNode *)treeNode
{
    
    
    ODWebBookmarkData *treeData = treeNode.representedObject;
    
    NSMutableArray *content = [NSMutableArray new];
    NSDictionary *result;
    
    if ([treeData isList]) {
        NSArray *childTree = [treeNode childNodes];
        for (NSTreeNode *n in childTree) {
            ODWebBookmarkData *childData = n.representedObject;
            if ([childData isList]) {
                result = [self dictionaryFromTreeNode:n]; 
            } else {
                ODWebBookmarkData *childNodeData = n.representedObject;
                result =  childNodeData.data;
            }
            [content addObject:result];
        }
    } else {
        result = treeData.data;
    }
    
    ODWebBookmarkData *nodeData = [[ODWebBookmarkData alloc] initListWithTitle:treeData.title content:content];
    
    return [nodeData data];
}


@end
