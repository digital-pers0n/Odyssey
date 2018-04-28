//
//  ODContentFilter.m
//  Odyssey
//
//  Created by Terminator on 4/24/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODContentFilter.h"
#import "ODContentFilterEditRule.h"
#import "ODDelegate.h"

@import WebKit;

#define BLACKLIST_SAVE_PATH [@"~/Library/Application Support/Odyssey/WebFilterList.txt" stringByExpandingTildeInPath]
#define WHITELIST_SAVE_PATH [@"~/Library/Application Support/Odyssey/WebFilterWhiteList.txt" stringByExpandingTildeInPath]

@interface ODContentFilter () <NSMenuDelegate>
{
    NSMenuItem *_jsFilterMenuItem;
    NSMenuItem *_addRuleMenuItem;
    NSMenuItem *_contextMenuItem;
    NSMutableArray *_blackList;
    NSMutableArray *_whiteList;
    NSURL *_blockImageURL;
    NSURL *_blockJSURL;
}

@end

@implementation ODContentFilter 

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *load = [NSString stringWithContentsOfFile:BLACKLIST_SAVE_PATH encoding:NSUTF8StringEncoding error:nil];
        
        if (!load) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"WebFilterList" ofType:@"txt"];
            load = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        _blackList = [[NSMutableArray alloc] initWithArray:[load componentsSeparatedByString:@"\n"]];
        load = nil;
        load = [NSString stringWithContentsOfFile:WHITELIST_SAVE_PATH encoding:NSUTF8StringEncoding error:nil];
        
        if (!load) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"WebFilterWhiteList" ofType:@"txt"];
            load = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        _whiteList = [[NSMutableArray alloc] initWithArray:[load componentsSeparatedByString:@"\n"]];
        
        _jsFilterMenuItem = [[NSMenuItem alloc] init];
        _jsFilterMenuItem.title = @"JS Filter";
        NSMenu *menu = [[NSMenu alloc] init];
        menu.delegate = self;
        _jsFilterMenuItem.submenu = menu;
        
        _addRuleMenuItem = [[NSMenuItem alloc] init];
        _addRuleMenuItem.title = @"Block Image...";
        _addRuleMenuItem.target = self;
        _addRuleMenuItem.action = @selector(addRuleMenuItemClicked:);
        
        _contextMenuItem = [[NSMenuItem alloc] init];
        _contextMenuItem.title = @"Content Filter";
        menu =[[NSMenu alloc] init];
        _contextMenuItem.submenu = menu;
        
        [[menu addItemWithTitle:@"Pause" action:@selector(pauseMenuItemClicked:) keyEquivalent:@""] setTarget:self];
        [[menu addItemWithTitle:@"Block Link..." action:@selector(addRuleMenuItemClicked:) keyEquivalent:@""] setTarget:self];
        [menu addItem:_jsFilterMenuItem];
        
        _blockImageURL = [[NSBundle mainBundle] URLForResource:@"blocked" withExtension:@"png"];
        _blockJSURL = [[NSBundle mainBundle] URLForResource:@"dummy" withExtension:@"js"];
    }
    return self;
}

-(void)saveData
{
    NSString *str = [_blackList componentsJoinedByString:@"\n"];
    [str writeToFile:BLACKLIST_SAVE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    str = [_whiteList componentsJoinedByString:@"\n"];
    [str writeToFile:WHITELIST_SAVE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(BOOL)isInsecure:(NSURL *)url domain:(NSString *)domain
{
    BOOL result = NO;
    NSString *addr = [url absoluteString];
    
    if (!_pause) {
        if ([self isAddress:addr inList:_blackList]) {
            if (![self isAddress:domain inList:_whiteList]) {
                result = YES;
            }
        }
    }
    
    return result;
}

-(NSURLRequest *)newRequestFrom:(NSURLRequest *)request dataSource:(WebDataSource *)dataSource domain:(NSString *)domain
{
 
    NSURL *requestURL = request.URL;
    
    if (![self isInsecure:requestURL domain:domain]) {
        return request; 
    } else {
        WebResource *rsc = [dataSource subresourceForURL:requestURL];
        NSRange range = [rsc.MIMEType rangeOfString:@"javascript"];
        if (range.length) {
            request = [NSURLRequest requestWithURL:_blockJSURL];
        } else {
            request = [NSURLRequest requestWithURL:_blockImageURL];
        }
    }
    return request;
}

-(BOOL)isAddress:(NSString *)address inList:(NSArray *)list
{
    BOOL result = NO;
    
    for (NSString *str in list) {
        NSRange range = [address rangeOfString:str];
        
        if (range.length) {
            result = YES;
        }
    }
    
    return result;
}

#pragma mark - menu actions

-(void)jsMenuItemClicked:(NSMenuItem *)sender
{
    id repObject = sender.representedObject;
    (sender.tag == 10) ? [_blackList addObject:repObject] : [_blackList removeObject:repObject];
}

-(void)pauseMenuItemClicked:(id)sender
{
    _pause = _pause ? NO : YES;
    [sender setState:_pause];
}

-(void)addRuleMenuItemClicked:(NSMenuItem *)sender
{
    NSDictionary *representedObject = sender.representedObject;
    NSString *str = @"";
    if (representedObject) {
        str = [[representedObject objectForKey:WebElementImageURLKey] absoluteString];
    }
//    NSURL *str = [representedObject objectForKey:WebElementImageURLKey];
//    if (!str) {
//        DOMHTMLElement *element = [representedObject objectForKey:WebElementDOMNodeKey];
//        if ([element respondsToSelector:@selector(outerHTML)]) {
//            str = element.outerHTML;
//        }
//    }
        ODContentFilterEditRule *editor = [[ODContentFilterEditRule alloc] init];
        [editor editRule:str withReply:^(NSString *newRule) {
            if (newRule) {
                [_blackList addObject:newRule];
                [self saveData];
            }
        }];
    

}


#pragma mark - NSMenuDelegate
-(void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    WebFrame *frame;
    WebView *webView;
    NSURL *URL;
    NSMenuItem *item;
    NSString *host;
    NSString *mime;
    NSRange range;
    
    webView = [(ODDelegate *)[NSApp delegate] webView];
    frame = webView.mainFrame;
    
    for (WebResource *rsc in frame.dataSource.subresources) {
        mime = [rsc MIMEType];
        URL = rsc.URL;
        
        range = [mime rangeOfString:@"javascript" options:NSCaseInsensitiveSearch];
        if (range.length && [URL.pathExtension isEqualToString:@"js"]) {
            
            host = URL.host;
            item = [[NSMenuItem alloc] initWithTitle:[URL lastPathComponent] action:@selector(jsMenuItemClicked:) keyEquivalent:@""];
            item.target = self;
            item.representedObject = [NSString stringWithFormat:@"%@%@", host, URL.path];
            item.toolTip = URL.absoluteString;
            if (![self isInsecure:URL domain:host]) {
                [item setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
                item.tag = 10;
                
            } else {
                [item setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
                item.tag = 11;
            }
            [menu addItem:item];
        }        //NSLog(@"\nMIMEType: %@ \nURL: %@\n", mime, rsc.URL);
    }
}

@end
