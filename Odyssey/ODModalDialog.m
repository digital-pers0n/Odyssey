//
//  ODModalDialog.m
//  Odyssey
//
//  Created by Terminator on 2018/04/19.
//  Copyright © 2018年 home. All rights reserved.
//

#import "ODModalDialog.h"
#import "ODPopoverWindow.h"

@implementation ODModalDialog

+ (NSPanel *)modalDialogWithView:(NSView *)view {
    static dispatch_once_t onceToken;
    static ODPopoverWindow *obj = nil;
    dispatch_once(&onceToken, ^{
        obj = [[ODPopoverWindow alloc] initWithContentRect:NSZeroRect
                                                 styleMask:NSBorderlessWindowMask
                                                   backing:NSBackingStoreBuffered defer:YES];
        [obj setWindowAppearance:1];
    });
    NSRect viewFrame = view.frame;
    NSRect frame = [[NSApp mainWindow] frame];
    NSPoint point = NSMakePoint(NSMinX(frame) + ((NSWidth(frame) - NSWidth(viewFrame)) / 2),
                                NSMinY(frame) + ((NSHeight(frame) - NSHeight(viewFrame)) / 2));
    [obj setFrame:viewFrame display:NO animate:NO];
    if (point.y > 0) {
        [obj setFrameOrigin:point];
    } else {
        [obj center];
    }
    [obj setContentView:view];
    return obj;
}

@end
