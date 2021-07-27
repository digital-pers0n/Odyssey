//
//  ODPopoverWindow.m
//  Odyssey
//
//  Created by Terminator on 5/26/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODPopoverWindow.h"
#import "ODPopover.h"

@interface NSNextStepFrame : NSView
-(instancetype)initWithFrame:(NSRect)frame styleMask:(NSUInteger)aStyle owner:(id)owner;
@end

@interface NSWindow (NSWindowPrivate)
-(id)_borderView;
@end

@interface ODPopoverFrame : NSNextStepFrame
{
@public
    BOOL _shouldDrawDarkBackground;
    NSColor *_darkColor;
    NSColor *_lightColor;
}

@end

@implementation ODPopoverFrame

//+(BOOL)_validateStyleMask:(NSUInteger)aStyle
//{
//    return NO;
//}

//+(NSRect)frameRectForContentRect:(NSRect)rect styleMask:(NSUInteger)aStyle
//{
//    rect.size.height += 16;
//    return rect;
//}
//
//-(NSRect)contentRectForFrameRect:(NSRect)rect styleMask:(NSUInteger)aStyle
//{
//    return rect;
//}



//-(NSUInteger)styleMask
//{
//    return 287;
//}

-(void)drawRect:(NSRect)dirtyRect
{
    
    if (_shouldDrawDarkBackground) {
        [_darkColor set];
    } else {
        [_lightColor set];
    }
    NSRectFill(self.bounds);
    //[[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:8 yRadius:8] fill];
    [self.window invalidateShadow];
}

-(instancetype)initWithFrame:(NSRect)frame styleMask:(NSUInteger)aStyle owner:(id)owner
{
    self = [super initWithFrame:frame styleMask:aStyle owner:owner];
    if (self) {
        [self setNextResponder:owner];
        _darkColor = [NSColor colorWithCalibratedWhite:0.08 alpha:1.0];
        _lightColor = [NSColor colorWithCalibratedWhite:0.96 alpha:1.0];
        
    }
    
    return self;
}

@end

@implementation ODPopoverWindow

+(Class)frameViewClassForStyleMask:(NSUInteger)aStyle
{
    return [ODPopoverFrame class];
}


-(instancetype)initWithContentRect:(NSRect)contentRect
                         styleMask:(NSWindowStyleMask)aStyle
                           backing:(NSBackingStoreType)bufferingType
                             defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        
        self.excludedFromWindowsMenu = YES;
        self.opaque = NO;
        NSColor *clearColor = NSColor.clearColor;
        self.backgroundColor = clearColor;
        self.hasShadow = YES;
        self.ignoresMouseEvents = NO;
        self.hidesOnDeactivate = NO;
        self.releasedWhenClosed = NO;
        self.movableByWindowBackground = YES;
    }  
    return self;
}

-(void)setWindowAppearance:(NSUInteger)windowAppearance
{
    //ODPopoverFrame *themeFrame = (id)[self.contentView superview];
    ODPopoverFrame *themeFrame = [self _borderView];
    themeFrame->_shouldDrawDarkBackground = (windowAppearance == ODPopoverAppearanceLight) ? NO : YES;
}

-(BOOL)canBecomeKeyWindow
{
    return YES;
}

-(BOOL)canBecomeMainWindow
{
    return NO;
}

@end
