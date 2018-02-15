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

@protocol ODPopoverDelegate;

@interface ODPopover : NSResponder

@property(assign) id<ODPopoverDelegate>delegate;

- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;
@property (readonly, getter=isShown) BOOL shown;
@property NSViewController *contentViewController;
@property NSRect positioningRect;
@property NSSize contentSize;
@property ODPopoverAppearance appearance;

// Close via popoverShouldClose:
- (IBAction)performClose:(id)sender;
// Force close
- (void)close;

@end

#pragma mark -
#pragma mark Delegate Methods

@protocol ODPopoverDelegate <NSObject>
@optional
- (BOOL)popoverShouldClose:(ODPopover *)popover;
- (void)popoverWillShow:(ODPopover *)popover;
- (void)popoverDidShow:(ODPopover *)popover;
- (void)popoverWillClose:(ODPopover *)popover;
- (void)popoverDidClose:(ODPopover *)popover;
@end
