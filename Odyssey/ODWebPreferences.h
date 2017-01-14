//
//  ODWebPreferences.h
//  Odyssey
//
//  Created by Terminator on 12/12/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DEFAULT_USERAGENT_NAME @"Odyssey/0.5 Version/9.0 Safari/601.56"

typedef NS_ENUM(NSUInteger, WebPrefsMenuTag) {
    WebPrefsJavaScriptTag = 100,    // isJavaScriptEnabled) BOOL javaScriptEnabled
    WebPrefsBlockPopups,            // BOOL javaScriptCanOpenWindowsAutomatically
    WebPrefsPluginsTag,             // arePlugInsEnabled) BOOL plugInsEnabled     
    WebPrefsImagesTag,              // loadsImagesAutomatically
    WebPrefsMediaAutoplayTag,
    WebPrefsMediaAutoloadTag,       // mediaDataLoadsAutomatically
    WebPrefsWebInspectorTag,
    WebPrefsQTKitTag,               // enableQTKit
    WebPrefsClearCacheTag,          // ClearCache
    WebPrefsUsesCacheTag,
    WebPrefsPrivateModeTag,
    WebPrefsIncrementalTag,
    
};


@interface ODWebPreferences : NSObject

+(id)shared;

@end
