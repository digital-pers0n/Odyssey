//
//  ODStatusBar.m
//  Odyssey
//
//  Created by Terminator on 9/29/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODStatusBar.h"

@implementation ODStatusBar
{
    NSGradient *_grad;
    NSDictionary *_attrs;
    NSBezierPath *_path;
    NSShadow *_shad;
    NSString *_tooltipString;
    
    BOOL _canDrawAttributedString;
  
}

- (void)drawRect:(NSRect)dirtyRect {
    
    
    if ([self->_tooltipString length] > 0) {
        
        
        NSSize size = [self->_tooltipString sizeWithAttributes:self->_attrs];
        if (size.width >= self.window.frame.size.width ) {
            size.width = self.window.frame.size.width - 17;
        }
        NSRect rect = NSMakeRect(3, 3, size.width + 9, size.height + 3);

        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius: 4 yRadius: 4];
        
        [[NSColor colorWithCalibratedWhite:0.96f alpha:1] setFill];
        [path fill];
        

        //
        [[NSColor colorWithCalibratedWhite:0.9f alpha:1] setStroke];
        [path setLineWidth:1];
        [path stroke];

        
        rect.origin.x = 8;
        rect.origin.y =  NSHeight(rect) / 6;
        rect.size.width = size.width;
        //[self class];
        //
        if (self->_canDrawAttributedString) {
            
            NSRange range = [self->_tooltipString rangeOfString:@"/"];
            NSMutableAttributedString *_string = [[NSMutableAttributedString alloc] initWithString:self->_tooltipString];
            [_string setAttributes:self->_attrs range:NSMakeRange(0, self->_tooltipString.length)];
            [_string addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize] - 1] range:NSMakeRange(0, range.location)];
            [_string drawInRect:rect];
            
        } else {
            
            [self->_tooltipString drawInRect:rect withAttributes:self->_attrs];
        }


    }
    
    
    
    // Drawing code here.
}



-(instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        
      
        self->_canDrawAttributedString = NO;
        
        [self setFrameOrigin:NSMakePoint(0, 0)];
        
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        
//        self->_grad = [[NSGradient alloc] initWithColorsAndLocations:
//                       NSColor.whiteColor, 0.0f,
//                       [NSColor.whiteColor blendedColorWithFraction: 0.5f ofColor: NSColor.lightGrayColor], 0.6f,
//                       NSColor.lightGrayColor, 1.0f, nil];
        
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        [paragraph setLineBreakMode: NSLineBreakByTruncatingMiddle];
        self->_attrs =  @{
                          NSFontAttributeName :[NSFont systemFontOfSize:[NSFont systemFontSize]],
                          NSParagraphStyleAttributeName : paragraph,
                          //NSForegroundColorAttributeName : [NSColor colorWithWhite:0.09f alpha:1],
                          //                              NSBackgroundColorAttributeName : [NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:0.93],
                          
                          };
        
//        self->_shad =  [[NSShadow alloc] init];
//
//        [self->_shad setShadowColor:[NSColor colorWithWhite:0.18f alpha:1]];
//        [self->_shad setShadowOffset: NSMakeSize(0, -1 )];
//        [self->_shad setShadowBlurRadius: 3];

    }
    
    return self;
}


-(void)setStatus:(NSString *)str
{
    NSRange range = [str rangeOfString:@"http://"];
    if (!range.length) {
        range = [str rangeOfString:@"https://"];

    }
    if (range.length) {
        str = [str stringByReplacingCharactersInRange:range withString:@""];
        self->_canDrawAttributedString = YES;
    } else {
        
             self->_canDrawAttributedString = NO;
    }
        
    self->_tooltipString = str;
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return NO;
}


@end
