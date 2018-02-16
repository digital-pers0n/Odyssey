//
//  ODPopover.m
//  Odyssey
//
//  Created by Terminator on 5/26/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODPopover.h"
#import "ODPopoverWindow.h"

@interface ODPopover () <NSWindowDelegate> {
    ODPopoverWindow *_visualRepresentation;
    NSViewController *_contentViewController;
    ODPopoverAppearance _appearance;
    id<ODPopoverDelegate> _delegate;
    
    struct __ODPoppverDelegateRespondTo {
        unsigned int popoverShouldClose:1;
        unsigned int popoverWillShow:1;
        unsigned int popoverDidShow:1;
        unsigned int popoverWillClose:1;
        unsigned int popoverDidClose:1;
    } _delegateRespondTo;
}

@end

@implementation ODPopover

- (instancetype)init {
    self = [super init];
    if (self) {
        _visualRepresentation = [[ODPopoverWindow alloc] initWithContentRect:NSZeroRect 
                                                                   styleMask:NSBorderlessWindowMask 
                                                                     backing:NSBackingStoreBuffered 
                                                                       defer:YES];
        _visualRepresentation.delegate = self;
    }
    return self;
}

- (id<ODPopoverDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<ODPopoverDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(popoverShouldClose:)]) {
        _delegateRespondTo.popoverShouldClose = YES;
    }
    if ([delegate respondsToSelector:@selector(popoverWillShow:)]) {
        _delegateRespondTo.popoverWillShow = YES;
    }
    if ([delegate respondsToSelector:@selector(popoverDidShow:)]) {
        _delegateRespondTo.popoverDidShow = YES;
    }
    if ([delegate respondsToSelector:@selector(popoverWillClose:)]) {
        _delegateRespondTo.popoverWillClose = YES;
    }
    if ([delegate respondsToSelector:@selector(popoverDidClose:)]) {
        _delegateRespondTo.popoverDidClose = YES;
    }
    _delegate = delegate;
}

- (ODPopoverAppearance)appearance {
    return _appearance;
}

- (void)setAppearance:(ODPopoverAppearance)appearance {
    _appearance = appearance;
    [_visualRepresentation setWindowAppearance:appearance];
}

#pragma mark - Methods

- (IBAction)performClose:(id)sender {
    BOOL shouldClose = (_delegateRespondTo.popoverShouldClose) ? [_delegate popoverShouldClose:self] : YES;
    if (shouldClose) {
        if (_delegateRespondTo.popoverWillClose) {
            [_delegate popoverWillClose:self];
        }
        [self close];
        if (_delegateRespondTo.popoverDidClose) {
           [_delegate popoverDidClose:self];
        }
    }
}

- (void)close {
    [_visualRepresentation close];
    _shown = NO;
}

- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge {
    NSView *contentView;
    NSRect contentViewFrame;
    NSRect popoverFrame;
    NSRect positioningScreenRect;
    NSRect screenFrame;
    preferredEdge = NSMaxYEdge;
    
    
    if (_contentViewController) {
        contentView = _contentViewController.view;
        contentViewFrame = contentView.frame;
        screenFrame = [[NSScreen mainScreen] visibleFrame];
        
        positioningScreenRect = [positioningView.window convertRectToScreen:positioningRect];
        [_visualRepresentation setContentSize:_contentSize];
        popoverFrame = _visualRepresentation.frame;
        popoverFrame.origin = positioningScreenRect.origin;
        
        switch (preferredEdge) {
            case NSMinXEdge:
                popoverFrame.origin.y -= NSHeight(contentViewFrame);
                break;
            case NSMaxXEdge:
                popoverFrame.origin.y += NSHeight(positioningRect);
                break;
            case NSMinYEdge:
                popoverFrame.origin.x -= NSWidth(contentViewFrame);
                popoverFrame.origin.y -= NSHeight(contentViewFrame);
                popoverFrame.origin.y += NSHeight(positioningRect);
                break;
            case NSMaxYEdge:
                popoverFrame.origin.x += NSWidth(positioningRect);
                popoverFrame.origin.y -= NSHeight(contentViewFrame);
                popoverFrame.origin.y += NSHeight(positioningRect);
                break;
                
            default:
                break;
        }
        
        if (NSMaxX(popoverFrame) > NSWidth(screenFrame)) {
            NSUInteger delta = NSMaxX(popoverFrame) - NSWidth(screenFrame);
            popoverFrame.origin.x -= delta;
        } else if (NSMinX(popoverFrame) < 0) {
            NSUInteger delta = NSMinX(popoverFrame) * (-1);
            popoverFrame.origin.x += delta;
        }
        
        if (NSMaxY(popoverFrame) > NSHeight(screenFrame)) {
            NSUInteger delta = NSMaxY(popoverFrame) - NSHeight(screenFrame);
            popoverFrame.origin.y -= delta;
        } else if (NSMinY(popoverFrame) < 0) {
            NSUInteger delta = NSMinY(popoverFrame) * (-1);
            popoverFrame.origin.y += delta;
        }
        
        [_visualRepresentation setFrame:popoverFrame display:YES animate:YES];
        _visualRepresentation.contentView = contentView;
        if (_delegateRespondTo.popoverWillShow) {
            [_delegate popoverWillShow:self];
        }
        [_visualRepresentation makeKeyAndOrderFront:self];
        if (_delegateRespondTo.popoverDidShow) {
            [_delegate popoverDidShow:self];
        }
        _shown = YES;
        
        
    }
    
}

#pragma mark - Window Delegate

- (void)windowDidResignKey:(NSNotification *)notification {
    [self close];
}

@end
