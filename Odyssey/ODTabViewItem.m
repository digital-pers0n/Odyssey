//
//  ODTabBarViewItem.m
//  TabBar
//
//  Created by Terminator on 2017/12/17.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import "ODTabViewItem.h"

@implementation ODTabViewItem


- (instancetype)init {
    return [self initWithView:nil];
}

- (instancetype)initWithView:(NSView *)view {
    self = [super init];
    if (self) {
        _label = @"Empty Tab";
        _view = view;
        _type = ODTabTypeDefault;
        
    }
    return self;
}



- (void)_setState:(ODTabState)state {
    _state = state;
}

- (void)dealloc {
    _representedObject = nil;
    _view = nil;
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
        return _label;
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
        _label = [url lastPathComponent];
        // Make sure we have a name
        if (_label == nil) {
            _label = [url path];
            if (_label == nil) {
                _label = @"Untitled";
            }
        }
        
        // See if the URL was a container; if so, make us marked as a container too
//        NSNumber *value;
//        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && [value boolValue]) {
//            _list = YES;
//            _children = @[];
//        } else {
//            
//            _address = [url absoluteString];
//            
//        }
        
    } else if ([type isEqualToString:NSPasteboardTypeString]) {
        self = [self init];
        _label = propertyList;
        
        // self.selectable = YES;
    } else {
        NSAssert(NO, @"internal error: type not supported");
    }
    return self;
}

@end
