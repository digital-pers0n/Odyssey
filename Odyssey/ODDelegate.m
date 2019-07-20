//
//  ODDelegate.m
//  Odyssey
//
//  Created by Terminator on 4/6/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODDelegate.h"
#import "ODWindow.h"
#import "ODTabView.h"
#import "ODTabViewItem.h"
#import "ODTabSwitcher.h"
#import "ODAddressField.h"
#import "ODBookmarks.h"
#import "ODDownloadManager.h"
#import "ODContentFilter.h"
#import "ODPreferences.h"
#import "ODHistory.h"
#import "ODFindBanner.h"
#import "ODSessionItem.h"
#import "ODSessionManager.h"

@import WebKit;


extern NSString *WebElementMediaURLKey;

typedef NS_ENUM(NSUInteger, ODMenuItemList) {
    ODMenuItemOpenLinkInNewTab = 0,
    ODMenuItemImageInNewTab,
    ODMenuItemOpenWithMpv,
    ODMenuItemSearchImage,
};

typedef NS_ENUM(NSUInteger, ODWebTabTag) {
    ODWebTabNewTag = 100,
    ODWebTabLoadedTag = 101,
};

@interface WebView (WebViewPrivate)
/*!
 @method setPageSizeMultiplier:
 @abstract Change the zoom factor of the page in views managed by this webView.
 @param multiplier A fractional percentage value, 1.0 is 100%.
 */    
- (void)setPageSizeMultiplier:(float)multiplier;

/*!
 @method pageSizeMultiplier
 @result The page size multipler.
 */    
- (float)pageSizeMultiplier;

// Commands for doing page zoom.  Will end up in WebView (WebIBActions) <NSUserInterfaceValidations>
- (BOOL)canZoomPageIn;
- (IBAction)zoomPageIn:(id)sender;
- (BOOL)canZoomPageOut;
- (IBAction)zoomPageOut:(id)sender;
- (BOOL)canResetPageZoom;
- (IBAction)resetPageZoom:(id)sender;

@end

#define DEFAULTS_PAGE_ZOOM_KEY @"PageZoom"
#define DEFAULTS_TEXT_ZOOM_KEY @"TextZoom"
#define DEFAULTS_ZOOM_TEXT_ONLY_KEY @"ZoomTextOnly"


@interface ODDelegate () <ODTabViewDelegate, ODTabSwitcherDelegate, ODSessionManagerDelegate, WebUIDelegate, WebFrameLoadDelegate, WebPolicyDelegate, WebResourceLoadDelegate> {
    
    ODBookmarks *_bookmarks;
    ODDownloadManager *_downloadManager;
    ODContentFilter *_contentFilter;
    ODPreferences *_preferences;
    ODHistory *_history;
    ODFindBanner *_findBanner;
    ODTabSwitcher *_tabSwitcher;
    ODSessionManager *_sessionManager;
    
    NSMenuItem *_openWithMpvMenuItem;
    NSArray *_menuItemList;
    BOOL _zoomTextOnly;
    NSString *_initPath;
    
    NSString *_previousStatus;
    
    NSUserDefaults *_userDefaults;
}

@property (weak) IBOutlet NSMenuItem *zoomTextOnlyMenuItem;

@property (weak) IBOutlet ODWindow *window;
@end

@implementation ODDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _windows = [NSMutableArray new];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(openUrl:withReplyEvent:)
                                                         forEventClass:kInternetEventClass
                                                            andEventID:kAEGetURL];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
    NSFileManager *shared = [NSFileManager defaultManager];
    NSURL *appSupp = [[shared URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
    appSupp = [appSupp URLByAppendingPathComponent:@"Odyssey" isDirectory:YES];
    
    if (![shared fileExistsAtPath:appSupp.path]) {
        
        [shared createDirectoryAtURL:appSupp withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    _bookmarks = [[ODBookmarks alloc] init];
    _downloadManager = [[ODDownloadManager alloc] init];
    _contentFilter = [[ODContentFilter alloc] init];
    _preferences = [[ODPreferences alloc] init];
    _history = [[ODHistory alloc] init];
    _tabSwitcher = [ODTabSwitcher tabSwitcher];
    _tabSwitcher.delegate = self;
    [_tabSwitcher.view setNeedsDisplay:YES];
    _sessionManager = [[ODSessionManager alloc] init];
    _sessionManager.sessionSavePath = [@"~/Library/Application Support/Odyssey/archivedSession.plist" stringByExpandingTildeInPath];
    _sessionManager.delegate = self;
    
    
    
    _zoomTextOnly = [_userDefaults boolForKey:DEFAULTS_ZOOM_TEXT_ONLY_KEY];
    _zoomTextOnlyMenuItem.state = _zoomTextOnly;
    
    if (![_userDefaults doubleForKey:DEFAULTS_PAGE_ZOOM_KEY]) {
        [_userDefaults setDouble:1.0 forKey:DEFAULTS_PAGE_ZOOM_KEY];
    }
    if (![_userDefaults doubleForKey:DEFAULTS_TEXT_ZOOM_KEY]) {
        [_userDefaults setDouble:1.0 forKey:DEFAULTS_TEXT_ZOOM_KEY];
    }
     
    { 
    
        NSMenuItem *openWithMpvItem = [[NSMenuItem alloc] initWithTitle:@"Open With MPV" 
                                                          action:@selector(openWithMpvMenuItemClicked:) 
                                                   keyEquivalent:@""];
        openWithMpvItem.target = self;
        openWithMpvItem.toolTip = @"Click: 1080p, ⌥+Click: 720p, ⌘+Click: 480p, ⇧+Click: Audio";
    
        NSMenuItem *openLinkInNewTab = [[NSMenuItem alloc] initWithTitle:@"Open Link In New Tab" 
                                                             action:@selector(openInNewTabMenuItemClicked:) 
                                                      keyEquivalent:@""];
        openLinkInNewTab.target = self;
        
        NSMenuItem *openImageInNewTab = [[NSMenuItem alloc] initWithTitle:@"Open Image In New Tab" 
                                                                  action:@selector(openInNewTabMenuItemClicked:) 
                                                           keyEquivalent:@""];
        openImageInNewTab.target = self;
        
        NSMenuItem *searchImage = [[NSMenuItem alloc] initWithTitle:@"Search By Image"
                                                                   action:@selector(searchImageMenuItemClicked:)
                                                            keyEquivalent:@""];
        searchImage.target = self;
        searchImage.toolTip = @"Click: New Background Tab, ⌥+Click: New Window, ⌘+Click: New Foreground Tab, ⇧+Click: Current Tab";
        
        _menuItemList = @[openLinkInNewTab, openImageInNewTab, openWithMpvItem, searchImage];
        
    
    }

  [self restoreSession];
    if (_initPath) {
        [self openInNewWindow:_initPath];
    } else {
        _initPath = @"";
    }

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self storeSession];
    [_sessionManager saveSession];
}



#pragma mark - Application Actions

static inline NSString *_sessionName() {
    time_t t = 0;
    time(&t);
    struct tm  sometime;
    struct tm *p = &sometime;
    p = localtime(&t);
    sometime = *p;
    return [NSString stringWithFormat:@"Session-%i%.2i%.2i-%.2i%.2i%.2i",
            sometime.tm_year + 1900, sometime.tm_mon + 1, sometime.tm_mday, sometime.tm_hour, sometime.tm_min, sometime.tm_sec];

}

- (IBAction)saveSessionMenuAction:(id)sender {

    ODSessionItem *i = [[ODSessionItem alloc] init];
    i.name =  _sessionName();
    i.sessionArray = [self sessionArray];
    [_sessionManager addSessionItem:i];
}

- (IBAction)manageSessionsMenuAction:(id)sender {
    [_sessionManager showSessionWindow];
}

- (ODWindow *)newWindow {
    NSRect screen = [[NSScreen mainScreen] visibleFrame];
    NSRect frame = (_window) ? _window.frame : NSMakeRect(NSMinX(screen), NSMinY(screen), 800, 600);
    
    NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask
    | NSMiniaturizableWindowMask  ;
    
    ODWindow *window  = [[ODWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
    window.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
    [self _setUpWindow:window];
    
    
    NSPoint point;
    if (_window) {
        frame = _window.frame;
        point = NSMakePoint(NSMinX(frame) - 22, NSMinY(frame) + NSHeight(frame) - 22);
    } else {
        point = NSMakePoint(10, NSHeight(screen) - 10);
    }
    [window cascadeTopLeftFromPoint:point];
    [window makeKeyAndOrderFront:nil];
    
    [window awakeFromNib];
    window.tabView.delegate = self;
    return window;
}

- (void)openInNewWindow:(NSString *)path {
    [self newWindow];
    [self openInMainWindow:path newTab:YES background:NO];
}

- (void)openInMainWindow:(NSString *)path newTab:(BOOL)newTab background:(BOOL)background {
    if (_windows.count == 0) {
        
        [self openInNewWindow:path];
        
    } else {
        
        ODTabView *tabView = _window.tabView;
        
        if (tabView.numberOfTabViewItems == 0) {
            
            newTab = YES;
            background = NO;
        }
        
        if (newTab) {
            
            ODTabViewItem *item = [self _setUpWebTabItem];
            item.representedObject = path;
            [tabView addTabViewItem:item relativeToSelectedTab:YES];
            
            if (!background) {
                [tabView selectTabViewItem:item];
//                [(id)item.view setMainFrameURL:path];
//                NSLog(@"path: %@ mainFrameURL: %@",path, [(id)item.view mainFrameURL]);

            }
            
        } else {
            
            WebView *webView = [self webView];
            [webView setMainFrameURL:path];
        }
        
    }
}

- (void)openInMainWindow:(NSString *)path newTab:(BOOL)value {
    [self openInMainWindow:path newTab:value background:NO];
}

- (void)openInMainWindow:(NSString *)path {
    [self openInMainWindow:path newTab:YES background:NO];
}

- (void)openAddressListInTabs:(NSArray *)addressList newWindow:(BOOL)value {
    if (value) {
        
        [self openInNewWindow:@"about:blank"];
    }
    
    ODTabView *tabView = _window.tabView;
    for (NSString *str in addressList) {
        ODTabViewItem *webTab = [self _setUpWebTabItem];
        webTab.representedObject = str;
        [tabView addTabViewItem:webTab];
    }
    
    if (value) {
        [tabView removeTabViewItemAtIndex:0];
    }
    
}

- (void)newWindowWithTabViewItem:(ODTabViewItem *)item {
    ODWindow *window = [self newWindow];
    ODTabView *tabView = window.tabView;
    [tabView addTabViewItem:item];
    [tabView selectTabViewItem:item];
}

#pragma mark - Window Actions

- (void)toggleTitlebar:(id)sender {
    BOOL value = [_window isTitlebarHidden];
    _window.titlebarHidden = (value) ? NO : YES;
}

- (void)toggleStatusbar:(id)sender {
    BOOL value = [_window isStatusbarHidden];
    _window.statusbarHidden = (value) ? NO : YES;
}

- (IBAction)toggleTabView:(id)sender {
    BOOL value = [_window isTabViewHidden];
    _window.tabViewHidden = (value) ? NO : YES;
}

- (void)toggleFindBanner:(id)sender {
    if (!_findBanner) {
        _findBanner = [[ODFindBanner alloc] init];
        [_findBanner installBanner];
    } else {
        ([_findBanner isInstalled]) ? [_findBanner uninstallBanner] : [_findBanner installBanner]; 
    }

}

- (void)zoomVertically:(id)sender {
    [_window zoomVertically:sender];
}


#pragma mark - Tab Actions 

- (void)showTabs:(id)sender {
    [_tabSwitcher showPopover:nil];
}

- (void)openTab:(id)sender {
    NSString *addr = @"about:blank";
    if (_windows.count == 0) {
        [self openInNewWindow:addr];
    } else {
        [self openInMainWindow:addr newTab:YES];
    }
}

- (void)closeTab:(id)sender {
    [_window.tabView removeSelectedTabViewItem];
}

- (void)nextTab:(id)sender
{
    [_window.tabView selectNextTabViewItem];
}

- (void)previousTab:(id)sender {
    [_window.tabView selectPreviousTabViewItem];
}


#pragma mark - Navigation Actions

- (void)goForward:(id)sender {
    [self.webView goForward];
}

- (void)goBackward:(id)sender {
    [self.webView goBack];
}

- (void)reloadPage:(id)sender {
    [self.webView reload:nil];
}

- (void)reloadFromOrigin:(id)sender {
    [self.webView reloadFromOrigin:nil];
}

- (void)stopLoad:(id)sender {
    [self.webView stopLoading:nil];
}

- (void)zoomIn:(id)sender {
    float zoom;
    float step;
     WebView *webView = self.webView;
    if ([sender isAlternate]) {
        step = 0.075f;
    } else {
        step = 0.025f;

    }
    if (!_zoomTextOnly) {
         zoom = [webView pageSizeMultiplier];
        [webView setPageSizeMultiplier:zoom + step];
        [_userDefaults setDouble:zoom + step forKey:DEFAULTS_PAGE_ZOOM_KEY];
    } else {
        zoom = [webView textSizeMultiplier];
        [webView setTextSizeMultiplier:zoom + step];
        [_userDefaults setDouble:zoom - step forKey:DEFAULTS_TEXT_ZOOM_KEY];
    }
    
    
}

- (void)zoomOut:(id)sender {
    float zoom;
    float step;
    WebView *webView = self.webView;
    if ([sender isAlternate]) {
        step = 0.075f;
    } else {
        step = 0.025f;
    }
    if (!_zoomTextOnly) {
        zoom = [webView pageSizeMultiplier];
        [webView setPageSizeMultiplier:zoom - step];
        [_userDefaults setDouble:zoom + step forKey:DEFAULTS_PAGE_ZOOM_KEY];
    } else {
        zoom = [webView textSizeMultiplier];
        [webView setTextSizeMultiplier:zoom - step];
        [_userDefaults setDouble:zoom - step forKey:DEFAULTS_TEXT_ZOOM_KEY];
    }
    
    
//    float zoom;
//    float step;
//    WebView *webView = self.webView;
//    
//    if ([sender isAlternate]) {
//        
//        step = 0.075f;
//        [webView zoomPageOut:sender];
//        return;
//        
//    } else {
//        
//        step = 0.025f;
//    }
//        
//        zoom = [webView pageSizeMultiplier];
//        if (zoom < 0.3f) {
//            return;
//        }
//        
//        [webView setPageSizeMultiplier:zoom - step];
        
}

- (void)defaultZoom:(id)sender {
    self.webView.textSizeMultiplier = 1.0;
    [_userDefaults setDouble:1.0 forKey:DEFAULTS_PAGE_ZOOM_KEY];
    [_userDefaults setDouble:1.0 forKey:DEFAULTS_TEXT_ZOOM_KEY];
}

- (void)zoomTextOnly:(id)sender {
//    WebPreferences *prefs = _preferences.preferences;
//    BOOL value = prefs.zoomsTextOnly;
//    [sender setState:value];
//     prefs.zoomsTextOnly = (value) ? NO : YES;
    _zoomTextOnly = (_zoomTextOnly) ? NO : YES;
    [sender setState:_zoomTextOnly];
    [_userDefaults setBool:_zoomTextOnly forKey:DEFAULTS_ZOOM_TEXT_ONLY_KEY];
}

- (void)showDownloads:(id)sender {
    [_downloadManager.view setNeedsDisplay:YES];
    [_downloadManager showPopoverForWindow:_window];
}

- (void)goTo:(id)sender
{
    WebView *view = [self webView];
    
    if (view) {
        
        ODAddressField *aField = [[ODAddressField alloc] init];
        NSString *address = view.mainFrameURL;
        [aField editString:address withReply:^(NSString *address) {
            [view setMainFrameURL:address];
        }];
    }

}

- (void)restartApplication:(id)sender
{
    NSURL *path = [[NSBundle mainBundle] bundleURL];
    if(path){
        [self storeSession];
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:path options:NSWorkspaceLaunchNewInstance configuration:@{} error:nil];
        [NSApp terminate:nil];
    }
}



#pragma mark - Documents

- (void)openUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (_initPath) {
          [self openInMainWindow:urlStr newTab:NO background:NO];
    } else {
        _initPath = urlStr;
    }
  
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL URLWithString:urlStr]];
}

- (void)openDocument:(id)sender
{
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        
        if (result == NSOKButton) {
            
            NSURL *url = openPanel.URL;
            [self openInMainWindow:url.path newTab:YES];
        }
        
    }];
    openPanel = nil;
}

- (void)newDocument:(id)sender
{
    [self openInNewWindow:@"about:blank"];
}

- (void)saveDocumentAs:(id)sender
{
    __block NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"webarchive"]];
    [savePanel setExtensionHidden:YES];
    WebView *view = [self webView];
    NSString *name = [view mainFrameTitle];
    if (name) {
        [savePanel setNameFieldStringValue:name];
    }
    [savePanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        
        
        
        if (result == NSOKButton) {
            
            NSData *data = [self webArchiveDataFromWebView:view];
            NSError *error;
            BOOL result = [data writeToURL:[savePanel URL] options:0 error:&error];
            if (!result) {
                NSAlert  *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
        
        savePanel = nil;
    }];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self openInMainWindow:filename newTab:NO background:NO];
    
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
    return YES;
}

#pragma mark - WebUIDelegate

//- (NSUInteger)webView:(WebView *)webView dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
//{
//    puts("drag");
//    return WebDragDestinationActionDHTML | WebDragDestinationActionEdit | WebDragDestinationActionLoad;
//}

- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags
{
    
    ODWindow *window = (id)sender.window;
    sender.toolTip = nil;
    if (window == _window) {
        NSURL *url = [elementInformation objectForKey:WebElementLinkURLKey];
        if (url) {
            NSString *str = url.absoluteString;
            if (([NSEvent modifierFlags] & NSAlternateKeyMask) && [self canOpenWithMpv:url] && !_shouldUseYtdl) {
                NSTask *task = [[NSTask alloc] init];
                NSPipe *outPipe = [[NSPipe alloc] init];
                task.launchPath = @"/usr/local/bin/ffprobe";
                task.arguments = @[@"-hide_banner", @"-i", str];
                task.standardError = outPipe;
                [task launch];
                NSData *data = [[task.standardError fileHandleForReading] readDataToEndOfFile];
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                sender.toolTip = string;
            }
            ODStatusbar *sbar = _window.statusbar;
            if (![str isEqualToString:_previousStatus] || sbar.alphaValue == 0.0) {
                _previousStatus = str;
                BOOL hasHttpDomain = NO;
                NSRange range = [str rangeOfString:@"http://"];
                if (range.length) {
                    str = [str stringByReplacingCharactersInRange:range withString:@""];
                    hasHttpDomain = YES;
                }
                NSMutableAttributedString *aStatus = [[NSMutableAttributedString alloc] initWithString:str attributes:sbar.attributes];
                if (hasHttpDomain) {
                    range = [str rangeOfString:@"/"];
                    [aStatus addAttribute:NSFontAttributeName value:sbar.boldFont range:NSMakeRange(0, range.location)];
                }
                sbar.attributedStatus = aStatus;
                
            }
        }
    }
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles
{
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:allowMultipleFiles];
    [openPanel setCanChooseDirectories:NO];
    
    
    if([openPanel runModal] == NSOKButton){
        
        [resultListener chooseFilenames:openPanel.filenames];
    }  else {
        [resultListener cancel];
    }
}
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSEventModifierFlags flag = [NSEvent modifierFlags];
    if (flag == NSAlternateKeyMask) {
        [self openInNewWindow:nil];
        return (WebView *)_window.tabView.selectedTabViewItem.view;

    } else {
    ODWindow *window = (id)sender.hostWindow;
    ODTabView *tabView = window.tabView;
    ODTabViewItem *item = [self _setUpWebTabItem];
    
    item.representedObject = request.URL.absoluteString;
    [tabView addTabViewItem:item relativeToSelectedTab:YES];
    return (id)item.view;
    }
  
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *menuItems = [defaultMenuItems mutableCopy];
    NSURL *url = [element objectForKey:WebElementLinkURLKey];
    NSUInteger index = 0;
    
    
    for (NSMenuItem *item in defaultMenuItems) {
        long tag = item.tag;
        
        if (tag == WebMenuItemTagOpenLinkInNewWindow || tag == WebMenuItemTagOpenImageInNewWindow || tag == 2042) {
            NSMenuItem *openInNewTab, *searchImage, *saveImage;
            index = [menuItems indexOfObject:item];
            
            if (tag == WebMenuItemTagOpenImageInNewWindow) {
                openInNewTab = _menuItemList[ODMenuItemImageInNewTab];
                searchImage = _menuItemList[ODMenuItemSearchImage];
                saveImage = _downloadManager.saveImageMenuItem;
                url = [element objectForKey:WebElementImageURLKey];
                openInNewTab.representedObject = url;
                [menuItems insertObject:openInNewTab atIndex:index + 1];
                
                WebFrame *frm = [element objectForKey:WebElementFrameKey];
                WebResource *rsc = [[frm dataSource] subresourceForURL:url];
                if (rsc) {
                    index = [menuItems indexOfObject:openInNewTab];
                    saveImage.representedObject = rsc;
                    searchImage.representedObject = rsc.URL;
                    [menuItems insertObject:saveImage atIndex:index + 1];
                } else {
                    searchImage.representedObject = url;
                }
                 [menuItems insertObject:searchImage atIndex:index + 1];
                
            } else  if (tag == WebMenuItemTagOpenLinkInNewWindow){
                openInNewTab = _menuItemList[ODMenuItemOpenLinkInNewTab];
                index = [menuItems indexOfObject:item];
                openInNewTab.representedObject = url;
                [menuItems insertObject:openInNewTab atIndex:index + 1];
            } else if (tag == 2042) {
                url = [element objectForKey:WebElementMediaURLKey];
            }
            
            item.action = @selector(openInNewWindowMenuItemClicked:);
            item.target = self;
            item.representedObject = url;
            
        } else if (tag == WebMenuItemTagDownloadLinkToDisk || tag == WebMenuItemTagDownloadImageToDisk || tag == 2043) {
           
            if (tag == WebMenuItemTagDownloadImageToDisk) {
                 NSMenuItem *addRule = [_contentFilter addRuleMenuItem];
                 addRule.representedObject = element;
                [menuItems addObject:addRule];
            }
           
            item.action = @selector(downloadMenuItemClicked:);
            item.target = _downloadManager;
            
        } else if (tag == 21) {
            DOMText *text = element[WebElementDOMNodeKey];
#ifdef DEBUG
            NSLog(@"element class %@", [text className]);
#endif
            if ([text respondsToSelector:@selector(wholeText)]) {
                NSString *string = text.wholeText;
                NSRange range = [string rangeOfString:@"http"];
                
                if (range.length == 0) {
                    string = [NSString stringWithFormat:@"http://%@", string];
                }
                url = [NSURL URLWithString:string];
            }
        }
        
    }
    
    if (url) {
        
        if ([self canOpenWithMpv:url]) {
            NSMenuItem *openWithMpv = _menuItemList[ODMenuItemOpenWithMpv];
            openWithMpv.representedObject = url;
            [menuItems addObject:[NSMenuItem separatorItem]];
            [menuItems addObject:openWithMpv];
            NSString *host = url.host;
            NSRange range = [host rangeOfString:@"youtu"];
            if (_shouldUseYtdl && range.length) {
                NSMenuItem *ytdl = [_downloadManager ytdlMenuItem];
                ytdl.representedObject = url;
                [menuItems addObject:ytdl];
            }
        }
        
    }
       return menuItems;
}

//- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
//{
//    NSMutableArray *menuItems = [defaultMenuItems mutableCopy];
//    for (NSMenuItem *item in defaultMenuItems) {
//        long tag = item.tag;
//        if (tag == WebMenuItemTagOpenLinkInNewWindow) {
//            //   [menuItems replaceObjectAtIndex:[defaultMenuItems indexOfObject:item] withObject:item];
//            [item setAction:@selector(openInNewWindow:)];
//            [item setTarget:self];
//            NSMenuItem *openTab = [[NSMenuItem alloc] initWithTitle:@"Open Link in New Tab" action:@selector(openInNewTab:) keyEquivalent:@""];
//            [openTab setTarget:self];
//            [openTab setRepresentedObject:element];
//            [menuItems insertObject:openTab atIndex:2];
//            
//            NSURL *url = [element objectForKey:WebElementLinkURLKey];
//            
//            if ([self canOpenWithMpv:url]) {
//                
//                _openWithMpvMenuItem.representedObject = url;
//                [menuItems addObject:[NSMenuItem separatorItem]];
//                [menuItems addObject:_openWithMpvMenuItem];
//            }
//            
//        } else if (tag == WebMenuItemTagDownloadLinkToDisk) {
//            
//            [item setAction:@selector(startDownloadingURL:)];
//            [item setTarget:manager];
//        } else if (tag == WebMenuItemTagOpenImageInNewWindow) {
//            
//            //  [menuItems replaceObjectAtIndex:[defaultMenuItems indexOfObject:item] withObject:item];
//            [item setAction:@selector(openInNewWindow:)];
//            [item setTarget:self];
//            [item setTag:100];
//            NSMenuItem *openTab = [[NSMenuItem alloc] initWithTitle:@"Open Image in New Tab" 
//                                                             action:@selector(openInNewTab:) 
//                                                      keyEquivalent:@""];
//            [openTab setTarget:self];
//            [openTab setRepresentedObject:element];
//            [openTab setTag:100];
//            [menuItems insertObject:openTab atIndex:[menuItems indexOfObject:item] + 1];
//            NSURL *url = [element objectForKey:@"WebElementImageURL"];
//            WebFrame *frm = [element objectForKey:@"WebElementFrame"];
//            WebResource *rsc =    [[frm dataSource] subresourceForURL:url];
//            if (rsc) {
//                NSMenuItem *saveImage = [manager saveImage];
//                saveImage.representedObject = rsc;
//                [menuItems insertObject:saveImage atIndex:[menuItems indexOfObject:openTab]];
//            }
//            
//            
//            
//            
//        } else if (tag == WebMenuItemTagDownloadImageToDisk || tag == 2043){
//            [item setAction:@selector(startDownloadingURL:)];
//            [item setTarget:manager];
//            
//            [menuItems addObject:[_contentBlocker elementHideItemWithRepObj:element]];
//            
//        } else if (tag == 2042) {
//            
//            [item setAction:@selector(openInNewWindow:)];
//            [item setTarget:self];
//        } else if (tag == 21) {
//            
//            DOMText *text = element[@"WebElementDOMNode"];
//#ifdef DEBUG
//            NSLog(@"element class %@", [text className]);
//#endif
//            if ([text respondsToSelector:@selector(wholeText)]) {
//                
//                NSString *string = text.wholeText;
//                NSRange range = [string rangeOfString:@"http"];
//                if (range.length == 0) {
//                    string = [NSString stringWithFormat:@"http://%@", string];
//                }
//                NSURL *url = [NSURL URLWithString:string] ;
//                if (url) {
//                    if ([self canOpenWithMpv:url]) {
//                        NSMenuItem *play = [[NSMenuItem alloc] initWithTitle:@"Play With MPV" action:@selector(openWithMpv:) keyEquivalent:@""];
//                        play.target = self;
//                        play.representedObject = url;
//                        [menuItems addObject:[NSMenuItem separatorItem]];
//                        [menuItems addObject:play];
//                    }
//                    
//                }
//                
//            }
//            
//            
//        }
//        
//        
//    }
//    
//    //    [menuItems addObject:[[ODContentBlocker shared] elementHideItemWithRepObj:element]];
//    //    [menuItems addObject:[[ODContentBlocker shared] contextItemForFrame:sender.mainFrame]];
//    
//    
//    
//    
//    return menuItems;
//}

- (void)webViewClose:(WebView *)sender
{
    ODWindow *window = (id)sender.hostWindow;
    ODTabView *tabView = window.tabView;
    NSUndoManager *undo = window.undoManager;
    NSString *url = [sender mainFrameURL];
    
    [undo registerUndoWithTarget:self
                        selector:@selector(openInMainWindow:)
                          object:url];
    [undo setActionName:@"Close Tab"];
    [tabView removeTabViewItemWithView:sender];
}

- (void)webViewShow:(WebView *)sender
{
    sender.groupName = @"Popup";
}

- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender {
    
    NSString *selector = NSStringFromSelector(action);
    NSLog(@"sender: %@\nselector: %@", sender, selector);
    return YES;
}


#pragma mark - Web Frame Load Delegate
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
  /*   NSURL *URL = [error.userInfo objectForKey:NSURLErrorFailingURLErrorKey];
    
    if (error.code == WebKitErrorCannotShowMIMEType) {        
        

    } else */ if (error.code != WebKitErrorFrameLoadInterruptedByPolicyChange) {
        NSURL *URL = [error.userInfo objectForKey:NSURLErrorFailingURLErrorKey];
        NSString *localizedDescription = error.localizedDescription;
    
[frame loadAlternateHTMLString:[NSString stringWithFormat:@"<style>body{font-family:Verdana; font-size:14px; text-align:center;}</style> <h3>This page cannot be displayed</h3>"
                                @"<a href=\"%@\"> %@"
                                @"</a> <br><br> %@",
                                URL, URL,
                                localizedDescription]
                       baseURL:URL
             forUnreachableURL:URL];

//        ODWindow *win = (id)sender.window;
//        ODTabView *tv = win.tabView;
//        [tv tabViewItemWithView:sender].label = localizedDescription;
        
    }
  
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    [_history addItemWithTitle:title address:sender.mainFrameURL];
     ODWindow *window = (id)sender.hostWindow;
    if (window.tabView.selectedTabViewItem.view == sender) {
        [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
    }
    
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    ODWindow *window = (id)sender.hostWindow;
    [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
//    if (window.tabView.selectedTabViewItem.view == sender) {
//        [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
//    }
    
    NSURL *URL = frame.dataSource.initialRequest.URL;
    
    if ([_contentFilter isInsecure:URL domain:URL.host]) {
        [frame stopLoading];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    ODWindow *window = (id)sender.hostWindow;
   // NSString *title = sender.mainFrameTitle;
    [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
//    if (window.tabView.selectedTabViewItem.view == sender) {
//        [self setTitle:title forWindow:window webView:sender];
//    } else {
//        ODTabViewItem *item = [window.tabView tabViewItemWithView:sender];
//        item.label = title;
//    }
}
- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
    ODWindow *window = (id)sender.hostWindow;
    [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
//    if (window.tabView.selectedTabViewItem.view == sender) {
//        [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
//    }
}


#pragma mark - Web Resource Load Delegate
- (NSURLRequest *)webView:(WebView *)sender 
                 resource:(id)identifier 
          willSendRequest:(NSURLRequest *)request 
         redirectResponse:(NSURLResponse *)redirectResponse 
           fromDataSource:(WebDataSource *)dataSource
{
//    NSEventModifierFlags flag = [NSEvent modifierFlags];
//    if (flag == NSCommandKeyMask) {
//        [self openInMainWindow:originalURL.absoluteString newTab:YES background:YES];
//        (void)frame.stopLoading;
//    } else if (flag == NSAlternateKeyMask) {
//        [self openInNewWindow:originalURL.absoluteString];
//        (void)frame.stopLoading;
//    } else
    
    if (![_contentFilter isPaused]) {
        NSString *domain = [NSURL URLWithString:sender.mainFrameURL].host;
         request = [_contentFilter newRequestFrom:request dataSource:dataSource domain:domain];
    }
   
      ODWindow *window = (id)sender.hostWindow;
    if (window.tabView.selectedTabViewItem.view == sender) {
        [self setTitle:sender.mainFrameTitle forWindow:window webView:sender];
    }
    
    return request;  
}

- (void)setTitle:(NSString *)title forWindow:(ODWindow *)window webView:(WebView *)webView
{
    if (title.length == 0) {
        title = webView.mainFrameURL;
    }
    if (webView.loading) {
        title = [NSString stringWithFormat:@"(%.0f%%) %@", webView.estimatedProgress * 100, title];
    }
    [window setTitle:title];
    ODTabView *tabView = window.tabView;
    ODTabViewItem *item = [tabView tabViewItemWithView:webView];
    item.label = title;
    [tabView setNeedsDisplay:YES];
    //window.tabView.selectedTabViewItem.label = title;
}

#pragma mark - Web Policy Delegate

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
    NSURL *URL = [error.userInfo objectForKey:NSURLErrorFailingURLErrorKey];
    if (error.code == WebKitErrorCannotShowMIMEType) { 
        if ([[URL pathExtension] isEqualToString:@"webm"]) {
            [self openWithMpv:URL];
            
        } else {
            
            [_downloadManager newDownloadWithURL:URL];
        }
    } else {
        NSLog(@"unableToImplementPolicyWithError: %@ URL: %@", error.localizedDescription, URL); 
    }
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
//    if (![WebView canShowMIMEType:type]) {
//        NSURL *URL = request.URL;
//        
//        
//    }
        [listener use];
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSURL *originalURL = actionInformation[WebActionOriginalURLKey];
    BOOL ignored = NO;
    if (![_contentFilter isPaused]) {
        if ([_contentFilter isInsecure:originalURL domain:originalURL.host]) {
            [listener ignore];
            ignored = YES;
#ifdef DEBUG
            NSLog(@"decidePolicyForNewWindowAction: %@ insecure URL detected! Closing tab...", originalURL);
#endif
        }    
    }
    
    if (!ignored) {
        [listener use];
    }
}

- (void)webView:(WebView *)sender 
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request 
          frame:(WebFrame *)frame 
decisionListener:(id)listener {

    NSUInteger navigationType = [actionInformation[WebActionNavigationTypeKey] unsignedIntegerValue];
    BOOL ignored = NO;
    
    if (navigationType == WebNavigationTypeLinkClicked) {
        NSURL *originalURL = actionInformation[WebActionOriginalURLKey];
        NSEventModifierFlags flag = [NSEvent modifierFlags];
        if (flag == NSCommandKeyMask) {
            [self openInMainWindow:originalURL.absoluteString newTab:YES background:YES];
            (void)frame.stopLoading;
            [listener ignore];
            ignored = YES;
        } else if (flag == NSAlternateKeyMask) {
            [self openInNewWindow:originalURL.absoluteString];
            (void)frame.stopLoading;
            [listener ignore];
            ignored = YES;
        } else if (flag == NSShiftKeyMask) {
            [_downloadManager newDownloadWithURL:originalURL];
            (void)frame.stopLoading;
            [listener ignore];
            ignored = YES;
            
        } else if (![_contentFilter isPaused]) {
            if ([_contentFilter isInsecure:originalURL domain:originalURL.host]) {
                [listener ignore];
                ignored = YES;
            } 
        }
    }
    
    if (!ignored) {
        [listener use];
    }
    
//    NSString *groupName = sender.groupName;
//    NSURL *URL = request.URL;
//    if ([groupName isEqualToString: @"Popup"]) {
//#ifdef DEBUG
//        NSLog(@"decidePolicyForNavigationAction: checking URL - %@", URL);
//#endif
//        if (![_contentFilter isPaused]) {
//            NSString *domain = URL.host;
//            if([_contentFilter isInsecure:URL domain:domain]) {
//#ifdef DEBUG
//                NSLog(@"decidePolicyForNavigationAction: insecure URL detected! Closing tab...");
//#endif
//                ODWindow *window = (id)sender.hostWindow;
//                ODTabView *tabView = window.tabView;
//                [tabView removeTabViewItemWithView:sender];
//            };
//        }
//    }
//    [listener use];
    
}
#pragma mark - ODTabSwitcherDelegate
- (void)openNewTab {
    [self openTab:nil];
}

#pragma mark - ODTabViewDelegate

- (void)tabView:(ODTabView *)tabView willSelectTabViewItem:(ODTabViewItem *)item {
//    NSView *view = tabView.selectedTabItem.view;
//    [view removeFromSuperview];
}

- (void)tabView:(ODTabView *)tabView didSelectTabViewItem:(ODTabViewItem *)item {

    ODWindow *window = (ODWindow *)tabView.window;
    NSView *view = item.view;
    if (item.tag == ODWebTabNewTag) {
        [(id)view setMainFrameURL:item.representedObject];
        item.tag = ODWebTabLoadedTag;
    }       
    //[window setTitlebarInfo:tabView.info];
    [window setContentView:view];
    [window makeFirstResponder:view];
    NSString *label = item.label;
    if (window.titlebarHidden) {
        [window.statusbar setStatus:[NSString stringWithFormat:@"Tab %lu of %lu '%@'",
                           [tabView indexOfTabViewItem:item] + 1,
                           tabView.numberOfTabViewItems,
                           label]];
        
        //window.titlebarHidden = NO;
    }
        [window setTitle:label];
    
}

- (void)tabView:(ODTabView *)tabView willRemoveTabViewItem:(ODTabViewItem *)item {
    [item.view removeFromSuperview];
}

- (void)tabView:(ODTabView *)tabView didRemoveTabViewItem:(ODTabViewItem *)item {
    //[tabView.window setTitlebarInfo:tabView.info];
    if (item.type == ODTabTypeDefault) {
        WebView *webView = (id)item.view;
        [webView setMaintainsBackForwardList:NO];
        [webView close];
    }

}

- (void)tabView:(ODTabView *)tabView willAddTabViewItem:(ODTabViewItem *)item {}

- (void)tabView:(ODTabView *)tabView didAddTabViewItem:(ODTabViewItem *)item {
     //[tabView.window setTitlebarInfo:tabView.info];
}

- (void)tabView:(ODTabView *)tabView tabViewList:(NSArray *__autoreleasing *)tabViewList {

    NSMutableArray *tvList = [[NSMutableArray alloc] init];
    for (ODWindow *w in _windows) {
        [tvList addObject:w.tabView];
    }
    *tabViewList = tvList;
}

- (BOOL)tabView:(ODTabView *)tabView shouldMoveTabViewItem:(ODTabViewItem *)item to:(ODTabView **)newTabView {
    
    ODWindow *window = [self newWindow];
    //ODTabView *tv = window.tabView;
    *newTabView = window.tabView;
    
    return YES;
}

- (void)tabView:(ODTabView *)tabView didMoveTabViewItem:(ODTabViewItem *)item to:(ODTabView *)tv {
    WebView *wView = (id)item.view;
    wView.hostWindow = tv.window;
}

#pragma mark - ODSessionManagerDelegate

- (void)sessionManager:(ODSessionManager *)manager restoreSession:(ODSessionItem *)item {
    [self storeSession];
    for (ODWindow *w in _windows.copy) {
        [w performClose:nil];
    }
    [self restoreSessionArray:item.sessionArray];
}
- (void)sessionManager:(ODSessionManager *)manager storeSession:(ODSessionItem **)item {
    ODSessionItem *i = [[ODSessionItem alloc] init];
    i.name = _sessionName();
    i.sessionArray = [self sessionArray];
    *item = i;
}

#pragma mark - NSNotifications

- (void)windowWillClose:(NSNotification *)notification {
    NSWindow * win = notification.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:win];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:win];

    [_windows removeObject:win];
    if ([_window isEqualTo:win]) {
        _window = nil;
    }
    
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    _window = notification.object;
    
}


#pragma mark - Private

- (WebView *)webView {
    ODTabViewItem *item = _window.tabView.selectedTabViewItem;
    if (item.type == ODTabTypeDefault) {
        return (WebView *)item.view;
    }
    
    return nil;
}

- (NSData *)webArchiveDataFromWebView:(WebView *)view {
    NSData *data;
    WebDataSource *dataSource = [view.mainFrame dataSource];
    data = dataSource.webArchive.data;
    return data;
}

- (id)_setUpWebTabItem {
    WebView *view = [[WebView alloc] init];
    [view setUIDelegate:self];
    [view setFrameLoadDelegate:self];
    //[view setDownloadDelegate:self];
    [view setResourceLoadDelegate:self];
    [view setPolicyDelegate:self];
    [view setGroupName:@"Odyssey"];
    
    //NSWindow *window = window;
    [view setHostWindow:_window];
    
    NSView *contentView = _window.contentView;
    //[contentView addSubview:view positioned:NSWindowBelow relativeTo:contentView];
    NSRect frame = contentView.frame;
    [view setFrame:NSMakeRect(0, 0, NSWidth(frame), NSHeight(frame))];
    [view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    view.shouldUpdateWhileOffscreen = NO;
    view.customUserAgent = _preferences.userAgentString;
    view.textSizeMultiplier = [_userDefaults doubleForKey:DEFAULTS_TEXT_ZOOM_KEY];
    view.pageSizeMultiplier = [_userDefaults doubleForKey:DEFAULTS_PAGE_ZOOM_KEY];
    ODTabViewItem *result = [[ODTabViewItem alloc] initWithView:view];
    result.type  = ODTabTypeDefault;
    result.tag = ODWebTabNewTag;
    
    return result;
    
}


- (void)_setUpWindow:(ODWindow *)window {
    [_windows  insertObject:window atIndex:0];
    window.auxButton.action = @selector(showDownloads:);
    window.auxButton.target = self;
   
//    [window setReleasedWhenClosed:NO];
//    [window setMovableByWindowBackground:YES];
//    

//    if (![window isRestorable]) {
//        NSRect frame = window.frame;
//        [window setFrame:NSMakeRect(NSMinX(frame), NSMinY(frame), 800, 600) display:NO animate:NO];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeMain:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:window];
    
    
    
}
@end
