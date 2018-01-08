//
//  ODBookmarksEditor.h
//  Odyssey
//
//  Created by Terminator on 4/14/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODBookmarksOutline : NSViewController

@property (readonly) NSOutlineView *outlineView;

- (instancetype)initWithData:(NSDictionary *)data;

-(NSDictionary *)saveAtPath:(NSString *)path;

@end
