//
//  ODSessionData.h
//  Odyssey
//
//  Created by Terminator on 11/1/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODSessionData : NSObject

-(id)initWithWindows:(NSArray *)windows;

-(void)saveTo:(NSString *)path;
-(NSArray *)restoreFrom:(NSString *)path;

@end
