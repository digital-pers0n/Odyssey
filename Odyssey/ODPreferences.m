//
//  ODPreferences.m
//  Odyssey
//
//  Created by Terminator on 4/26/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODPreferences.h"
#import "WebPreferencesPrivate.h"
#import "ODContentFilter.h"
#import "ODDelegate.h"

@import WebKit;

#define NAME_KEY @"Name"
#define USERAGENT_KEY @"UserAgentString"

@class WebInspectorFrontend;

@interface WebInspector : NSObject
{
    WebView *_inspectedWebView;
    WebInspectorFrontend *_frontend;
}
- (id)initWithInspectedWebView:(WebView *)inspectedWebView;
- (void)inspectedWebViewClosed;
- (void)show:(id)sender;
- (void)showConsole:(id)sender;
- (void)close:(id)sender;
- (void)attach:(id)sender;
- (void)detach:(id)sender;
@end

@interface WebView (WebPrivate)

- (WebInspector *)inspector;

@end

@interface WebStorageManager : NSObject

+ (WebStorageManager *)sharedWebStorageManager;

// Returns an array of WebSecurityOrigin objects that have LocalStorage.
- (NSArray *)origins;

- (void)deleteAllOrigins;
- (void)deleteOrigin:(id *)origin;
- (unsigned long long)diskUsageForOrigin:(id *)origin;

- (void)syncLocalStorage;
- (void)syncFileSystemAndTrackerDatabase;

+ (NSString *)_storageDirectoryPath;
+ (void)setStorageDatabaseIdleInterval:(double)interval;
+ (void)closeIdleLocalStorageDatabases;

@end

@interface ODPreferences () <NSMenuDelegate> {
    
    NSMenu *_menu;
    
}

@end

@implementation ODPreferences

- (instancetype)init {
    self = [super init];
    if (self) {
        _menu = [[NSMenu alloc] init];
        _menu.title = @"Preferences";
        NSMenuItem *item;
        NSArray *userAgents = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                pathForResource:@"UserAgent"
                                                                ofType: @"plist"]];
        if (userAgents) {
            item = [[NSMenuItem alloc] initWithTitle:@"User Agent" action:nil keyEquivalent:@""];
            NSMenu *userAgentMenu = [NSMenu new];
            [item setSubmenu:userAgentMenu];
            [_menu addItem:item];
            item = [userAgentMenu addItemWithTitle:@"Reset User Agent" action:@selector(setUserAgent:) keyEquivalent:@""];
            item.tag = 10;
            item.target = self;
            [userAgentMenu addItem:[NSMenuItem separatorItem]];
            
            for (NSDictionary *d in userAgents) {
                item = [userAgentMenu addItemWithTitle:d[NAME_KEY] action:@selector(setUserAgent:) keyEquivalent:@""];
                item.toolTip = d[USERAGENT_KEY];
                item.target = self;
            }
            
        }
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *string = [NSString stringWithFormat:@"Odyssey %@/(%@)", info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"]];
        _defaultUserAgentString = [string stringByAppendingString:@" Version/10.1.2 Safari/603.3.8"];
        
        ODDelegate *delegate = [NSApp delegate];
        [_menu addItem:[delegate.contentFilter contextMenuItem]];
        [_menu addItem:[NSMenuItem separatorItem]];
        
        _preferences = [WebPreferences standardPreferences];
         NSString* dbPath = [WebStorageManager _storageDirectoryPath];
         NSString* localDBPath = [_preferences _localStorageDatabasePath];
        
//        [_preferences setSubpixelCSSOMElementMetricsEnabled:NO];
//        [_preferences setCanvasUsesAcceleratedDrawing:YES];
//        [_preferences setAcceleratedCompositingEnabled:YES];
//        [_preferences setAcceleratedDrawingEnabled:YES];
//        [_preferences setAccelerated2dCanvasEnabled:YES];
//        if (_preferences.canvasUsesAcceleratedDrawing) {
//            puts("Canvas Uses Accelerate Drawing");
//        }
//        if (_preferences.acceleratedDrawingEnabled) {
//            puts("Accelerated Drawing Enabled");
//        }
//        if (_preferences.acceleratedCompositingEnabled) {
//            puts("Accelerated Compositing Enabled");
//        }
//        if (_preferences.accelerated2dCanvasEnabled) {
//            puts("Accelerated 2D Canvas Enabled");
//        }
//        if (_preferences.subpixelCSSOMElementMetricsEnabled) {
//            puts("Subpixel CSS OM Element Metrics Enabled");
//        }
//        if (_preferences.webGLEnabled) {
//            puts("WebGL Enabled");
//        }
//        if (_preferences.domTimersThrottlingEnabled) {
//            puts("DOM Times Throttling Enabled");
//        }
//        if (_preferences.hiddenPageDOMTimerThrottlingEnabled) {
//            puts("hidden page DOM timer throttling enabled");
//        }
//        if (_preferences.applicationChromeModeEnabled) {
//            puts("application chrome mode enabled");
//        }
//        if (_preferences.hiddenPageCSSAnimationSuspensionEnabled) {
//            puts("hidden page CSS animation suspension enabled");
//        }
//        if (_preferences.requestAnimationFrameEnabled) {
//            puts("request animation frame enabled");
//        }
//        if (_preferences.webGL2Enabled) {
//            puts("WebGL2 Enabled");
//        }
//        if (_preferences.webAnimationsEnabled) {
//            puts("Web Animations Enabled");
//        }
        [_preferences setWebSecurityEnabled:YES];
        [_preferences setXSSAuditorEnabled:YES];
        
        
        if (![localDBPath isEqualToString:dbPath]) {
            
            [_preferences setAutosaves:YES];
            [_preferences setOfflineWebApplicationCacheEnabled:YES];
            [_preferences setDatabasesEnabled:YES];
            [_preferences setDeveloperExtrasEnabled:YES];
            [_preferences _setLocalStorageDatabasePath:dbPath];
            [_preferences setLocalStorageEnabled:YES];
            [_preferences setCacheModel:WebCacheModelPrimaryWebBrowser];
            [_preferences setMediaPlaybackRequiresUserGesture:YES];
            
            if ([_preferences respondsToSelector:@selector(setImageControlsEnabled:)]) {
                [_preferences setImageControlsEnabled:YES];
            }
            [_preferences setShrinksStandaloneImagesToFit:YES];
            [_preferences setTextAreasAreResizable:YES];
            [_preferences setMediaPlaybackAllowsInline:NO];
            [_preferences setFrameFlatteningEnabled:YES];
        }
        
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load JavaScript" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemJavaScriptTag;
        item.target = self;
        [_menu addItem:item];
        
        //// mediaDataLoadsAutomatically;
        
        item = [[NSMenuItem alloc] initWithTitle:@"Block Pop-Ups" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemBlockPopupsTag;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load Plugins" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemPluginsTag;
        item.target = self;
        [_menu addItem:item];   
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load Images" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemLoadImagesTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Disable Autoplay" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemMediaAutoplayTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Enable WebGL" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemWebGLTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        if ([_preferences respondsToSelector:@selector(mediaDataLoadsAutomatically)]) {
            
            item = [[NSMenuItem alloc] initWithTitle:@"Disable Media Autoload" action:@selector(menuItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemMediaAutoloadTag;
            item.target = self;
            [_menu addItem:item];
        }
        
        ///
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Web Inspector" action:@selector(menuItemAction:) keyEquivalent:@"i"];
        item.tag = ODMenuItemWebInspectorTag;
        item.target = self;
        item.keyEquivalentModifierMask = NSAlternateKeyMask | NSCommandKeyMask;
        [_menu addItem:item];
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Clear Cache" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemClearCacheTag;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Uses Cache" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemUsesCacheTag;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Private Browsing" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = ODMenuItemPrivateBrowsingTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        ///
        
        _menu.delegate = self;
        [[[NSApp mainMenu] itemWithTag:400] setSubmenu:_menu];
        
        {
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Debug"];
            NSMenuItem *item;
            
            item = [[NSMenuItem alloc] initWithTitle:@"Accelerated Drawing" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemAcceleratedDrawingTag;
            item.target = self;
            [menu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Accelerated Canvas" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemAcceleratedCanvasTag;
            item.target = self;
            [menu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Accelerated 2D Canvas" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemAccelerated2DCanvasTag;
            item.target = self;
            [menu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Accelerated Compositing" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemAcceleratedCompositingTag;
            item.target = self;
            [menu addItem:item];
            
            [menu addItem:[NSMenuItem separatorItem]];
            
            item = [[NSMenuItem alloc] initWithTitle:@"DOM Timer Throttling" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemDOMTimerThrottlingTag;
            item.target = self;
            [menu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"Hidden Page DOM Timer Throttling" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemHiddenPageDOMTimerThrottlingTag;
            item.target = self;
            [menu addItem:item];
            
            item = [[NSMenuItem alloc] initWithTitle:@"CSS Animation Suspension" action:@selector(debugItemAction:) keyEquivalent:@""];
            item.tag = ODMenuItemHiddenPageCSSAnimationSuspensionTag;
            item.target = self;
            [menu addItem:item];
            
            menu.delegate = self;
            item = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
            item.submenu = menu;
            [_menu addItem:[NSMenuItem separatorItem]];
            [_menu addItem:item];
            
        }
        
    }
    return self;
}

- (void)menuItemAction:(id)sender {
    NSMenuItem *item = sender;
    long tag = [item tag];
    WebView *wv = [(ODDelegate *)[NSApp delegate] webView];

    switch (tag) {
        case ODMenuItemJavaScriptTag:
            _preferences.javaScriptEnabled = [_preferences isJavaScriptEnabled] ? NO : YES;
            break;
        case ODMenuItemBlockPopupsTag:
            _preferences.javaScriptCanOpenWindowsAutomatically = [_preferences javaScriptCanOpenWindowsAutomatically] ? NO : YES;
            break;
        case ODMenuItemPluginsTag:
            _preferences.plugInsEnabled = [_preferences arePlugInsEnabled] ? NO : YES;
            break;
        case ODMenuItemLoadImagesTag:
            _preferences.loadsImagesAutomatically = [_preferences loadsImagesAutomatically] ? NO : YES;
            break;
        case ODMenuItemMediaAutoplayTag:
            _preferences.mediaPlaybackRequiresUserGesture = _preferences.mediaPlaybackRequiresUserGesture ? NO : YES;
            break;
        case ODMenuItemMediaAutoloadTag:
            _preferences.mediaDataLoadsAutomatically = _preferences.mediaDataLoadsAutomatically ? NO : YES;
            break;
            
        case ODMenuItemWebInspectorTag:
            [wv.inspector show:self];
            break;
            
        case ODMenuItemClearCacheTag:
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            break;
        case ODMenuItemUsesCacheTag:
            _preferences.usesPageCache = [_preferences usesPageCache] ? NO : YES;
            break;
        case ODMenuItemPrivateBrowsingTag:
            _preferences.privateBrowsingEnabled = [_preferences privateBrowsingEnabled] ? NO : YES;
            break;
        case ODMenuItemWebGLTag:
            _preferences.webGLEnabled = [_preferences webGLEnabled] ? NO : YES;
            break;
            
        default:
            break;
    }

}

- (void)debugItemAction:(id)sender {
    NSMenuItem *item = sender;
    NSUInteger tag = item.tag;
    switch (tag) {
        case ODMenuItemAcceleratedDrawingTag:
        {
            BOOL v = _preferences.acceleratedDrawingEnabled;
            if (v) {
                _preferences.acceleratedDrawingEnabled = NO;
                _preferences.canvasUsesAcceleratedDrawing = NO;
                _preferences.accelerated2dCanvasEnabled = NO;
                _preferences.acceleratedCompositingEnabled = NO;
            } else {
                _preferences.acceleratedDrawingEnabled = YES;
                _preferences.canvasUsesAcceleratedDrawing = YES;
                _preferences.accelerated2dCanvasEnabled = YES;
                _preferences.acceleratedCompositingEnabled = YES;
            }
        }
            //_preferences.acceleratedDrawingEnabled = _preferences.acceleratedDrawingEnabled ? NO : YES;
            break;
        case ODMenuItemAcceleratedCanvasTag:
            _preferences.canvasUsesAcceleratedDrawing = _preferences.canvasUsesAcceleratedDrawing ? NO : YES;
            break;
        case ODMenuItemAccelerated2DCanvasTag:
            _preferences.accelerated2dCanvasEnabled = _preferences.accelerated2dCanvasEnabled ? NO : YES;
            break;
        case ODMenuItemAcceleratedCompositingTag:
            _preferences.acceleratedCompositingEnabled = _preferences.acceleratedCompositingEnabled ? NO : YES;
            break;
        case ODMenuItemDOMTimerThrottlingTag:
              [_preferences setDOMTimersThrottlingEnabled:(_preferences.acceleratedCompositingEnabled ? NO : YES)];
            break;
        case ODMenuItemHiddenPageDOMTimerThrottlingTag:
            _preferences.hiddenPageDOMTimerThrottlingEnabled = _preferences.hiddenPageDOMTimerThrottlingEnabled ? NO : YES;
            break;
        case ODMenuItemHiddenPageCSSAnimationSuspensionTag:
            _preferences.hiddenPageCSSAnimationSuspensionEnabled = _preferences.hiddenPageCSSAnimationSuspensionEnabled ? NO : YES;
            break;
            
        default:
            break;
    }
}

- (void)setUserAgent:(id)sender {
    WebView *v = [(ODDelegate *)[NSApp delegate] webView];
    if ([sender tag] == 10) {
        [v setCustomUserAgent:nil];
        [v setApplicationNameForUserAgent:_defaultUserAgentString];
    } else {
        [v setCustomUserAgent:[sender toolTip]];
    }
    [v reload:self];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {

        for (NSMenuItem *item in menu.itemArray) {
            
            long tag = [item tag];
            switch (tag) {
                    
                case ODMenuItemJavaScriptTag:
                    item.state = _preferences.javaScriptEnabled;
                    break;
                case ODMenuItemBlockPopupsTag:
                    item.state = _preferences.javaScriptCanOpenWindowsAutomatically;
                    break;
                case ODMenuItemPluginsTag:
                    item.state = _preferences.plugInsEnabled;
                    break;
                case ODMenuItemLoadImagesTag:
                    item.state =    _preferences.loadsImagesAutomatically;
                    break;
                case ODMenuItemMediaAutoplayTag:
                    item.state = _preferences.mediaPlaybackRequiresUserGesture;
                    break;
                case ODMenuItemMediaAutoloadTag:
                    item.state = _preferences.mediaDataLoadsAutomatically;
                    break;
                case ODMenuItemUsesCacheTag:
                    item.state = _preferences.usesPageCache;
                    break;
                case ODMenuItemPrivateBrowsingTag:
                    item.state = _preferences.privateBrowsingEnabled;
                    break;
                case ODMenuItemWebGLTag:
                    item.state = _preferences.webGLEnabled;
                    break;
                    
                case ODMenuItemAcceleratedDrawingTag:
                    item.state = _preferences.acceleratedDrawingEnabled;
                    break;
                case ODMenuItemAcceleratedCanvasTag:
                    item.state = _preferences.canvasUsesAcceleratedDrawing;
                    break;
                case ODMenuItemAccelerated2DCanvasTag:
                    item.state = _preferences.accelerated2dCanvasEnabled;
                    break;
                case ODMenuItemAcceleratedCompositingTag:
                    item.state = _preferences.acceleratedCompositingEnabled;
                    break;
                case ODMenuItemDOMTimerThrottlingTag:
                    item.state = _preferences.domTimersThrottlingEnabled;
                    break;
                case ODMenuItemHiddenPageDOMTimerThrottlingTag:
                    item.state = _preferences.hiddenPageDOMTimerThrottlingEnabled;
                    break;
                case ODMenuItemHiddenPageCSSAnimationSuspensionTag:
                    item.state = _preferences.hiddenPageCSSAnimationSuspensionEnabled;
                    break;
                    
                default:
                    break;
            }
        }
        

}



@end
