//
//  ODWindow.h
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODController : NSObject

+(id)sharedController;

-(void)newWindowWithAddress:(NSString *)address;
-(void)newWindowWithTabs:(NSArray *)array;

-(void)openInExistingWindow:(NSString *)address;
-(void)openTabInBackground:(NSString *)address;
-(void)openTabsInExistingWindow:(NSArray *)array;

//Actions

-(IBAction)openTab:(id)sender;
-(IBAction)closeTab:(id)sender;
-(IBAction)tabsMenu:(id)sender;  // Deprecated
-(IBAction)showTabs:(id)sender;
-(IBAction)nextTab:(id)sender;
-(IBAction)previousTab:(id)sender;
-(IBAction)moveTabToNewWindow:(id)sender;
-(IBAction)mergeAllTabs:(id)sender;

-(IBAction)goForward:(id)sender;
-(IBAction)goBackward:(id)sender;

-(IBAction)showSearchForString:(id)sender;

-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)defaultZoom:(id)sender;
-(IBAction)zoomTextOnly:(id)sender;

-(IBAction)reloadPage:(id)sender;
-(IBAction)reloadFromOrigin:(id)sender;
-(IBAction)stopLoad:(id)sender;

-(IBAction)goTo:(id)sender;

-(IBAction)showDownloads:(id)sender;

-(IBAction)restartApplication:(id)sender;


///

-(NSWindow *)activeWindow;
-(id)webView;
-(NSData *)webArchiveData;
-(NSWindow *)windowWithNumber:(NSUInteger)number;

-(void)saveSession;
-(void)restoreSession;

@end
