//
//  ODTabSwitcher.m
//  Odyssey
//
//  Created by Terminator on 4/9/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODTabSwitcher.h"
#import "ODTabBar.h"
#import "ODTabItem.h"
#import "ODWindow.h"
#import "ODPopover.h"
#import "ODDelegate.h"
#import <WebKit/WebView.h>

@interface ODTabSwitcher () <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *_tableView;
    ODTabBar *_tabBar;
    ODPopover *_popover;
}

-(void)removeTabItem:(id)sender;
-(void)selectTabItem:(id)sender;


@end

@implementation ODTabSwitcher

+(id)tabSwitcher
{
    static dispatch_once_t onceToken;
    static ODTabSwitcher *result;
    dispatch_once(&onceToken, ^{
        result = [[ODTabSwitcher alloc] init];
    });
    
    return result;
}

-(NSString *)nibName
{
    return [self className];
}

-(void)awakeFromNib
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.doubleAction = @selector(selectTabItem:);
    _popover = [[ODPopover alloc] init];
    _popover.contentViewController = self;
    _popover.contentSize = self.view.frame.size;
    _popover.appearance = ODPopoverAppearanceLight;
}

#pragma mark - Actions


- (void)showPopoverForTabBar:(ODTabBar *)tabBar window:(ODWindow *)window
{
    NSView *contentView = window.contentView;
    NSRect contentRect = contentView.frame;
//    NSRect relativeRect = NSMakeRect(8, NSHeight(contentRect) - 16, 4, 4);
    NSRect relativeRect = NSMakeRect(NSMaxX(contentRect) - 256, NSMaxY(contentRect) - 10, 1, 1);
    [_popover showRelativeToRect:relativeRect ofView:contentView preferredEdge:NSMinYEdge];
    _tabBar = tabBar;
    [_tableView reloadData];
    
}

- (void)showPopover:(id)sender
{
    ODWindow *window = (id)[NSApp mainWindow];
    ODTabBar *tabBar = window.tabBar;
    if (tabBar) {
        [self showPopoverForTabBar:tabBar window:window];
    }
//    if (!_popover.shown) {
//        ODWindow *window = (id)[NSApp mainWindow];
//        ODTabBar *tabBar = window.tabBar;
//        if (tabBar) {
//            [self showPopoverForTabBar:tabBar window:window];
//        }   
//    } else {
//        [self closeView:nil];
//    }
}


- (IBAction)closeView:(id)sender
{
    [_popover close];
    _tabBar = nil;
    
}

- (IBAction)removeTabItem:(id)sender
{
    NSInteger idx = _tableView.selectedRow;

    if (_tabBar.numberOfTabItems > idx) {
        
        [_tabBar removeTabItemAtIndex:idx];
    }
    
    [_tableView reloadData];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx - 1] byExtendingSelection:NO];
}

- (IBAction)selectTabItem:(id)sender
{
    NSInteger idx = _tableView.selectedRow;

    if (_tabBar.numberOfTabItems > idx) {
        
        [_tabBar selectTabItemAtIndex:idx];
    }
    
    [self closeView:nil];
}

- (IBAction)newTab:(id)sender
{
    ODDelegate *delegate = [NSApp delegate];
    [delegate openTab:nil];
    [_tableView reloadData];
}

#pragma mark - Table View

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{

    NSString *result = nil;
    if (row < _tabBar.numberOfTabItems) {
        
        ODTabItem *obj = [_tabBar tabItemAtIndex:row];
        if (obj.type == ODTabTypeWebView) {
            WebView *v = (id)obj.view;
            result = v.mainFrameURL;
        }
       
        
    }
    
    return result; 
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    ODTabItem *obj;
    //NSString *mode;

    if (row < _tabBar.numberOfTabItems) {
        
        obj = [_tabBar tabItemAtIndex:row];
    
        NSString *title = obj.label;
        if (!title.length && obj.type == ODTabTypeWebView) {
            WebView *v = (id)obj.view;
            NSString *name = [[v.mainFrameURL lastPathComponent] stringByDeletingPathExtension];
            title = name;
        }
        return title;
  
        
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    
    return _tabBar.numberOfTabItems;
}


#pragma mark - NSEvent


-(void)keyDown:(NSEvent *)theEvent
{
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
