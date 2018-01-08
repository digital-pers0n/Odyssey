//
//  ODFindBanner.m
//  Odyssey
//
//  Created by Terminator on 4/28/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODFindBanner.h"
#import "ODDelegate.h"
#import "ODWindow.h"

@import WebKit;

@interface ODFindBannerView : NSView
@end

@implementation ODFindBannerView

-(void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedWhite:0.96 alpha:0.96] set];
    NSRectFill(dirtyRect);
//    [[NSColor lightGrayColor] set];
//    NSFrameRect(dirtyRect);
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    long deltaX = theEvent.deltaX;
    long deltaY = theEvent.deltaY;
    NSWindow *window = self.window;
    NSRect frame = window.frame;
    NSPoint point = NSMakePoint(NSMinX(frame) + (deltaX), NSMinY(frame) - (deltaY));

    [window setFrameOrigin:point];
}

@end

@interface ODFindBanner ()
{
    IBOutlet NSSearchField *_searchField;
}

-(IBAction)findNext:(id)sender;
-(IBAction)findPrevious:(id)sender;
-(IBAction)closeView:(id)sender;

-(void)_findString:(NSString *)string direction:(BOOL)forward;

@end

@implementation ODFindBanner

-(NSString *)nibName
{
    return [self className];
}

-(void)awakeFromNib
{
   // _searchField.sendsSearchStringImmediately = NO;
    _searchField.cell.sendsActionOnEndEditing  = NO;
    //_searchField.sendsWholeSearchString = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


-(void)installBanner
{
    _installed = YES;
    ODWindow *window = (id)NSApp.mainWindow;
    NSView *view = self.view;
    NSView *contentView = window.contentView;
    NSRect windowFrame = contentView.frame;
    [view setFrame:NSMakeRect(0, NSHeight(windowFrame), NSWidth(windowFrame), 32)];
    [contentView addSubview:view];
    [window makeFirstResponder:_searchField];
    view.wantsLayer = YES;
    [view.animator setFrameOrigin:NSMakePoint(0, NSHeight(windowFrame) - 32)];
}

-(void)uninstallBanner
{
    [self.view removeFromSuperview];
    _installed = NO;
}

#pragma mark - actions

-(void)findNext:(id)sender
{
    NSString *string = _searchField.stringValue;
    [self _findString:string direction:YES];
}

-(void)findPrevious:(id)sender
{
    NSString *string = _searchField.stringValue;
    [self _findString:string direction:NO];
}

-(void)closeView:(id)sender
{
    [self uninstallBanner];
}

#pragma mark - private

-(void)_findString:(NSString *)string direction:(BOOL)forward
{
    WebView *webView = [(ODDelegate *)[NSApp delegate] webView];
    BOOL result = [webView searchFor:string direction:forward caseSensitive:NO wrap:YES];
    if (!result) {
        NSBeep();
    }
}

@end
