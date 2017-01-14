//
//  ODTitleBarView.m
//  Odyssey
//
//  Created by Terminator on 1/11/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODTitleBarView.h"

@interface ODTitleBarView () {
        
    NSString *_title;
    NSImage *_icon;
    NSString *_status;
   BOOL _canDrawAttributedString;
    
}

@end

@implementation ODTitleBarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
//    if (_icon) {
//        NSCell *icell = [[NSCell alloc] initImageCell:_icon];
//        
//        [icell drawWithFrame:NSMakeRect(0, 2, 20, 20) inView:self];
//    }
    
    if (_status) {
        
         NSCell *cell = [[NSCell alloc] initTextCell:_status];
        [cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
        if (_canDrawAttributedString) {
            NSRange range = [_status rangeOfString:@"/"];
            NSMutableAttributedString *_string = [cell.attributedStringValue mutableCopy]; //[[NSMutableAttributedString alloc] initWithString:_status];
            
            //[_string setAttributes:self->_attrs range:NSMakeRange(0, _status.length)];
            
            [_string addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize] - 1] range:NSMakeRange(0, range.location)];
            
            [cell setAttributedStringValue:_string];
        }

        //[cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [cell drawWithFrame:NSMakeRect(6, 0, NSWidth(self.frame) - 95, 20) inView:self];
        //[_string drawInRect:NSMakeRect(36, 0, NSWidth(self.frame) - 90, 20)];
    } else if(_title) {
        NSCell *tcell = [[NSCell alloc] initTextCell:_title];
        
        [tcell setLineBreakMode:NSLineBreakByTruncatingMiddle];
        
        [tcell drawWithFrame:NSMakeRect(6, 0, NSWidth(self.frame) - 95, 20) inView:self];
    }
    
    
    // Drawing code here.
}

-(void)setTitle:(NSString *)title icon:(NSImage *)icon
{
    _title = title;
    //_icon = icon;
    [self setNeedsDisplay:YES];
}

-(void)setStatus:(NSString *)str
{
    if (str) {
        
        NSRange range = [str rangeOfString:@"http://"];
        if (!range.length) {
            range = [str rangeOfString:@"https://"];
            
        }
        if (range.length) {
            str = [str stringByReplacingCharactersInRange:range withString:@""];
            _canDrawAttributedString = YES;
        } else {
            
            _canDrawAttributedString = NO;
        }
        
    }

    
    _status = str;
}

-(BOOL)allowsVibrancy
{
    return NO;
}

@end
