//
//  ODWindowController.h
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface ODWindowController : NSWindowController


-(WebView *)mainWebView;
-(id)tabsController;
-(id)tabBar;
-(id)titleBar;

//-(IBAction)goTo:(id)sender;
-(IBAction)showSearchDocument:(id)sender;
-(IBAction)closeSearchDocument:(id)sender;

-(IBAction)searchForward:(id)sender;
-(IBAction)searchBackward:(id)sender;


-(void)loadURL:(NSString *)url;

-(void)openTab;
-(void)openTabWithAddress:(NSString *)address;
-(void)openTabWithWebView:(WebView *)view;
-(WebView *)openBackgroundTabWithAddress:(NSString *)addr;
-(void)closeTab:(id)sender;
-(void)showTabs;

//Session Restore

-(NSArray *)tabsList;
-(void)setTabList:(NSArray *)list;

-(void)_setUpWebView:(id)view;

@end
