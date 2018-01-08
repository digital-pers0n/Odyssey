//
//  ODPopover.h
//  Odyssey
//
//  Created by Terminator on 5/26/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, ODPopoverAppearance) {
    ODPopoverAppearanceLight,
    ODPopoverAppearanceDark
};

@interface ODPopover : NSResponder

- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;
@property (readonly, getter=isShown) BOOL shown;
@property NSViewController *contentViewController;
@property NSRect positioningRect;
@property (nonatomic) NSSize contentSize;
@property ODPopoverAppearance appearance;

-(void)close;

@end
