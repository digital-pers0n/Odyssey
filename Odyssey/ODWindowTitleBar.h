//
//  ODWindowTitleBar.h
//  Odyssey
//
//  Created by Terminator on 1/11/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODWindowTitleBar : NSViewController

-(void)setTitle:(NSString *)title icon:(NSImage *)icon tabInfo:(NSString *)tabInfo;
-(void)setTitle:(NSString *)title;
-(void)setStatus:(NSString *)status;


@end
