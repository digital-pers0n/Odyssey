//
//  ODTabBarViewItem.h
//  TabBar
//
//  Created by Terminator on 2017/12/17.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, ODTabState) {
    
    ODTabStateBackground = 0,
    ODTabStateSelected = 1,
    
};

typedef NS_ENUM(NSUInteger, ODTabType) {
    
    ODTabTypeDefault = 1,
    ODTabTypeOther,
    
};

@interface ODTabViewItem : NSObject <NSPasteboardWriting, NSPasteboardReading>

- (instancetype)initWithView:(NSView *)view;

@property NSString *label;
@property NSView *view;

@property ODTabType type;
@property (readonly) ODTabState state;
@property NSInteger tag;
@property id representedObject;

-(void)_setState:(ODTabState)state;


@end
