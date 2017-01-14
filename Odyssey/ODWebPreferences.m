//
//  ODWebPreferences.m
//  Odyssey
//
//  Created by Terminator on 12/12/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebPreferences.h"
#import "WebPreferencesPrivate.h"
#import "ODController.h"
#import "AppDelegate.h"
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

@interface ODWebPreferences () <NSMenuDelegate> {
    
    NSMenu *_menu;
    
}


@end

@implementation ODWebPreferences

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self->_menu = [[NSMenu alloc] init];
        _menu.title = @"Preferences";
   
        NSArray *userAgents = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                       pathForResource:@"UserAgent"
                                                                       ofType: @"plist"]];
        if (userAgents) {
                 NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"User Agent" action:nil keyEquivalent:@""];
            NSMenu *uaMenu = [NSMenu new];
            for (NSDictionary *d in userAgents) {
                NSMenuItem * itm = [uaMenu addItemWithTitle:d[NAME_KEY] action:@selector(setUserAgent:) keyEquivalent:@""];
                itm.toolTip = d[USERAGENT_KEY];
                itm.target = self;
            }
            [uaMenu insertItem:[NSMenuItem separatorItem] atIndex:0];
            NSMenuItem *itm = [uaMenu insertItemWithTitle:@"Reset User Agent" action:@selector(setUserAgent:) keyEquivalent:@"" atIndex:0];
            itm.tag = 10;
            itm.target = self;
            [item setSubmenu:uaMenu];
            [_menu addItem:item];

        }
        
         [_menu addItem:[NSMenuItem separatorItem]];
        
        ODController *ctl = [[NSApp delegate] controller];
        WebView *wv = [ctl webView];
        WebPreferences *wprefs = [wv preferences];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Load JavaScript" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsJavaScriptTag;
        item.target = self;
        [_menu addItem:item];
        
        //// mediaDataLoadsAutomatically;
        
        item = [[NSMenuItem alloc] initWithTitle:@"Block Pop-Ups" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsBlockPopups;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load Plugins" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsPluginsTag;
        item.target = self;
        [_menu addItem:item];   
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load Images" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsImagesTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Disable Autoplay" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsMediaAutoplayTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        if ([wprefs respondsToSelector:@selector(mediaDataLoadsAutomatically)]) {
            
            item = [[NSMenuItem alloc] initWithTitle:@"Disable Media Autoload" action:@selector(menuItemAction:) keyEquivalent:@""];
            item.tag = WebPrefsMediaAutoloadTag;
            item.target = self;
            [_menu addItem:item];
        }
        
        ///
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Web Inspector" action:@selector(menuItemAction:) keyEquivalent:@"i"];
        item.tag = WebPrefsWebInspectorTag;
        item.target = self;
        item.keyEquivalentModifierMask = NSAlternateKeyMask | NSCommandKeyMask;
        [_menu addItem:item];
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        ///
        
        item = [[NSMenuItem alloc] initWithTitle:@"Clear Cache" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsClearCacheTag;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Uses Cache" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsUsesCacheTag;
        item.target = self;
        [_menu addItem:item];
        
        ////
        
        item = [[NSMenuItem alloc] initWithTitle:@"Private Browsing" action:@selector(menuItemAction:) keyEquivalent:@""];
        item.tag = WebPrefsPrivateModeTag;
        item.target = self;
        [_menu addItem:item];
        
        ///
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        ///
        
//        item = [[NSMenuItem alloc] initWithTitle:@"Incremental Rendering" action:@selector(menuItemAction:) keyEquivalent:@""];
//        item.tag = WebPrefsIncrementalTag;
//        item.target = self;
//        [_menu addItem:item];
        
        ///
        
        _menu.delegate = self;
        [[[NSApp mainMenu] itemWithTag:400] setSubmenu:_menu];
        
            
    }
    return self;
}

+(id)shared
{
    static ODWebPreferences *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ODWebPreferences alloc] init];
    });
    
    return shared;
}

-(void)menuItemAction:(id)sender
{
    NSMenuItem *item = sender;
    long tag = [item tag];
    ODController *ctl = [[NSApp delegate] controller];
    WebView *wv = [ctl webView];
    WebPreferences *wprefs = [wv preferences];
    switch (tag) {
        case WebPrefsJavaScriptTag:
             wprefs.javaScriptEnabled = [wprefs isJavaScriptEnabled] ? NO : YES;
            break;
        case WebPrefsBlockPopups:
             wprefs.javaScriptCanOpenWindowsAutomatically = [wprefs javaScriptCanOpenWindowsAutomatically] ? NO : YES;
            break;
        case WebPrefsPluginsTag:
             wprefs.plugInsEnabled = [wprefs arePlugInsEnabled] ? NO : YES;
            break;
        case WebPrefsImagesTag:
             wprefs.loadsImagesAutomatically = [wprefs loadsImagesAutomatically] ? NO : YES;
            break;
        case WebPrefsMediaAutoplayTag:
            wprefs.mediaPlaybackRequiresUserGesture = wprefs.mediaPlaybackRequiresUserGesture ? NO : YES;
            break;
        case WebPrefsMediaAutoloadTag:
            wprefs.mediaDataLoadsAutomatically = wprefs.mediaDataLoadsAutomatically ? NO : YES;
            break;
            
        case WebPrefsWebInspectorTag:
            [wv.inspector show:self];
            break;

        case WebPrefsClearCacheTag:
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            break;
        case WebPrefsUsesCacheTag:
            wprefs.usesPageCache = [wprefs usesPageCache] ? NO : YES;
            break;
        case WebPrefsPrivateModeTag:
            wprefs.privateBrowsingEnabled = [wprefs privateBrowsingEnabled] ? NO : YES;
            break;
        case WebPrefsIncrementalTag:
             wprefs.suppressesIncrementalRendering = [wprefs suppressesIncrementalRendering] ? NO : YES;
            break;
            
        default:
            break;
    }
    
    
//    if (tag == WebPrefsJavaScriptTag) {
//        wprefs.javaScriptEnabled = [wprefs isJavaScriptEnabled] ? NO : YES;
//    }
}

-(void)setUserAgent:(id)sender
{
    //ODController *ctl = [ODController sharedController];
    ODController *ctl = [[NSApp delegate] controller];
    WebView *v = [ctl webView];
    if ([sender tag] == 10) {
        [v setCustomUserAgent:nil];
        [v setApplicationNameForUserAgent:DEFAULT_USERAGENT_NAME];
    } else {
    [v setCustomUserAgent:[sender toolTip]];
    }
    [v reload:self];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    for (NSMenuItem *item in menu.itemArray) {
        
        long tag = [item tag];
        ODController *ctl = [[NSApp delegate] controller];
        WebView *wv = [ctl webView];
        WebPreferences *wprefs = [wv preferences];
        switch (tag) {
                
            case WebPrefsJavaScriptTag:
                item.state = wprefs.javaScriptEnabled;
                //wprefs.javaScriptEnabled = [wprefs isJavaScriptEnabled] ? NO : YES;
                break;
            case WebPrefsBlockPopups:
                item.state = wprefs.javaScriptCanOpenWindowsAutomatically;
                //wprefs.javaScriptCanOpenWindowsAutomatically = [wprefs javaScriptCanOpenWindowsAutomatically] ? NO : YES;
                break;
            case WebPrefsPluginsTag:
                item.state = wprefs.plugInsEnabled;
                //wprefs.plugInsEnabled = [wprefs arePlugInsEnabled] ? NO : YES;
                break;
            case WebPrefsImagesTag:
                item.state =    wprefs.loadsImagesAutomatically;
                //wprefs.loadsImagesAutomatically = [wprefs loadsImagesAutomatically] ? NO : YES;
                break;
            case WebPrefsMediaAutoplayTag:
                item.state = wprefs.mediaPlaybackRequiresUserGesture;
                break;
            case WebPrefsMediaAutoloadTag:
                item.state = wprefs.mediaDataLoadsAutomatically;
                break;
            case WebPrefsUsesCacheTag:
                item.state = wprefs.usesPageCache;
                //wprefs.usesPageCache = [wprefs usesPageCache] ? NO : YES;
                break;
            case WebPrefsPrivateModeTag:
                item.state = wprefs.privateBrowsingEnabled;
                //wprefs.privateBrowsingEnabled = [wprefs privateBrowsingEnabled] ? NO : YES;
                break;
            case WebPrefsIncrementalTag:
                item.state = wprefs.suppressesIncrementalRendering;
                //wprefs.suppressesIncrementalRendering = [wprefs suppressesIncrementalRendering] ? NO : YES;
                break;
                
            default:
                break;
        }
    }
}


@end
