//
//  ODSearchFor.m
//  Odyssey
//
//  Created by Terminator on 9/29/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODSearchForView.h"

@implementation ODSearchForView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor windowBackgroundColor] setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath* bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint: NSMakePoint(0, 1)];
    [bezierPath lineToPoint: NSMakePoint(NSWidth(self.frame), 1)];
    //[bezierPath closePath];
    [[NSColor grayColor] setStroke];
    [bezierPath setLineWidth: 1];
    [bezierPath stroke];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
    
}

@end
