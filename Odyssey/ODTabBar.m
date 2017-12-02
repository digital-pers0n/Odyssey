//
//  ODTabBar.m
//  Odyssey
//
//  Created by Terminator on 4/7/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODTabBar.h"
#import "ODTabItem.h"
#import "ODWindow.h"

@interface ODTabBar ()
{
    NSMutableArray *_tabItems;
}

@end

@implementation ODTabBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tabItems = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Select

-(void)selectTabItem:(ODTabItem *)item
{

       // [self selectTabItemAtIndex:[_tabItems indexOfObject:item]];
    [_delegate tabBar:self willSelectTabItem:item];
    [_selectedTabItem.view setHidden:YES];
    //[_selectedTabItem.view removeFromSuperview];
    [_selectedTabItem _setState:ODTabStateBackground];
    
    _selectedTabItem = item;
    NSView *contentView = _window.contentView;
    NSView *view = item.view;
    view.frame = contentView.frame;
    //[_window addSubview:view];
    [item _setState:ODTabStateSelected];
    [view setHidden:NO];
    
    [_delegate tabBar:self didSelectTabItem:item];
            
}

-(void)selectTabItemAtIndex:(NSInteger)idx
{
    if (_tabItems.count > idx) {
        
        ODTabItem *item = _tabItems[idx];
        
        [self selectTabItem:item];
        
    }
}

#pragma mark - Navigation

-(void)selectFirstTabItem
{
    [self selectTabItem:_tabItems.firstObject];
}

-(void)selectLastTabItem
{
    [self selectTabItem:_tabItems.lastObject];
}

-(void)selectNextTabItem
{
    NSInteger idx = [_tabItems indexOfObject:_selectedTabItem];
    idx = idx + 1;
    if (_tabItems.count > idx) {
        
        [self selectTabItemAtIndex:idx];
        
    } else {
        
        [self selectFirstTabItem];
    }
}

-(void)selectPreviousTabItem
{
    NSInteger idx = [_tabItems indexOfObject:_selectedTabItem];
    idx = idx - 1;
    if (0 <= idx) {
        
        [self selectTabItemAtIndex:idx];
        
    } else {
        
        [self selectLastTabItem];
    } 
}

#pragma mark - Add/Remove

-(void)addTabItems:(NSArray *)objects
{
    for (ODTabItem *item in objects) {
        [_tabItems addObject:item];
    }
}

-(void)addTabItem:(ODTabItem *)item
{
    [_delegate tabBar:self willAddTabItem:item];
    [_tabItems addObject:item];
    [_delegate tabBar:self didAddTabItem:item];
}

-(void)insertTabItem:(ODTabItem *)item atIndex:(NSInteger)idx
{
    if (_tabItems.count > idx) {
        
        [_delegate tabBar:self willAddTabItem:item];
        [_tabItems insertObject:item atIndex:idx];
        [_delegate tabBar:self didAddTabItem:item];
    }
}

-(void)addTabItem:(ODTabItem *)item relativeToSelectedTab:(BOOL)value
{
    if (value && _tabItems.lastObject != _selectedTabItem) {
        NSInteger idx = [_tabItems indexOfObject:_selectedTabItem];
        idx = idx + 1;
        [self insertTabItem:item atIndex:idx];
    } else {
        [self addTabItem:item];
    }
}

-(void)removeTabItem:(ODTabItem *)item
{
    
    if (_selectedTabItem == item) {
        
        if (_tabItems.count > 1) {
            
             (item == _tabItems.lastObject) ? [self selectPreviousTabItem] : [self selectNextTabItem];
        }
       
    }
    
    [_delegate tabBar:self willRemoveTabItem:item];
    [_tabItems removeObject:item];
    [_delegate tabBar:self didRemoveTabItem:item];
    
    if (_tabItems.count == 0) {
        
        _selectedTabItem = nil;
        [_window close];
    } 
}

-(void)removeTabItemAtIndex:(NSInteger)idx
{
    if (_tabItems.count > idx) {
        
        ODTabItem *item = [_tabItems objectAtIndex:idx];
        [self removeTabItem:item];
    }
}

-(void)removeTabItemWithView:(id)view
{
    for (ODTabItem *item in _tabItems) {
        if (item.view == view) {
            [self removeTabItem:item];
            break;
        }
    }
}

-(void)removeSelectedTabItem
{
    [self removeTabItem:_selectedTabItem];
}

-(void)removeAllTabs
{
    NSArray *openTabs = _tabItems.copy;
    for (ODTabItem *item in openTabs) {
        [self removeTabItem:item];
    }
}

#pragma mark - Query

-(NSInteger)numberOfTabItems
{
    return _tabItems.count;
}

-(NSInteger)indexOfTabItem:(ODTabItem *)tabItem
{
    return [_tabItems indexOfObject:tabItem];
}

-(ODTabItem *)tabItemAtIndex:(NSInteger)idx
{
    if (_tabItems.count > idx) {
        return _tabItems[idx];
    }
    
    return nil;
}

-(ODTabItem *)tabItemWithView:(id)view
{
    for (ODTabItem *item in _tabItems) {
        if (item.view == view) {
            return item;
        }
    }
    
    return nil;
}

#pragma mark - info

-(NSString *)info
{
    NSString *result =  [NSString stringWithFormat:@"%li/%li", [_tabItems indexOfObject:_selectedTabItem] + 1, _tabItems.count];
    return result;
}












@end
