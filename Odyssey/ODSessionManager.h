//
//  ODSessionManager.h
//  Odyssey
//
//  Created by Terminator on 2018/04/13.
//  Copyright © 2018年 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ODSessionItem;
@protocol ODSessionManagerDelegate;

@interface ODSessionManager : NSWindowController

@property id<ODSessionManagerDelegate> delegate;

@property NSString *sessionSavePath;
@property (readonly) NSArray *itemArray;

- (void)addSessionItem:(ODSessionItem *)item;
- (void)saveSession;

- (void)showSessionWindow;

@end

@protocol ODSessionManagerDelegate <NSObject>

- (void)sessionManager:(ODSessionManager *)manager restoreSession:(ODSessionItem *)item;
- (void)sessionManager:(ODSessionManager *)manager storeSession:(ODSessionItem **)item;

@end