//
//  ODTabSwitcher.h
//  Odyssey
//
//  Created by Terminator on 4/9/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODTabBar;

@interface ODTabSwitcher : NSViewController

+(id)tabSwitcher;

-(IBAction)showPopover:(id)sender;
-(void)closeView:(id)sender;

@end
