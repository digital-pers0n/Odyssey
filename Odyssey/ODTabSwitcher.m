

//
//  ODTabSwitcherView.m
//  Odyssey
//
//  Created by Terminator on 12/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWindowController.h"
#import "AppDelegate.h"
//#import "ODTabController.h"
#import "ODTabBar.h"
#import "ODTabSwitcher.h"
#import "ODWindowTitleBar.h"

@import WebKit;
#define tableColumn(x) [self->_table tableColumnWithIdentifier:x]

@interface ODTabSwitcher () <NSTableViewDataSource, NSTableViewDelegate>
{
    //NSMutableArray *_tabs;
    NSPopover *_popover;
    BOOL _sidebar;
}

@end

@implementation ODTabSwitcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sidebar = NO;
    }
    return self;
}

+(instancetype)switcher
{
    static ODTabSwitcher *switcher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        switcher = [[ODTabSwitcher alloc] init];
    });
    
    return switcher;
}

-(NSString *)nibName
{
    return [self className];
}

-(void)awakeFromNib
{
    //_tabs = [NSMutableArray new];
    _table.dataSource = self;
    _table.delegate = self;
    [_table setDoubleAction:@selector(cellClicked:)];
    
    _popover = [[NSPopover alloc] init];
    [_popover setContentSize:NSMakeSize(NSWidth(self.view.frame), NSHeight(self.view.frame))];
    [_popover setBehavior: NSPopoverBehaviorSemitransient];
    [_popover setAnimates:YES];
    //[_popover setContentViewController:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(BOOL)isSidebarOpen
{
    return _sidebar;
}

-(void)update
{
//    [_tabs removeAllObjects];
//    
//    ODWindowController *ctl = [NSApp mainWindow].windowController;
//    ODTabController *tabctl = [ctl tabsController];
//    for (NSMenuItem *itm in tabctl.menu.itemArray) {
//        
//        [_tabs addObject:itm.representedObject];
//        
//    }
//    
    [_table reloadData];
}

-(void)showPopover
{
    
    if (![_popover isShown]) {
        
        
        //        [_popover setDelegate:self];
        NSWindow * win = [NSApp mainWindow];
        //NSButton *button = [win standardWindowButton:NSWindowZoomButton];
        
        //NSPoint mouseCoord = [NSEvent mouseLocation];
        //NSRect rect = [[NSApp mainWindow] convertRectFromScreen:button.frame];
        [_table reloadData];
        
        ODWindowController *ctl = win.windowController;
        ODWindowTitleBar *titleBar = ctl.titleBar;
        
       // NSRect winFrame = win.contentView.frame;
        
       // NSRect frame = NSMakeRect(NSMaxX(winFrame) - 130, NSMaxY(winFrame) - 5, 130, 5);
        
        //NSRect frame = NSMakeRect(0, NSMaxY(win.contentView.frame) - 5, 270, 5);
        [_popover showRelativeToRect:titleBar.tabButton.frame ofView:titleBar.view preferredEdge:NSMinYEdge];
        //[_popover showRelativeToRect:frame ofView:win.contentView preferredEdge:NSMinYEdge];
        //[_popover showRelativeToRect:button.frame ofView:button.superview preferredEdge:NSMinYEdge];
        
    } else {
        
        [_popover close];
    };

}

-(void)runModal
{
    [self update];
    
    NSWindow *win = [[NSWindow alloc] init];
    
     long height = 28 * _table.numberOfRows;
    if (height > 480) {
        [self.view setFrameSize:NSMakeSize(280, 480)];
    } else {
        if (height < 100) {
            height = 100;
        }
        [self.view setFrameSize:NSMakeSize(280, height)];
    }
    
    NSRect frame = self.view.frame;
    
    [win setFrame:NSMakeRect(0, 0, NSWidth(frame), NSHeight(frame) + 8) display:NO animate:NO];
    
    [win.contentView addSubview:self.view];
    
    [NSApp beginSheet:win modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:win];
    // sheet is up here...
    
    [NSApp endSheet:win];
    [win orderOut:self];
}

-(void)showSidebar
{
    NSView *view = self.view;
    NSWindow *win = [NSApp mainWindow];
    ODWindowController *ctl = win.windowController;
    ODTabBar *tabBar = [ctl tabBar];
    WebView *wView = tabBar.activeTab;
    NSRect viewRect = wView.frame;
    
    if (!view.window) {
        
        [_table reloadData];
     
        [win.contentView addSubview:view];

        [wView setFrame:NSMakeRect(200, 0, NSWidth(viewRect) - 200, NSHeight(viewRect))];
        NSRect winRect = win.contentView.frame;
        [view setFrameSize:NSMakeSize(200, NSHeight(winRect) + 20)];
        [win makeFirstResponder:_table];
        _sidebar = YES;
        
        
        //[view setNeedsDisplay:YES];
    } else {
        
        [view removeFromSuperview];
        NSRect winRect = win.contentView.frame;
        [wView setFrame:NSMakeRect(0, 0, NSWidth(winRect), NSHeight(winRect))];
        _sidebar = NO;
    }
    
}

-(void)closeSidebar
{
    NSView *view = self.view;
    NSWindow *win = view.window;
    ODWindowController *ctl = win.windowController;
    ODTabBar *tabBar = [ctl tabBar];
    WebView *wView = tabBar.activeTab;
    NSRect winRect = win.contentView.frame;
    [wView setFrame:NSMakeRect(0, 0, NSWidth(winRect), NSHeight(winRect))];
    [view removeFromSuperview];
    _sidebar = NO;
}

#pragma mark - Actions
-(void)closeButtonClicked:(id)sender
{
    NSInteger row = _table.selectedRow;
    if (row == -1) {
        return;
    }
     ODWindowController *ctl = [NSApp mainWindow].windowController;
    // ODTabController *tabctl = [ctl tabsController];
    ODTabBar *tabBar = [ctl tabBar];
    [tabBar closeTabAtIndex:row];
   // NSUInteger idx = [tabctl.menu indexOfItemWithRepresentedObject:[_tabs objectAtIndex:row]];
//    [_tabs removeObjectAtIndex:row];
    //[tabctl closeTab:[tabctl.menu itemAtIndex:row]];
//    [_table beginUpdates];
//    [_table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideDown];
//    [_table endUpdates];
 [self update];
    if (row > 0) {
        row--;
        [_table selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    } 
    
    //[_tabs removeObjectAtIndex:idx];
    
    
}

-(void)cancelButtonClicked:(id)sender
{
    [_popover close];
  //  [self closeSidebar];
     //[self.view removeFromSuperview];
    [NSApp stopModal];
}

-(void)addButtonClicked:(id)sender
{
     ODWindowController *ctl = [NSApp mainWindow].windowController;
    [ctl openTab];
    [self update];
}

-(void)cellClicked:(id)sender
{
    [self update];
    ODWindowController *ctl = [NSApp mainWindow].windowController;
    //ODTabController *tabctl = [ctl tabsController];
     ODTabBar *tabBar = [ctl tabBar];
    long row = _table.selectedRow;
    if (tabBar.tabList.count > row) {
            [tabBar selectTabAtIndex:row];
    }
    
//     [self.view removeFromSuperview];
   // [self closeSidebar];
    [NSApp stopModal];

    //NSUInteger idx = [tabctl.menu indexOfItemWithRepresentedObject:[_tabs objectAtIndex:_table.selectedRow]];
    //[tabctl switchTab:[tabctl.menu itemAtIndex:_table.selectedRow]];
    
}

#pragma mark - Table View

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
    ODWindowController *ctl = [NSApp mainWindow].windowController;
    ODTabBar *tabBar = [ctl tabBar];
    NSArray *items = tabBar.tabList;
    NSString *result = nil;
    if (row < items.count) {
        
        WebView *obj = [items objectAtIndex:row];
        result = obj.mainFrameURL;
        
    }
    
    return result; 
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{

    WebView *obj;
    //NSString *mode;
    
    
    if (tableView == _table) {
        ODWindowController *ctl = [NSApp mainWindow].windowController;
        //ODTabController *tabctl = [ctl tabsController];
         ODTabBar *tabBar = [ctl tabBar];
        NSArray *items = tabBar.tabList; //= tabctl.menu.itemArray;
        if (row < items.count) {
            
            //NSMenuItem *item = [items objectAtIndex:row];
            //obj = item.representedObject;
            obj = [items objectAtIndex:row];
            
            
//            if (tableColumn == tableColumn(@"ICON")) {
//                
//                return [obj mainFrameIcon];
//            }
            if (tableColumn == tableColumn(@"TITLE")) {
                NSString *title = obj.mainFrameTitle.length ? obj.mainFrameTitle : obj.mainFrameURL;
                if (!title.length) {
                    title = @"(Empty Tab)";
                }
                return title;
            }

            
            
            
            
        }
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    ODWindowController *ctl = [NSApp mainWindow].windowController;
    //ODTabController *tabctl = [ctl tabsController];
     ODTabBar *tabBar = [ctl tabBar];
    NSArray *items =  tabBar.tabList; //tabctl.menu.itemArray;
    return (items ? [items count] : 0);
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors{
    
    //NSArray *network = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY];
    
    
    //self->_scan = [_table sortedArrayUsingDescriptors:[tableView sortDescriptors]];
    
    
    
    
    [tableView reloadData];
}

@end
