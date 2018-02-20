//
//  ODWindow.h
//  Odyssey
//
//  Created by Terminator on 4/6/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODTabView;

@interface NSWindow (NSWindowPrivate)

- (id)_borderView;

@end

@interface ODWindow : NSWindow

@property (readonly) ODTabView *tabView;
@property (readonly, getter=isFullscreen) BOOL fullscreen;
- (IBAction)zoomVertically:(id)sender;

//-(void)addSubview:(NSView *)view;

@property NSString *statusString;
@property (getter=isStatusbarHidden) BOOL statusbarHidden;


//- (void)setTitlebarInfo:(NSString *)string;
@property (getter=isTitlebarHidden) BOOL titlebarHidden;
@property (getter=isTabViewHidden) BOOL tabViewHidden;

@property (readonly) NSButton *auxButton;

@end
