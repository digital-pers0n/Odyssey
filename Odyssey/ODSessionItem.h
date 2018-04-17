//
//  ODSessionItem.h
//  Odyssey
//
//  Created by Terminator on 2018/04/13.
//  Copyright © 2018年 home. All rights reserved.
//

@import Cocoa;

@interface ODSessionItem : NSObject <NSCoding, NSCopying, NSPasteboardWriting>

@property NSString *name;
@property NSArray *sessionArray;

@end
