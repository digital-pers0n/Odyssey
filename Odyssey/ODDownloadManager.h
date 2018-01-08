//
//  ODDownloadManager.h
//  Odyssey
//
//  Created by Terminator on 4/20/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RECENT_PATHS @"RecentPaths"

@interface ODDownloadManager : NSViewController

@property NSString *saveDestination;
-(void)newDownloadWithURL:(NSURL *)url;

-(void)showPopover;
-(void)showPopoverForWindow:(NSWindow *)window;

-(void)downloadMenuItemClicked:(id)sender;

@property (readonly) NSMenuItem *saveImageMenuItem;
-(NSMenuItem *)ytdlMenuItem;

@end
