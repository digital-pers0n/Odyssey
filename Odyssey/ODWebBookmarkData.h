//
//  ODWebBookmarkData.h
//  Bookmarks-Playground
//
//  Created by Terminator on 10/11/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODWebBookmarkData : NSObject

-(id)initWithTitle:(NSString *)title address:(NSString *)address;
-(id)initListWithTitle:(NSString *)title content:(NSArray *)content;
-(id)initWithData:(NSDictionary *)bookmarkData;

-(NSDictionary *)data;
-(void)setData:(NSDictionary *)data;

-(BOOL)isList;

-(NSString *)title;
-(void)setTitle:(NSString *)title;

-(NSString *)address;
-(void)setAddress:(NSString *)addr;

-(NSArray *)children;
-(void)setChildren:(NSArray *)children;
-(void)addObject:(id)obj;
-(void)insertObject:(ODWebBookmarkData *)obj atIndex:(NSUInteger)idx;
-(void)removeObjectAtIndex:(NSUInteger)idx;


@end
