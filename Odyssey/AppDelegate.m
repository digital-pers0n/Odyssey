//
//  AppDelegate.m
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//


#import "ODController.h"
#import "ODBookmarksController.h"
#import "AppDelegate.h"
#import "ODContentBlocker.h"
#import "ODWebHistory.h"
#import "WebCache.h"
#import "WebApplicationCache.h"
#import "ODWebPreferences.h"

#import <WebKit/WebKit.h>

@interface AppDelegate ()
{
   IBOutlet ODController *_controller;
      ODBookmarksController *_bookmarks;
    ODContentBlocker *_contentBlocker;
    ODWebHistory *_history;
    ODWebPreferences *_preferences;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //_controller = [[ODController alloc] init];
        //_controller = [ODController sharedController];
        
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(openUrl:withReplyEvent:)
                                                         forEventClass:kInternetEventClass
                                                            andEventID:kAEGetURL];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

//    

  
    // Insert code here to initialize your application
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
    NSFileManager *shared = [NSFileManager defaultManager];
    NSURL *appSupp = [[shared URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
    appSupp = [appSupp URLByAppendingPathComponent:@"void.digital-person.Odyssey" isDirectory:YES];
    if (![shared fileExistsAtPath:appSupp.path]) {
        
        [shared createDirectoryAtURL:appSupp withIntermediateDirectories:NO attributes:nil error:nil];
    }

  
    _bookmarks = [[ODBookmarksController alloc] init];
    _contentBlocker = [ODContentBlocker shared];
    _history = [[ODWebHistory alloc] init];
    _preferences = [ODWebPreferences shared];
//    NSMenuItem *item = [_contentBlocker menuBarItem];
//    [[[NSApp mainMenu] itemWithTag:101].submenu addItem:item];
    

    [_controller restoreSession];
//    float size = [WebApplicationCache maximumSize];
//    size = [WebApplicationCache defaultOriginQuota];
//    NSArray *ar = [WebApplicationCache originsWithCache];
//    ar.count;
    
//    BOOL state = [WebCache isDisabled];
//    state; 
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [_controller saveSession];
    //[_contentBlocker saveData]; 
}

- (void)openUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    [_controller openInExistingWindow:urlStr];
    

    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL URLWithString:urlStr]];
}

-(id)controller
{
    return _controller;
}

-(id)contentBlocker
{
    return _contentBlocker;
}

- (void)openDocument:(id)sender
{
    NSOpenPanel *OpnPanel = [NSOpenPanel openPanel];
    
    [OpnPanel setCanChooseFiles:YES];
    [OpnPanel setAllowsMultipleSelection:NO];
    [OpnPanel setCanChooseDirectories:NO];
    
    
    if([OpnPanel runModal] == NSModalResponseOK){
        
        [_controller openInExistingWindow:OpnPanel.URL.path];
        
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:OpnPanel.URL];
    }
}

- (void)saveDocumentAs:(id)sender
{
    __block NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"webarchive"]];
    NSString *name = [[_controller webView] mainFrameTitle];
    if (name) {
        [savePanel setNameFieldStringValue:name];
    }
    [savePanel beginSheetModalForWindow:[_controller activeWindow] completionHandler:^(NSInteger result) {
        

       
        if (result == NSOKButton) {
            
            NSData *data = [_controller webArchiveData];
            NSError *error;
            BOOL result = [data writeToURL:[savePanel URL] options:0 error:&error];
            if (!result) {
                NSAlert  *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
        
        savePanel = nil;
    }];
}

-(void)newDocument:(id)sender
{
    [_controller newWindowWithAddress:nil];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    
    [_controller openInExistingWindow:filename];
    
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
    
    return YES;
}

@end
