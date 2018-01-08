//
//  ODTabItem.m
//  Odyssey
//
//  Created by Terminator on 4/7/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODTabItem.h"
@import WebKit;



@interface ODTabItem ()
{
    @public
    id _view;
    NSString *_label;
    ODTabType _type;
    ODTabState _state;
}

@end

@implementation ODTabItem

-(instancetype)init
{
    return [self initWithView:nil];
}

- (instancetype)initWithView:(NSView *)view
{
    self = [super init];
    if (self) {
        _label = @"Empty Tab";
        _view = view;
        _type = ODTabTypeDefault;
        
    }
    return self;
}

//-(void)setUrl:(NSString *)url
//{
//    
//}
//
//-(NSString *)url
//{
//    return @"";
//}

//-(void)load
//{
//    
//}


-(void)_setState:(ODTabState)state
{
    _state = state;
}

- (void)dealloc
{
    _representedObject = nil;
    _view = nil;
}


@end

//@interface ODWebTabItem ()
//{
//    NSString *_label;
//    NSString *_url; 
//}
//
//@end
//
//@implementation ODWebTabItem
//
//- (instancetype)initWithWebView:(id)view
//{
//    self = [super init];
//    if (self) {
//        _label = @"Empty Tab";
//        _view = view;
//        _type = ODTabTypeWebView;
//        _url = @"about:blank";
//        _loaded = NO;
//    }
//    return self;
//}
//
//-(instancetype)init
//{
//    return [self initWithView:nil];
//}
//
//-(void)setLabel:(NSString *)label
//{
//    [_view setGroupName:label];
//    _label = label;
//}
//
//-(NSString *)label
//{
//    NSString *result;
//    
//    if (_loaded) {
//        result = [_view mainFrameTitle];
//    } else {
//        result = _label;
//    }
//    
//    return result;
//}
//
//-(void)setUrl:(NSString *)url
//{
//    if (_loaded) {
//        
//        [_view setMainFrameURL:url];
//
//    } 
//#ifdef DEBUG
//    NSLog(@"setUrl: url is %@", url);
//#endif
//    _url = url;
//}
//
//-(NSString *)url
//{
//    NSString *result;
//    
//    if (_loaded) {
//        result = [_view mainFrameURL];
//    } else {
//        result = _url;
//    }
//    
//    return result;
//}
//
//-(void)load
//{
//    if (!_loaded) {
//        
//        [_view setMainFrameURL:_url];
//        _loaded = YES;
//        
//    }
//}
//
//@end
