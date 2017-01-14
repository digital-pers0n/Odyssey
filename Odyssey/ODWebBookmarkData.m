//
//  ODWebBookmarkData.m
//  Bookmarks-Playground
//
//  Created by Terminator on 10/11/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebBookmarkData.h"
#import "Bookmarks.h"

@import Cocoa;

//#define TITLE_KEY @"Title"
//#define ADDRESS_KEY @"URLString"
//#define TYPE_KEY @"BookmarkType"
//#define CHILDREN_KEY @"Children"
//
//#define LEAF @"BookmarkTypeLeaf"
//#define LIST @"BookmarkTypeList"



@interface ODWebBookmarkData ()<NSPasteboardWriting, NSPasteboardReading>

{
    NSMutableDictionary *_data;
}



@end

@implementation ODWebBookmarkData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_data = [NSMutableDictionary new];
        [self->_data setObject:@"Untitled" forKey:TITLE_KEY];
        [self->_data setObject:@"" forKey:ADDRESS_KEY];
        [self->_data setObject:LEAF forKey:TYPE_KEY];
        
    }
    return self;
}


-(id)initWithTitle:(NSString *)title address:(NSString *)address
{
    self = [[ODWebBookmarkData alloc] init];
    [_data setObject:title forKey:TITLE_KEY];
    [_data setObject:address forKey:ADDRESS_KEY];
    [_data setObject:LEAF forKey:TYPE_KEY];
    return self;
}

-(id)initListWithTitle:(NSString *)title content:(NSArray *)content
{
    self = [[ODWebBookmarkData alloc] init];
    [_data setObject:title forKey:TITLE_KEY];
    [_data setObject:content forKey:CHILDREN_KEY];
    [_data setObject:LIST forKey:TYPE_KEY];
    return self;
}

-(id)initWithData:(NSDictionary *)bookmarkData
{
    self = [[ODWebBookmarkData alloc] init];
    _data = [bookmarkData mutableCopy];
    return self;
}

- (NSComparisonResult)compare:(id)anOther {
    // We want the data to be sorted by name, so we compare [self name] to [other name]
    if ([anOther isKindOfClass:[ODWebBookmarkData class]]) {
        ODWebBookmarkData *other = (ODWebBookmarkData *)anOther;
        return [self.title compare:[other title]];
    } else {
        return NSOrderedAscending;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - '%@' type: %@",
            [super description], self.title, self.data[TYPE_KEY]];
}



-(NSArray *)children
{
    if ([self isList]) {
        
        return [_data objectForKey:CHILDREN_KEY];
    }
    
    return nil;
}

-(void)setChildren:(NSArray *)children
{
    [_data setObject:children forKey:CHILDREN_KEY];
    if (![self isList]) {
        [_data removeObjectForKey:ADDRESS_KEY];
        [_data setObject:LIST forKey:TYPE_KEY];
    }
}

-(void)addObject:(id)obj
{
    NSMutableArray *array = [[self children] mutableCopy];
    [array addObject:obj];
    [self setChildren:[NSArray arrayWithArray:array]];
}

-(void)insertObject:(ODWebBookmarkData *)obj atIndex:(NSUInteger)idx
{
    NSMutableArray *array = [[self children] mutableCopy];
    [array insertObject:[obj data] atIndex:idx];
    [self setChildren:[NSArray arrayWithArray:array]];  
}

-(void)removeObjectAtIndex:(NSUInteger)idx
{
    NSMutableArray *array = [[self children] mutableCopy];
    [array removeObjectAtIndex:idx];
    [self setChildren:[NSArray arrayWithArray:array]];
}


-(NSString *)title
{
    return [_data objectForKey:TITLE_KEY];
}
-(void)setTitle:(NSString *)title
{
    [_data setObject:title forKey:TITLE_KEY];
}

-(NSString *)address
{
    return [_data objectForKey:ADDRESS_KEY];
}

-(void)setAddress:(NSString *)addr
{
    [_data setObject:addr forKey:ADDRESS_KEY];
}

-(void)setData:(NSDictionary *)data
{
    _data = [data mutableCopy];
}

-(NSDictionary *)data
{
    return [NSDictionary dictionaryWithDictionary:_data];
}

-(BOOL)isList
{
    if ([[_data objectForKey:TYPE_KEY] isEqualToString:LIST]) {
        return YES;
    }
    
    return NO;
}


#pragma mark - NSPasteboardWriting support

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // These are the types we can write.
    NSArray *ourTypes = @[NSPasteboardTypeString];
    // Also include the images on the pasteboard too!
//    NSArray *imageTypes = [self.image writableTypesForPasteboard:pasteboard];
//    if (imageTypes) {
//        ourTypes = [ourTypes arrayByAddingObjectsFromArray:imageTypes];
//    }
    return ourTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return 0;
    }
    // Everything else is delegated to the image
//    if ([self.image respondsToSelector:@selector(writingOptionsForType:pasteboard:)]) {            
//        return [self.image writingOptionsForType:type pasteboard:pasteboard];
//    }
    
    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return self.title;
    } else {
       // return [self.image pasteboardPropertyListForType:type];
        return nil;
    }
}


#pragma mark - NSPasteboardReading support

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // We allow creation from URLs so Finder items can be dragged to us
    return @[(id)kUTTypeURL, NSPasteboardTypeString];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:NSPasteboardTypeString] || UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        return NSPasteboardReadingAsString;
    } else {
        return NSPasteboardReadingAsData; 
    }
}

- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    // See if an NSURL can be created from this type
    if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        // It does, so create a URL and use that to initialize our properties
        NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
        self = [self init];
        self.title = [url lastPathComponent];
        // Make sure we have a name
        if (self.title == nil) {
            self.title = [url path];
            if (self.title == nil) {
                self.title = @"Untitled";
            }
        }
        //self.selectable = YES;
        
        // See if the URL was a container; if so, make us marked as a container too
        NSNumber *value;
        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && [value boolValue]) {
//            self.container = YES;
//            self.expandable = YES;
        } else {
//            self.container = NO; 
//            self.expandable = NO;
            [self setAddress:[url absoluteString]];
        }
        
//        NSImage *localImage;
//        if ([url getResourceValue:&localImage forKey:NSURLEffectiveIconKey error:NULL] && localImage) {
//            self.image = localImage;
//        }
        
    } else if ([type isEqualToString:NSPasteboardTypeString]) {
        self = [super init];
        self.title = propertyList;
       // self.selectable = YES;
    } else {
        NSAssert(NO, @"internal error: type not supported");
    }        
    return self;
}

@end
