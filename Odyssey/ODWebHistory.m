//
//  ODWebHistoryController.m
//  Odyssey
//
//  Created by Terminator on 10/1/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebHistory.h"
#import "ODController.h"
#import "AppDelegate.h"

@import WebKit;

@interface ODWebHistory ()<NSMenuDelegate>
{
    NSMenu *_historyMenu;
    ODController *_controller;
}


@end

@implementation ODWebHistory 

- (instancetype)init
{
    self = [super init];
    if (self) {
        _historyMenu = [[NSMenu alloc] init];
        _historyMenu.title = @"History";
        [_historyMenu setDelegate:self];
        _controller = [[NSApp delegate] performSelector:@selector(controller)];
        NSMenuItem *item = [[NSApp mainMenu] itemWithTag:200];
        [[item.submenu itemWithTag:202] setSubmenu:_historyMenu];
    }
    return self;
}

-(void)itemClicked:(id)sender
{
  WebView *view = [_controller webView];
    view.mainFrameURL = [sender representedObject];
    //[view setMainFrameURL:[[sender representedObject] URLString]];
    //[[view backForwardList] goToItem:[sender representedObject]]; 
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    //[_historyMenu removeAllItems];
    
    WebView *view = [_controller webView];
    NSArray *list = [[view backForwardList] backListWithLimit:45];
    for (WebHistoryItem *obj in list) {
        
        NSInteger idx = [_historyMenu indexOfItemWithRepresentedObject:obj.URLString];
        if (idx == -1) {
            NSString *title = obj.title;
            if(!title)
            {
                title = @"(Empty)";
            }
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(itemClicked:) keyEquivalent:@""];
            item.target = self;
            //item.image = obj.icon;
            item.representedObject = obj.URLString;
            item.toolTip = obj.URLString;
            
            [_historyMenu insertItem:item atIndex:0];
        } else {
            if ([list indexOfObject:obj] == 0) {
                NSMenuItem *i = [_historyMenu itemAtIndex:idx];
                [_historyMenu removeItem:i];
                [_historyMenu insertItem:i atIndex:0];
            }

        }

        
        
    }
    
    if (_historyMenu.itemArray.count > 45) {
        
        for (NSMenuItem *itm in [[_historyMenu itemArray] copy]) {
            
            if ([_historyMenu indexOfItem:itm] > 44) {
                [_historyMenu removeItem:itm];
            }
            
        }
    }
}

@end
