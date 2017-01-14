//
//  ODWebDownloadView.m
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebDownloadView.h"
#import "ODWebDownloadData.h"
#import "ODWebDownloadManager.h"

#define tableColumn(x) [self->_table tableColumnWithIdentifier:x]

@interface ODWebDownloadView () <NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate, NSMenuDelegate>
{
    IBOutlet NSTableView *_table;
    NSPopover *_popover;
    
    dispatch_source_t _updateTimer;
}

@end

@implementation ODWebDownloadView



-(NSString *)nibName
{
    return [self className];
}

-(void)awakeFromNib
{
    _table.dataSource = self;
    _table.delegate = self;
    [_table setDoubleAction:@selector(openFile:)];
    
    _popover = [[NSPopover alloc] init];
    [_popover setContentSize:NSMakeSize(NSWidth(self.view.frame), NSHeight(self.view.frame))];
    [_popover setBehavior: NSPopoverBehaviorTransient];
    [_popover setAnimates:YES];
    [_popover setContentViewController:self];
    _popover.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions
-(void)openFile:(id)sender
{
    NSInteger row = _table.selectedRow;
    
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        
        NSInteger clickedRow = _table.clickedRow;
        if (clickedRow != -1) {
            row = clickedRow;
        }
    }
    
    if (row != -1) {
        
        NSArray *array = [[ODWebDownloadManager sharedManager] downloads];
        ODWebDownloadData *data = [array objectAtIndex:row];
        [[NSWorkspace sharedWorkspace] openFile:data.destination];
    }
}

-(void)showInFinder:(id)sender
{
    NSInteger row = _table.selectedRow;
    
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        
        NSInteger clickedRow = _table.clickedRow;
        if (clickedRow != -1) {
            row = clickedRow;
        }
    }
    
    if (row != -1) {
        NSArray *array = [[ODWebDownloadManager sharedManager] downloads];
        ODWebDownloadData *data = [array objectAtIndex:row];
        [[NSWorkspace sharedWorkspace] selectFile:data.destination inFileViewerRootedAtPath:@""];
        //[[NSWorkspace sharedWorkspace] openFile:data.destination];
    }
}

-(void)stop:(id)sender
{
    NSInteger row = _table.selectedRow;
    
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSInteger clickedRow = _table.clickedRow;
        if (clickedRow != -1) {
            row = clickedRow;
            [sender setTitle:@"Resume"];
            [sender setAction:@selector(resume:)];
            
        }
    }
    
    if (row != -1) {
        
        [[ODWebDownloadManager sharedManager] pauseDownloadAtIndex:row];
        
    }
}

-(void)resume:(id)sender
{
    NSInteger row = _table.clickedRow;
    
    if (row != -1) {
        [sender setTitle:@"Stop"];
        [sender setAction:@selector(stop:)];
        [[ODWebDownloadManager sharedManager] resumeDownloadAtIndex:row];
        
        
    }
}

-(void)removeFromList:(id)sender
{
    NSInteger row = _table.selectedRow;
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSInteger clickedRow = _table.clickedRow;
        if (clickedRow != -1) {
            row = clickedRow;
        }
    }
    if (row != -1) {
        ODWebDownloadManager *manager = [ODWebDownloadManager sharedManager];
        [manager removeDownloadAtIndex:row];
        [_table reloadData];
        
    }
}

-(void)removeAll:(id)sender
{
    ODWebDownloadManager *manager = [ODWebDownloadManager sharedManager];
    [manager removeAll];
    [_table reloadData];
}

-(void)copyLink:(id)sender
{
    NSInteger row = _table.selectedRow;
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSInteger clickedRow = _table.clickedRow;
        if (clickedRow != -1) {
            row = clickedRow;
        }
        
    }
    if (row != -1) {
        NSArray *array = [[ODWebDownloadManager sharedManager] downloads];
        ODWebDownloadData *data = [array objectAtIndex:row];
        //[[NSWorkspace sharedWorkspace] selectFile:data.destination inFileViewerRootedAtPath:@"/Users/"];
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:@[[data.initialRequest.URL.absoluteString copy]]];
        //[[NSWorkspace sharedWorkspace] openFile:data.destination];
    }
}

-(void)showPopover
{
    
    if (![_popover isShown]) {
        
        
        //        [_popover setDelegate:self];
        NSWindow * win = [NSApp mainWindow];
        //NSButton *button = [win standardWindowButton:NSWindowZoomButton];
        
        //NSPoint mouseCoord = [NSEvent mouseLocation];
        //NSRect rect = [[NSApp mainWindow] convertRectFromScreen:button.frame];
        //[self update];
        [_table reloadData];
        
        NSRect winFrame = win.contentView.frame;
        
        NSRect frame = NSMakeRect(NSMaxX(winFrame) - 72, NSMaxY(winFrame) - 5, 72, 5);
        
        [_popover showRelativeToRect:frame ofView:win.contentView preferredEdge:NSMinYEdge];
        //[_popover showRelativeToRect:button.frame ofView:button.superview preferredEdge:NSMinYEdge];
        
    };
    
}

-(void)startScanUpdateTimerWithInterval:(int)sec
{
    if (![_popover isShown]) {
        
        if(_updateTimer){
            dispatch_source_cancel(_updateTimer);
        }
        
        return;
    }
    
    //dispatch_source_t timer = self->_updateTimer;
    if(_updateTimer){
        dispatch_source_cancel(_updateTimer);
    }
    _updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //self->_updateTimer = timer;
    
    dispatch_source_set_timer(_updateTimer, dispatch_time(0, sec * NSEC_PER_SEC), 1.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_updateTimer, ^{
        
        dispatch_source_cancel(_updateTimer);
        // puts("updated");
        [_table reloadData];
        
        
        return [self startScanUpdateTimerWithInterval:sec];
        
    });
    
    
    
    dispatch_resume(_updateTimer);
    
}

#pragma mark - Popover Delegate

- (void)popoverDidShow:(NSNotification *)notification
{
    //puts("didshow");
    [self startScanUpdateTimerWithInterval:3];
}

- (void)popoverDidClose:(NSNotification *)notification
{
    
    //puts("didclose");
    if(_updateTimer){
        
        dispatch_source_cancel(_updateTimer);
    }
}

#pragma mark - Table View
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    ODWebDownloadData *obj;
    //NSString *mode;
    
    
    if (tableView == _table) {
        
        NSArray *items = [[ODWebDownloadManager sharedManager] downloads];
        if (row < items.count) {
            
            obj = [items objectAtIndex:row];
            
            
            if (tableColumn == tableColumn(@"DOWNLOADS")) {
                
                NSString *result = obj.description;
                //                if (obj.error) {
                //                    result = obj.error.localizedDescription;
                //                } else {
                ////                    int received = obj.bytesReceived / 1024;
                ////                    if (received > 1024 ) {
                ////                        received 
                ////                    }
                //                result = [NSString stringWithFormat:@"%i/%lldkb %.0f%% %@", 
                //                                    obj.bytesReceived / 1024, 
                //                                    obj.expectedLength / 1024, 
                //                                    obj.percentComplete, 
                //                                    obj.filename];
                //                   
                //                }
                return result;
            }
            
            
        }
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //    ODWindowController *ctl = [NSApp mainWindow].windowController;
    //    ODTabController *tabctl = [ctl tabsController];
    NSArray *items = [[ODWebDownloadManager sharedManager] downloads];;
    return (items ? [items count] : 0);
}

#pragma mark - Menu Delegate
-(void)menuNeedsUpdate:(NSMenu *)menu
{
    
    long row = _table.clickedRow;
    ODWebDownloadData *data = [[[ODWebDownloadManager sharedManager] downloads] objectAtIndex:row];
    BOOL completed = [data isCompleted];
    
    for (NSMenuItem *item in menu.itemArray) {
        long tag = item.tag;
        if (row == -1) {
            [item setEnabled:NO];
        } else {
            
            switch (tag) {
                case 1:
                    item.enabled = !completed ? NO : YES;
                    //                    if (!completed) {
                    //                        item.enabled = NO;
                    //                    } else {
                    //                        item.enabled = YES;
                    //                    }
                    
                    break;
                case 2:
                    item.enabled = !completed ? NO : YES;
                    //                    if (!completed) {
                    //                        item.enabled = NO;
                    //                    } else {
                    //                        item.enabled = YES;
                    //                    }
                    break;
                case 5:
                    item.enabled = !completed ? YES : NO;
                    //                    if (completed) {
                    //                        item.enabled = NO;
                    //                    } else {
                    //                        item.enabled = YES;
                    //                    }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

@end
