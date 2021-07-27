//
//  ODWindow.m
//  Odyssey
//
//  Created by Terminator on 6/3/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODWindow.h"
#import "ODTabView.h"
#import "ODTabViewItem.h"
#import "ODTabSwitcher.h"
//#import "ODDelegate.h"


@import Quartz;

BOOL is_full_screen(long mask);

@interface NSNextStepFrame : NSView
@property NSString *title;

- (instancetype)initWithFrame:(NSRect)frame styleMask:(NSUInteger)aStyle owner:(id)owner;
- (NSRect)contentRectForFrameRect:(NSRect)rect styleMask:(NSUInteger)aStyle;
- (void)shapeWindow;
- (void)_setFrameNeedsDisplay:(BOOL)arg1;
- (id)zoomButton;
- (id)minimizeButton;
- (id)closeButton;
- (NSUInteger)styleMask;
- (void)setStyleMask:(NSUInteger)arg1;
- (id)doClose:(id)arg1;

@end

@interface ODStatusbar ()
{
    NSColor *_backgroundColor;
    NSColor *_strokeColor;
    NSFont *_boldFont;
    dispatch_source_t _statusTimer;
    NSString *_status;
    NSAttributedString *_attributedStatus;
    NSDictionary *_attributes;
}
@end

@implementation ODStatusbar

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    if (self.alphaValue == 1.0) {
        self.wantsLayer = YES;
        NSSize size = [_attributedStatus size];
        NSRect frame = self.bounds;
        if (NSWidth(frame) >= size.width) {
            frame.size.width = size.width + 6;
        } else {
            size.width = frame.size.width;
            size.width -= 6;
            frame.size.width -=4;
            
        }
        
        frame.origin.x = 2;
        frame.origin.y = 2;
        frame.size.height = 22;
        //frame.size.width;
        
        [_backgroundColor set];
        NSRectFill(frame);
        [_strokeColor set];
        NSFrameRect(frame);
        
        frame.origin.x = 4;
        frame.origin.y = 5;
        frame.size.height = 17;
        frame.size.width = size.width;
        
        [_attributedStatus drawInRect:frame];
        
        
    }    // Drawing code here.
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alphaValue = 0.0;
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        [paragraph setLineBreakMode: NSLineBreakByTruncatingMiddle];
        NSUInteger fontSize = 12;
        _attributes =  @{
                    NSFontAttributeName:[NSFont systemFontOfSize:fontSize]/*[NSFont fontWithName:@"Lucida Grande" size:12]*/,
                    NSParagraphStyleAttributeName : paragraph,
                    };
        
        _backgroundColor = [NSColor colorWithDeviceWhite:0.96 alpha:1.0];
        _strokeColor = [NSColor colorWithDeviceWhite:0.64 alpha:1.0];
        _boldFont = [NSFont boldSystemFontOfSize:fontSize];
    }
    return self;
}

- (void)setAttributedStatus:(NSAttributedString *)attributedStatus {
    _attributedStatus = attributedStatus;
    self.wantsLayer = NO;
    [self setAlphaValue:1];
    [self setNeedsDisplay:YES];
    [self fadeTimerWithInterval:4];
}

- (NSAttributedString *)attributedStatus {
    return _attributedStatus;
}

- (NSString *)status {
    return _status;
}

- (void)setStatus:(NSString *)status {
    _status = status;
    if (status) {
        self.attributedStatus = [[NSAttributedString alloc] initWithString:status attributes:_attributes];
    }
}

-(void)fadeTimerWithInterval:(int)seconds
{
    if(_statusTimer){
        dispatch_source_cancel(_statusTimer);
    }
    _statusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_statusTimer, dispatch_time(0, seconds * NSEC_PER_SEC), 1.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_statusTimer, ^{
        dispatch_source_cancel(_statusTimer);
        
        [self.animator setAlphaValue:0];
        [self.superview setNeedsDisplay:YES];
        
    });
    dispatch_resume(_statusTimer);
}


@end

@interface ODWindowFrame : NSNextStepFrame {
@public
    NSButton *_closeButton;
    NSButton *_minimizeButton;
    NSButton *_zoomButton;
    NSButton *_tabButton;
    NSButton *_auxButton;
    
    NSTextFieldCell *_titleCell;
    
    NSColor *_backgroundColor;
    
    NSTrackingArea *_trackingArea;
    
    //BOOL _mouseEntered;
    BOOL _shouldHideTitlebar;
    BOOL _shouldDrawTitle;
}
//@property NSUInteger styleMask;
//@property NSString *title;
//@property id owner;

@end

@implementation ODWindowFrame


- (NSRect)contentRectForFrameRect:(NSRect)rect styleMask:(NSUInteger)aStyle {
    
    if (!_shouldHideTitlebar) {
        rect.size.height -= 22;
    }
    
    return rect;
}

- (id)zoomButton {
    return _zoomButton;
}
- (id)minimizeButton {
    return _minimizeButton;
}
- (id)closeButton {
    return _closeButton;
}

- (instancetype)initWithFrame:(NSRect)frame styleMask:(NSUInteger)aStyle owner:(id)owner {
    self = [super initWithFrame:frame styleMask:aStyle owner:owner];
    [self setNextResponder:owner];
    NSAutoresizingMaskOptions mask = NSViewMaxXMargin | NSViewMinYMargin;
    //    CGFloat a = 8;
    //    CGFloat i = 15;
    CGFloat a = 16;
    CGFloat b = 2;
    CGFloat i = 19;
    _closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(b + 3, NSHeight(frame) - i, a, a)];
    _closeButton.autoresizingMask = mask;
    _closeButton.image = [NSImage imageNamed:@"ODWindowCloseButton"];
    //_closeButton.image = [NSImage imageNamed:NSImageNameStatusNone];
    _closeButton.bordered = NO;
    _closeButton.action = @selector(performClose:);
    _closeButton.target = self;
    
    _minimizeButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_closeButton.frame) + b, NSHeight(frame) - i, a, a)];
    _minimizeButton.autoresizingMask = mask;
    _minimizeButton.image = [NSImage imageNamed:@"ODWindowMinimizeButton"];
    //_minimizeButton.image = [NSImage imageNamed:NSImageNameStatusNone];
    _minimizeButton.bordered = NO;
    _minimizeButton.action = @selector(performMiniaturize:);
    _minimizeButton.target = self;
    
    _zoomButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_minimizeButton.frame) + b, NSHeight(frame) - i, a, a)];
    _zoomButton.autoresizingMask = mask;
    _zoomButton.image = [NSImage imageNamed:@"ODWindowZoomButton"];
    //_zoomButton.image = [NSImage imageNamed:NSImageNameStatusNone];
    _zoomButton.bordered = NO;
    _zoomButton.action = @selector(performZoom:);
    _zoomButton.target = self;
    
    mask = NSViewMinXMargin | NSViewMinYMargin;
    
    _tabButton = [[NSButton alloc] init];
    //[_tabButton setButtonType: NSMomentaryLightButton];
    //[_tabButton setPeriodicDelay:60 interval:60];
    _tabButton.bordered = NO;
    _tabButton.cell.bezeled = NO;
    _tabButton.action = @selector(tabButtonAction:);
    _tabButton.target = self;
    _tabButton.image = [NSImage imageNamed:NSImageNameListViewTemplate];
    //_tabButton.font = [NSFont systemFontOfSize:10];
    //_tabButton.title = @"1/10";
    _tabButton.alignment = NSTextAlignmentRight;
    //_tabButton.frame = NSMakeRect(NSMaxX(frame) - 58, NSHeight(frame) - 17, 36, 10);
    _tabButton.frame = NSMakeRect(NSMaxX(frame) - 40, NSHeight(frame) - i, a, a);
    _tabButton.autoresizingMask = mask;
    
    _auxButton = [[NSButton alloc] init];
    _auxButton.bordered = NO;
    _auxButton.action = @selector(auxButtonAction:);
    _auxButton.target = self;
    _auxButton.image = [NSImage imageNamed:@"ODWindowAuxButton"];
    //_auxButton.image = [NSImage imageNamed:NSImageNameSmartBadgeTemplate];
    _auxButton.frame = NSMakeRect(NSWidth(frame) - 20, NSHeight(frame) - i, a, a);
    _auxButton.autoresizingMask = mask;
    
    [self addSubview:_closeButton];
    [self addSubview:_minimizeButton];
    [self addSubview:_zoomButton];
    [self addSubview:_auxButton];
    [self addSubview:_tabButton];
    
    _titleCell = [[NSTextFieldCell alloc] init];
    _titleCell.font = [NSFont systemFontOfSize:11];
    _titleCell.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleCell.alignment = NSTextAlignmentCenter;
    
    _backgroundColor = [NSColor colorWithDeviceWhite:0.95 alpha:0.90];
    
    //[_button setButtonType:NSMomentaryPushButton];
    // [self performSelector:@selector(_setWindow:) withObject:owner];
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [_backgroundColor set];
    NSRectFill(dirtyRect);
    if (_shouldDrawTitle) {
        NSRect frame = self.frame;
        NSRect buttonFrame = _zoomButton.frame;
        frame = NSMakeRect(NSMaxX(buttonFrame), NSMinY(buttonFrame) + 1, NSMinX(_tabButton.frame) - 48, 14);
        _titleCell.stringValue = super.title;
        [_titleCell drawWithFrame:frame inView:self];
    }

    //[self.window invalidateShadow];
}

//- (void)updateTrackingAreas
//{
//    [super updateTrackingAreas];
//    if (_trackingArea) {
//        [self removeTrackingArea:_trackingArea];
//    }
//
//    NSRect frame = self.frame;
//    CGFloat value = (_mouseEntered) ? 32 : 4;
//    frame = NSMakeRect(0, NSHeight(frame) - value, NSWidth(frame), value);
//    _trackingArea = [[NSTrackingArea alloc] initWithRect:frame
//                                                 options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited
//                                                   owner:self
//                                                userInfo:nil];
//
//
//    [self addTrackingArea:_trackingArea];
//
//}
//
//- (void)mouseEntered:(NSEvent *)theEvent
//{
//    [super mouseEntered:theEvent];
//    if (!_mouseEntered && theEvent.trackingArea == _trackingArea) {
//        _mouseEntered = YES;
//        NSView *contentView = self.window.contentView;
//        NSRect frame = self.frame;
//        frame.size.height -= 22;
//        [self updateTrackingAreas];
//        contentView.animator.frame = frame;
//    }
//}
//
//- (void)mouseExited:(NSEvent *)theEvent
//{
//    [super mouseExited:theEvent];
//    if (theEvent.trackingArea == _trackingArea) {
//        //self.wantsLayer = YES;
//        _mouseEntered = NO;
//        [self updateTrackingAreas];
//        [self.window.contentView.animator setFrameSize:self.frame.size];
//    }
//
//}

- (BOOL)mouseDownCanMoveWindow {
    return YES;
}

//- (void)mouseDragged:(NSEvent *)theEvent
//{
//
//}

- (void)performClose:(id)sender {
    [self.window close];
    //[super doClose:sender];
    //[self.window performClose:sender];
}

- (void)performMiniaturize:(id)sender {
    NSWindow *window = self.window;
    BOOL state = window.miniaturized;
    if (state) {
        [window deminiaturize:sender];
    } else {
        [window miniaturize:sender];
    }
}

#ifdef MAC_OS_X_VERSION_10_13

- (void)performZoom:(id)sender {
    [self.window zoom:sender];
}

#else

- (void)performZoom:(id)sender {
    NSWindow *window = self.window;
    if ([NSEvent modifierFlags] == NSAlternateKeyMask) {
        [window zoom:sender];
    } else {
        [window toggleFullScreen:sender];
        //        NSUInteger styleMask = window.styleMask;
        //        if (styleMask & NSFullScreenWindowMask)
        //        {
        //            styleMask ^= NSFullScreenWindowMask;
        //
        //        } else {
        //            styleMask |= NSFullScreenWindowMask;
        //        }
        //        window.styleMask = styleMask;
    }
}

#endif

- (void)tabButtonAction:(id)sender {
    //    ODDelegate *delegate = [NSApp delegate];
    //    [delegate showTabs:sender];
    [[ODTabSwitcher tabSwitcher] showPopover:sender];
    
}

- (void)auxButtonAction:(id)sender {
    //    ODDelegate *delegate = [NSApp delegate];
    //    [delegate showDownloads:sender];
}

@end

@interface ODWindow () {
    ODStatusbar *_statusbar;
    ODTabView *_tabView;
    ODWindowFrame *_themeFrame;
    BOOL _fullscreen;
}
@end

@implementation ODWindow

+ (Class)frameViewClassForStyleMask:(NSUInteger)aStyle {
    return [ODWindowFrame class];
    
}

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)aStyle
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    self.movableByWindowBackground = YES;
    self.ignoresMouseEvents = NO;
    self.hidesOnDeactivate = NO;
    self.releasedWhenClosed = NO;
    _tabView = [[ODTabView alloc] init];
    //_tabView.window = self;
    
    _fullscreen = is_full_screen(aStyle);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(windowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:self];
    [center addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self];
    [center addObserver:self selector:@selector(windowDidEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:self];
    //_themeFrame = (id)self.contentView.superview;
    _themeFrame = self._borderView;
    //self.backgroundColor = NSColor.clearColor;
    
    return self;
}

- (void)awakeFromNib {
    
    _statusbar = [[ODStatusbar alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 24)];
    [_themeFrame addSubview:_statusbar positioned:NSWindowAbove relativeTo:nil];
    _tabView.frame = NSMakeRect(64, NSHeight(self.frame) - 22, NSWidth(self.frame) - 120, 22);
    _tabView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [_themeFrame addSubview:_tabView];
    
    //CGSSetWindowBackgroundBlurRadius(CGSDefaultConnectionForThread(), self.windowNumber, 16);
    // CGSSetWindowShadowAndRimParameters(CGSDefaultConnectionForThread(), (int)self.windowNumber, 200, 300, 10, 35, 0);
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)isMiniaturizable {
    return YES;
}

#pragma mark - Properties

- (void)setStatusString:(NSString *)status {
    _statusbar.status = status;
}

- (void)setStatusbarHidden:(BOOL)value {
    _statusbar.hidden = value;
    if (!value) {
        _statusbar.alphaValue = 1;
        [_statusbar fadeTimerWithInterval:5];
    }
}

- (BOOL)isStatusbarHidden {
    return _statusbar.hidden;
}

- (BOOL)isTitlebarHidden {
    BOOL result = NO;
    if (NSHeight(self.frame) == NSHeight(self.contentView.frame)) {
        result = YES;
    }
    return result;
    //    ODWindowFrame *windowFrame = [self _borderView];
    //
    //    return windowFrame->_shouldHideTitlebar;
}

- (void)setTitlebarHidden:(BOOL)value {
    _themeFrame->_shouldHideTitlebar = value;
    NSView *view = self.contentView;
    NSSize size = self.frame.size;
    if (!value) {
        size.height -= 22;
    }
    [view setFrameSize:size];
}

- (void)setTabViewHidden:(BOOL)value {
    _tabView.hidden = value;
    _themeFrame->_shouldDrawTitle = value;
    if (value) {
        [_themeFrame setNeedsDisplay:YES];
    }
}

- (BOOL)isTabViewHidden {
    return _tabView.hidden;
}

- (void)setTitlebarInfo:(NSString *)string {
    
    _themeFrame->_tabButton.title = string;
}

- (void)setTitle:(NSString *)title {
        [super setTitle:title];
    if (_themeFrame->_shouldDrawTitle) {
        [_themeFrame setNeedsDisplay:YES];
    } else {
        [_tabView setNeedsDisplay:YES];
    }
}

- (NSButton *)auxButton {
    return _themeFrame->_auxButton;
}


#pragma mark - Actions

- (void)toggleTitlebar:(id)sender {
    BOOL value = ([self isTitlebarHidden]) ? NO : YES;
    [self setTitlebarHidden:value];
    //    NSView *view = self.contentView;
    //    NSSize size = self.frame.size;
    //    size.height -= 22;
    //    [view setFrameSize:size];
}

- (void)zoomVertically:(id)sender {
    NSRect screenFrame = self.screen.visibleFrame;
    NSRect frame = self.frame;
    frame.size.height = screenFrame.size.height;
    frame.origin.y = screenFrame.origin.y;
    [self setFrame:frame display:YES animate:YES];
}

#pragma mark - NSWindow Delegate

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
    _fullscreen = YES;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    _fullscreen = NO;
}

- (void)windowWillClose:(NSNotification *)notification {
    //self.delegate = nil;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [_tabView removeAllTabs];
    [_tabView removeFromSuperview];
    _tabView = nil;
    [_statusbar removeFromSuperview];
    _statusbar = nil;
    [_themeFrame removeFromSuperview];
    _themeFrame = nil;
}

#pragma mark - NSEvent

- (void)keyDown:(NSEvent *)theEvent {
    NSUInteger modifierFlags = theEvent.modifierFlags;
    if (modifierFlags & NSControlKeyMask && modifierFlags & NSAlternateKeyMask) {
        u_short keyCode = [theEvent keyCode];
        long deltaX = 0;
        long deltaY = 0;
        long step = (modifierFlags & NSCommandKeyMask) ? 8 : 1;
        switch (keyCode) {
            case 0x7e:
                deltaY = -step; //up
                break;
            case 0x7d:
                deltaY = step; //down
                break;
            case 0x7b:
                deltaX = -step; //left
                break;
            case 0x7c:
                deltaX = step; //right
                break;
                
            default:
                break;
        }
        
        // NSRect frame = self.frame;
        if (deltaX || deltaY) {
            NSPoint origin = self.frame.origin;
            origin.x += deltaX;
            origin.y -= deltaY;
            [self setFrameOrigin:origin];
        }
        
    } else if ([NSEvent modifierFlags] == NSCommandKeyMask) {
        u_short keyCode = [theEvent keyCode];
        u_long idx = 9;
        switch (keyCode) {
            case 18:
                idx = 0;  //    char: 1
                break;
            case 19:
                idx = 1;  //    char: 2
                break;
            case 20:
                idx = 2;  //    char: 3
                break;
            case 21:
                idx = 3;  //    char: 4
                break;
            case 23:
                idx = 4;  //    char: 5
                break;
            case 22:
                idx = 5;  //    char: 6
                break;
            case 26:
                idx = 6;  //    char: 7
                break;
            case 28:
                idx = 7;  //    char: 8
                break;
            case 25:
                idx = 8;  //    char: 9
                break;
            default:
                break;
        }
        u_long count = _tabView.numberOfTabViewItems;
        if (count > idx && idx != 9) {
            [_tabView selectTabViewItemAtIndex:idx];
        }
    }
}

@end



inline BOOL is_full_screen(long mask) {
    BOOL result = (mask & NSFullScreenWindowMask) ? YES : NO;
    
    return result;
}
