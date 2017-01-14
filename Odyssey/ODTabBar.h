//
//  ODTabs.h
//  Odyssey
//
//  Created by Terminator on 12/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

#define TAB_TITLE_KEY @"TabTitle"
#define TAB_URL_KEY @"TabURL"
#define TAB_IS_MAIN_KEY @"Main"

@interface ODTabBar: NSObject

@property NSWindow *window;

-(NSArray *)tabList;

-(WebView *)activeTab;
-(void)setActiveTab:(WebView *)obj;
-(NSUInteger)activeTabIdx;

-(void)openTabWithObject:(WebView *)obj background:(BOOL)state;

-(void)closeTabAtIndex:(NSUInteger)idx;
-(void)closeActiveTab;
-(void)closeAllTabs;

-(void)selectTabAtIndex:(NSUInteger)idx;

-(void)moveTabAtIndex:(NSUInteger)idx toWindow:(NSWindow *)window;
-(void)moveAllTabsToWindow:(NSWindow *)window;


-(void)nextTab;
-(void)previousTab;


-(void)restoreSession:(NSArray *)sessionArray forWindow:(id)window;
-(NSArray *)sessionArray;

-(NSString *)info;
-(NSString *)tabInfo;


@end
