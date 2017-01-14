//
//  ODSearchForController.h
//  Odyssey
//
//  Created by Terminator on 9/29/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODSearchForController : NSObject
{
    IBOutlet NSSearchField  *_searchField;
    IBOutlet NSView         *_contentView;
//    IBOutlet NSButton *_forward;
//    IBOutlet NSButton *_backward;
//    IBOutlet NSButton *_done;
}

-(NSString *)searchString;
-(NSView *)view;
-(NSSearchField *)searchField;

-(void)makeFirstResponder;


@end
