//
//  ODImageButton.m
//  Odyssey
//
//  Created by Terminator on 9/28/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODUnifiedFieldButton.h"

@implementation ODUnifiedFieldButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        [self setFrameSize:NSMakeSize(22, 22)];
//        [self setFrameOrigin:NSMakePoint(NSMinX(self.frame), NSMinY(self.frame) + 1)];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
        //[super drawRect:dirtyRect];
//    [[NSColor whiteColor] set];
//    NSRectFill(self.frame);
    
    NSCell *icell = [[NSCell alloc] initImageCell:[self image]];
    
    [icell drawWithFrame:NSMakeRect(0, 0, 20, 20) inView:self];
    
    // Drawing code here.
}

-(BOOL)allowsVibrancy
{
    return NO;
}

-(BOOL)isOpaque
{
    return NO;
}



@end
