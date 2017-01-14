//
//  ODContentBlocker.m
//  Odyssey
//
//  Created by Terminator on 11/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODContentBlocker.h"
#import "ODContentBlockerAddRuleDialog.h"

@import WebKit;

#define BLACKLIST_SAVE_PATH [@"~/Library/Application Support/void.digital-person.Odyssey/WebFilterList.txt" stringByExpandingTildeInPath]
#define WHITELIST_SAVE_PATH [@"~/Library/Application Support/void.digital-person.Odyssey/WebFilterWhiteList.txt" stringByExpandingTildeInPath]

@interface ODContentBlocker () <NSMenuDelegate>
{
    NSMenuItem *_contextItem;
    NSMenuItem *_elementHideItem;
    NSMutableArray *_blackList;
    NSMutableArray *_whiteList;
    NSURL *_blockImg;
    NSURL *_blockJS;
    
}

@end

@implementation ODContentBlocker

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *load = [NSString stringWithContentsOfFile:BLACKLIST_SAVE_PATH 
                                                   encoding:NSUTF8StringEncoding 
                                                      error:nil];
        if (!load) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"WebFilterList" ofType:@"txt"];
            
            
            load = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        
        _blackList = [[load componentsSeparatedByString:@"\n"] mutableCopy];
        
        load = nil;
        
        load = [NSString stringWithContentsOfFile:WHITELIST_SAVE_PATH encoding:NSUTF8StringEncoding error:nil];
        if (!load) {
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"WebFilterWhiteList" ofType:@"txt"];
            
            
            load = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
        }
        _whiteList = [[load componentsSeparatedByString:@"\n"] mutableCopy];
        
        _contextItem = [[NSMenuItem alloc] init];
        _contextItem.title = @"JS Blocker";
        NSMenu *menu = [[NSMenu alloc] init];
        menu.delegate = self;
        _contextItem.submenu = menu;
        
        _elementHideItem = [[NSMenuItem alloc] init];
        _elementHideItem.title = @"Block Element...";
        _elementHideItem.target = self;
        _elementHideItem.action = @selector(blockElement:);
        
        
        
        _blockImg = [[NSBundle mainBundle] URLForResource:@"blocked" withExtension:@"png"];
        _blockJS = [[NSBundle mainBundle] URLForResource:@"dummy" withExtension:@"js"];
    }
    return self;
}

+(id)shared
{
    static ODContentBlocker *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ODContentBlocker alloc] init];
    });
    
    return shared;
}

-(void)saveData
{
    NSString *str = [_blackList componentsJoinedByString:@"\n"];
    [str writeToFile:BLACKLIST_SAVE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    str = [_whiteList componentsJoinedByString:@"\n"];
    [str writeToFile:WHITELIST_SAVE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSURLRequest *)checkRequest:(NSURLRequest *)req dataSource:(WebDataSource *)data
{
    NSString *addr = [req.URL absoluteString];
    if ([self isPaused] || [self isURL:addr inList:_whiteList] || ![self isURL:addr inList:_blackList]) {
        return req; 
    } else {
        WebResource *rsc = [data subresourceForURL:req.URL];
        NSRange range = [rsc.MIMEType rangeOfString:@"javascript"];
        if (range.length) {
            req = [NSURLRequest requestWithURL:_blockJS];
            
        } else {
            req = [NSURLRequest requestWithURL:_blockImg];
        }
    }
    return req;
}

-(BOOL)isUnsafe:(NSURLRequest *)req
{
    BOOL result = YES;
     NSString *addr = [req.URL absoluteString];
    if ([self isPaused] || [self isURL:addr inList:_whiteList] || ![self isURL:addr inList:_blackList]) {
        
        result = NO; 
        
    } else {
        
        result = YES;
    }
    
    return result;
}

-(NSMenuItem *)contextItemForFrame:(WebFrame *)frame
{
    _contextItem.representedObject = frame;
    
    return _contextItem;
}

-(NSMenuItem *)elementHideItemWithRepObj:(id)repObj
{
    _elementHideItem.representedObject = repObj;
    return _elementHideItem;
}

-(void)blockElement:(NSMenuItem *)sender
{
    NSString *str = [sender.representedObject objectForKey:WebElementImageURLKey];
    if (!str) {
        DOMHTMLElement *element = [sender.representedObject objectForKey:WebElementDOMNodeKey];
        if ([element respondsToSelector:@selector(outerHTML)]) {
            str = element.outerHTML;
        } else {
            
            return;
        }
    }
    ODContentBlockerAddRuleDialog *diag = [[ODContentBlockerAddRuleDialog alloc] init];
    str = [diag editRule:str];
    if (str && ![diag wasCancelled]) {
        [self addRule:str toList:_blackList];
        [self saveData];
    }
}

-(void)jsItem:(NSMenuItem *)sender
{
    if (sender.tag == 10) {
        [self addRule:sender.representedObject toList:_blackList];
    } else {
        [self removeRule:sender.representedObject fromList:_blackList];
    }
}


-(void)addRule:(NSString *)rule toList:(NSMutableArray *)list
{
    if (rule) {
        [list addObject:rule];
    }
}

-(void)removeRule:(NSString *)rule fromList:(NSMutableArray *)list
{
    if (rule) {
        [list removeObject:rule];
    }
}

-(BOOL)isURL:(NSString *)url inList:(NSArray *)list
{
    BOOL result = NO;
    for (NSString *str in list) {
        NSRange range = [url rangeOfString:str];
        if (range.length) {
            result = YES;
        }
    }
    
    return result;
}

#pragma mark - NSMenu Delegate
-(void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    WebFrame *frame = _contextItem.representedObject;
    
    for (WebResource *rsc in frame.dataSource.subresources) {
        NSString *mime = [rsc MIMEType];
        
        
        NSRange range = [mime rangeOfString:@"javascript" options:NSCaseInsensitiveSearch];
        if (range.length && [rsc.URL.path.pathExtension isEqualToString:@"js"]) {
            NSString *url = rsc.URL.absoluteString;
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[rsc.URL lastPathComponent] action:@selector(jsItem:) keyEquivalent:@""];
            item.target = self;
            item.representedObject = [NSString stringWithFormat:@"%@%@", rsc.URL.host, rsc.URL.path];
            
            item.toolTip = url;
            if ([self isPaused] || [self isURL:url inList:_whiteList] || ![self isURL:url inList:_blackList]) {
                [item setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
                item.tag = 10;
                
            } else {
                [item setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
                item.tag = 11;
            }
            [menu addItem:item];
            
            
        }
        //NSLog(@"\nMIMEType: %@ \nURL: %@\n", mime, rsc.URL);
    }
    
}

@end
