//
//  ODTabSwitcher.h
//  Odyssey
//
//  Created by Terminator on 4/9/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODTabViewItem;
@protocol ODTabSwitcherDelegate;

@interface ODTabSwitcher : NSViewController

+(id)tabSwitcher;

@property id<ODTabSwitcherDelegate> delegate;

-(IBAction)showPopover:(id)sender;
-(void)closeView:(id)sender;

@end

@protocol ODTabSwitcherDelegate <NSObject>
@optional
- (NSString *)toolTipForTabViewItem:(ODTabViewItem *)item;
- (NSString *)labelForTabViewItem:(ODTabViewItem *)item;
- (void)openNewTab;

@end
