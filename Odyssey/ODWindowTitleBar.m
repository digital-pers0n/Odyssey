//
//  ODWindowTitleBar.m
//  Odyssey
//
//  Created by Terminator on 1/11/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODWindowTitleBar.h"
#import "ODTitleBarView.h"
#import "ODWebDownloadManager.h"
#import "ODController.h"
#import "ODWindowController.h"
#import "AppDelegate.h"
#import "ODTabSwitcher.h"

@interface ODWindowTitleBar () {

IBOutlet NSButton *_tabButton;
IBOutlet NSButton *_downloadsButton;
    

}

-(IBAction)tabButtonClicked:(id)sender;
-(IBAction)downloadsButtonClicked:(id)sender;


@end

@implementation ODWindowTitleBar

-(NSString *)nibName
{
    return [self className];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)setTitle:(NSString *)title icon:(NSImage *)icon tabInfo:(NSString *)tabInfo
{
    ODTitleBarView *view = (ODTitleBarView *)self.view;
    [view setTitle:title icon:icon];
    _tabButton.title = tabInfo;
}

-(void)setTitle:(NSString *)title
{
    ODTitleBarView *view = (ODTitleBarView *)self.view;
    [view setTitle:title];
}

-(void)setStatus:(NSString *)status
{
    ODTitleBarView *view = (ODTitleBarView *)self.view;
    [view setStatus:status];
}

#pragma mark - Actions

-(void)tabButtonClicked:(id)sender
{
    ODController *ctl = [[NSApp delegate] controller];
    [ctl showTabs:self];
}

-(void)downloadsButtonClicked:(id)sender
{
    ODController *ctl = [[NSApp delegate] controller];
    [ctl showDownloads:self];
}

@end
