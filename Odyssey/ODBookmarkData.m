//
//  ODBookmarkData.m
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODBookmarkData.h"

@interface ODBookmarkData ()
{
    NSArray *_children;
    NSString *_title;
    NSString *_address;
    
}

@end

@implementation ODBookmarkData

#pragma mark - init

- (instancetype)init
{
    return [self initLeafWithTitle:@"Untitled" address:@""];
}

- (instancetype)initLeafWithTitle:(NSString *)title address:(NSString *)address    
{
    self = [super init];
    if (self) {
        _title = title;
        _address = address;
        _list = NO;
        
    }
    
    return self;
}

- (instancetype)initListWithTitle:(NSString *)title content:(NSArray *)content  
{
    self = [super init];
    if (self) {
        
        _title = title;
        _children = content;
        _list= YES;
        
    }
    return self;
}

- (instancetype)initWithData:(NSDictionary *)bookmarkData
{
    self = [super init];
    if (self) {
        
        [self setData:bookmarkData];
    }
    return self;
}

#pragma mark - methods

-(NSArray *)children
{
    return _children;
}

-(void)setChildren:(NSArray *)children 
{
    _children = children;
    if (!_list) {
        _address = nil;
        _list = YES;
    }
}

-(void)setData:(NSDictionary *)data
{
    _title = data[TITLE_KEY];
    _children = data[CHILDREN_KEY];
    if (_children) {
        _list = YES;
    } else {
        _list = NO;
        _address = data[ADDRESS_KEY];
    }

}

-(NSDictionary *)data
{
    NSDictionary *result = (_list) ? @{TITLE_KEY: _title, CHILDREN_KEY: _children} : @{TITLE_KEY: _title, ADDRESS_KEY: _address};
    return result;
}


#pragma mark - NSPasteboardWriting support


- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // These are the types we can write.
    NSArray *ourTypes = @[NSPasteboardTypeString];

    return ourTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    
    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return _title;
    } else {
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
        _title = [url lastPathComponent];
        // Make sure we have a name
        if (_title == nil) {
            _title = [url path];
            if (_title == nil) {
                _title = @"Untitled";
            }
        }
        
        // See if the URL was a container; if so, make us marked as a container too
        NSNumber *value;
        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && [value boolValue]) {
            _list = YES;
            _children = @[];
        } else {
            
            _address = [url absoluteString];
            
        }
        
    } else if ([type isEqualToString:NSPasteboardTypeString]) {
        self = [self init];
        _title = propertyList;
        
        // self.selectable = YES;
    } else {
        NSAssert(NO, @"internal error: type not supported");
    }        
    return self;
}


@end
