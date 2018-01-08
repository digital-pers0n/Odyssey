//
//  ODContentFilter.h
//  Odyssey
//
//  Created by Terminator on 4/24/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;

@class WebDataSource;

@interface ODContentFilter : NSObject

- (BOOL)isInsecure:(NSURL *)url domain:(NSString *)domain;
- (NSURLRequest *)newRequestFrom:(NSURLRequest *)request dataSource:(WebDataSource *)dataSource domain:(NSString *)domain;

@property (getter=isPaused) BOOL pause;
@property (readonly) NSMenuItem *contextMenuItem;
@property (readonly) NSMenuItem *addRuleMenuItem;



@end
