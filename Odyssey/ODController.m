//
//  ODWindow.m
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODController.h"
#import "ODWindowController.h"

#import <WebKit/WebKit.h>
#import "ODSessionData.h"
#import "Bookmarks.h"
#import "ODGoTo.h"
//#import "ODTabController.h"
#import "ODTabBar.h"

#import "ODTabSwitcher.h"
#import "ODWebView.h"

#import "ODWebDownloadManager.h"


#define ZOOM_TEXT_ONLY_KEY @"ZoomTextOnly"

@interface ODController ()
{
    NSMutableArray *_windowControllers;
    
    NSUInteger _activeWindowIndex;
    
    ODTabSwitcher *_tabSwitcher;
    NSWindow *_window;
    
    BOOL _zoomTextOnly;
}

@end

@implementation ODController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_windowControllers = [NSMutableArray new];
//        self->_tabSwitcher = [[ODTabSwitcher alloc] init];
        self->_tabSwitcher = [ODTabSwitcher switcher];
        //        [[NSUserDefaults standardUserDefaults] setObject:data[ID_KEY] forKey:DEFAULTS_KEY];
        //        [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY];
        
        
    }
    
    return self;
}

+(id)sharedController
{
    static ODController *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        result = [[ODController alloc] init];
        
    });
    
    return result;
}



-(void)newWindowWithAddress:(NSString *)address
{
    ODWindowController *a = [[ODWindowController alloc] init];
    
    [self _objectSetUp:a];
    
    [a showWindow:self];
    
    [a loadURL:address];
}

-(void)newWindowWithTabs:(NSArray *)array
{
    ODWindowController *a = [[ODWindowController alloc] init];
    
    [self _objectSetUp:a];
    
    [a showWindow:self];
    for (NSString *addr in array) {
        [a openTabWithAddress:addr];
    }
}

-(void)openInExistingWindow:(NSString *)address
{
    if (_windowControllers.count == 0) {
        
        [self newWindowWithAddress:address];
        
    } else {
        
        [[self _activeController] performSelector:@selector(loadURL:) withObject:address];
        
    }
}

-(void)openTabInBackground:(NSString *)address
{
    if (_windowControllers.count == 0) {
        
        [self newWindowWithAddress:address];
        
    } else {
        
        [[self _activeController] openBackgroundTabWithAddress:address];
        
    }
}

-(void)openTabsInExistingWindow:(NSArray *)array
{
    if (_windowControllers.count == 0) {
        
        [self newWindowWithTabs:array];
        
    } else {
        
        ODWindowController *a = [self _activeController];
        for (NSString *addr in array) {
            [a openTabWithAddress:addr];
        }
        
        
    }
}

#pragma mark - other 
-(NSWindow *)activeWindow
{
    //return [self _activeController].window;
    return _window;
}

-(NSWindow *)windowWithNumber:(NSUInteger)number
{
    NSWindow *result;
    for (ODWindowController *ctl in _windowControllers) {
        if (ctl.window.windowNumber == number) {
            result = ctl.window;
            break;
        }
    }
    
    return result;
}

-(WebView *)webView
{
    return [self _activeController].mainWebView;
}

-(NSData *)webArchiveData
{
    WebView *view = [self webView];
    NSData *data;
    
    WebDataSource *dataSource = [view.mainFrame dataSource];
    data = dataSource.webArchive.data;
    
    return data;
    
}

-(void)saveSession
{
    ODSessionData *session = [[ODSessionData alloc] initWithWindows:_windowControllers];
    [session saveTo:SESSION_SAVE_PATH];
    
    
}

-(void)restoreSession
{
    ODSessionData *session = [[ODSessionData alloc] init];
    NSArray *windows = [session restoreFrom:SESSION_SAVE_PATH];
    if (windows) {
        for (ODWindowController *a in windows) {
            [self _objectSetUp:a];
        }
    }
    
    // This shouldn't be here
    
    _zoomTextOnly = [[NSUserDefaults standardUserDefaults] boolForKey:ZOOM_TEXT_ONLY_KEY];
    NSMenu * menu = [[NSApp mainMenu] itemWithTag:300].submenu;
    [[menu itemWithTag:301] setState:_zoomTextOnly ? NSOnState : NSOffState];
}

#pragma mark - Actions

-(void)openTab:(id)sender
{
    if (_windowControllers.count == 0) {
        
        [self newWindowWithAddress:nil];
        
    } else {
        
        //[[_windowControllers objectAtIndex:_activeWindowIndex] performSelector:@selector(openTab)];
        [_window.windowController performSelector:@selector(openTab)];
        
    }
}

-(void)closeTab:(id)sender
{
    
    [[self _activeController] performSelector:@selector(closeTab:) withObject:sender];
    
    
}

-(void)tabsMenu:(id)sender
{
    [[self _activeController] performSelector:@selector(showTabs)];
}

-(void)showTabs:(id)sender
{
    if (_tabSwitcher) {
        
        [_tabSwitcher.view setNeedsDisplay:YES];
        //[_tabSwitcher showPopover];
        [_tabSwitcher runModal];
        //[_tabSwitcher showSidebar];
        
        //       }
        
    } else {
        
    }
}

-(void)nextTab:(id)sender
{
    //ODTabController *ctl = [[self _activeController] tabsController];
    ODTabBar *ctl = [[self _activeController] tabBar];
    [ctl nextTab];
}

-(void)previousTab:(id)sender
{
    // ODTabController *ctl = [[self _activeController] tabsController];
    ODTabBar *ctl = [[self _activeController] tabBar];
    [ctl previousTab];
}

-(void)moveTabToNewWindow:(id)sender
{
    ODWindowController *old = [self _activeController];
    ODTabBar *oldCtl = [old tabBar];
    
    if (oldCtl.tabList.count > 1) {
        
        ODWindowController *a = [[ODWindowController alloc] init];
        [self _objectSetUp:a];
        [a showWindow:nil];
        
        [oldCtl moveTabAtIndex:[oldCtl activeTabIdx] toWindow:a.window];
        
    }
    
    
    //    ODWindowController *old = [self _activeController];
    //    ODTabController *oldCtl = [old tabsController];
    //    
    //    
    //    if (oldCtl.menu.numberOfItems > 1) {
    //        
    //        ODWindowController *a = [[ODWindowController alloc] init];
    //        WebView *w = [old mainWebView];
    //        
    //        [w removeFromSuperview];
    ////        w.UIDelegate = nil;
    ////        w.frameLoadDelegate = nil;
    ////        w.policyDelegate = nil;
    ////        w.downloadDelegate = nil;
    //        
    //        long idx = [oldCtl.menu indexOfItemWithRepresentedObject:w];
    //        [oldCtl setActiveTabObject:nil];
    //        [self _objectSetUp:a];
    //        [a showWindow:nil];
    //        [a openTabWithWebView:w];
    //        [old closeTab:[oldCtl.menu itemAtIndex:idx]];
    //    }
    
    
    
    
}

-(void)mergeAllTabs:(id)sender
{
    if (_windowControllers.count > 1) {
        ODWindowController *a = [[ODWindowController alloc] init];
        
        //ODTabBar *tabBar = [a tabBar];
        for (ODWindowController *c in [_windowControllers copy]) {
            ODTabBar *tabCtl = [c tabBar];
            [tabCtl moveAllTabsToWindow:a.window];
            //            [c close];
            [c.window performClose:nil];
        }
        
        [self _objectSetUp:a];
        [a showWindow:nil];
        [a.tabBar selectTabAtIndex:0];
        
        //        NSMutableArray *webViews = [NSMutableArray new];
        //        for (ODWindowController *c in [_windowControllers copy]) {
        //            ODTabController *ctl = [c tabsController];
        //            for (NSMenuItem *i in [ctl.menu.itemArray copy]) {
        //                WebView *w = i.representedObject;
        ////                w.UIDelegate = nil;
        ////                w.frameLoadDelegate = nil;
        ////                w.policyDelegate = nil;
        ////                w.downloadDelegate = nil;
        //                [w setHidden:YES];
        //                [webViews addObject:i];
        //                 [w removeFromSuperview];
        //                //i.representedObject = nil;
        //                
        //                //[ctl closeTab:i];
        //                [ctl.menu removeAllItems];
        //                
        //            }
        //            
        //            [c.window performClose:nil];
        //            
        //        }
        
        
        //        ODWindowController *a = [[ODWindowController alloc] init];
        //        [self _objectSetUp:a];
        //        [a showWindow:nil];
        //        //ODTabController *ctl = [a tabsController];
        //        
        //        ODTabBar *tabBar = [a tabBar];
        //        
        //        
        //        for (NSMenuItem *i in webViews) {
        //            
        //            //[a openTabWithWebView:w];
        //            [a performSelector:@selector(_setUpWebView:) withObject:[i representedObject]];
        //            [i.representedObject removeFromSuperview];
        //            [[ctl menu] addItem:i];
        //            i.target = ctl;
        //            i.keyEquivalent = @"";
        //            
        //        }
        [a.window setFrame:NSMakeRect(NSMinX(a.window.frame), NSMinY(a.window.frame), 800, 600) display:NO animate:NO];
        //[ctl selectItemAtIndex:0];
    }   
}

-(void)goBackward:(id)sender
{
    [[self webView] performSelector:@selector(goBack:) withObject:sender];
}

-(void)goForward:(id)sender
{
    [[self webView] performSelector:@selector(goForward:) withObject:sender];
}

-(void)showSearchForString:(id)sender
{
    [[self _activeController] performSelector:@selector(showSearchDocument:) withObject:self];
}

-(void)zoomIn:(id)sender
{
    float zoom;
    float step;
    if ([NSEvent modifierFlags] == (NSAlternateKeyMask | NSCommandKeyMask)) {
        step = 0.075f;
    } else {
        
        step = 0.025f;
    }
    if (_zoomTextOnly) {
        
        zoom = [self.webView textSizeMultiplier];
        [[self webView] setTextSizeMultiplier:zoom + step];
        
    } else {
        
        zoom = [self.webView pageSizeMultiplier];
        [[self webView] setPageSizeMultiplier:zoom + step];
        
    }
    //   [[self _activeController].mainWebView makeTextLarger:sender];
    //    float zoom = [self.webView textSizeMultiplier];
    //    [[self webView] setTextSizeMultiplier:zoom + 0.025f];
    
}

-(void)zoomOut:(id)sender
{
    float zoom;
    float step;
    if ([NSEvent modifierFlags] == (NSAlternateKeyMask | NSCommandKeyMask)) {
        
        step = 0.075f;
        
    } else {
        
        step = 0.025f;
    }
    if (_zoomTextOnly) {
        
        zoom = [self.webView textSizeMultiplier];
        if (zoom < 0.3f) {
            return;
        }
        
        [[self webView] setTextSizeMultiplier:zoom - step];
        
    } else {
        
        zoom = [self.webView pageSizeMultiplier];
        if (zoom < 0.3f) {
            return;
        }
        [[self webView] setPageSizeMultiplier:zoom - step];
        
    }
    //  [[self _activeController].mainWebView makeTextSmaller:sender];
    //    float zoom = [self.webView textSizeMultiplier];
    //    if (zoom < 0.3f) {
    //        return;
    //    }
    //    [[self webView] setTextSizeMultiplier:zoom - 0.025f];
    
    //      [[self webView] makeTextSmaller:sender];
    
    
    //     [[self webView] performSelector:@selector(zoomPageOut:) withObject:sender];
}

-(void)defaultZoom:(id)sender
{
    [[self _activeController].mainWebView makeTextStandardSize:sender];
    [[self webView] setPageSizeMultiplier:1.0];
}

-(void)zoomTextOnly:(id)sender
{
    NSMenuItem *item = sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (_zoomTextOnly) {
        _zoomTextOnly = NO;
        
        [item setState:NSOffState];
        
        
    } else {
        
        _zoomTextOnly = YES;
        
        [item setState:NSOnState];
    }
    
    [defaults setBool:_zoomTextOnly forKey:ZOOM_TEXT_ONLY_KEY];
}

-(void)reloadPage:(id)sender
{
    [[self _activeController].mainWebView reload:sender];
}

-(void)reloadFromOrigin:(id)sender
{
    [[self _activeController].mainWebView reloadFromOrigin:sender];
    
}

-(void)stopLoad:(id)sender
{
    [[self _activeController].mainWebView stopLoading:sender];
}

-(void)goTo:(id)sender
{
    ODGoTo *window = [[ODGoTo alloc] init];
    NSString *req = [self.webView mainFrameURL];
    req = [window editRequest:req];
    if (![window wasCancelled]) {
        if ([self _activeController]) {
            [self.webView setMainFrameURL:req];
        } else {
            [self newWindowWithAddress:req];
        }
        
    }
    
}

-(void)showDownloads:(id)sender
{
    [[ODWebDownloadManager sharedManager] showDownloads];
}

-(void)restartApplication:(id)sender
{
    NSURL *path = [[NSBundle mainBundle] bundleURL];
    if(path){
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:path options:NSWorkspaceLaunchNewInstance configuration:@{} error:nil];
        [NSApp terminate:nil];
    }
}

#pragma mark - Window Notifications

-(void)windowWillClose:(NSNotification *)notification
{
    NSWindow * win = notification.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:win];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:win];
    [[notification.object windowController] close];
    
    [_windowControllers removeObject:[win windowController]];
    if ([_window isEqualTo:win]) {
        _window = nil;
    }
    
}

-(void)windowDidBecomeMain:(NSNotification *)notification
{
    _window = notification.object;
    _activeWindowIndex = [_windowControllers indexOfObject:[_window windowController]];
}

#pragma mark - private
-(ODWindowController *)_activeController
{
    //u_long count = _windowControllers.count;
    ODWindowController *result;
    result = _window.windowController;
    if (!result) {
        result = [NSApp mainWindow].windowController;
    }
    
    return result;
    
    
}

-(void)_objectSetUp:(ODWindowController *)a
{
     [_windowControllers  insertObject:a atIndex:0];
    [a showWindow:self];
    NSWindow *window = a.window;
    _window = window;
    if (![window isRestorable]) {
        NSRect frame = window.frame;
        [window setFrame:NSMakeRect(NSMinX(frame), NSMinY(frame), 800, 600) display:NO animate:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeMain:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:window];
    
   

    [window makeKeyAndOrderFront:nil];
    //    [a restoreStateWithCoder:]
}

@end
