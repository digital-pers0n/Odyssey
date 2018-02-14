//
//  ODTabSwitcher.m
//  Odyssey
//
//  Created by Terminator on 4/9/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODTabSwitcher.h"
#import "ODTabView.h"
#import "ODTabViewItem.h"
#import "ODWindow.h"
#import "ODPopover.h"
#import "ODDelegate.h"
#import <WebKit/WebView.h>

const NSString *ODTabSwitcherPboard = @"ODTabSwitcherPboard";

@interface ODTabSwitcher () <NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *_tableView;
    ODTabView *_tabView;
    ODPopover *_popover;
    
    NSIndexSet *_draggedRows;
    
    id<ODTabSwitcherDelegate> _delegate;
    struct __ODTabSwitcherDelegateRespondTo {
        unsigned int toolTipForTabViewItem:1;
        unsigned int openNewTab:1;
        unsigned int labelForTabViewItem:1;
    } _delegateRespondTo;
}

- (void)removeTabItem:(id)sender;
- (void)selectTabItem:(id)sender;


@end

@implementation ODTabSwitcher

+ (id)tabSwitcher {
    static dispatch_once_t onceToken;
    static ODTabSwitcher *result;
    dispatch_once(&onceToken, ^{
        result = [[ODTabSwitcher alloc] init];
    });
    
    return result;
}

- (NSString *)nibName {
    return [self className];
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerForDraggedTypes:@[ODTabSwitcherPboard, /* NSStringPboardType, NSFilenamesPboardType */]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    // [_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    _tableView.doubleAction = @selector(selectTabItem:);
    _popover = [[ODPopover alloc] init];
    _popover.contentViewController = self;
    _popover.contentSize = self.view.frame.size;
    _popover.appearance = ODPopoverAppearanceLight;
    
}


- (void)setDelegate:(id<ODTabSwitcherDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(toolTipForTabViewItem:)]) {
        _delegateRespondTo.toolTipForTabViewItem = YES;
    }
    if ([delegate respondsToSelector:@selector(labelForTabViewItem:)]) {
        _delegateRespondTo.labelForTabViewItem = YES;
    }
    if ([delegate respondsToSelector:@selector(openNewTab)]) {
        _delegateRespondTo.openNewTab = YES;
    }
    _delegate = delegate;
}

- (id<ODTabSwitcherDelegate>)delegate {
    return _delegate;
}

#pragma mark - Actions


- (void)showPopoverForTabBar:(ODTabView *)tabBar window:(ODWindow *)window
{
    NSView *contentView = window.contentView;
    NSRect contentRect = contentView.frame;
    //    NSRect relativeRect = NSMakeRect(8, NSHeight(contentRect) - 16, 4, 4);
    NSRect relativeRect = NSMakeRect(NSMaxX(contentRect) - 256, NSMaxY(contentRect) - 10, 1, 1);
    [_popover showRelativeToRect:relativeRect ofView:contentView preferredEdge:NSMinYEdge];
    _tabView = tabBar;
    [_tableView reloadData];
    
}

- (void)showPopover:(id)sender
{
    ODWindow *window = (id)[NSApp mainWindow];
    ODTabView *tabBar = window.tabView;
    if (tabBar) {
        [self showPopoverForTabBar:tabBar window:window];
    }
}


- (IBAction)closeView:(id)sender {
    [_popover close];
    _tabView = nil;
    
}

- (IBAction)removeTabItem:(id)sender {
    NSInteger idx = _tableView.selectedRow;

    if (_tabView.numberOfTabViewItems > idx) {
        
        [_tabView removeTabViewItemAtIndex:idx];
    }
    
    [_tableView reloadData];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx - 1] byExtendingSelection:NO];
}

- (IBAction)selectTabItem:(id)sender {
    NSInteger idx = _tableView.selectedRow;

    if (_tabView.numberOfTabViewItems > idx) {
        
        [_tabView selectTabViewItemAtIndex:idx];
    }
    
    [self closeView:nil];
}

- (IBAction)newTab:(id)sender {
    
    if (_delegateRespondTo.openNewTab) {
        [_delegate openNewTab];
        [_tableView reloadData];
    } else {
        NSBeep();
    }
}

#pragma mark - Table View

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
    NSString *result = nil;
    if (row < _tabView.numberOfTabViewItems) {
        ODTabViewItem *obj = [_tabView tabViewItemAtIndex:row];
        if (_delegateRespondTo.toolTipForTabViewItem) {
            result = [_delegate toolTipForTabViewItem:obj];
        } else {
            result = obj.label;
        }
    }
    
    return result;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ODTabViewItem *obj;
    if (row < _tabView.numberOfTabViewItems) {
        obj = [_tabView tabViewItemAtIndex:row];
        NSString *title = nil;
        if (_delegateRespondTo.labelForTabViewItem) {
            title = [_delegate labelForTabViewItem:obj];
        } else {
            title = obj.label;
        }
        return title;
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _tabView.numberOfTabViewItems;
}

#pragma mark - TableView Drag and Drop

- (BOOL)_dragIsLocalReorder:(id <NSDraggingInfo>)info {
    // It is a local drag if the following conditions are met:
    if ([info draggingSource] == _tableView) {
        // We were the source
        if (_draggedRows != nil) {
            // Our nodes were saved off
            if ([[info draggingPasteboard] availableTypeFromArray:@[ODTabSwitcherPboard]] != nil) {
                // Our pasteboard marker is on the pasteboard
                return YES;
            }
        }
    }
    return NO;
}

- (nullable id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    if (row < _tabView.numberOfTabViewItems) {
        return [_tabView tabViewItemAtIndex:row];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes {
    _draggedRows = rowIndexes;
    [session.draggingPasteboard setData:[NSData data] forType:(NSString *)ODTabSwitcherPboard];
    
}
- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
    if (operation == NSDragOperationDelete) {
        [_tableView beginUpdates];
        
        [_tabView.tabViewItems.copy enumerateObjectsAtIndexes:_draggedRows options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_tabView removeTabViewItem:obj];
        }];
        
        [_tableView removeRowsAtIndexes:_draggedRows withAnimation:NSTableViewAnimationEffectFade];
        
        [_tableView endUpdates];
    }
    _draggedRows = nil;
}


- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSDragOperation result = NSDragOperationGeneric;
    return result;
}

- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info row:(NSInteger)row {
    // We will use the dragged nodes we saved off earlier for the objects we are actually moving
    NSAssert(_draggedRows != nil, @"_draggedRows should be valid");
    
    
    // We want to enumerate all things in the pasteboard. To do that, we use a generic NSPasteboardItem class
    NSArray *classes = @[[NSPasteboardItem class]];
    __block NSInteger insertionIndex = row;
    NSArray *draggedData = [_tabView.tabViewItems objectsAtIndexes:_draggedRows];
    [_tabView._tabViewItemArray removeObjectsAtIndexes:_draggedRows];
    
    
    [info enumerateDraggingItemsWithOptions:0 forView:_tableView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        // We ignore the draggingItem.item -- it is an NSPasteboardItem. We only care about the index. The index is deterministic, and can directly be used to look into the initial array of dragged items.
        ODTabViewItem *data = [draggedData objectAtIndex:index];
        if (insertionIndex > _tabView.numberOfTabViewItems) {
            insertionIndex--; // account for the remove
        }
        [_tabView._tabViewItemArray insertObject:data atIndex:insertionIndex];
        
        // Tell NSOutlineView about the insertion; let it leave a gap for the drop animation to come into place
        [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] withAnimation:NSTableViewAnimationEffectGap];
        insertionIndex++;
    }];
    [_tableView reloadData];
    [_tabView setNeedsDisplay:YES];
}

- (void)_performInsertWithDragInfo:(id <NSDraggingInfo>)info row:(NSInteger)row {
    /* Not Implemented */
    //    // Enumerate all items dropped on us and create new model objects for them
    //    NSArray *classes = @[[ODTabViewItem class]];
    //    __block NSInteger insertionIndex = row;
    //    [info enumerateDraggingItemsWithOptions:0 forView:_tableView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
    //        //ODTabViewItem *newData = (ODTabViewItem *)draggingItem.item;
    //        // Wrap the model object in a tree node
    //
    //        // Add it to the model
    //        //[_documents insertObject:newData atIndex:insertionIndex];
    //        [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] withAnimation:NSTableViewAnimationEffectGap];
    //
    //        // Update the final frame of the dragging item
    //
    //        // Insert all children one after another
    //        insertionIndex++;
    //    }];
    //    [_tableView reloadData];
}
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    // Group all insert or move animations together
    [_tableView beginUpdates];
    // If the source was ourselves, we use our dragged nodes and do a reorder
    if ([self _dragIsLocalReorder:info]) {
        [self _performDragReorderWithDragInfo:info row:row];
    } else {
        //[self _performInsertWithDragInfo:info row:row];
    }
    [_tableView endUpdates];
    
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}


#pragma mark - NSEvent


- (void)keyDown:(NSEvent *)theEvent {
    if ([NSEvent modifierFlags] == 0) {
        
        int keyCode = [theEvent keyCode];
        switch (keyCode) {
            case 51:    //backspace
                [self removeTabItem:nil];
                break;
            case 53:    //esc
                [self closeView:nil];
                break;
            case 36:    //return
                [self selectTabItem:nil];
                break;
                
            default:
                break;
        }
    }
    
    //                NSLog(@"KeyUp:"
    //                      @"       \nchar: %@"
    //                      @"   \nmodifier: %lu"
    //                      @"    \nkeyCode: %i"
    //                      @"\nglobal mask: %lu", [theEvent characters], (unsigned long)[theEvent modifierFlags], [theEvent keyCode], [NSEvent modifierFlags]);
    
}

@end
