//
//  ODWindowController.m
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWindowController.h"
#import "ODWebView.h"
//#import "ODTabController.h"
//#import "ODUnifiedFieldController.h"
#import "ODTabBar.h"
#import "ODTabSwitcher.h"
#import "ODStatusBar.h"
#import "ODSearchForController.h"

#import "ODController.h"
#import "ODContentBlocker.h"
#import "ODWebDownloadManager.h"
#import "AppDelegate.h"
#import "ODWindowTitleBar.h"
//#import <zlib.h>

void ODLog(NSString *s);

@interface ODWindowController ()<NSWindowDelegate, WebUIDelegate, WebFrameLoadDelegate, WebDownloadDelegate, WebResourceLoadDelegate, WebPolicyDelegate>
{
    //    NSMutableArray *_tabs;
    //    NSUInteger _activeTabIdx;
    // ODTabController *_tabsCtl;
    ODTabBar *_tabBar;
    //IBOutlet ODUnifiedFieldController *_unifiedField;
    IBOutlet ODSearchForController *_searchFor;
    
    ODStatusBar *_statusBar;
    ODWindowTitleBar *_titleBar;
    
    
    //    BOOL _legacyWindow;
    //    NSTextField *_winTitle;
    
    
    
}

@end

@implementation ODWindowController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"ODWindowController"];
    if (self) {
        // self->_tabs = [NSMutableArray new];
        //self->_tabsCtl = [[ODTabController alloc] init];
        self->_tabBar = [[ODTabBar alloc] init];
        //        
        //       NSButton *a = [self.window standardWindowButton:NSWindowCloseButton];
        //        NSView *v = a.superview;
        
        //        [self.window setStyleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask];
    }
    return self;
}

-(void)close
{
    //[_tabsCtl closeAllTabs:self];
    [_tabBar closeAllTabs];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setDelegate:self];
    //    [self.window setFrame:NSMakeRect(0, 0, 800, 600) display:NO];
    //    [self.window center];
    _statusBar = [[ODStatusBar alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.window.contentView.frame), 24)];
    //[self.window.contentView addSubview:_statusBar];
    [self.window.contentView addSubview:_statusBar positioned:NSWindowAbove relativeTo:nil];
    //[_tabBar setWindow:self.window];
    
    _titleBar = [[ODWindowTitleBar alloc] init];
    [_titleBar loadView];
    
                NSButton *a = [self.window standardWindowButton:NSWindowCloseButton];
                NSView *v = a.superview;
    [v addSubview:_titleBar.view];
    NSRect frame = v.frame;
    [_titleBar.view setFrame:NSMakeRect(65, NSHeight(frame) - 22, NSWidth(frame) - 65, 22)];
//    [_titleBar.view setFrameOrigin:NSMakePoint(65, 0)];
    //[self openTab];
    //[_unifiedField validate];
    
    //    if([self.window respondsToSelector:@selector(setTitleVisibility:)])
    //    {
    //            //[self.window setTitleVisibility:  NSWindowTitleHidden];
    //            //self.window.styleMask |= NSFullSizeContentViewWindowMask;
    ////             self.window.styleMask |= NSTexturedBackgroundWindowMask;
    ////             self.window.backgroundColor = [NSColor blackColor];
    //      
    //        
    //    }
    
    //            NSButton *a = [self.window standardWindowButton:NSWindowCloseButton];
    //            NSView *v = a.superview;
    //    for (id a  in v.subviews) {
    //        if ([a isKindOfClass:[NSTextField class]]) {
    //            _winTitle = a;
    //        }
    //    }
    //    
    //    self.window.toolbar.visible = NO;
    
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Actions

-(void)loadURL:(NSString *)url
{
    //    [[_tabs objectAtIndex:_activeTabIdx] setMainFrameURL:url];
    //    if (![_tabsCtl activeTabObject]) {
    //        [self openTab];
    //    }
    //    [[_tabsCtl activeTabObject] setMainFrameURL:url];
    WebView *view = [_tabBar activeTab];
    if (!view) {
        
        [self openTabWithAddress:url];
        
    } else {
        [view setMainFrameURL:url];
    }
}
//
//-(void)goTo:(id)sender
//{
//    BOOL(^checkString)(id, id) = ^(NSString *arg0, NSString *arg1) {
//        NSRange range = [arg0 rangeOfString:arg1 options:NSCaseInsensitiveSearch];
//        if (range.length) {
//            return YES;
//        }
//        return NO;
//};
//    NSString *request = [sender stringValue];
//    if (checkString(request, @".")) {
//        if (checkString(request, @"http") || checkString(request, @"file")) {
//            [self loadURL:request];
//        } else {
//            NSString *newReq = [NSString stringWithFormat:@"http://%@", request];
//            [self loadURL:newReq];
//        }
//        
//    } else {
//        request = [request stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *searchReq = @"https://www.google.com/search?client=safari&rls=en&q={searchTerms}&ie=UTF-8&oe=UTF-8";
//        searchReq = [searchReq stringByReplacingOccurrencesOfString:@"{searchTerms}" withString:request];
//         [self loadURL:searchReq];
//    }
//   
//}

-(void)showSearchDocument:(id)sender
{
    //   NSArray *subvs = [_tabsCtl.activeTabObject subviews];
    
    
    [self.window.contentView addSubview:_searchFor.view positioned:NSWindowAbove relativeTo:self.window.contentView];
    if ([_searchFor.view isHidden]) {
        [_searchFor.view setHidden:NO];
    }
    
    [_searchFor.view setFrameSize:NSMakeSize(NSWidth(self.window.contentView.frame), 28)];
    [_searchFor.view setFrameOrigin:NSMakePoint(0, NSHeight(self.window.contentView.frame) - NSHeight(_searchFor.view.frame))];
    
    [_searchFor.view setNeedsDisplay:YES];
    [self.window makeFirstResponder:_searchFor.searchField];
    
    //    NSView *titleBar = [self.window performSelector:@selector(titleBarView)];
    //   
    //    [titleBar setFrame:NSMakeRect(NSMinX(titleBar.frame), NSMinY(titleBar.frame) - NSHeight(_searchFor.view.frame),
    //                                  NSWidth(titleBar.frame),
    //                                  NSHeight(titleBar.frame) + NSHeight(_searchFor.view.frame))];
    //    [titleBar addSubview:_searchFor.view positioned:NSWindowAbove relativeTo:nil];
    //     [_searchFor.view setNeedsDisplay:YES];
}

-(void)closeSearchDocument:(id)sender
{
    [_searchFor.view removeFromSuperview];
}

-(void)searchForward:(id)sender
{
    
    //    [[_tabsCtl activeTabObject] searchFor:[_searchFor searchString] direction:YES caseSensitive:NO wrap:YES];
    [[_tabBar activeTab] searchFor:[_searchFor searchString] direction:YES caseSensitive:NO wrap:YES];
    
    
}

-(void)searchBackward:(id)sender
{
    //    [[_tabsCtl activeTabObject] searchFor:[_searchFor searchString] direction:NO caseSensitive:NO wrap:YES];
    [[_tabBar activeTab] searchFor:[_searchFor searchString] direction:NO caseSensitive:NO wrap:YES];
}

-(WebView *)mainWebView
{
    //return [_tabsCtl activeTabObject];
    return [_tabBar activeTab];
}

-(id)tabBar
{
    return _tabBar;
}

-(id)titleBar
{
    return _titleBar;
}

-(void)openInNewWindow:(id)sender
{
    NSDictionary *repObj = [sender representedObject];
    NSURL *url;
    if ([sender tag] == 100) {
        url = [repObj objectForKey:@"WebElementImageURL"];
    } else {
        url = [repObj objectForKey:@"WebElementLinkURL"];
    }
    NSString *addr = [url absoluteString];
    ODController *ctl = [[NSApp delegate] controller];
    [ctl newWindowWithAddress:addr];
}

-(void)openInNewTab:(id)sender
{
    NSDictionary *repObj = [sender representedObject];
    NSURL *url;
    if ([sender tag] == 100) {
        url = [repObj objectForKey:@"WebElementImageURL"];
    } else {
        url = [repObj objectForKey:@"WebElementLinkURL"];
    }
    NSString *addr = [url absoluteString];
    [self openBackgroundTabWithAddress:addr];
}

#pragma mark - Tabs

-(void)_setUpWebView:(ODWebView *)view
{
    [view setUIDelegate:self];
    [view setFrameLoadDelegate:self];
    //[view setDownloadDelegate:self];
    [view setResourceLoadDelegate:self];
    [view setPolicyDelegate:self];
    [view setGroupName:@"Odyssey"];
    [view setHostWindow:self.window];
    
    //[self.window.contentView addSubview:view positioned:NSWindowBelow relativeTo:self.window.contentView];
    NSRect frame = self.window.contentView.frame;
    [self.window.contentView addSubview:view];
    if ([[ODTabSwitcher switcher] isSidebarOpen]) {
        [view setFrame:NSMakeRect(200, 0, NSWidth(frame) - 200, NSHeight(frame))];
    } else {
        
        [view setFrame:NSMakeRect(0, 0, NSWidth(frame), NSHeight(frame))];
    }
    
    [view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    
}

-(void)openTab
{
    ODWebView *view = [[ODWebView alloc] init];
    [self openTabWithWebView:view];
    //    [self _setUpWebView:view];
    //
    //    
    //    //[_unifiedField setTitle:@"Empty Tab"];
    //    //[_unifiedField setAddress:@""];
    //    
    //    
    //        //    [_tabs insertObject:view atIndex:0];
    //        //    _activeTabIdx = 0;
    //    
    ////    [_tabsCtl newTabWithObject:view];
    //    [_tabBar openTabWithObject:view background:NO];
    //    [self updateTitle];
}

-(void)openTabWithWebView:(WebView *)view
{
    [self _setUpWebView:(ODWebView *)view];
    //    [_tabsCtl newTabWithObject:view];
    [_tabBar openTabWithObject:view background:NO];
    [self updateTitle];
}

-(WebView *)openBackgroundTabWithAddress:(NSString *)addr
{
    ODWebView *view = [[ODWebView alloc] init];
    [self _setUpWebView:view];
    [view setHidden:YES];
    [view setMainFrameURL:addr];
    
    [view removeFromSuperview];
    
    //    [_tabsCtl newBackgroundTabWithObject:view];
    [_tabBar openTabWithObject:view background:YES];
    [self updateTitle];
    return view;
}

-(void)closeTab:(id)sender
{
    [_tabBar closeActiveTab];
    [self updateTitle];
    //   [_tabsCtl closeTab:sender];
}

-(void)openTabWithAddress:(NSString *)address
{
    [self openTab];
    [self loadURL:address];
}

-(void)showTabs
{
    // [_tabsCtl popUpMenu];
}

-(NSArray *)tabsList
{
    return [_tabBar sessionArray];
    //    return [_tabsCtl tabsArray];
}

-(void)setTabList:(NSArray *)list
{

    [_tabBar restoreSession:list forWindow:self.window];
}

-(void)updateTitle
{

    NSString *title = [_tabBar info];
    [_titleBar setTitle:title icon:_tabBar.activeTab.mainFrameIcon tabInfo:_tabBar.tabInfo];
    [_titleBar.view setNeedsDisplay:YES];
    //self.window.title = title;
    //[_winTitle setStringValue:title];
    //[_unifiedField setTitle:title];
}

-(void)updateStatusBar
{
    [self.window.contentView addSubview:_statusBar];
    //    [self.window.contentView addSubview:_statusBar positioned:NSWindowAbove relativeTo:nil];
    [_statusBar setNeedsDisplay:YES];
}

-(BOOL)canPlayWithMpv:(NSURL *)url
{
#ifdef DEBUG
    NSLog(@"checking URL: %@", url);
#endif
    
    

    NSString *string = url.absoluteString;
    NSRange range = [string rangeOfString:@"youtube.com/watch"];
    if (range.length) {
        return YES;
    }
    range = [string rangeOfString:@"youtu.be/"];
    if (range.length) {
        return YES;
    }
    
    range = [string rangeOfString:@"vimeo.com/"];
    if (range.length) {
        return YES;
    }
    
    string = url.pathExtension;
    if ([string isEqualToString:@"webm"] 
        || [string isEqualToString:@"mp3"] 
        || [string isEqualToString:@"mp4"] 
        || [string isEqualToString:@"ogg"]) {
        
        return YES;
    }
    
    return NO;
}
-(void)playWithMpv:(id)sender;
{
    NSURL *url;
    if ([sender respondsToSelector:@selector(representedObject)]) {
        url = [sender representedObject];
    } else {
        url = sender;
    }

    
    NSString *cmd = [NSString stringWithFormat:@"/usr/local/bin/mpv --loop=yes \"%@\" &", url];
    const char *str = cmd.UTF8String;
#ifdef DEBUG
    if (str) {
          NSLog(@"playing URL with MPV: %@  cmd: %s", url, str);
    } else {
        
        NSLog(@"playWithMpv: failed - cmd is NULL");
    }
  
#endif
   
   NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"io.mpv"];
    if (appURL) {
        NSArray *option = @[@"--loop=yes", url.absoluteString];
        NSError *error = nil;
            [[NSWorkspace sharedWorkspace] launchApplicationAtURL:appURL 
                                                          options:NSWorkspaceLaunchAsync | NSWorkspaceLaunchNewInstance
                                                    configuration:@{NSWorkspaceLaunchConfigurationArguments:option} 
                                                            error:&error];
        if (error) {
            
            NSLog(@"playwithMpv: failed \n%@", error.localizedDescription);
        }
    } else {
        
         system(str);
    }
    

    
//    if (NSAppKitVersionNumber > NSAppKitVersionNumber10_9) {
////        [[NSWorkspace sharedWorkspace] openURLs:@[url] 
////                        withAppBundleIdentifier:@"io.mpv" 
////                                        options:NSWorkspaceLaunchAsync 
////                 additionalEventParamDescriptor:nil 
////                              launchIdentifiers:nil];
//    } else {
//        
//        NSString *cmd = [NSString stringWithFormat:@"/usr/local/bin/mpv %@&", url];
//        system(cmd.UTF8String);
//    }
}

#pragma mark - Events


-(void)keyDown:(NSEvent *)theEvent
{
    //    if (theEvent.keyCode == 50 && [NSEvent modifierFlags] == (NSShiftKeyMask | NSControlKeyMask)) {
    //        
    //        //[_tabsCtl popUpMenu];
    //    }
    
    if ([NSEvent modifierFlags] == NSCommandKeyMask) {
        u_short keyCode = [theEvent keyCode];
        u_long idx = 9;
        switch (keyCode) {
            case 18:
                idx = 0;  //    char: 1 
                break;
            case 19:
                idx = 1;  //    char: 2 
                break;
            case 20:
                idx = 2;  //    char: 3 
                break;
            case 21:
                idx = 3;  //    char: 4 
                break;
            case 23:
                idx = 4;  //    char: 5
                break;
            case 22:
                idx = 5;  //    char: 6
                break;
            case 26:
                idx = 6;  //    char: 7 
                break;
            case 28:
                idx = 7;  //    char: 8 
                break;
            case 25:
                idx = 8;  //    char: 9 
                break;
                
                
            default:
                break;
        }
        
        u_long count = _tabBar.tabList.count;
        if (count > idx && idx != 9) {
            
            [_tabBar selectTabAtIndex:idx];
            
        }
    }
    
    
    //
    //            NSLog(@"KeyUp:"
    //                  @"       \nchar: %@"
    //                  @"   \nmodifier: %lu"
    //                  @"    \nkeyCode: %i"
    //                  @"\nglobal mask: %lu", [theEvent characters], (unsigned long)[theEvent modifierFlags], [theEvent keyCode], [NSEvent modifierFlags]);
}

#pragma mark - Delegates

#pragma mark - Web Download Delegate


#pragma mark - Web UI Delegate

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles 
{
    NSOpenPanel *OpnPanel = [NSOpenPanel openPanel];
    
    [OpnPanel setCanChooseFiles:YES];
    [OpnPanel setAllowsMultipleSelection:allowMultipleFiles];
    [OpnPanel setCanChooseDirectories:NO];
    
    
    if([OpnPanel runModal] == NSOKButton){
        
        [resultListener chooseFilenames:[OpnPanel filenames]];
    }  else {
        [resultListener cancel];
    }
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    return [self openBackgroundTabWithAddress:request.URL.absoluteString];
    //return sender;
}

-(void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags
{
    NSString *str =  [[elementInformation objectForKey:@"WebElementLinkURL"] absoluteString];
    
    if (str) {
        
//        [_statusBar setStatus:str];
//        [_statusBar setHidden:NO];
//        [self.window.contentView addSubview:_statusBar];
        //[_titleBar setTitle:str];
        [_titleBar setStatus:str];

        
    } else {
        
//        [_statusBar setHidden:YES];
//        [_statusBar removeFromSuperview];
        //[_titleBar setTitle:sender.mainFrameTitle];
        [_titleBar setStatus:nil];
        
    }
    
    //[_statusBar setNeedsDisplay:YES];
    [_titleBar.view setNeedsDisplay:YES];
    
    //[self updateStatusBar];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *menuItems = [defaultMenuItems mutableCopy];
    ODWebDownloadManager *manager = [ODWebDownloadManager sharedManager];
    for (NSMenuItem *item in defaultMenuItems) {
        long tag = item.tag;
        if (tag == WebMenuItemTagOpenLinkInNewWindow) {
            //   [menuItems replaceObjectAtIndex:[defaultMenuItems indexOfObject:item] withObject:item];
            [item setAction:@selector(openInNewWindow:)];
            [item setTarget:self];
            NSMenuItem *openTab = [[NSMenuItem alloc] initWithTitle:@"Open Link in New Tab" action:@selector(openInNewTab:) keyEquivalent:@""];
            [openTab setTarget:self];
            [openTab setRepresentedObject:element];
            [menuItems insertObject:openTab atIndex:2];
            
            NSURL *url = [element objectForKey:WebElementLinkURLKey];
            
            if ([self canPlayWithMpv:url]) {
                NSMenuItem *play = [[NSMenuItem alloc] initWithTitle:@"Play With MPV" action:@selector(playWithMpv:) keyEquivalent:@""];
                play.target = self;
                play.representedObject = url;
                [menuItems addObject:[NSMenuItem separatorItem]];
                [menuItems addObject:play];
                
            }
            
        } else if (tag == WebMenuItemTagDownloadLinkToDisk) {
            
            [item setAction:@selector(startDownloadingURL:)];
            [item setTarget:manager];
        } else if (tag == WebMenuItemTagOpenImageInNewWindow) {
            
            //  [menuItems replaceObjectAtIndex:[defaultMenuItems indexOfObject:item] withObject:item];
            [item setAction:@selector(openInNewWindow:)];
            [item setTarget:self];
            [item setTag:100];
            NSMenuItem *openTab = [[NSMenuItem alloc] initWithTitle:@"Open Image in New Tab" 
                                                             action:@selector(openInNewTab:) 
                                                      keyEquivalent:@""];
            [openTab setTarget:self];
            [openTab setRepresentedObject:element];
            [openTab setTag:100];
            [menuItems insertObject:openTab atIndex:[menuItems indexOfObject:item] + 1];
            NSURL *url = [element objectForKey:@"WebElementImageURL"];
            WebFrame *frm = [element objectForKey:@"WebElementFrame"];
            WebResource *rsc =    [[frm dataSource] subresourceForURL:url];
            if (rsc) {
                NSMenuItem *saveImage = [manager saveImage];
                saveImage.representedObject = rsc;
                [menuItems insertObject:saveImage atIndex:[menuItems indexOfObject:openTab]];
            }
            
            
        } else if (tag == WebMenuItemTagDownloadImageToDisk || tag == 2043){
            [item setAction:@selector(startDownloadingURL:)];
            [item setTarget:manager];
            
        } else if (tag == 2042) {
            
            [item setAction:@selector(openInNewWindow:)];
            [item setTarget:self];
        } else if (tag == 21) {
            
            DOMText *text = element[@"WebElementDOMNode"];
#ifdef DEBUG
            NSLog(@"element class %@", [text className]);
#endif
            if ([text respondsToSelector:@selector(wholeText)]) {
                
                NSString *string = text.wholeText;
                NSRange range = [string rangeOfString:@"http"];
                if (range.length == 0) {
                    string = [NSString stringWithFormat:@"http://%@", string];
                }
                NSURL *url = [NSURL URLWithString:string] ;
                if (url) {
                    if ([self canPlayWithMpv:url]) {
                        NSMenuItem *play = [[NSMenuItem alloc] initWithTitle:@"Play With MPV" action:@selector(playWithMpv:) keyEquivalent:@""];
                        play.target = self;
                        play.representedObject = url;
                        [menuItems addObject:[NSMenuItem separatorItem]];
                        [menuItems addObject:play];
                    }
                    
                }
                
            }


        }
        

    }
    
    [menuItems addObject:[[ODContentBlocker shared] elementHideItemWithRepObj:element]];
    [menuItems addObject:[[ODContentBlocker shared] contextItemForFrame:sender.mainFrame]];
    
    
    
    
    return menuItems;
}

- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender {
    
    NSString *selector = NSStringFromSelector(action);
    NSLog(@"sender: %@\nselector: %@", sender, selector);
    return YES;
}

//-(BOOL)webViewIsStatusBarVisible:(WebView *)sender
//{
//    if ([sender isEqualTo:[self mainWebView]]) {
//        return YES;
//    }
//    return NO;
//    
//}
//
//-(NSString *)webViewStatusText:(WebView *)sender
//{
//    return @"Test status text";
//}

#pragma mark - Web Frame Load Delegate


-(void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    //[_unifiedField endLoading];
      NSURL *URL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    if (error.code == WebKitErrorFrameLoadInterruptedByPolicyChange || error.code == WebKitErrorCannotShowMIMEType) {
        //NSString *url = [error.userInfo objectForKey:@"NSErrorFailingURLStringKey" ];
         //[[ODWebDownloadManager sharedManager] startDownloadingURL:url];
      
       
                if ([[URL pathExtension] isEqualToString:@"webm"]) {
                    //[[NSWorkspace sharedWorkspace] openFile:url withApplication:@"mpv"];
//                    [frame loadAlternateHTMLString:[NSString stringWithFormat:@"<style>body{font-family:Verdana; font-size:14px; text-align:center;}</style>" 
//                                                    "<h3>Playing with mpv ...</h3>"
//                                                    @"<a href=\"%@\"> %@",
//                                                    URL, URL]
//                                           baseURL:URL
//                                 forUnreachableURL:URL];
//                                [frame loadHTMLString:[NSString stringWithFormat:
//                                                       @"<body>"
//                                                       "<style>body{font-family:Verdana; font-size:14px; text-align:center;}</style>"
//                                                       "<h4>Playing with mpv ...</h4>"
//                                                       @"<a href=\"%@\"> %@"
//                                                       "</body>", URL, URL]
//                                              baseURL:URL];
                    
                    //[sender stopLoading:self];
                    
                    [self playWithMpv:URL];
                    
                    long idx = [_tabBar.tabList indexOfObject:sender];
                    [_tabBar closeTabAtIndex:idx];
                    [self updateTitle];

                    

                    
                } else {
                    
                    [[ODWebDownloadManager sharedManager] startDownloadingURL:URL];
                }
//        if ([[[NSURL URLWithString:url] pathExtension] isEqualToString:@"webm"]) {
//            [frame loadHTMLString:[NSString stringWithFormat:
//                                   @"<body>"
//                                   "<video controls=\"\" autoplay=\"\" name=\"media\" style=\"max-width:100%%; max-height:100%%;\">"
//                                   "<source src=\"%@\" type=\"video/mp4\">"
//                                   "</video>"
//                                   "</body>", url]
//                          baseURL:[NSURL URLWithString:url]];
//        } else {
//            
//            [[ODWebDownloadManager sharedManager] startDownloadingURL:url];
//        }
        
        //        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
        //                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
        //                                                timeoutInterval:60.0];
        //        
        //        
        //        NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
        //        if (!theDownload) {
        //            // Inform the user that the download failed.
        //        }
    } else {
//        NSString *str = [error.userInfo objectForKey:@"NSErrorFailingURLStringKey"];
//        NSURL *url = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
        
        [frame loadAlternateHTMLString:[NSString stringWithFormat:@"<style>body{font-family:Verdana; font-size:14px; text-align:center;}</style> <h3>This page cannot be displayed</h3>"
                                        @"<a href=\"%@\"> %@"
                                        @"</a> <br><br> %@",
                                        URL, URL,
                                        error.localizedDescription]
                               baseURL:URL
                     forUnreachableURL:URL];
    }
    
    
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if ([sender isEqualTo:_tabBar.activeTab]) {
        [self updateTitle];
    }
}

-(void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    if ([sender isNotEqualTo:[_tabBar activeTab]]) {
        return;
    }
    //[_unifiedField beginLoading];
    //[_unifiedField setTitle:@"Loading..."];
    [self updateTitle];
    
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if ([sender isNotEqualTo:[_tabBar activeTab]]) {
        return;
    }
    
    
    //    NSString *a = [sender mainFrameTitle];
    //    if ([a length]) {
    //        
    //        [_unifiedField setTitle:a];
    //        [self.window setTitle:a];
    //        a = [sender mainFrameURL];
    //        [_unifiedField setAddress:a];
    //    } else {
    //        a = [sender mainFrameURL];
    //        
    //        [_unifiedField setTitle:a];
    //        [_unifiedField setAddress:a];
    //        
    //        [self.window setTitle:a];
    //        
    //        
    //        
    //    }
    
    [self updateTitle];
    //    NSString *addr = [sender mainFrameURL];
    //    if ([addr.pathExtension isEqualToString:@"webm"]) {
    //        [frame loadHTMLString:[NSString stringWithFormat:
    //                               @"<body>"
    //                               "<video controls=\"\" autoplay=\"\" name=\"media\" style=\"max-width:100%%; max-height:100%%;\">"
    //                               "<source src=\"%@\" type=\"video/mp4\">"
    //                               "</video>"
    //                               "</body>", addr]
    //                      baseURL:[NSURL URLWithString:addr]];
    //    }
    
    //[_unifiedField endLoading];
}
- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
    //[self->_unifiedField endLoading];
    [self updateTitle];
}

#pragma mark - Web Resource Load Delegate
- (NSURLRequest *)webView:(WebView *)sender 
                 resource:(id)identifier 
          willSendRequest:(NSURLRequest *)request 
         redirectResponse:(NSURLResponse *)redirectResponse 
           fromDataSource:(WebDataSource *)dataSource
{

    ODContentBlocker *contentBlocker = [ODContentBlocker shared];
    if (contentBlocker) {
        request = [contentBlocker checkRequest:request dataSource:dataSource];
    }
    if ([sender isEqualTo:_tabBar.activeTab]) {
        [self updateTitle];
    }
    
    return request;  
}

#pragma mark - Web Policy Delegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener {
    //NSString *host = [[request URL] host];
    if ([[ODContentBlocker shared] isUnsafe:request]) {
        [listener ignore];
        //[sender stopLoading:self];
        
    } else {
        
        [listener use];
    }
    
    
}

#pragma mark - Window Delegate

-(void)windowDidBecomeMain:(NSNotification *)notification
{
    // [[NSApp mainMenu] setSubmenu:_tabsCtl.menu forItem:[[NSApp mainMenu] itemWithTitle:@"Tabs"]];
    //    NSMenuItem *item = [[NSApp mainMenu] itemWithTag:200];
    //    [[item.submenu itemWithTag:201] setSubmenu:_tabsCtl.menu];
}
-(void)windowWillClose:(NSNotification *)notification
{
    _tabBar.window = nil;
}

@end

void ODLog(NSString *str)
{
    @autoreleasepool {
        str = [str stringByAppendingString:@"\n"];
        [str writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
}
