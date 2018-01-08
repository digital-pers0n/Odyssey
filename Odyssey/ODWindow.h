//
//  ODWindow.h
//  Odyssey
//
//  Created by Terminator on 4/6/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODTabBar, WebView;

@interface NSWindow (NSWindowPrivate)

- (id)_borderView;

@end

@interface ODWindow : NSWindow

@property (readonly) ODTabBar *tabBar;
@property (readonly) WebView *webView; 
@property (readonly, getter=isFullscreen) BOOL fullscreen;
- (IBAction)zoomVertically:(id)sender;

//-(void)addSubview:(NSView *)view;

@property NSString *status;
@property (getter=isStatusbarHidden) BOOL statusbarHidden;


- (void)setTitlebarInfo:(NSString *)string;
@property (getter=isTitlebarHidden) BOOL titlebarHidden;

@property (readonly) NSButton *auxButton;

@end
