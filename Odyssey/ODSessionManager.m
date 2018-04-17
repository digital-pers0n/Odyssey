//
//  ODSessionManager.m
//  Odyssey
//
//  Created by Terminator on 2018/04/13.
//  Copyright © 2018年 home. All rights reserved.
//

#import "ODSessionManager.h"
#import "ODSessionItem.h"

NSString * const ODLocalReorderPboardType = @"ODLocalPboardType";

@interface ODSessionManager () <NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *_tableView;
    
    NSString *_sessionSavePath;
    NSMutableArray <ODSessionItem *> *_itemArray;
    NSIndexSet *_draggedRows;
    BOOL _edited;
    
}
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)restoreButtonAction:(id)sender;
- (IBAction)addItemButtonAction:(id)sender;
- (IBAction)removeItemButtonAction:(id)sender;

@end

@implementation ODSessionManager

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemArray = [[NSMutableArray alloc] init];
        _sessionSavePath = @"";
    }
    return self;
}

- (NSString *)windowNibName  {
    return [self className];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerForDraggedTypes:@[ODLocalReorderPboardType]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Methods

- (void)loadSession {
    NSMutableArray *itemArray = [NSKeyedUnarchiver unarchiveObjectWithFile:_sessionSavePath];
    if (!itemArray) {
        NSLog(@"Error: %s array is nil", __PRETTY_FUNCTION__);
    } else {
        _itemArray = itemArray;
    }
}

- (void)saveSession {
    if (_edited) {
        [NSKeyedArchiver archiveRootObject:_itemArray toFile:_sessionSavePath];
    }
}

- (void)addSessionItem:(ODSessionItem *)item {
    [_itemArray addObject:item];
    _edited = YES;
}

- (void)showSessionWindow {
    [self.window makeKeyAndOrderFront:nil];
    [_tableView reloadData];
}

#pragma mark - Properties

- (void)setSessionSavePath:(NSString *)sessionSavePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    _sessionSavePath = sessionSavePath;
    if ([fm fileExistsAtPath:sessionSavePath]) {
        [self loadSession];
    }
}

- (NSString *)sessionSavePath {
    return _sessionSavePath;
}

#pragma mark - NSTableView DataSource

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *obj = nil;
    if (row < _itemArray.count) {
        obj = _itemArray[row].name;
        _edited = YES;
    }
    return obj;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < _itemArray.count && object) {
        _itemArray[row].name = object;
    }
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _itemArray.count;
}

#pragma mark - NSTableView Drag n Drop

- (BOOL)_dragIsLocalReorder:(id <NSDraggingInfo>)info {
    // It is a local drag if the following conditions are met:
    if ([info draggingSource] == _tableView) {
        // We were the source
        if (_draggedRows != nil) {
            // Our nodes were saved off
            if ([[info draggingPasteboard] availableTypeFromArray:@[ODLocalReorderPboardType]] != nil) {
                // Our pasteboard marker is on the pasteboard
                return YES;
            }
        }
    }
    return NO;
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    if (row < _itemArray.count) {
        return [_itemArray objectAtIndex:row];
    }
    return nil;
}


- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes {
    _draggedRows = rowIndexes;
    [session.draggingPasteboard setData:[NSData data] forType:(NSString *)ODLocalReorderPboardType];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
    if (operation == NSDragOperationDelete) {
        [_tableView beginUpdates];
        [_itemArray.copy enumerateObjectsAtIndexes:_draggedRows options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_itemArray removeObject:obj];
        }];
        [_tableView removeRowsAtIndexes:_draggedRows withAnimation:NSTableViewAnimationEffectFade];
        [_tableView endUpdates];
    }
    _draggedRows = nil;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    return (dropOperation == NSTableViewDropAbove) ? NSDragOperationMove : NSDragOperationNone;
}

- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info row:(NSInteger)row {
    // We will use the dragged nodes we saved off earlier for the objects we are actually moving
    NSAssert(_draggedRows != nil, @"_draggedRows should be valid");
    // We want to enumerate all things in the pasteboard. To do that, we use a generic NSPasteboardItem class
    NSArray *classes = @[[NSPasteboardItem class]];
    __block NSInteger insertionIndex = row;
    NSArray *draggedData = [_itemArray objectsAtIndexes:_draggedRows];
    //[_itemArray removeObjectsAtIndexes:_draggedRows];
    [info enumerateDraggingItemsWithOptions:0 forView:_tableView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        
        id data = [draggedData objectAtIndex:index];
        [_itemArray removeObject:data];
        
        if (insertionIndex > _itemArray.count) {
            insertionIndex--; // account for the remove
        }
        [_itemArray insertObject:data atIndex:insertionIndex];
        
        // Tell NSOutlineView about the insertion; let it leave a gap for the drop animation to come into place
        [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] withAnimation:NSTableViewAnimationEffectGap];
        insertionIndex++;
    }];
    [_tableView reloadData];
    _edited = YES;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    // Group all insert or move animations together
    [_tableView beginUpdates];
    // If the source was ourselves, we use our dragged nodes and do a reorder
    if ([self _dragIsLocalReorder:info]) {
        [self _performDragReorderWithDragInfo:info row:row];
    }
    [_tableView endUpdates];
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}


#pragma mark - IBAction

- (IBAction)cancelButtonAction:(id)sender {
    [self.window close];
}

- (IBAction)restoreButtonAction:(id)sender {
    NSUInteger row = _tableView.selectedRow;
    if (row < _itemArray.count) {
        ODSessionItem *itm = _itemArray[row];
        [_delegate sessionManager:self restoreSession:itm];
    }
}

- (IBAction)addItemButtonAction:(id)sender {
    ODSessionItem *itm = nil;
    [_delegate sessionManager:self storeSession:&itm];
    if (itm) {
        [_itemArray addObject:itm];
        [_tableView reloadData];
        _edited = YES;
    }
}

- (IBAction)removeItemButtonAction:(id)sender {
    NSUInteger row = _tableView.selectedRow;
    if (row < _itemArray.count) {
        [_itemArray removeObjectAtIndex:row];
        [_tableView reloadData];
        _edited = YES;
    }
}
@end
