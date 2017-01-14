

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

@import WebKit;
#define tableColumn(x) [self->_table tableColumnWithIdentifier:x]

@interface ODTabSwitcher () <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *_tabs;
    NSPopover *_popover;
}

@end

@implementation ODTabSwitcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(NSString *)nibName
{
    return [self className];
}

-(void)awakeFromNib
{
    _tabs = [NSMutableArray new];
    _table.dataSource = self;
    _table.delegate = self;
    [_table setDoubleAction:@selector(cellClicked:)];
    
    _popover = [[NSPopover alloc] init];
    [_popover setContentSize:NSMakeSize(NSWidth(self.view.frame), NSHeight(self.view.frame))];
    [_popover setBehavior: NSPopoverBehaviorTransient];
    [_popover setAnimates:YES];
    [_popover setContentViewController:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
        [self update];
        
        NSRect winFrame = win.contentView.frame;
        
        NSRect frame = NSMakeRect(NSMaxX(winFrame) - 150, NSMaxY(winFrame) - 5, 150, 5);
        
        //NSRect frame = NSMakeRect(0, NSMaxY(win.contentView.frame) - 5, 270, 5);
        
        [_popover showRelativeToRect:frame ofView:win.contentView preferredEdge:NSMinYEdge];
        //[_popover showRelativeToRect:button.frame ofView:button.superview preferredEdge:NSMinYEdge];
        
    };

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
    [tabBar selectTabAtIndex:_table.selectedRow];
    //NSUInteger idx = [tabctl.menu indexOfItemWithRepresentedObject:[_tabs objectAtIndex:_table.selectedRow]];
    //[tabctl switchTab:[tabctl.menu itemAtIndex:_table.selectedRow]];
    
}

#pragma mark - Table View
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
            
            
            if (tableColumn == tableColumn(@"ICON")) {
                
                return [obj mainFrameIcon];
            }
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
