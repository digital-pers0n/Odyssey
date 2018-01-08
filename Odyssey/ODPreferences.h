//
//  ODPreferences.h
//  Odyssey
//
//  Created by Terminator on 4/26/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;
#import <WebKit/WebPreferences.h>

typedef NS_ENUM(NSUInteger, ODMenuItemTag) {
    ODMenuItemJavaScriptTag = 100,    // isJavaScriptEnabled) BOOL javaScriptEnabled
    ODMenuItemBlockPopupsTag,            // BOOL javaScriptCanOpenWindowsAutomatically
    ODMenuItemPluginsTag,             // arePlugInsEnabled) BOOL plugInsEnabled     
    ODMenuItemLoadImagesTag,              // loadsImagesAutomatically
    ODMenuItemMediaAutoplayTag,
    ODMenuItemMediaAutoloadTag,       // mediaDataLoadsAutomatically
    ODMenuItemWebInspectorTag,
    ODMenuItemQTKitTag,               // enableQTKit
    ODMenuItemClearCacheTag,          // ClearCache
    ODMenuItemUsesCacheTag,
    ODMenuItemPrivateBrowsingTag,
    ODMenuItemWebGLTag,
    
    ODMenuItemAcceleratedDrawingTag,
    ODMenuItemAcceleratedCanvasTag,
    ODMenuItemAccelerated2DCanvasTag,
    ODMenuItemAcceleratedCompositingTag,
    ODMenuItemDOMTimerThrottlingTag,
    ODMenuItemHiddenPageDOMTimerThrottlingTag,
    ODMenuItemHiddenPageCSSAnimationSuspensionTag,
    
};

@interface WebPreferences (WebPreferencesPrivate)

- (BOOL)zoomsTextOnly;
- (void)setZoomsTextOnly:(BOOL)zoomsTextOnly;


@end

@interface ODPreferences : NSObject

@property (readonly) WebPreferences *preferences;
@property (readonly) NSString *defaultUserAgentString;


@end
