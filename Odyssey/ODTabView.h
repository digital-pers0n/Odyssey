//
//  ODTabView.h
//  tabView
//
//  Created by Terminator on 2017/12/17.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODTabViewItem, ODWindow;
@protocol ODTabViewDelegate;

@interface ODTabView : NSView

//- (NSArray *)tabList;
//- (void)addTabViewItem:(ODTabViewItem *)item;
//- (ODTabViewItem *)itemAtIndex:(NSUInteger)idx;


//@property NSWindow *window;

/* Select */

- (void)selectTabViewItem:(ODTabViewItem *)item;
- (void)selectTabViewItemAtIndex:(NSInteger)idx;

/* Navigation */

- (void)selectFirstTabViewItem;
- (void)selectLastTabViewItem;
- (void)selectNextTabViewItem;
- (void)selectPreviousTabViewItem;

/* Getters */

@property (readonly) ODTabViewItem *selectedTabViewItem;
@property (readonly, copy) NSArray *tabViewItems;

/* Add/Remove */

- (void)addTabViewItems:(NSArray *)objects;
- (void)addTabViewItem:(ODTabViewItem *)item;
- (void)addTabViewItem:(ODTabViewItem *)item relativeToSelectedTab:(BOOL)value;
- (void)insertTabViewItem:(ODTabViewItem *)item atIndex:(NSInteger)idx;
- (void)removeTabViewItem:(ODTabViewItem *)item;
- (void)removeTabViewItemAtIndex:(NSInteger)idx;
- (void)removeTabViewItemWithView:(NSView *)view;
- (void)removeSelectedTabViewItem;
- (void)removeAllTabs;

/* Delegate */

@property (assign) id<ODTabViewDelegate> delegate;

/* Query */

- (NSInteger)numberOfTabViewItems;
- (NSInteger)indexOfTabViewItem:(ODTabViewItem *)TabViewItem;
- (ODTabViewItem *)tabViewItemAtIndex:(NSInteger)idx;
- (ODTabViewItem *)tabViewItemWithView:(id)view;

/* Private */

@property (readonly) NSMutableArray *_tabViewItemArray;

@end

//================================================================================
//	ODTabViewDelegate protocol
//================================================================================

@protocol ODTabViewDelegate <NSObject>

- (void)tabView:(ODTabView *)tabView willSelectTabViewItem:(ODTabViewItem *)item;
- (void)tabView:(ODTabView *)tabView didSelectTabViewItem:(ODTabViewItem *)item;
- (void)tabView:(ODTabView *)tabView willRemoveTabViewItem:(ODTabViewItem *)item;
- (void)tabView:(ODTabView *)tabView didRemoveTabViewItem:(ODTabViewItem *)item;
- (void)tabView:(ODTabView *)tabView willAddTabViewItem:(ODTabViewItem *)item;
- (void)tabView:(ODTabView *)tabView didAddTabViewItem:(ODTabViewItem *)item;

@optional

- (BOOL)tabView:(ODTabView *)tabView shouldMoveTabViewItem:(ODTabViewItem *)item to:(ODTabView **)newTabView;
- (void)tabView:(ODTabView *)tabView didMoveTabViewItem:(ODTabViewItem *)item to:(ODTabView *)otherTabView;
- (void)tabView:(ODTabView *)tabView tabViewList:(NSArray **)tabViewList; // other windows tabViews

@end
