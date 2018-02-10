//
//  ODHistory.m
//  Odyssey
//
//  Created by Terminator on 4/27/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODHistory.h"
#import "ODDelegate.h"
#import "ODWindow.h"
#import "ODTabView.h"
#import "ODTabViewItem.h"

@import WebKit;

@interface ODHistory () <NSMenuDelegate>
{
    NSMenu *_historyMenu;
}


@end


@implementation ODHistory

- (instancetype)init
{
    self = [super init];
    if (self) {
        _historyMenu = [[NSMenu alloc] init];
        _historyMenu.title = @"History";
        [_historyMenu setDelegate:self];
        NSMenuItem *item = [[NSApp mainMenu] itemWithTag:200];
        [[item.submenu itemWithTag:202] setSubmenu:_historyMenu];
    }
    return self;
}

-(void)addItemWithTitle:(NSString *)title address:(NSString *)address
{
    NSMenuItem *item = nil;
    
    for (NSMenuItem *i in _historyMenu.itemArray.copy) {
        if ([i.toolTip isEqualToString:address]) {
            [_historyMenu removeItem:i];
            item = i;
            break;
        }
    }

    if (!item) {
        item  = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemClicked:) keyEquivalent:@""];
        item.toolTip = address;
        item.target = self;
    }
    
    [_historyMenu insertItem:item atIndex:0];
    
    if (_historyMenu.numberOfItems > 35) {
        [_historyMenu removeItemAtIndex:35];
    }
}

-(void)menuItemClicked:(id)sender
{
    ODWindow *window = (id)[NSApp mainWindow];
    WebView *view = (WebView *)window.tabView.selectedTabViewItem.view;
    view.mainFrameURL = [sender toolTip];
    //[view setMainFrameURL:[[sender representedObject] URLString]];
    //[[view backForwardList] goToItem:[sender representedObject]]; 
}

#pragma mark - Session


//-(void)menuNeedsUpdate:(NSMenu *)menu
//{
//    //[_historyMenu removeAllItems];
//    
//    WebView *view = [_controller webView];
//    NSArray *list = [[view backForwardList] backListWithLimit:35];
//    for (WebHistoryItem *obj in list) {
//        
//        NSInteger idx = [_historyMenu indexOfItemWithRepresentedObject:obj.URLString];
//        if (idx == -1) {
//            NSString *title = obj.title;
//            if(!title)
//            {
//                title = @"(Empty)";
//            }
//            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(itemClicked:) keyEquivalent:@""];
//            item.target = self;
//            //item.image = obj.icon;
//            item.representedObject = obj.URLString;
//            item.toolTip = obj.URLString;
//            
//            [_historyMenu insertItem:item atIndex:0];
//        } else {
//            if ([list indexOfObject:obj] == 0) {
//                NSMenuItem *i = [_historyMenu itemAtIndex:idx];
//                [_historyMenu removeItem:i];
//                [_historyMenu insertItem:i atIndex:0];
//            }
//            
//        }
//        
//        
//        
//    }
//    
//    if (_historyMenu.itemArray.count > 35) {
//        
//        for (NSMenuItem *itm in [[_historyMenu itemArray] copy]) {
//            
//            if ([_historyMenu indexOfItem:itm] > 34) {
//                [_historyMenu removeItem:itm];
//            }
//            
//        }
//    }
//}
//


@end
