//
//  ODSessionItem.m
//  Odyssey
//
//  Created by Terminator on 2018/04/13.
//  Copyright © 2018年 home. All rights reserved.
//

#import "ODSessionItem.h"

NSString * const ODSessionItemNameKey = @"Name";
NSString * const ODSessionItemArrayKey = @"Array";

@implementation ODSessionItem

- (id)copyWithZone:(NSZone *)zone {
    ODSessionItem *item = [[ODSessionItem alloc] init];
    item.name = _name.copy;
    item.sessionArray = _sessionArray.copy;
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:ODSessionItemNameKey];
        _sessionArray = [coder decodeObjectForKey:ODSessionItemArrayKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:ODSessionItemNameKey];
    [coder encodeObject:_sessionArray forKey:ODSessionItemArrayKey];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return 0;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    NSArray *ourTypes = @[NSPasteboardTypeString];
    return ourTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return _name;
    } else {
        return nil;
    }
}

@end
