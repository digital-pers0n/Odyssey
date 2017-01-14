//
//  ODSearchForController.m
//  Odyssey
//
//  Created by Terminator on 9/29/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODSearchForController.h"

@implementation ODSearchForController

-(NSString *)searchString
{
    return [_searchField stringValue];
}

-(NSView *)view
{
    return _contentView;
}

-(NSSearchField *)searchField
{
    return _searchField;
}

-(void)makeFirstResponder
{
    
}

@end
