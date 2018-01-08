//
//  ODAddressField.h
//  Odyssey
//
//  Created by Terminator on 4/13/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODAddressField : NSViewController


-(void)editString:(NSString *)string withReply:(void (^)(NSString *address))respond;

@end
