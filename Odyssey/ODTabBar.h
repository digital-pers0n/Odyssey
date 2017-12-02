//
//  ODTabBar.h
//  Odyssey
//
//  Created by Terminator on 4/7/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ODTabItem, ODWindow;
@protocol ODTabBarDelegate;

@interface ODTabBar : NSObject

@property ODWindow *window;

 /* Select */

- (void)selectTabItem:(ODTabItem *)item;
- (void)selectTabItemAtIndex:(NSInteger)idx;

 /* Navigation */

- (void)selectFirstTabItem;
- (void)selectLastTabItem;
- (void)selectNextTabItem;
- (void)selectPreviousTabItem;

 /* Getters */

@property (readonly) ODTabItem *selectedTabItem;
@property (readonly, copy) NSArray *tabItems;

 /* Add/Remove */

- (void)addTabItems:(NSArray *)objects;
- (void)addTabItem:(ODTabItem *)item;
- (void)addTabItem:(ODTabItem *)item relativeToSelectedTab:(BOOL)value;
- (void)insertTabItem:(ODTabItem *)item atIndex:(NSInteger)idx;
- (void)removeTabItem:(ODTabItem *)item;
- (void)removeTabItemAtIndex:(NSInteger)idx;
- (void)removeTabItemWithView:(NSView *)view;
- (void)removeSelectedTabItem;
- (void)removeAllTabs;

 /* Delegate */

@property (assign) id<ODTabBarDelegate> delegate;

 /* Query */

-(NSInteger)numberOfTabItems;
-(NSInteger)indexOfTabItem:(ODTabItem *)tabItem;
-(ODTabItem *)tabItemAtIndex:(NSInteger)idx;
-(ODTabItem *)tabItemWithView:(id)view;

 /* Info */

- (NSString *)info;

@end

//================================================================================
//	ODTabBarDelegate protocol
//================================================================================

@protocol ODTabBarDelegate <NSObject>

- (void)tabBar:(ODTabBar *)tabBar willSelectTabItem:(ODTabItem *)item;
- (void)tabBar:(ODTabBar *)tabBar didSelectTabItem:(ODTabItem *)item;
- (void)tabBar:(ODTabBar *)tabBar willRemoveTabItem:(ODTabItem *)item;
- (void)tabBar:(ODTabBar *)tabBar didRemoveTabItem:(ODTabItem *)item;
- (void)tabBar:(ODTabBar *)tabBar willAddTabItem:(ODTabItem *)item;
- (void)tabBar:(ODTabBar *)tabBar didAddTabItem:(ODTabItem *)item;


@end