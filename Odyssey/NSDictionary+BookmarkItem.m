//
//  NSDictionary+BookmarkItem.m
//  Bookmarks-Playground
//
//  Created by Terminator on 10/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "NSDictionary+BookmarkItem.h"
#import "Bookmarks.h"

@implementation NSDictionary (BookmarkItem)

-(NSString *)title
{
    return [self objectForKey:TITLE_KEY];
}

-(NSString *)address
{
    if (![self isDirectory]) {
        return [self objectForKey:ADDRESS_KEY];
    }
    
    return nil;
}

-(BOOL)isDirectory
{
    
    if ([self[TYPE_KEY] isEqualToString:LIST]) {
        return YES;
    }
    return NO;
    
}

-(NSArray *)directoryContent
{
    if ([self isDirectory]) {
        
        return [self objectForKey:CHILDREN_KEY];
    }
    
    return nil;
}




@end
