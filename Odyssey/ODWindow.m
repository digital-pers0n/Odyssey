//
//  ODWindow.m
//  Odyssey
//
//  Created by Terminator on 6/3/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODWindow.h"
#import "ODTabBar.h"
#import "ODTabItem.h"
#import "ODTabSwitcher.h"
#import "ODDelegate.h"


@import Quartz;
@import WebKit;
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

@interface ODStatusbar : NSView
{
    NSColor *_backgroundColor;
    NSColor *_strokeColor;
    NSMutableAttributedString *_attributedStatus;
    NSDictionary *_attrs;
    NSFont *_boldFont;
    dispatch_source_t _statusTimer;
    
@public
    NSString *_status;
}



@property NSString *status;


@end

@implementation ODStatusbar

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    if (_status && self.alphaValue == 1.0) {
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
        
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        [paragraph setLineBreakMode: NSLineBreakByTruncatingMiddle];
        NSUInteger fontSize = 12;
        _attrs =  @{
                    NSFontAttributeName:[NSFont systemFontOfSize:fontSize]/*[NSFont fontWithName:@"Lucida Grande" size:12]*/,
                    NSParagraphStyleAttributeName : paragraph,
                    };
        
        _backgroundColor = [NSColor colorWithDeviceWhite:0.96 alpha:1.0];
        _strokeColor = [NSColor colorWithDeviceWhite:0.64 alpha:1.0];
        //[NSBezierPath setDefaultLineWidth:0.75];
        
        _boldFont = [NSFont boldSystemFontOfSize:fontSize];
        
        
        
    }
    return self;
}

-(NSString *)status
{
    return _status;
}

-(void)setStatus:(NSString *)status
{
    BOOL hasHttpDomain = NO;
    _status = status;
    if (status) {        
        NSRange range = [status rangeOfString:@"http://"];
        if (range.length) {
            status = [status stringByReplacingCharactersInRange:range withString:@""];
            hasHttpDomain = YES;
            
        }
        _attributedStatus = [[NSMutableAttributedString alloc] initWithString:status attributes:_attrs];
        if (hasHttpDomain) {
            range = [status rangeOfString:@"/"];
            [_attributedStatus addAttribute:NSFontAttributeName value:_boldFont range:NSMakeRange(0, range.location)]; 
        }
        self.wantsLayer = NO;
        [self setAlphaValue:1];
        [self setNeedsDisplay:YES];
        [self _fadeTimerWithInterval:4];
    }
}

-(void)_fadeTimerWithInterval:(int)seconds
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
    _closeButton.bordered = NO;
    _closeButton.action = @selector(performClose:);
    _closeButton.target = self;
    
    _minimizeButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_closeButton.frame) + b, NSHeight(frame) - i, a, a)];
    _minimizeButton.autoresizingMask = mask;
    _minimizeButton.image = [NSImage imageNamed:@"ODWindowMinimizeButton"];
    _minimizeButton.bordered = NO;
    _minimizeButton.action = @selector(performMiniaturize:);
    _minimizeButton.target = self;
    
    _zoomButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_minimizeButton.frame) + b, NSHeight(frame) - i, a, a)];
    _zoomButton.autoresizingMask = mask;
    _zoomButton.image = [NSImage imageNamed:@"ODWindowZoomButton"];
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
    _tabButton.font = [NSFont systemFontOfSize:10];
    _tabButton.title = @"1/10";
    _tabButton.alignment = NSTextAlignmentRight;
    _tabButton.frame = NSMakeRect(NSMaxX(frame) - 58, NSHeight(frame) - 17, 36, 10);
    _tabButton.autoresizingMask = mask;
    
    _auxButton = [[NSButton alloc] init];
    _auxButton.bordered = NO;
    _auxButton.action = @selector(auxButtonAction:);
    _auxButton.target = self;
    _auxButton.image = [NSImage imageNamed:@"ODWindowAuxButton"];
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
    
    _backgroundColor = [NSColor colorWithDeviceWhite:0.98 alpha:0.96];
    
    //[_button setButtonType:NSMomentaryPushButton];
    // [self performSelector:@selector(_setWindow:) withObject:owner];
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [_backgroundColor set];
    NSRectFill(dirtyRect);
    NSRect frame = self.frame;
    NSRect buttonFrame = _zoomButton.frame;
    frame = NSMakeRect(NSMaxX(buttonFrame), NSMinY(buttonFrame) + 1, NSMinX(_tabButton.frame) - 48, 14);
    _titleCell.stringValue = super.title;
    [_titleCell drawWithFrame:frame inView:self];
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
    ODTabBar *_tabBar;
    ODWindowFrame *_themeFrame;
    BOOL _fullscreen;
}
@end

@implementation ODWindow

+ (Class)frameViewClassForStyleMask:(NSUInteger)aStyle {
    return [ODWindowFrame class];
    
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    self.movableByWindowBackground = YES;
    self.ignoresMouseEvents = NO;
    self.hidesOnDeactivate = NO;
    self.releasedWhenClosed = NO;
    _tabBar = [[ODTabBar alloc] init];
    _tabBar.window = self;
    [[[ODTabSwitcher tabSwitcher] view] setNeedsDisplay:YES];
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

- (WebView *)webView {
    WebView *result = nil;
    ODTabItem *item = _tabBar.selectedTabItem;
    if (item.type == ODTabTypeWebView) {
        result = (id)item.view;
    }
    return result;
}

- (void)setStatus:(NSString *)status {
    _statusbar.status = status;
}

- (NSString *)status {
    return _statusbar->_status;
}

- (void)setStatusbarHidden:(BOOL)value {
    _statusbar.hidden = value;
    if (!value) {
        _statusbar.alphaValue = 1;
        [_statusbar _fadeTimerWithInterval:5];
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
    ODWindowFrame *windowFrame = [self _borderView];
    windowFrame->_shouldHideTitlebar = value;
    NSView *view = self.contentView;
    NSSize size = self.frame.size;
    if (!value) {
        size.height -= 22;
    }
    [view setFrameSize:size];
}

- (void)setTitlebarInfo:(NSString *)string {
    
    _themeFrame->_tabButton.title = string;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [[self _borderView] setNeedsDisplay:YES];
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
    [_tabBar removeAllTabs];
    _tabBar.window = nil;
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
        u_long count = _tabBar.numberOfTabItems;
        if (count > idx && idx != 9) {
            [_tabBar selectTabItemAtIndex:idx];
        }
    }
}

@end



inline BOOL is_full_screen(long mask) {
    BOOL result = (mask & NSFullScreenWindowMask) ? YES : NO;
    
    return result;
}