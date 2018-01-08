//
//  ODBookmarksEditor.m
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODBookmarksOutline.h"
#import "ODBookmarkData.h"
#import "ODDelegate.h"
#import "ODBookmarks.h"

#define COLUMNID_NAME @"NameColumn"
#define COLUMNID_ADDRESS @"AddressColumn"
#define LOCAL_REORDER_PASTEBOARD_TYPE   @"MyCustomOutlineViewPboardType"

@interface ODBookmarksOutline () <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSTreeNode *_rootTreeNode;
    NSArray *_draggedNodes;
    IBOutlet NSOutlineView *_outlineView;
    IBOutlet NSMenu *_contextMenu;
    
    
}

-(IBAction)addFolder:(id)sender;
-(IBAction)addLeaf:(id)sender;
-(IBAction)deleteSelections:(id)sender;

-(IBAction)openBookmark:(id)sender;
-(IBAction)duplicateSelection:(id)sender;


@end

@implementation ODBookmarksOutline

-(NSString *)nibName
{
    return [self className];
}

- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _rootTreeNode = [self treeNodeFromDictionary:data];
        assert(_rootTreeNode);
    }
    return self;
}

-(void)awakeFromNib
{
    [_outlineView setDelegate:self];
    [_outlineView setDataSource:self];
    [_outlineView registerForDraggedTypes:@[LOCAL_REORDER_PASTEBOARD_TYPE, NSStringPboardType, NSFilenamesPboardType]];
    [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [_outlineView setAutoresizesOutlineColumn:NO];
    [_outlineView setDoubleAction:@selector(openBookmark:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
}

- (void)addFolder:(id)sender {
    // Create a new model object, and insert it into our tree structure
    ODBookmarkData *childNodeData = [[ODBookmarkData alloc] initListWithTitle:@"Untitled" content:@[]];
    [self addNewDataToSelection:childNodeData];
}

- (void)addLeaf:(id)sender {
    ODBookmarkData *childNodeData = [[ODBookmarkData alloc] initLeafWithTitle:@"Untitled" address:@""];
    
    [self addNewDataToSelection:childNodeData];
}

-(void)duplicateSelection:(id)sender
{
    NSTreeNode *selectedNode;
    NSInteger row = [_outlineView selectedRow];
    if ( row != -1) {
        selectedNode = [_outlineView itemAtRow:row];
    } else {
        selectedNode = _rootTreeNode;
        
    }
    ODBookmarkData *childNodeData;
    ODBookmarkData *nodeData = [selectedNode representedObject];
    NSString *title = nodeData.title;
    if (![title hasSuffix:@"Duplicate"]) {
        title = [NSString stringWithFormat:@"%@ Duplicate", title];
    }
    if (![nodeData isList]) {
        
        
        childNodeData = [[ODBookmarkData alloc] initLeafWithTitle:title 
                                                         address:nodeData.address];
        [self addNewDataToSelection:childNodeData];
    } else {
        
        childNodeData = [[ODBookmarkData alloc] 
                         initListWithTitle:title 
                         content:@[]];
        
        [self addNewDataToSelection:childNodeData];
        
        
    }
}

- (void)deleteSelections:(id)sender {
    [_outlineView beginUpdates];
    [[_outlineView selectedRowIndexes] enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger row, BOOL *stop) {
        NSTreeNode *node = [_outlineView itemAtRow:row];
        NSTreeNode *parent = [node parentNode];
        
        NSMutableArray *childNodes = [parent mutableChildNodes];
        NSInteger index = [childNodes indexOfObject:node];
        //  [parentData removeObjectAtIndex:index];
        [childNodes removeObjectAtIndex:index];
        if (parent == _rootTreeNode) {
            parent = nil; // NSOutlineView doesn't know about our root node, so we use nil
        }
        [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideLeft];
    }];
    [_outlineView endUpdates];
}

-(void)openBookmark:(id)sender
{
    NSTreeNode *selectedNode;
    long clickedRow = _outlineView.clickedRow;
    if (clickedRow != -1) {
        selectedNode = [_outlineView itemAtRow:clickedRow];
        ODBookmarkData *nodeData = [selectedNode representedObject];
        if (![nodeData isList]) {
            //[nodeData.description writeToFile:@"/dev/stdout" atomically:NO];
            ODDelegate *delegate = [NSApp delegate];
            NSString *address = [nodeData address];
            
            if ([sender tag] == 10) {
                
                [delegate openInMainWindow:address newTab:YES];
                
            } else {
                
                [delegate openInNewWindow:address];
            }
        }
    }
    
    
}


- (void)addNewDataToSelection:(ODBookmarkData *)newChildData {
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    
    NSInteger row = _outlineView.selectedRow;
    if (row != -1) {
        selectedNode = [_outlineView itemAtRow:row];
    } else {
        selectedNode = _rootTreeNode;
    }
    
    // If the selected node is a container, use its parent. We access the underlying model object to find this out.
    // In addition, keep track of where we want the child.
    NSInteger childIndex;
    NSTreeNode *parentNode;
    
    ODBookmarkData *nodeData = [selectedNode representedObject];
    if ([nodeData isList]) {
        // Since it was already a container, we insert it as the first child
        childIndex = 0;
        parentNode = selectedNode;
     
    } else {
        // The selected node is not a container, so we use its parent, and insert after the selected node
        parentNode = [selectedNode parentNode]; 
        childIndex = [[parentNode childNodes] indexOfObject:selectedNode ] + 1; // + 1 means to insert after it.
    }
    
    // Use the new 10.7 API to update the tree directly in an animated fashion
    [_outlineView beginUpdates];
    
    // Now, create a tree node for the data and insert it as a child and tell the outlineview about our new insertion
    NSTreeNode *childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:newChildData];
    [[parentNode mutableChildNodes] insertObject:childTreeNode atIndex:childIndex];
    // NSOutlineView uses 'nil' as the root parent
    if (parentNode == _rootTreeNode) {
        parentNode = nil;
    }
    [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex] inParent:parentNode withAnimation:NSTableViewAnimationEffectFade];
    
    [_outlineView endUpdates];
    
    NSInteger newRow = [_outlineView rowForItem:childTreeNode];
    if (newRow >= 0) {
        [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
        NSInteger column = 0;
        // With "full width" cells, there is no column
        //        if (newChildData.container && [useGroupRowLook state]) {
        //            column = -1;
        //        }
        [_outlineView editColumn:column row:newRow withEvent:nil select:YES];
    }
}


- (NSTreeNode *)treeNodeFromDictionary:(NSDictionary *)dictionary {
    // We will use the built-in NSTreeNode with a representedObject that is our model object - the SimpleNodeData object.
    // First, create our model object.
    NSString *nodeName = dictionary[TITLE_KEY];
    NSArray *nodeArray = dictionary[CHILDREN_KEY];
    ODBookmarkData *nodeData = [[ODBookmarkData alloc] initListWithTitle:nodeName content:nodeArray];
    // The image for the nodeData is lazily filled in, for performance.
    
    // Create a NSTreeNode to wrap our model object. It will hold a cache of things such as the children.
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:nodeData];
    
    // Walk the dictionary and create NSTreeNodes for each child.
    //NSArray *children = dictionary[CHILDREN_KEY];
    
    for (id item in nodeArray) {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        if (item[CHILDREN_KEY]) {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self treeNodeFromDictionary:item];
        } else {
            // It is a regular leaf item with just the name
            ODBookmarkData *childNodeData = [[ODBookmarkData alloc] initLeafWithTitle:item[TITLE_KEY] address:item[ADDRESS_KEY]];
            //childNodeData.container = NO;
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    return result;
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
    }
    //[content addObject:result];
    ODBookmarkData *nodeData = [[ODBookmarkData alloc] initListWithTitle:treeData.title content:content];
    
    return [nodeData data];
}

-(NSDictionary *)saveAtPath:(NSString *)path
{
    //ODBookmarkData *node = [_rootTreeNode representedObject];
    NSDictionary *data = [self dictionaryFromTreeNode:_rootTreeNode];
    
    
    [data writeToFile:path atomically:YES];
    
    return data;
}

#pragma mark - NSEvent
//-(void)mouseUp:(NSEvent *)theEvent
//{
//    if ([theEvent clickCount] == 2) {
//        NSTreeNode *selectedNode;
//        if ([_outlineView selectedRow] != -1) {
//            selectedNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
//        } else {
//            selectedNode = _rootTreeNode;
//            
//        }
//        
//        ODBookmarkData *nodeData = [selectedNode representedObject];
//        if (![nodeData isList]) {
//            puts("should open tab");
//        }
//        
//    }
//}
//
//-(void)mouseDown:(NSEvent *)theEvent
//{
//    
//    
//}

#pragma mark - NSOutlineViewDataSource

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        return [_rootTreeNode childNodes];
    } else {
        return [item childNodes];
    }
}

// Required methods. 
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    // This will return an NSTreeNode with our model object as the representedObject
    return children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    // 'item' will always be non-nil. It is an NSTreeNode, since those are always the objects we give NSOutlineView.
    // We access our model object from it.
    ODBookmarkData *nodeData = [item representedObject];
    // We can expand items if the model tells us it is a container
    return [nodeData isList];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    return [children count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    id objectValue = nil;
    ODBookmarkData *nodeData = [item representedObject];
    
    // The return value from this method is used to configure the state of the items cell via setObjectValue:
    if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COLUMNID_NAME]) {
        objectValue = [nodeData title];
    } else if ([[tableColumn identifier] isEqualToString:COLUMNID_ADDRESS]) {
        // Here, object value will be used to set the state of a check box.

        if ([nodeData isList]) {
            // [item setForegroundColor:[NSColor grayColor]];
            NSAttributedString *str = [[NSAttributedString alloc] 
                                       initWithString:[NSString stringWithFormat:@"%lu items", [[item childNodes] count]] 
                                       attributes:@{NSForegroundColorAttributeName : [NSColor lightGrayColor]}];
            objectValue = str;
        } else {
            objectValue = [nodeData address];
        }
    }  
    
    return objectValue;
}

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  {
    ODBookmarkData *nodeData = [item representedObject];
    BOOL dataChanged = NO;
    
    // Here, we manipulate the data stored in the node.
    if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COLUMNID_NAME]) {
        [nodeData setTitle:object];
        dataChanged = YES;
        
    } else if ([[tableColumn identifier] isEqualToString:COLUMNID_ADDRESS]) {
        
        if (![nodeData isList]) {
            [nodeData setAddress:object];
            dataChanged = YES;
            
        }
    }
    
    if (dataChanged) {
        ODDelegate *delegate = [NSApp delegate];
        ODBookmarks *bookmarks = [delegate bookmarks];
        bookmarks.bookmarksTreeData = [self saveAtPath:BOOKMARKS_SAVE_PATH];
        [bookmarks updateMenu];
    }
    
}



/* In 10.7 multiple drag images are supported by using this delegate method. */
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
    return (id <NSPasteboardWriting>)[item representedObject];
}

/* Setup a local reorder. */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
    _draggedNodes = draggedItems;
    [session.draggingPasteboard setData:[NSData data] forType:LOCAL_REORDER_PASTEBOARD_TYPE];
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
    if (operation == NSDragOperationDelete) {
        [_outlineView beginUpdates];
        
        [_draggedNodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id node, NSUInteger index, BOOL *stop) {
            id parent = [node parentNode];
            NSMutableArray *children = [parent mutableChildNodes];
            NSInteger childIndex = [children indexOfObject:node];
            [children removeObjectAtIndex:childIndex];
            [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex] inParent:parent == _rootTreeNode ? nil : parent withAnimation:NSTableViewAnimationEffectFade];
        }];
        
        [_outlineView endUpdates];
    }
    ODDelegate *delegate = [NSApp delegate];
    ODBookmarks *bookmarks = [delegate bookmarks];
    bookmarks.bookmarksTreeData = [self saveAtPath:BOOKMARKS_SAVE_PATH];
    [bookmarks updateMenu];
    
    _draggedNodes = nil;
}

- (BOOL)treeNode:(NSTreeNode *)treeNode isDescendantOfNode:(NSTreeNode *)parentNode {
    while (treeNode != nil) {
        if (treeNode == parentNode) {
            return YES;
        }
        treeNode = [treeNode parentNode];
    }
    return NO;
}

- (BOOL)_dragIsLocalReorder:(id <NSDraggingInfo>)info {
    // It is a local drag if the following conditions are met:
    if ([info draggingSource] == _outlineView) {
        // We were the source
        if (_draggedNodes != nil) {
            // Our nodes were saved off
            if ([[info draggingPasteboard] availableTypeFromArray:@[LOCAL_REORDER_PASTEBOARD_TYPE]] != nil) {
                // Our pasteboard marker is on the pasteboard
                return YES;
            }
        }
    }
    return NO;
}

-(NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    // NSLog(@"outlineView:validateDrop:proposedItem:%@ proposedChildIndex:%ld", item, (long)index);
    NSDragOperation result = NSDragOperationGeneric;
    // Check to see what we are proposed to be dropping on
    NSTreeNode *targetNode = item;
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) {
        targetNode = _rootTreeNode;
    }
    ODBookmarkData *nodeData = [targetNode representedObject];
    if (![nodeData isList])
    {
        result = NSDragOperationNone;
    }
    
    if (result != NSDragOperationNone) {
        [info setAnimatesToDestination:YES];
        if ([self _dragIsLocalReorder:info]) {
            if (targetNode != _rootTreeNode) {
                for (NSTreeNode *draggedNode in _draggedNodes) {
                    
                    if ([self treeNode:targetNode isDescendantOfNode:draggedNode]) {
                        result = NSDragOperationNone;
                        break;
                    }
                }
            }
        }
    }
    
    // NSLog(result == NSDragOperationNone ? @" - Refusing drop" : @" + Accepting drop");
    return result;
}


- (void)_performInsertWithDragInfo:(id <NSDraggingInfo>)info parentNode:(NSTreeNode *)parentNode childIndex:(NSInteger)childIndex {
    // NSOutlineView's root is nil
    id outlineParentItem = parentNode == _rootTreeNode ? nil : parentNode;
    NSMutableArray *childNodeArray = [parentNode mutableChildNodes];
    NSInteger outlineColumnIndex = [[_outlineView tableColumns] indexOfObject:[_outlineView outlineTableColumn]];
    
    // Enumerate all items dropped on us and create new model objects for them    
    NSArray *classes = @[[ODBookmarkData class]];
    __block NSInteger insertionIndex = childIndex;
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        ODBookmarkData *newNodeData = (ODBookmarkData *)draggingItem.item;
        // Wrap the model object in a tree node
        NSTreeNode *treeNode = [NSTreeNode treeNodeWithRepresentedObject:newNodeData];
        // Add it to the model
        [childNodeArray insertObject:treeNode atIndex:insertionIndex];
        [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] inParent:outlineParentItem withAnimation:NSTableViewAnimationEffectGap];
        // Update the final frame of the dragging item
        NSInteger row = [_outlineView rowForItem:treeNode];
        draggingItem.draggingFrame = [_outlineView frameOfCellAtColumn:outlineColumnIndex row:row];
        
        // Insert all children one after another
        insertionIndex++;
    }];
    
}

- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info parentNode:(NSTreeNode *)newParent childIndex:(NSInteger)childIndex {
    // We will use the dragged nodes we saved off earlier for the objects we are actually moving
    NSAssert(_draggedNodes != nil, @"_draggedNodes should be valid");
    
    NSMutableArray *childNodeArray = [newParent mutableChildNodes];
    
    // We want to enumerate all things in the pasteboard. To do that, we use a generic NSPasteboardItem class
    NSArray *classes = @[[NSPasteboardItem class]];
    __block NSInteger insertionIndex = childIndex;
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        // We ignore the draggingItem.item -- it is an NSPasteboardItem. We only care about the index. The index is deterministic, and can directly be used to look into the initial array of dragged items.
        NSTreeNode *draggedTreeNode = _draggedNodes[index];
        
        // Remove this node from its old location
        NSTreeNode *oldParent = [draggedTreeNode parentNode];
        NSMutableArray *oldParentChildren = [oldParent mutableChildNodes];
        NSInteger oldIndex = [oldParentChildren indexOfObject:draggedTreeNode];
        [oldParentChildren removeObjectAtIndex:oldIndex];
        // Tell the table it is going away; make it pop out with NSTableViewAnimationEffectNone, as we will animate the draggedItem to the final target location.
        // Don't forget that NSOutlineView uses 'nil' as the root parent.
        [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:oldIndex] inParent:oldParent == _rootTreeNode ? nil : oldParent withAnimation:NSTableViewAnimationEffectNone];
        
        // Insert this node into the new location and new parent
        if (oldParent == newParent) {
            // Moving it from within the same parent! Account for the remove, if it is past the oldIndex
            if (insertionIndex > oldIndex) {
                insertionIndex--; // account for the remove
            }
        }
        [childNodeArray insertObject:draggedTreeNode atIndex:insertionIndex];
        
        // Tell NSOutlineView about the insertion; let it leave a gap for the drop animation to come into place
        [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] inParent:newParent == _rootTreeNode ? nil : newParent withAnimation:NSTableViewAnimationEffectGap];
        
        insertionIndex++;
    }];
    
    // Now that the move is all done (according to the table), update the draggingFrames for the all the items we dragged. -frameOfCellAtColumn:row: gives us the final frame for that cell
    NSInteger outlineColumnIndex = [[_outlineView tableColumns] indexOfObject:[_outlineView outlineTableColumn]];
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        NSTreeNode *draggedTreeNode = _draggedNodes[index];
        NSInteger row = [_outlineView rowForItem:draggedTreeNode];
        draggingItem.draggingFrame = [_outlineView frameOfCellAtColumn:outlineColumnIndex row:row];
    }];
    
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)childIndex {
    NSTreeNode *targetNode = item;
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) {
        targetNode = _rootTreeNode;
    }
    ODBookmarkData *nodeData = [targetNode representedObject];
    
    // Determine the parent to insert into and the child index to insert at.
    if ([nodeData isList]) {
        
        if (childIndex == NSOutlineViewDropOnItemIndex) {
            // Insert it at the start, if we were dropping on it
            childIndex = 0;
        }

    }    
    // Group all insert or move animations together
    [_outlineView beginUpdates];
    // If the source was ourselves, we use our dragged nodes and do a reorder
    if ([self _dragIsLocalReorder:info]) {
        [self _performDragReorderWithDragInfo:info parentNode:targetNode childIndex:childIndex];
    } else {
        [self _performInsertWithDragInfo:info parentNode:targetNode childIndex:childIndex];
    }
    [_outlineView endUpdates];
    
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}

/* Multi-item dragging destiation support. 
 */
- (void)outlineView:(NSOutlineView *)outlineView updateDraggingItemsForDrag:(id <NSDraggingInfo>)draggingInfo {
    // If the source is ourselves, then don't do anything. If it isn't, we update things
    if (![self _dragIsLocalReorder:draggingInfo]) {
        // We will be doing an insertion; update the dragging items to have an appropriate image
        NSArray *classes = @[[ODBookmarkData class]];
        
        // Create a copied temporary cell to draw to images
        NSTableColumn *tableColumn = [_outlineView outlineTableColumn];
        //        ODBookmarkData *tempCell = [[tableColumn dataCell] copy];
        
        // Calculate a base frame for new cells
        NSRect cellFrame = NSMakeRect(0, 0, [tableColumn width], [outlineView rowHeight]);
        
        // Subtract out the intercellSpacing from the width only. The rowHeight is sans-spacing
        cellFrame.size.width -= [outlineView intercellSpacing].width;
        
        [draggingInfo enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {

            // Wrap the model object in a tree node
   
            draggingItem.draggingFrame = cellFrame;
           
        }];
    }
}

#pragma mark - NSEvent

- (void)keyDown:(NSEvent *)theEvent
{
    NSUInteger modifierFlags = theEvent.modifierFlags;
     u_short keyCode = [theEvent keyCode];
    if (modifierFlags & NSShiftKeyMask && modifierFlags & NSAlternateKeyMask) {
       
        if (keyCode == 0x2d) {
            [self addLeaf:nil];
        }
         
    } else if (modifierFlags & NSShiftKeyMask && modifierFlags & NSCommandKeyMask) {
        if (keyCode == 0x2d) {
            [self addFolder:nil];
        }
    } else if (keyCode == 0x33) {
        [self deleteSelections:nil];
    }
}

#pragma mark - NSMenu delegate

//- (BOOL)menu:(NSMenu*)menu updateItem:(NSMenuItem*)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel
//{
//    return YES;
//}

//- (void)menuNeedsUpdate:(NSMenu *)menu
//{
//    NSInteger clickedRow = [_outlineView clickedRow];
//    id item = nil;
//    ODBookmarkData *nodeData = nil;
//    
//    if (clickedRow != -1) {
//        // If we clicked on a selected row, then we want to consider all rows in the selection. Otherwise, we only consider the clicked on row.
//        item = [_outlineView itemAtRow:clickedRow];
//        nodeData = [item representedObject];
//        
//    } else {
//        [[menu itemWithTag:10] setEnabled:NO];
//        [[menu itemWithTag:11] setEnabled:NO];
//        [[menu itemWithTag:20] setEnabled:NO];
//        [[menu itemWithTag:21] setEnabled:NO];
//        
//    }
//    
//    if (!nodeData) {
//        return;
//    }
//    
//    if ([nodeData isList]) {
//        
//        //        [[menu itemWithTag:10] setHidden:NO];
//        //        [[menu itemWithTag:11] setHidden:NO];
//        //        [[menu itemWithTag:20] setHidden:NO];
//        // [[menu itemWithTag:21] setEnabled:NO];
//        [[menu itemWithTag:10] setEnabled:NO];
//        [[menu itemWithTag:11] setEnabled:NO];
//        [[menu itemWithTag:20] setEnabled:YES];
//        [[menu itemWithTag:21] setEnabled:YES];
//    } else {
//        
//        [[menu itemWithTag:10] setEnabled:YES];
//        [[menu itemWithTag:11] setEnabled:YES];
//        [[menu itemWithTag:20] setEnabled:YES];
//        [[menu itemWithTag:21] setEnabled:YES];
//    }
//    
//}



@end
