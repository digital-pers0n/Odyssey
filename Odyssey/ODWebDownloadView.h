//
//  ODWebDownloadView.h
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODWebDownloadView : NSViewController

-(void)showPopover;

-(IBAction)showInFinder:(id)sender;
-(IBAction)copyLink:(id)sender;
-(IBAction)openFile:(id)sender;
-(IBAction)removeFromList:(id)sender;
-(IBAction)removeAll:(id)sender;
-(IBAction)stop:(id)sender;
-(IBAction)resume:(id)sender;

@end
