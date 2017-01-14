//
//  ODContentBlockerAddRuleDialog.h
//  Odyssey
//
//  Created by Terminator on 11/25/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODContentBlockerAddRuleDialog : NSWindowController

-(NSString *)editRule:(NSString *)rule;

@property (getter=wasCancelled) BOOL cancel;

@end
