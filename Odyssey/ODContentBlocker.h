//
//  ODContentBlocker.h
//  Odyssey
//
//  Created by Terminator on 11/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DOMDocument, WebFrame, WebDataSource;
@interface ODContentBlocker : NSObject

+(id)shared;

-(BOOL)isUnsafe:(NSURLRequest *)req;

-(NSURLRequest *)checkRequest:(NSURLRequest *)req dataSource:(WebDataSource *)data;

-(NSMenuItem *)contextItemForFrame:(WebFrame *)frame;
-(NSMenuItem *)elementHideItemWithRepObj:(id)obj;

-(void)saveData;

@property (getter=isPaused) BOOL pause;
@property (readonly) NSArray *whiteList;
@property (readonly) NSArray *blackList;

@end
