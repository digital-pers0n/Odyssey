//
//  ODWindow.m
//  Odyssey
//
//  Created by Terminator on 4/6/17.
//  Copyright © 2017 home. All rights reserved.
//

//#import "ODWindow.h"
#import "ODTabBar.h"
#import "ODTabItem.h"
#import "ODTabSwitcher.h"
#import "ODDelegate.h"

@import WebKit;


BOOL is_full_screen(long arg0);

@interface NSView (NSThemeView) //NSWindow's NSThemeView methods

-(void)_addKnownSubview:(id)arg1 positioned:(long long)arg2 relativeTo:(id)arg3;
-(NSView *)titlebarContainerView;
- (void)setTitlebarContainerView:(id)arg1;
- (void)setTitlebarView:(id)arg1;

@end

@interface ODStatusbar : NSView
{
    
    
    NSColor *_backgroundColor;
    NSColor *_strokeColor;
    
   
    
    NSMutableAttributedString *_attributedStatus;
    NSDictionary *_attrs;
    NSFont *_boldFont;
    
    BOOL _canDrawAttributedString;
    
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

        
        NSSize size = [_status sizeWithAttributes:_attrs];
        
        CGFloat width = NSWidth(self.window.frame);
        if (size.width >= width) {
            size.width = width - 17;
        }
        
          NSRect rect = NSMakeRect(3, 3, size.width + 9, size.height + 3);
        
        [_backgroundColor setFill];
        NSRectFill(rect);
        
        [_strokeColor setStroke];
        [NSBezierPath strokeRect:rect];
        
        rect.origin.x = 8;
        rect.origin.y =  NSHeight(rect) / 6;
        rect.size.width = size.width;
        
        if (_canDrawAttributedString) {
            
            NSRange range = [_attributedStatus.string rangeOfString:@"/"];
             
            [_attributedStatus addAttribute:NSFontAttributeName value:_boldFont range:NSMakeRange(0, range.location)];
            [_attributedStatus drawInRect:rect];
            
        } else {
            
            [_status drawInRect:rect withAttributes:_attrs];
        }
      
        
    }    // Drawing code here.
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        _canDrawAttributedString = NO;
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        [paragraph setLineBreakMode: NSLineBreakByTruncatingMiddle];
        _attrs =  @{
                    NSFontAttributeName :[NSFont systemFontOfSize:[NSFont systemFontSize]],
                    NSParagraphStyleAttributeName : paragraph,
                    };
        
        _backgroundColor = [NSColor colorWithDeviceWhite:0.97 alpha:1.0];
        _strokeColor = [NSColor colorWithDeviceWhite:0.90 alpha:1.0];
        [NSBezierPath setDefaultLineWidth:0.75];
    
        _boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize] - 1];
        
        
        
    }
    return self;
}

-(NSString *)status
{
    return _status;
}

-(void)setStatus:(NSString *)status
{
    _status = status;
    if (status) {
        
        NSRange range = [status rangeOfString:@"http://"];
        if (!range.length) {
            range = [status rangeOfString:@"https://"];
            
        }
        if (range.length) {
            
            _attributedStatus = [[NSMutableAttributedString alloc] initWithString:[status stringByReplacingCharactersInRange:range withString:@""] attributes:_attrs];
            _canDrawAttributedString = YES;
            
        } else {
            
            _canDrawAttributedString = NO;
        }
         self.wantsLayer = NO;
         [self.animator setAlphaValue:1];

        
    } else {
        
        [self.animator setAlphaValue:0];
    }
}


@end

@interface ODTitlebar : NSView
{
    NSTrackingArea *_trackingArea;
    
    NSColor *_backgroundColor;
    NSColor *_strokeColor;
    
    
    NSCell *_titleCell;
    
  
    
    @public
    BOOL _outOfBounds;
    BOOL _mouseDragged;
    NSString *_title;
    NSButton *_tabButton;
}

@property NSString *title;

@property (readonly) NSButton *tabButton;

-(void)setTabButtonTitle:(NSString *)string;

@end

@implementation ODTitlebar

-(void)drawRect:(NSRect)dirtyRect
{
    if (!_outOfBounds && !_mouseDragged) {

        //NSRectClip(dirtyRect);
        dirtyRect = self.bounds;
        [_backgroundColor setFill];
        NSRectFill(dirtyRect);
        
        [_strokeColor set];
        NSFrameRect(dirtyRect);
        
        //[NSBezierPath strokeRect:dirtyRect];
        
        [_tabButton setFrameOrigin:NSMakePoint(NSWidth(dirtyRect) - 60, 3)];
        
        if (_title) {
            [_titleCell setStringValue:_title];
            [_titleCell drawWithFrame:NSMakeRect(70, 0, NSWidth(dirtyRect) - 126, 19) inView:self];
        }
        
    }
    
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tabButton = [[NSButton alloc] init];
        _tabButton.bordered = NO;
        _tabButton.cell.bezeled = NO;
        _tabButton.action = @selector(tabButtonClicked:);
        _tabButton.target = self;
        _tabButton.font = [NSFont systemFontOfSize:11];
        //_tabButton.title = @"99|99";
        _tabButton.alignment = NSTextAlignmentRight;
        [_tabButton setFrameSize:NSMakeSize(45, 16)];
        [self addSubview:_tabButton positioned:NSWindowAbove relativeTo:nil];
        
        _backgroundColor = [NSColor colorWithDeviceWhite:0.97 alpha:1.0];
        _strokeColor = [NSColor colorWithDeviceWhite:0.90 alpha:1.0];
        [NSBezierPath setDefaultLineWidth:0.5];
        
        _titleCell = [[NSCell alloc] initTextCell:@"Empty"];
        [_titleCell setLineBreakMode:NSLineBreakByTruncatingTail];
        
        _outOfBounds = NO;
        _mouseDragged = NO;
        
        
    }
    return self;
}



-(void)tabButtonClicked:(id)sender
{
    ODDelegate *delegate = [NSApp delegate];
    [delegate showTabs:sender];
}

-(void)setTabButtonTitle:(NSString *)string
{
    _tabButton.title = string;
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent    
{
    return NO;
}

-(BOOL)acceptsFirstResponder
{
    return NO;
}

-(BOOL)mouseDownCanMoveWindow
{
    return YES;
}


-(void)action:(id)sender
{
    [self.window toggleFullScreen:sender];
}


- (void)updateTrackingAreas
{
//    NSView *superview = self.superview;
//    [superview addSubview:self]; |NSTrackingInVisibleRect
    [super updateTrackingAreas];

    
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
        
    } 
    
    NSRect frame = self.frame;
    frame = NSMakeRect(0, -22, NSWidth(frame), 44);
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:frame 
                                                 options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited 
                                                   owner:self 
                                                userInfo:nil];
    
    
    [self addTrackingArea:_trackingArea];
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    _outOfBounds = NO;
    self.wantsLayer = YES;
    
    
    //[self setAlphaValue:1.0];
//    [self setAlphaValue:1.0];
    NSRect frame = self.superview.frame;
    [self.animator setFrameOrigin:NSMakePoint(0, NSHeight(frame) - 22)];
  

    //    FOTWindow* window = (FOTWindow*)self.window;
    //    [[window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [[window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [[window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [[window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [[window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [[window standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:window.titleBarFadeInAlphaValue];
    //    [_titleBar.animator setAlphaValue:window.titleBarFadeInAlphaValue];
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    //[self setAlphaValue:0.0];
    if (!_mouseDragged) {
        _outOfBounds = YES;
        self.wantsLayer = NO;
        
        //    [self setAlphaValue:0.0];
        [self.animator setFrameOrigin:NSMakePoint(0, NSMinY(self.frame) + 34)];
    }

    

    
    //    FOTWindow* window = (FOTWindow*)self.window;
    //    [[window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [[window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [[window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [[window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [[window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [[window standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:window.titleBarFadeOutAlphaValue];
    //    [_titleBar.animator setAlphaValue:window.titleBarFadeOutAlphaValue];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    
//    long deltaX = theEvent.deltaX;
//    long deltaY = theEvent.deltaY;
//    printf("X = %li, Y = %li", deltaX, deltaY);
   // puts("mouseDown");
    
}

-(void)mouseUp:(NSEvent *)theEvent
{
    //self.wantsLayer = NO;
    _mouseDragged = NO;

}


- (void)mouseDragged:(NSEvent *)theEvent
{
    _mouseDragged = YES;
    
    long deltaX = theEvent.deltaX;
    long deltaY = theEvent.deltaY;

    
    NSWindow *window = self.window;
    
    NSRect frame = window.frame;
    NSPoint point = NSMakePoint(NSMinX(frame) + (deltaX), NSMinY(frame) - (deltaY));
    [window setFrameOrigin:point];
    //[window setFrame:NSMakeRect(point.x, point.y, NSWidth(frame), NSHeight(frame)) display:YES animate:NO];
    //[window setFrameTopLeftPoint:point];
    
    
    
    //printf("X = %li, Y = %li", deltaX, deltaY);
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@, superview: %@", super.description,
            NSStringFromRect(self.frame), self.superview];
}



@end

@interface ODWindow () <NSWindowDelegate>
{
    ODTitlebar *_titleBar;
    ODStatusbar *_statusBar;
    ODTabBar *_tabBar;
    
    NSView *_themeFrame;
    NSArray *_windowButtons;
    NSView *_containerView;
    BOOL _fullscreen;
   
    
    
}

@end

@implementation ODWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    
    if (self) {
        
        self.delegate = self;
        self.movableByWindowBackground = YES;
        _fullscreen = is_full_screen(aStyle);
    }
    
    return self;
}

-(void)awakeFromNib
{
    _tabBar = [[ODTabBar alloc] init];
    _tabBar.window = self;
    NSView *contentView = self.contentView;
    NSView *themeFrame = contentView.superview;
    
    [contentView removeFromSuperview];
    [themeFrame _addKnownSubview:contentView positioned:NSWindowBelow relativeTo:themeFrame];
    NSRect frame = themeFrame.frame;
    contentView.frame = frame;
    
    _titleBar = [[ODTitlebar alloc] initWithFrame:NSMakeRect(0, NSHeight(frame)-22, NSWidth(frame), 22)];
    [_titleBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin|NSViewMinXMargin];
    
    _statusBar = [[ODStatusbar alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 24)];
    [contentView addSubview:_statusBar positioned:NSWindowAbove relativeTo:nil];
    
    [themeFrame _addKnownSubview:_titleBar positioned:NSWindowAbove relativeTo:contentView];
    _themeFrame = themeFrame;
    self.backgroundColor = NSColor.whiteColor;
    
    
    _windowButtons = @[[self standardWindowButton:NSWindowCloseButton],
                       [self standardWindowButton:NSWindowZoomButton],
                       [self standardWindowButton:NSWindowMiniaturizeButton]];
    
    
    _containerView = [_themeFrame performSelector:@selector(titlebarContainerView)];
    if (_containerView) {
        [_containerView removeFromSuperview];
    }
    
    if (!_fullscreen) {
        
        for (NSButton *button in _windowButtons) {
            [button setFrameOrigin:NSMakePoint(button.frame.origin.x, 3)];
            //[button removeFromSuperview];
            [_titleBar addSubview:button];
        }
    }
    
    
    
}

#pragma mark - Methods

-(WebView *)webView
{
    WebView *result = nil;
    ODTabItem *item = _tabBar.selectedTabItem;
    if (item.type == ODTabTypeWebView) {
        result = (id)item.view;
    }
    return result;
}

-(void)setStatus:(NSString *)status
{
    _statusBar.status = status;
}

-(NSString *)status
{
    return _statusBar->_status;
}

-(void)setStatusbarHidden:(BOOL)value
{
    _statusBar.hidden = value;
}

-(BOOL)isStatusbarHidden
{
    return _statusBar.hidden;
}

-(BOOL)isTitlebarHidden
{
    BOOL result = NO;
    if (_titleBar.hidden || _titleBar->_outOfBounds) {
        result = YES;
    }
    return result;
}

-(void)setTitlebarHidden:(BOOL)value
{
    if (_titleBar->_outOfBounds) {
        [_titleBar mouseEntered:(id)self];
        value = NO;
    }
        _titleBar.hidden = value;
    
}

-(void)setTitlebarInfo:(NSString *)string
{
   
    _titleBar->_tabButton.title = string;
}

-(void)addSubview:(NSView *)view
{
//    NSView *contentView = self.contentView;
//    [contentView addSubview:view];
//    [contentView addSubview:_titleBar positioned:NSWindowAbove relativeTo:view];
    [self setContentView:view];
    [self.contentView setFrameSize:self.frame.size];
}

-(void)setTitle:(NSString *)title
{
    _titleBar->_title = title;
    [_titleBar setNeedsDisplay:YES];
    [NSApp removeWindowsItem:self];
    [NSApp addWindowsItem:self title:title filename:NO];
}

#pragma mark - NSWindow Delegate


-(void)windowDidResize:(NSNotification *)notification
{
    [self.contentView setFrameSize:self.frame.size];
    for (NSButton *button in _windowButtons) {
        
        [button setFrameOrigin:NSMakePoint(button.frame.origin.x, 3)];
    }
}

-(void)windowDidEndLiveResize:(NSNotification *)notification
{
     _fullscreen = is_full_screen(self.styleMask);
}

//-(void)windowWillMove:(NSNotification *)notification
//{
//    puts("willmove");
//
//}
//
//-(void)windowDidMove:(NSNotification *)notification
//{
//     puts("didmove");
//}

-(void)windowDidExitFullScreen:(NSNotification *)notification
{
    [_containerView removeFromSuperview];
    _fullscreen = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        for (NSButton *button in _windowButtons) {
            [_titleBar addSubview:button];
        }
    });
}

-(void)windowDidEndSheet:(NSNotification *)notification 
{
    if (!_fullscreen) {
        for (NSButton *button in _windowButtons) {
            [_titleBar addSubview:button];
            [button setFrameOrigin:NSMakePoint(button.frame.origin.x, 3)];
        }
    }
}

-(void)windowWillClose:(NSNotification *)notification
{
    self.delegate = nil;
    [_tabBar removeAllTabs];
    _tabBar.window = nil;
    [NSApp removeWindowsItem:self];
}


#pragma mark - Private

#pragma mark - NSEvent


-(void)keyDown:(NSEvent *)theEvent
{
    NSEventModifierFlags flags = [theEvent modifierFlags];
    if ([NSEvent modifierFlags] == NSCommandKeyMask) {
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
    } else if (flags == 11927819 /*(NSCommandKeyMask | NSShiftKeyMask | NSControlKeyMask)*/) {
        u_short keyCode = [theEvent keyCode];
        long deltaX = 0;
        long deltaY = 0;
        switch (keyCode) {
            case 0x7e:
                deltaY = -8;
                break;
            case 0x7d:
                deltaY = 8;
                break;
            case 0x7b:
                deltaX = -8;
                break;
            case 0x7c:
                deltaX = 8;
                break;
                
            default:
                break;
        }
        
        NSRect frame = self.frame;
        NSPoint point = NSMakePoint(NSMinX(frame) + (deltaX), NSMinY(frame) - (deltaY));
        [self setFrameOrigin:point];
    }
    
    /* 
     code:0x7e       name:Up                      
     code:0x7d       name:Down         
     code:0x7b       name:Left                  
     code:0x7c       name:Right           
 */
    
}


@end

BOOL is_full_screen(long mask)
{
    BOOL result = (mask & NSFullScreenWindowMask) ? YES : NO;
    
    return result;
}
