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

@interface ODTabSwitcher () <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *_tableView;
    ODTabView *_tabView;
    ODPopover *_popover;
    
    id<ODTabSwitcherDelegate> _delegate;
    struct __ODTabSwitcherDelegateRespondTo {
        unsigned int toolTipForTabViewItem:1;
        unsigned int openNewTab:1;
        unsigned int labelForTabViewItem:1;
    } _delegateRespondTo;
}

-(void)removeTabItem:(id)sender;
-(void)selectTabItem:(id)sender;


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
//    if (!_popover.shown) {
//        ODWindow *window = (id)[NSApp mainWindow];
//        ODTabView *tabBar = window.tabBar;
//        if (tabBar) {
//            [self showPopoverForTabBar:tabBar window:window];
//        }   
//    } else {
//        [self closeView:nil];
//    }
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

//    NSString *result = nil;
//    if (row < _tabView.numberOfTabViewItems) {
//        
//        ODTabViewItem *obj = [_tabView tabViewItemAtIndex:row];
//        if (obj.type == ODTabTypeDefault) {
//            WebView *v = (id)obj.view;
//            result = v.mainFrameURL;
//        }
//       
//        
//    }
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
    
//    ODTabViewItem *obj;
//    //NSString *mode;
//
//    if (row < _tabView.numberOfTabViewItems) {
//        
//        obj = [_tabView tabViewItemAtIndex:row];
//    
//        NSString *title = obj.label;
//        if (!title.length && obj.type == ODTabTypeDefault) {
//            WebView *v = (id)obj.view;
//            NSString *name = [[v.mainFrameURL lastPathComponent] stringByDeletingPathExtension];
//            title = name;
//        }
//        return title;
//  
//        
//    }
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
