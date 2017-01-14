//
//  ODTabBar.m
//  Odyssey
//
//  Created by Terminator on 12/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODTabBar.h"
#import "ODWindowController.h"
#import "ODWebView.h"

@import WebKit;

@interface ODTabBar () {
    
    NSMutableArray *_tabList;
    WebView *_activeTab;
    NSWindow *_window;
}



@end

@implementation ODTabBar
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self->_tabList = [NSMutableArray new];
    
    }
    return self;
}

#pragma mark - tab managment

-(void)openTabWithObject:(WebView *)obj background:(BOOL)state
{
    [_tabList addObject:obj];
    
    if (!state) {
        
        [self selectTabAtIndex:[_tabList indexOfObject:obj]];
//        [_activeTab setHidden:YES];
//        _activeTab = obj;
//        [obj setHidden:NO]; 
    
    } else {
        
        [obj setHidden:YES];
        
    }
}

-(void)selectTabAtIndex:(NSUInteger)idx
{
    [_activeTab setHidden:YES];
    [_activeTab removeFromSuperview];
    _activeTab = [_tabList objectAtIndex:idx];
 //   [_window.contentView addSubview:_activeTab];
//    [_window.contentView addSubview:_activeTab positioned:NSWindowBelow relativeTo:_window.contentView];
    [_activeTab setHidden:NO];
    [_activeTab setNeedsDisplay:YES];
}

-(void)nextTab
{
    u_long count = _tabList.count;
    
    if (count > 1) {
        
        u_long idx = [_tabList indexOfObject:_activeTab] + 1;
        
        if (idx > count - 1) {
            
            [self selectTabAtIndex:0];
            
        } else {
            
            [self selectTabAtIndex:idx];
        }
    }
    

}

-(void)previousTab
{
    u_long count = _tabList.count;
    
    if (count > 1) {
        
        u_long idx = [_tabList indexOfObject:_activeTab];
        
        if (idx != 0) {
            
            [self selectTabAtIndex:idx - 1];
            
        } else {
            
            idx = count - 1;
            
            [self selectTabAtIndex:idx];
        }
    }
    
    
    
}

-(void)closeTabAtIndex:(NSUInteger)idx
{
     u_long tab_idx = [_tabList indexOfObject:_activeTab];
    if (tab_idx == idx) {
        [_activeTab close];
      
        
        if (tab_idx == _tabList.count - 1) {
            
            [self previousTab];
            
        } else {
            
            [self nextTab];
        }
        
        [_tabList removeObjectAtIndex:tab_idx];
        
    } else {
        
        WebView *tab = [_tabList objectAtIndex:idx];
        [tab close];
        [_tabList removeObject:tab];
        
        
    }
    
    if (_tabList.count == 0) {
        
        [[NSApp mainWindow] performClose:nil];
    }
    
    
}

-(void)closeActiveTab
{
    u_long idx = [_tabList indexOfObject:_activeTab];
    [self closeTabAtIndex:idx];
}

-(void)closeAllTabs
{
    for (WebView *v in [_tabList copy]) {
        
        v.UIDelegate = nil;
        [v close];
        [v removeFromSuperview];
        [_tabList removeObject:v];
    }
    [_activeTab setHidden:YES];
    _activeTab = nil;
    
    [[NSApp mainWindow] performClose:nil];
}

-(void)moveTabAtIndex:(NSUInteger)idx toWindow:(NSWindow *)window
{
    WebView *view = [_tabList objectAtIndex:idx];
    if ([view isEqualTo:_activeTab]) {
        WebView *dummy = [WebView new] ;
        [_tabList replaceObjectAtIndex:idx withObject:dummy];
        _activeTab = dummy;
    }
    [view removeFromSuperview];
    [self closeTabAtIndex:idx];
    ODWindowController *ctl = window.windowController;
    [ctl openTabWithWebView:view];
    
}

-(void)moveAllTabsToWindow:(NSWindow *)window
{
    ODWindowController *ctl = window.windowController;
   ODTabBar *tabBar = ctl.tabBar;
//    NSWindow *win = [_activeTab window];
    [_activeTab setHidden:YES];
     _activeTab = nil;
    for (WebView *view in [_tabList copy]) {
        //[_tabList removeObject:view];
        [view removeFromSuperview];
        [ctl _setUpWebView:view];
        [tabBar openTabWithObject:view background:YES];
        //[ctl openTabWithWebView:view];
        
        
        }
    //[tabBar selectTabAtIndex:0];
    [_tabList removeAllObjects];
    //[win performClose:nil];
    
    
}

-(NSString *)info
{
    //WebView *obj = self.activeTabObject;
    
    
    NSString *title = [[_activeTab mainFrameTitle] length] ? [_activeTab mainFrameTitle] : [_activeTab mainFrameURL];
    if (!title) {
        title = @"Empty Tab";
    }
    
    if ([_activeTab isLoading]) {
        title = [NSString stringWithFormat:@"(%.0f%%) %@", [_activeTab estimatedProgress] * 100, title];
    }
//    u_long idx = [_tabList indexOfObject:_activeTab];
//    NSString *result = [NSString stringWithFormat:@"[%lu/%lu] :: %@", idx + 1, _tabList.count, title];
    
    return title;
}

-(NSString *)tabInfo
{
    u_long idx = [_tabList indexOfObject:_activeTab];
    NSString *result = [NSString stringWithFormat:@"[%lu/%lu]", idx + 1, _tabList.count];
    
    return result;
}

#pragma mark - ivars

-(WebView *)activeTab
{
    return _activeTab;
}

-(NSUInteger)activeTabIdx
{
    return [_tabList indexOfObject:_activeTab];
}

-(void)setActiveTab:(WebView *)obj
{
    u_long idx = [_tabList indexOfObject:_activeTab];
    
    [_tabList replaceObjectAtIndex:idx withObject:obj];
    [_activeTab close];
    [_activeTab setHidden:YES];

    
    
    _activeTab = obj;
    [_activeTab setHidden:NO];
}

-(NSArray *)tabList
{
    return _tabList;
}

#pragma mark - session restore

-(void)restoreSession:(NSArray *)sessionArray forWindow:(id)window
{
    ODWindowController *ctl = [window windowController];
    for (NSDictionary *dict in sessionArray) {
        @autoreleasepool {
            ODWebView *view = [[ODWebView alloc] init];
            [ctl _setUpWebView:view];
           //  [view setHidden:YES];
            [view setMainFrameURL:dict[TAB_URL_KEY]];
           // [_tabList addObject:view];
            BOOL isMain = [dict[TAB_IS_MAIN_KEY] boolValue];
            if (isMain) {
                
                [self openTabWithObject:view background:NO];
                // [self selectTabAtIndex:[_tabList indexOfObject:view]];
            } else {
                
                [self openTabWithObject:view background:YES];
            }
        }
    }
    
    
}

-(NSArray *)sessionArray
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (WebView *view in _tabList) {
        
        NSMutableDictionary *tab = [NSMutableDictionary new];
        NSString *str = [view mainFrameTitle];
        if (!str.length) {
            str = @"(No Title)";
        }
        [tab setObject:str forKey:TAB_TITLE_KEY];
        str = [view mainFrameURL];
        if (!str) {
            str = @"about:blank";
        }
        [tab setObject:str forKey:TAB_URL_KEY];
        
        if ([view isEqualTo:[self activeTab]]) {
            
            [tab setObject:[NSNumber numberWithBool:YES] forKey:TAB_IS_MAIN_KEY];
        
        } else {
           
            [tab setObject:[NSNumber numberWithBool:NO] forKey:TAB_IS_MAIN_KEY];
        }
        
        [result addObject:tab];
    }
    return result;
}


@end
