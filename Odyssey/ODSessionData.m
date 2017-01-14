//
//  ODSessionData.m
//  Odyssey
//
//  Created by Terminator on 11/1/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODSessionData.h"
#import "ODWindowController.h"

#define TABS_KEY @"TabsList"
#define WINDOW_RECT_KEY @"WindowContentRect"
#define IS_MINIATURIZED_KEY @"Miniaturized"

@interface NSMutableDictionary (ODSessionDictionary)

-(void)setTabs:(NSArray *)tabs;
-(NSArray *)tabs;

-(void)setWindowContentRect:(NSRect)contentRect;
-(NSRect)windowContentRect;

-(BOOL)isMiniaturized;
-(void)setMiniaturized:(BOOL)state;


@end

@implementation NSMutableDictionary (ODSessionDictionary)

-(void)setTabs:(NSArray *)tabs
{
    [self setObject:tabs forKey:TABS_KEY];
}

-(NSArray *)tabs
{
    return [self objectForKey:TABS_KEY];
}

-(void)setWindowContentRect:(NSRect)contentRect
{
    [self setObject:NSStringFromRect(contentRect) forKey:WINDOW_RECT_KEY];
}


-(NSRect)windowContentRect
{
    NSString *string = [self objectForKey:WINDOW_RECT_KEY];
    return NSRectFromString(string);
}

-(void)setMiniaturized:(BOOL)state
{
    
    [self setObject:[NSNumber numberWithBool:state] forKey:IS_MINIATURIZED_KEY];
}

-(BOOL)isMiniaturized
{
    NSNumber *state = [self objectForKey:IS_MINIATURIZED_KEY];
    return [state boolValue];
}


@end

@interface ODSessionData ()
{
    NSMutableArray *_sessionArray;
    
}

@end

@implementation ODSessionData

- (instancetype)initWithWindows:(NSArray *)windows
{
   
    self = [super init];
    if (self) {
        _sessionArray = [NSMutableArray new];
        for (ODWindowController *ctl in windows) {
            NSMutableDictionary *windowData = [NSMutableDictionary new];
            [windowData setTabs:[ctl tabsList]];
            [windowData setWindowContentRect:[ctl.window frame]];
            [windowData setMiniaturized:[ctl.window isMiniaturized]];
            [_sessionArray addObject:windowData];
            
        }
        
    }
    return self;
}

-(NSArray *)restoreFrom:(NSString *)path
{
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    if (array) {
        _sessionArray = [array copy];
        [array removeAllObjects];
        
        for (NSMutableDictionary *obj in _sessionArray) {
            ODWindowController *ctl = [[ODWindowController alloc] init];
            [ctl showWindow:self];
            [ctl.window setFrame:[obj windowContentRect] display:NO animate:NO];
            if ([obj isMiniaturized]) {
                [ctl.window performMiniaturize:nil];
            }
            
            [ctl setTabList:[obj tabs]];
            [array addObject:ctl];
            
        }
    }
    
    return array;
}

-(void)saveTo:(NSString *)path
{
    [_sessionArray writeToFile:path atomically:YES];
}

@end
