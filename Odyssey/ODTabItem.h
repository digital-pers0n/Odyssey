//
//  ODTabItem.h
//  Odyssey
//
//  Created by Terminator on 4/7/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

typedef NS_ENUM(NSUInteger, ODTabState) {
    
    ODTabStateBackground = 0,
    ODTabStateSelected = 1,
    
};

typedef NS_ENUM(NSUInteger, ODTabType) {
    
    ODTabTypeDefault = 1,
    ODTabTypeWebView,
    
};

@interface ODTabItem : NSObject
{

}

- (instancetype)initWithView:(NSView *)view;

@property NSString *label;
@property NSView *view;

@property ODTabType type;
@property (readonly) ODTabState state;
@property NSInteger tag;
@property id representedObject;


 /* implemented by subclasses */

//-(void)setUrl:(NSString *)url;
//-(NSString *)url;
//-(void)load;

 /* Private */

-(void)_setState:(ODTabState)state;

@end

//@interface ODWebTabItem : ODTabItem
//
//- (instancetype)initWithWebView:(WebView *)view;
//@property (readonly, getter=isLoaded) BOOL loaded;
//@property NSString *url;
//
//-(void)load;
////-(void)close;
//
//@end
