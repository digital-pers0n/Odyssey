//
//  ODTabView.m
//  TabView
//
//  Created by Terminator on 2017/12/17.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import "ODTabView.h"
#import "ODTabViewItem.h"
#import "ODWindow.h"

NSString *kPrivateDragUTI = @"ODTabViewDragUTI";

@interface ODTabView () <NSMenuDelegate> {
    
    NSMutableArray *_tabViewItems;
    
    NSUInteger _selectedTabIdx;
    NSTrackingArea *_trackingArea;
    NSUInteger _count;
    NSInteger _highlightedTabIdx;
    
    NSColor *_backgroundColor;
    NSColor *_foregroundColor;
    NSColor *_highlightColor;
    NSColor *_shadowColor;
    
    NSDictionary *_activeTabFont;
    NSDictionary *_inactiveTabFont;
    BOOL _highlightDrop;
    NSInteger _draggedTabIdx;
    NSRect _draggedTabRect;
    
    NSMenu *_defaultMenu;
    
    NSUInteger _tabMenuIdx;
    
    NSRect *_rects;
    
    id<ODTabViewDelegate> _delegate;
    struct __ODTabViewDelegateRespondTo {
        unsigned int shouldMoveTabViewItem:1;
        unsigned int didMoveTabViewItem:1;
        unsigned int tabViewList:1;
    } _delegateRespondTo;
    
}
@end

@implementation ODTabView


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _setUp];
#if DEBUG
        printf("%s\n", __PRETTY_FUNCTION__);
#endif
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUp];
#if DEBUG
        printf("%s\n", __PRETTY_FUNCTION__);
#endif
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUp];
#if DEBUG
        printf("%s\n", __PRETTY_FUNCTION__);
#endif
    }
    return self;
}

- (void)_setUp {
    if (!_tabViewItems) {
        [self registerForDraggedTypes:@[kPrivateDragUTI, NSStringPboardType, NSFilenamesPboardType]];
        
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        _rects = malloc(sizeof(NSRect) * _count + 1);
        _tabViewItems = [NSMutableArray new];
        
        _selectedTabIdx = 0;
        _highlightedTabIdx = -1;
        _draggedTabIdx = -1;
        //_count = 1;
        
        {
            _backgroundColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
            _foregroundColor = [NSColor colorWithDeviceWhite:0.98 alpha:1.0];
            _highlightColor = [NSColor colorWithDeviceWhite:0.90 alpha:1.0];
            _shadowColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
            
            NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
            [paragraph setLineBreakMode: NSLineBreakByTruncatingTail];
            [paragraph setAlignment:NSTextAlignmentCenter];
            NSUInteger fontSize = 10;
            _activeTabFont =  @{
                                NSFontAttributeName:[NSFont systemFontOfSize:fontSize],
                                NSParagraphStyleAttributeName: paragraph,
                                };
            _inactiveTabFont = @{
                                 NSFontAttributeName:[NSFont systemFontOfSize:fontSize],
                                 NSParagraphStyleAttributeName: paragraph,
                                 NSForegroundColorAttributeName: [NSColor colorWithDeviceWhite:0.36 alpha:1.0],
                                 };
        }
        {
            _defaultMenu = [[NSMenu alloc] initWithTitle:@"Defalut Menu"];
           // _defaultMenu.delegate = self;
            _defaultMenu.font = [NSFont systemFontOfSize:12];
            NSMenuItem *item;
            NSMenu *subMenu;
            item = [[NSMenuItem alloc] initWithTitle:@"Close Tab"
                                              action:@selector(closeTabMenuItemClicked:)
                                       keyEquivalent:@""];
            item.target = self;
            [_defaultMenu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Close Other Tabs"
                                              action:@selector(closeOtherTabsMenuItemClicked:)
                                       keyEquivalent:@""];
            item.target = self;
            [_defaultMenu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Move Tab to New Window"
                                              action:@selector(moveTabToNewWindowMenuItemClicked:)
                                       keyEquivalent:@""];
            item.target = self;
            [_defaultMenu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Move Tab to" action:nil keyEquivalent:@""];
            subMenu = [NSMenu new];
            item.submenu = subMenu;
            [_defaultMenu addItem:item];
            subMenu.delegate = self;
            _tabMenuIdx = -1;
        }
    }

    
}

- (void)setDelegate:(id<ODTabViewDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(tabView:shouldMoveTabViewItem:to:)]) {
        _delegateRespondTo.shouldMoveTabViewItem = YES;
    }
    if ([delegate respondsToSelector:@selector(tabView:didMoveTabViewItem:to:)]) {
        _delegateRespondTo.didMoveTabViewItem = YES;
    }
    if ([delegate respondsToSelector:@selector(tabView:tabViewList:)]) {
        _delegateRespondTo.tabViewList = YES;
    }
    
    _delegate = delegate;
}

- (id<ODTabViewDelegate>)delegate {
    return _delegate;
}

#pragma mark - Tab Management

- (void)selectTabViewItem:(ODTabViewItem *)item {
    
    [_delegate tabView:self willSelectTabViewItem:item];
    [_selectedTabViewItem.view setHidden:YES];
    //[_selectedTabViewItem.view removeFromSuperview];
    [_selectedTabViewItem _setState:ODTabStateBackground];
    
    _selectedTabViewItem = item;
    NSView *contentView = _window.contentView;
    NSView *view = item.view;
    view.frame = contentView.frame;
    //[_window addSubview:view];
    [item _setState:ODTabStateSelected];
    [view setHidden:NO];
    
    [_delegate tabView:self didSelectTabViewItem:item];
    
}

- (void)selectTabViewItemAtIndex:(NSInteger)idx {
    //if (_tabViewItems.count > idx) {
    
    ODTabViewItem *item = _tabViewItems[idx];
    
    [self selectTabViewItem:item];
    
    // }
}

#pragma mark - Navigation

- (void)selectFirstTabViewItem {
    [self selectTabViewItem:_tabViewItems.firstObject];
}

- (void)selectLastTabViewItem {
    [self selectTabViewItem:_tabViewItems.lastObject];
}

- (void)selectNextTabViewItem {
    NSInteger idx = [_tabViewItems indexOfObject:_selectedTabViewItem];
    idx = idx + 1;
    if (_tabViewItems.count > idx) {
        
        [self selectTabViewItemAtIndex:idx];
        
    } else {
        
        [self selectFirstTabViewItem];
    }
}

- (void)selectPreviousTabViewItem
{
    NSInteger idx = [_tabViewItems indexOfObject:_selectedTabViewItem];
    idx = idx - 1;
    if (0 <= idx) {
        
        [self selectTabViewItemAtIndex:idx];
        
    } else {
        
        [self selectLastTabViewItem];
    }
}

#pragma mark - Add/Remove

- (void)addTabViewItems:(NSArray *)objects
{
    for (ODTabViewItem *item in objects) {
        [_tabViewItems addObject:item];
    }
}

- (void)addTabViewItem:(ODTabViewItem *)item
{
    [_delegate tabView:self willAddTabViewItem:item];
    [_tabViewItems addObject:item];
    [_delegate tabView:self didAddTabViewItem:item];
    [self setNeedsDisplay:YES];
}

- (void)insertTabViewItem:(ODTabViewItem *)item atIndex:(NSInteger)idx
{
    //if (_tabViewItems.count > idx) {
        
        [_delegate tabView:self willAddTabViewItem:item];
        [_tabViewItems insertObject:item atIndex:idx];
        [_delegate tabView:self didAddTabViewItem:item];
        [self setNeedsDisplay:YES];
    //}
}

- (void)addTabViewItem:(ODTabViewItem *)item relativeToSelectedTab:(BOOL)value {
    if (value && _tabViewItems.lastObject != _selectedTabViewItem) {
        NSInteger idx = [_tabViewItems indexOfObject:_selectedTabViewItem];
        idx = idx + 1;
        [self insertTabViewItem:item atIndex:idx];
    } else {
        [self addTabViewItem:item];
    }
}

- (void)removeTabViewItem:(ODTabViewItem *)item
{
    
    if (_selectedTabViewItem == item) {
        
        if (_tabViewItems.count > 1) {
            
            (item == _tabViewItems.lastObject) ? [self selectPreviousTabViewItem] : [self selectNextTabViewItem];
        }
        
    }
    
    [_delegate tabView:self willRemoveTabViewItem:item];
    [_tabViewItems removeObject:item];
    [_delegate tabView:self didRemoveTabViewItem:item];
    
    if (_tabViewItems.count == 0) {
        
        _selectedTabViewItem = nil;
        [_window close];
    }
    [self setNeedsDisplay:YES];
}

- (void)removeTabViewItemAtIndex:(NSInteger)idx
{
   // if (_tabViewItems.count > idx) {
        
        ODTabViewItem *item = [_tabViewItems objectAtIndex:idx];
        [self removeTabViewItem:item];
   // }
}

- (void)removeTabViewItemWithView:(id)view
{
    for (ODTabViewItem *item in _tabViewItems) {
        if (item.view == view) {
            [self removeTabViewItem:item];
            break;
        }
    }
}

- (void)removeSelectedTabViewItem
{
    [self removeTabViewItem:_selectedTabViewItem];
}

- (void)removeAllTabs
{
    NSArray *openTabs = _tabViewItems.copy;
    for (ODTabViewItem *item in openTabs) {
        [self removeTabViewItem:item];
    }
}

#pragma mark - Query

- (NSInteger)numberOfTabViewItems
{
    return _tabViewItems.count;
}

- (NSInteger)indexOfTabViewItem:(ODTabViewItem *)TabViewItem
{
    return [_tabViewItems indexOfObject:TabViewItem];
}

- (ODTabViewItem *)tabViewItemAtIndex:(NSInteger)idx
{
    if (_tabViewItems.count > idx) {
        return _tabViewItems[idx];
    }
    
    return nil;
}

- (ODTabViewItem *)tabViewItemWithView:(id)view {
    for (ODTabViewItem *item in _tabViewItems) {
        if (item.view == view) {
            return item;
        }
    }
    
    return nil;
}

- (NSMutableArray *)_tabViewItemArray {
    return _tabViewItems;
}

//- (void)addTabViewItem:(ODTabViewItem *)item {
//    _count++;
//    
//    [self setNeedsDisplay:YES];
//    
//}
#pragma mark -
#pragma mark  Drag n Drop
#pragma mark  Destination Operations

//- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
//    /*------------------------------------------------------
//     method called whenever a drag enters our drop zone
//     --------------------------------------------------------*/
//    
//    // Check if the pasteboard contains image data and source/user wants it copied
//    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
//        [sender draggingSourceOperationMask] &
//        NSDragOperationCopy ) {
//        
//        //highlight our drop zone
//        _highlightDrop = YES;
//        
//        [self setNeedsDisplay: YES];
//        
//        /* When an image from one window is dragged over another, we want to resize the dragging item to
//         * preview the size of the image as it would appear if the user dropped it in. */
//        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
//                                          forView:self
//                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
//                                    searchOptions:@{}
//                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
//                                           
//                                           /* Only resize a fragging item if it originated from one of our windows.  To do this,
//                                            * we declare a custom UTI that will only be assigned to dragging items we created.  Here
//                                            * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
//                                           if ( ![[[draggingItem item] types] containsObject:kPrivateDragUTI] ) {
//                                               
//                                               *stop = YES;
//                                               
//                                           } else {
//                                               /* In order for the dragging item to actually resize, we have to reset its contents.
//                                                * The frame is going to be the destination view's bounds.  (Coordinates are local
//                                                * to the destination view here).
//                                                * For the contents, we'll grab the old contents and use those again.  If you wanted
//                                                * to perform other modifications in addition to the resize you could do that here. */
//                                               [draggingItem setDraggingFrame:(NSRect){0, 0, 32, 32}
//                                                                     contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
//                                           }
//                                       }];
//        
//        //accept data as a copy operation
//        return NSDragOperationCopy;
//    }
//    
//    return NSDragOperationNone;
//}
//
//- (void)draggingExited:(id <NSDraggingInfo>)sender {
//    /*------------------------------------------------------
//     method called whenever a drag exits our drop zone
//     --------------------------------------------------------*/
//    //remove highlight of the drop zone
//    _highlightDrop = NO;
//    _draggedTabIdx = -1;
//    
//    [self setNeedsDisplay: YES];
//}
//
//- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
//    /*------------------------------------------------------
//     method to determine if we can accept the drop
//     --------------------------------------------------------*/
//    //finished with the drag so remove any highlighting
//   _highlightDrop = NO;
//    
//    [self setNeedsDisplay: YES];
//    
//    //check to see if we can accept the data
//    return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
//}
//
//- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
//    /*------------------------------------------------------
//     method that should handle the drop data
//     --------------------------------------------------------*/
//    if ( [sender draggingSource] != self ) {
//        NSURL* fileURL;
//        
//        //set the image using the best representation we can get from the pasteboard
//        if([NSImage canInitWithPasteboard: [sender draggingPasteboard]]) {
////            NSImage *newImage = [[NSImage alloc] initWithPasteboard: [sender draggingPasteboard]];
////            [self setImage:newImage];
////            [newImage release];
//        }
//        
//        //if the drag comes from a file, set the window title to the filename
//        fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
//        [[self window] setTitle: fileURL!=NULL ? [fileURL absoluteString] : @"(no name)"];
//    }
//    
//    NSPoint event_location = sender.draggingLocation;
//    NSPoint local_point = [self convertPoint:event_location fromView:nil];
//    NSUInteger count = _tabViewItems.count;
//    for (int i = 0; i < count; i++) {
//        NSRect rect = _rects[i];
//        BOOL result = [self mouse:local_point inRect:rect];
//        if (result && i != _draggedTabIdx && _draggedTabIdx < count) {
//            ODTabViewItem *item = _tabViewItems[_draggedTabIdx];
//            [self removeTabViewItemAtIndex:_draggedTabIdx];
//            [self insertTabViewItem:item atIndex:i];
//            
//            printf("%s\n", __PRETTY_FUNCTION__);
//            break;
//        }
//        
//    }
//    
//    return YES;
//}



//- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame; {
//    /*------------------------------------------------------
//     delegate operation to set the standard window frame
//     --------------------------------------------------------*/
//    //get window frame size
//    NSRect ContentRect=self.window.frame;
//    
//    //set it to the image frame size
//    ContentRect.size=[[self image] size];
//    
//    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
//};

#pragma mark Source Operations

//- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
//    /*------------------------------------------------------
//     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
//     --------------------------------------------------------*/
//    switch (context) {
//        case NSDraggingContextOutsideApplication:
//            return NSDragOperationCopy;
//            
//            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
//        case NSDraggingContextWithinApplication:
//        default:
//            return NSDragOperationCopy;
//            break;
//    }
//}
//
//- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
//    /*------------------------------------------------------
//     method called by pasteboard to support promised
//     drag types.
//     --------------------------------------------------------*/
//    //sender has accepted the drag and now we need to send the data for the type we promised
//    if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
//        
//        //set data for TIFF type on the pasteboard as requested
//        //[sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
//        
//    } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
//        
//        //set data for PDF type on the pasteboard as requested
//        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
//    }
//    
//}

#pragma mark - Tracking Mouse

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
        
    }
        
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame
                                                 options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited|NSTrackingInVisibleRect|NSTrackingMouseMoved
                                                   owner:self
                                                userInfo:nil];
    
    
    [self addTrackingArea:_trackingArea];
    
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint event_location = theEvent.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSUInteger count = _tabViewItems.count;
    for (int i = 0; i < count; i++) {
        NSRect rect = _rects[i];
        BOOL result = [self mouse:local_point inRect:rect];
        if (result && _highlightedTabIdx != i && i != _selectedTabIdx) {
      
            _highlightedTabIdx = i;
            [self setNeedsDisplay:YES];
            
            self.toolTip = nil;
            self.toolTip = [_tabViewItems[i] label];
           
#if DEBUG
            printf("%s\n", __PRETTY_FUNCTION__);
#endif
            break;
        }
        
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    _highlightedTabIdx = -1;
    [self setNeedsDisplay:YES];
}

- (void)otherMouseDown:(NSEvent *)theEvent {
    NSRect draggingRect;
    NSPoint event_location = theEvent.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSUInteger count = _tabViewItems.count;
    for (int i = 0; i < count; i++) {
        NSRect rect = _rects[i];
        BOOL result = [self mouse:local_point inRect:rect];
        if (result) {
            
            
            draggingRect = rect;
            _draggedTabRect = rect;
            _draggedTabIdx = i;
            [self setWantsLayer:YES];
            [self setNeedsDisplay:YES];
#if DEBUG
            printf("%s\n", __PRETTY_FUNCTION__);
#endif
            break;
        }
        
    }
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    if (_draggedTabIdx != -1) {
        CGFloat deltaX = theEvent.deltaX;
        _draggedTabRect.origin.x += deltaX;
        [self setWantsLayer:YES];
        [self setNeedsDisplay:YES];
    }
}

- (void)otherMouseUp:(NSEvent *)theEvent {
    
    NSPoint event_location = theEvent.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSUInteger count = _tabViewItems.count;
    for (int i = 0; i < count; i++) {
        NSRect rect = _rects[i];
        BOOL result = [self mouse:local_point inRect:rect];
        if (result && i != _draggedTabIdx && _draggedTabIdx < count) {
            ODTabViewItem *item = _tabViewItems[_draggedTabIdx];
            [_tabViewItems removeObject:item];
            [_tabViewItems insertObject:item atIndex:i];
//            [self removeTabViewItemAtIndex:_draggedTabIdx];
//            [self insertTabViewItem:item atIndex:i];
#if DEBUG
            printf("%s\n", __PRETTY_FUNCTION__);
#endif
            break;
        }
        
    }
    [self setWantsLayer:NO];
    [self setNeedsDisplay:YES];
    _draggedTabIdx = -1;


}

- (void)rightMouseDown:(NSEvent *)theEvent {
    NSPoint event_location = theEvent.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSUInteger count = _tabViewItems.count;
    for (int i = 0; i < count; i++) {
        NSRect rect = _rects[i];
        BOOL result = [self mouse:local_point inRect:rect];
        if (result) {
            _tabMenuIdx = i;
              break;
        }
        
    }

    [_defaultMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

//- (void)otherMouseDragged:(NSEvent *)theEvent {
//    /*------------------------------------------------------
//     catch mouse down events in order to start drag
//     --------------------------------------------------------*/
//    
//    /* Dragging operation occur within the context of a special pasteboard (NSDragPboard).
//     * All items written or read from a pasteboard must conform to NSPasteboardWriting or
//     * NSPasteboardReading respectively.  NSPasteboardItem implements both these protocols
//     * and is as a container for any object that can be serialized to NSData. */
//    
//    NSPasteboardItem *pbItem = [NSPasteboardItem new];
//    /* Our pasteboard item will support public.tiff, public.pdf, and our custom UTI (see comment in -draggingEntered)
//     * representations of our data (the image).  Rather than compute both of these representations now, promise that
//     * we will provide either of these representations when asked.  When a receiver wants our data in one of the above
//     * representations, we'll get a call to  the NSPasteboardItemDataProvider protocol method –pasteboard:item:provideDataForType:. */
//    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, NSPasteboardTypePDF, kPrivateDragUTI, nil]];
//    
//    //create a new NSDraggingItem with our pasteboard item.
//    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
//    
//    
//    /* The coordinates of the dragging frame are relative to our view.  Setting them to our view's bounds will cause the drag image
//     * to be the same size as our view.  Alternatively, you can set the draggingFrame to an NSRect that is the size of the image in
//     * the view but this can cause the dragged image to not line up with the mouse if the actual image is smaller than the size of the
//     * our view. */
//    NSRect draggingRect;
//    NSPoint event_location = theEvent.locationInWindow;
//    NSPoint local_point = [self convertPoint:event_location fromView:nil];
//    NSUInteger count = _tabViewItems.count;
//    for (int i = 0; i < count; i++) {
//        NSRect rect = _rects[i];
//        BOOL result = [self mouse:local_point inRect:rect];
//        if (result) {
//            
//            
//            draggingRect = rect;
//            _draggedTabRect = rect;
//            _draggedTabIdx = i;
//            [self setNeedsDisplay:YES];
//            printf("%s\n", __PRETTY_FUNCTION__);
//            break;
//        }
//        
//    }
//
//    
//    /* While our dragging item is represented by an image, this image can be made up of multiple images which
//     * are automatically composited together in painting order.  However, since we are only dragging a single
//     * item composed of a single image, we can use the convince method below. For a more complex example
//     * please see the MultiPhotoFrame sample. */
//    [dragItem setDraggingFrame:draggingRect contents:[NSImage imageNamed:NSImageNameApplicationIcon]];
//    
//    //create a dragging session with our drag item and ourself as the source.
//    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:@[dragItem] event:theEvent source:self];
//    //causes the dragging item to slide back to the source if the drag fails.
//    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
//    
//    draggingSession.draggingFormation = NSDraggingFormationNone;
//
//}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    /*------------------------------------------------------
     accept activation click as click in window
     --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {

    NSEventModifierFlags flags = theEvent.modifierFlags;
    if (!(flags & NSShiftKeyMask)) {
        NSPoint event_location = theEvent.locationInWindow;
        NSPoint local_point = [self convertPoint:event_location fromView:nil];
        NSUInteger count = _tabViewItems.count;
        for (int i = 0; i < count; i++) {
            NSRect rect = _rects[i];
            BOOL result = [self mouse:local_point inRect:rect];
            if (result) {
                
                
                _highlightedTabIdx = -1;
                
                
                if (flags & NSCommandKeyMask) {
                    [self removeTabViewItemAtIndex:i];
                    
                } else {
                    [self selectTabViewItemAtIndex:i];
                    _selectedTabIdx = i;
                }
                [self setNeedsDisplay:YES];
               
#if DEBUG
                printf("%s\n", __PRETTY_FUNCTION__);
#endif
                 break;
            }
            
        }
    }

}

//- (void)mouseUp:(NSEvent *)theEvent {
//
//}

#pragma mark - Drawing

static inline void _calcFrame(NSRect *cellFrame, CGFloat *h1, CGFloat *h2) {
    cellFrame->origin.y = (*h1 - *h2) / 2;
    cellFrame->size.height = *h2;
    cellFrame->origin.x += 4;
    cellFrame->size.width -= 8;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSUInteger count = _tabViewItems.count;
    
    if (count) {
        _selectedTabIdx = [_tabViewItems indexOfObject:_selectedTabViewItem];
        NSRect rect = self.bounds;
        CGFloat width = rect.size.width / count;
        rect.size.width = width;
        if (width != _rects[0].size.width) {
            if(_rects) {
                free(_rects);
            }
            _rects = malloc(sizeof(NSRect) * count + 1);
            for (int i = 0; i < count; i++) {
                rect.origin.x = width * i;
                _rects[i] = rect;

            }
        }
        
        for (int i = 0; i < count; i++) {
            
            NSRect cellFrame = _rects[i];
            NSDictionary *a;
            if (i == _selectedTabIdx) {
                
                [_foregroundColor set];
                a = _activeTabFont;
            } else {
                [_backgroundColor set];
                a = _inactiveTabFont;
            }
            if (i == _highlightedTabIdx) {
                [_highlightColor set];
            }
            NSRectFill(cellFrame);
//            if (i != _selectedTabIdx) {
//                [_shadowColor set];
//                NSFrameRect(cellFrame);
//            } else {
//                [_highlightColor set];
//                NSFrameRect(cellFrame);
//            }
            ODTabViewItem *item = _tabViewItems[i];
            NSString *title = item.label;
            
            //    cellFrame.origin.x += 15;
            CGFloat h1 = NSHeight(cellFrame);
            CGFloat h2 = [title sizeWithAttributes:a].height;
            _calcFrame(&cellFrame, &h1, &h2);
            [title drawInRect:cellFrame withAttributes:a];
        
        }
        
        if (_draggedTabIdx != -1) {
            ODTabViewItem *item = _tabViewItems[_draggedTabIdx];
            
            NSString *title = item.label;
            NSRect cellFrame = _draggedTabRect;
            [_foregroundColor set];
            NSRectFill(cellFrame);
            CGFloat h1 = NSHeight(cellFrame);
            CGFloat h2 = [title sizeWithAttributes:_activeTabFont].height;
            _calcFrame(&cellFrame, &h1, &h2);
            [title drawInRect:cellFrame withAttributes:_activeTabFont];
        }
//        [_highlightColor set];
//        //[[NSColor blackColor] set];
//        NSRect bounds = self.bounds;
//        [NSBezierPath strokeLineFromPoint:NSMakePoint(0, 0)
//                                  toPoint:NSMakePoint(0, NSHeight(bounds))];
//        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSWidth(bounds), 0)
//                                  toPoint:NSMakePoint(NSWidth(bounds), NSHeight(bounds))];
        
       // NSFrameRect(self.bounds);
#if DEBUG
        printf("width: %f\n", width);
#endif
       
        
    }

}

#pragma mark - Tab Menu

- (void)closeTabMenuItemClicked:(id)sender {
    if (_tabMenuIdx < _tabViewItems.count) {
        [self removeTabViewItemAtIndex:_tabMenuIdx];
    }
    _tabMenuIdx = NSUIntegerMax;
}

- (void)closeOtherTabsMenuItemClicked:(id)sender {
    NSUInteger count = _tabViewItems.count;
    if (_tabMenuIdx < count) {
        [self selectTabViewItemAtIndex:_tabMenuIdx];
        ODTabViewItem *item = _tabViewItems[_tabMenuIdx];
        for (ODTabViewItem *i in _tabViewItems.copy) {
            if(i != item) {
                [self removeTabViewItem:i];
            }
        }
    }
    _tabMenuIdx = NSUIntegerMax;
}

- (void)moveTabToNewWindowMenuItemClicked:(id)sender {
    NSUInteger count = _tabViewItems.count;
    if (_tabMenuIdx < count && count > 1) {
        if (_delegateRespondTo.shouldMoveTabViewItem) {
            ODTabView *tv = nil;
            ODTabViewItem *item = _tabViewItems[_tabMenuIdx];
            if ([_delegate tabView:self shouldMoveTabViewItem:item to:&tv]) {
                if (tv) {
                    if (item == self.selectedTabViewItem) {
                        [self selectNextTabViewItem];
                    }
                    [_tabViewItems removeObject:item];
                    [tv addTabViewItem:item];
                    [tv selectTabViewItem:item];
                    if (_delegateRespondTo.didMoveTabViewItem) {
                        [_delegate tabView:self didMoveTabViewItem:item to:tv];
                    }
                }
                
            }
        }
    }
    _tabMenuIdx = NSUIntegerMax;
}

- (void)moveTabToOtherWindowMenuItemClicked:(NSMenuItem *)sender {
    ODTabView *tv = sender.representedObject;
    ODTabViewItem *item = _tabViewItems[_tabMenuIdx];
    if (item == self.selectedTabViewItem) {
        [self selectNextTabViewItem];
    }
    [_tabViewItems removeObject:item];
    [tv addTabViewItem:item];
    [tv selectTabViewItem:item];
    if (_delegateRespondTo.didMoveTabViewItem) {
        [_delegate tabView:self didMoveTabViewItem:item to:tv];
    }
}

- (void)menuNeedsUpdate:(NSMenu*)menu {

    if (_delegateRespondTo.tabViewList) {
        [menu removeAllItems];
        NSArray *tabViews = nil;
        NSMenuItem *menuItem = nil;
        [_delegate tabView:self tabViewList:&tabViews];
        if (tabViews) {
            for (ODTabView *tv in tabViews) {
                if (tv != self) {
                    menuItem = [[NSMenuItem alloc] initWithTitle:tv.selectedTabViewItem.label
                                                          action:@selector(moveTabToOtherWindowMenuItemClicked:)
                                                   keyEquivalent:@""];
                    menuItem.target = self;
                    menuItem.representedObject = tv;
                    [menu addItem:menuItem];
                }

            }
        }
    }

}


#pragma mark - dealloc

- (void)dealloc
{
    if(_rects) {
        free(_rects);
    }
}

@end
