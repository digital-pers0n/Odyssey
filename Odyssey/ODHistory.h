//
//  ODHistory.h
//  Odyssey
//
//  Created by Terminator on 4/27/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;
#define SESSION_SAVE_PATH   [@"~/Library/Application Support/Odyssey/WebSession.plist" stringByExpandingTildeInPath]

@interface ODHistory : NSObject

-(void)addItemWithTitle:(NSString *)title address:(NSString *)address;

@end
