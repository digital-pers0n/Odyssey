//
//  ODGoTo.h
//  Odyssey
//
//  Created by Terminator on 11/28/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODGoTo : NSWindowController

-(NSString *)editRequest:(NSString *)request;

@property (getter=wasCancelled) BOOL cancel;

@end
