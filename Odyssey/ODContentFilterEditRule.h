//
//  ODContentFilterEditRule.h
//  Odyssey
//
//  Created by Terminator on 4/24/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODContentFilterEditRule : NSViewController

-(void)editRule:(NSString *)rule withReply:(void (^)(NSString *newRule))respond;

@end
