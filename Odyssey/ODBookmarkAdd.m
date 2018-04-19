//
//  ODBookmarkAdd.m
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODBookmarkAdd.h"
#import "ODBookmarkData.h"
#import "ODModalDialog.h"


@interface ODBookmarkAdd ()
{
    IBOutlet NSTextField *_nameField;
    IBOutlet NSTextField *_addressField;
    
    IBOutlet NSPopUpButton *_directoriesPopUp;
    
    
    NSTreeNode *_rootTreeNode;
    NSDictionary *_rootTreeData;
    
    ODBookmarkData *_bookmark;
    
    BOOL _shouldAddFolder;
    BOOL _cancelled;
    
    NSMutableArray *_popUpItems;
}

-(IBAction)okButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

@end

@implementation ODBookmarkAdd

- (instancetype)init
{
    self = [super init];
    if (self) {
        _popUpItems = [NSMutableArray new];
        _shouldAddFolder = NO;
    }
    return self;
}

-(NSString *)nibName
{
    return [self className];
}



- (void)addBookmark:(ODBookmarkData *)bookmark bookmarksTreeData:(NSDictionary *)treeData withReply:(void (^)(NSDictionary *))respond {
    _shouldAddFolder = [bookmark isList];
    _bookmark = bookmark;
    _rootTreeData = treeData;
    NSView *view = self.view;
    [self _popUpButtonWith:treeData];
    
    if (_bookmark) {
           [_nameField setStringValue:[_bookmark title]];
        if (_shouldAddFolder) {
            [_addressField setEnabled:NO];
        } else {
            [_addressField setStringValue:[_bookmark address]];
        }
    }
    NSPanel *window = [ODModalDialog modalDialogWithView:view];
    [window setInitialFirstResponder:_nameField];
    [window makeKeyAndOrderFront:nil];
    
    [NSApp runModalForWindow:window];
    // sheet is up here...
    
    [NSApp endSheet:window];
    [window orderOut:self];
    
    NSDictionary *result = nil;
    
    if (!_cancelled) {
        
        if (!_shouldAddFolder) {
            
            NSString *url = [_addressField stringValue];
            
            if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"file:///"] ) {
                url = [NSString stringWithFormat:@"http://%@", url];
            }
            [_bookmark setAddress:url];
        } 
        _bookmark.title = [_nameField stringValue];
        [self addNewDataToSelection:_bookmark];
        result = [self dictionaryFromTreeNode:_rootTreeNode];
        [result writeToFile:BOOKMARKS_SAVE_PATH atomically:YES];
    }
    respond(result);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - IBActions

-(void)okButtonClicked:(id)sender
{
    if ([[_nameField stringValue] length] == 0) {
        NSBeep();
        return;
    }
    _cancelled = NO;
    [NSApp stopModal];
}

-(void)cancelButtonClicked:(id)sender
{
    _cancelled = YES;
    [NSApp stopModal];
}

#pragma mark - Private

-(void)_popUpButtonWith:(NSDictionary *)data
{
    
    _rootTreeNode = [self treeNodeFromData:data];
    NSMenu *menu = _directoriesPopUp.menu;
    
    for (NSMenuItem *a in _popUpItems) {
        if (a.tag == 200) {
            [a setIndentationLevel:1];
            [menu addItem:a];
            
        } else {
            NSTreeNode *parentNode = [a representedObject];
            NSArray *childNodes = [parentNode childNodes];
            NSTreeNode *childNode = [childNodes firstObject];
            NSInteger idx = -1;
            idx = [menu indexOfItemWithRepresentedObject:childNode];
            if (idx != -1) {
                [menu insertItem:a atIndex:idx];
            } else {
                [menu addItem:a];
            }
            
            
        }
        
        
    }
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:0];
    NSMenuItem *menuItem = [NSMenuItem new];
    [menuItem setTitle:@"Bookmarks"];
    [menuItem setRepresentedObject:_rootTreeNode];
    [menu insertItem:menuItem atIndex:0];
}

-(NSTreeNode *)treeNodeFromData:(NSDictionary *)treeData
{
    NSString *nodeName = treeData[TITLE_KEY];
    NSArray *nodeArray = treeData[CHILDREN_KEY];
    ODBookmarkData *nodeData = [[ODBookmarkData alloc] initListWithTitle:nodeName content:nodeArray];
    // The image for the nodeData is lazily filled in, for performance.
    
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:nodeData];
    
    for (id item in nodeArray) {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        ODBookmarkData *childBookmark = [[ODBookmarkData alloc] initWithData:item];
        if ([childBookmark isList]) {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self treeNodeFromData:item];
            NSMenuItem *menuItem = [NSMenuItem new];
            [menuItem setTitle:childBookmark.title];
            [menuItem setRepresentedObject:childTreeNode];
            if ([nodeName isEqualToString:@"BookmarksRoot"]) {
                
                [menuItem setTag:100];
                
            } else {
                [menuItem setTag:200];
            }
            [_popUpItems addObject:menuItem];
            
            
        } else {
            // It is a regular leaf item with just the name
            //ODBookmarkData *childNodeData = [[ODBookmarkData alloc] initLeafWithTitle:item[TITLE_KEY] address:item[ADDRESS_KEY]];
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childBookmark];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    
    return result;
}

- (void)addNewDataToSelection:(ODBookmarkData *)newChildData {
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    selectedNode = [[_directoriesPopUp selectedItem] representedObject];
    
    // Now, create a tree node for the data and insert it as a child and tell the outlineview about our new insertion
    NSTreeNode *childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:newChildData];
    if ([newChildData isList]) {
        for (ODBookmarkData *data in newChildData.children) {
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
    
    
    ODBookmarkData *treeData = treeNode.representedObject;
    
    NSMutableArray *content = [NSMutableArray new];
    NSDictionary *result;
    
    if ([treeData isList]) {
        NSArray *childTree = [treeNode childNodes];
        for (NSTreeNode *n in childTree) {
            ODBookmarkData *childData = n.representedObject;
            if ([childData isList]) {
                result = [self dictionaryFromTreeNode:n]; 
            } else {
                ODBookmarkData *childNodeData = n.representedObject;
                result =  childNodeData.data;
            }
            [content addObject:result];
        }
    } /* else {
        
        result = treeData.data;
    } 
       */
    
    ODBookmarkData *nodeData = [[ODBookmarkData alloc] initListWithTitle:treeData.title content:content];
    
    return [nodeData data];
}


@end
