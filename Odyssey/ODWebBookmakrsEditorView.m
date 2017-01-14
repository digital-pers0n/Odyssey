//
//  ODWebBookmakrsEditorView.m
//  Bookmarks-Playground
//
//  Created by Terminator on 10/21/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebBookmakrsEditorView.h"

@implementation ODWebBookmakrsEditorView

- (void)drawRect:(NSRect)dirtyRect {
   // [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations: 
                            NSColor.lightGrayColor, 0.0, 
                            [NSColor.lightGrayColor blendedColorWithFraction: 0.5 ofColor: NSColor.whiteColor], 0.04, 
                            NSColor.whiteColor, 1.0, nil];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, NSWidth(dirtyRect), 35) xRadius:5 yRadius:5];;
    //[[NSColor windowBackgroundColor] setFill];
    //NSRectFill(dirtyRect);
    [gradient drawInBezierPath: path angle:-90];
    
//    NSBezierPath* bezierPath = [NSBezierPath bezierPath];
//    [bezierPath moveToPoint: NSMakePoint(0, 32)];
//    [bezierPath lineToPoint: NSMakePoint(NSWidth(dirtyRect), 32)];
//    [NSColor.darkGrayColor setStroke];
//    [bezierPath setLineWidth:0.3];
//    [bezierPath stroke];
//    [[NSColor blackColor] setStroke];
//    [path setLineWidth:2];
//    [path stroke];
}

-(BOOL)isOpaque
{
    return NO;
}

-(BOOL)allowsVibrancy
{
    return NO;
}

@end
