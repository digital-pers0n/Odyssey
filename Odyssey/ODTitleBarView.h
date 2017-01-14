//
//  ODTitleBarView.h
//  Odyssey
//
//  Created by Terminator on 1/11/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODTitleBarView : NSView
-(void)setTitle:(NSString *)title icon:(NSImage *)icon;
@property NSString * title;
@property NSImage *icon;
@property NSString * status;

@end
