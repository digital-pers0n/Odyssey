//
//  ODFindBanner.h
//  Odyssey
//
//  Created by Terminator on 4/28/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODFindBanner : NSViewController

-(void)installBanner;
-(void)uninstallBanner;
@property (readonly, getter=isInstalled) BOOL installed; 

@end
