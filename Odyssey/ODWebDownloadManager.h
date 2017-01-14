//
//  ODWebDownloadManager.h
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODWebDownloadManager : NSObject

+(id)sharedManager;


-(NSMenuItem *)saveImage;

- (void)startDownloadingURL:(id)sender;

-(NSArray *)downloads;
-(void)removeDownloadAtIndex:(NSUInteger)idx;
-(void)pauseDownloadAtIndex:(NSUInteger)idx;
-(void)resumeDownloadAtIndex:(NSUInteger)idx;
-(void)removeAll;

-(void)showDownloads;

@end
