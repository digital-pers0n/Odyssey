//
//  ODWebView.m
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebView.h"
#import "ODController.h"
#import "AppDelegate.h"
//#import "WebViewPrivate.h"
#import "WebPreferencesPrivate.h"
#import "ODWebPreferences.h"

@interface WebStorageManager : NSObject

+ (WebStorageManager *)sharedWebStorageManager;

// Returns an array of WebSecurityOrigin objects that have LocalStorage.
- (NSArray *)origins;

- (void)deleteAllOrigins;
- (void)deleteOrigin:(id *)origin;
- (unsigned long long)diskUsageForOrigin:(id *)origin;

- (void)syncLocalStorage;
- (void)syncFileSystemAndTrackerDatabase;

+ (NSString *)_storageDirectoryPath;
+ (void)setStorageDatabaseIdleInterval:(double)interval;
+ (void)closeIdleLocalStorageDatabases;
@end



@interface ODWebView ()
{
    NSUInteger _windowNumber;
}

@end

@implementation ODWebView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSString* dbPath = [WebStorageManager _storageDirectoryPath];
        
         //[[self preferences] setAutosaves:YES];
        WebPreferences* prefs = [self preferences];
        NSString* localDBPath = [prefs _localStorageDatabasePath];
        prefs.showsURLsInToolTips = NO;
        // PATHS MUST MATCH!!!!  otherwise localstorage file is erased when starting program
        if( [localDBPath isEqualToString:dbPath] == NO) {
            [prefs setAutosaves:YES];  //SET PREFS AUTOSAVE FIRST otherwise settings aren't saved.
            // Define application cache quota
//            static const unsigned long long defaultTotalQuota = 10 * 1024 * 1024; // 10MB
//            static const unsigned long long defaultOriginQuota = 5 * 1024 * 1024; // 5MB
//            [prefs setApplicationCacheTotalQuota:defaultTotalQuota];
//            [prefs setApplicationCacheDefaultOriginQuota:defaultOriginQuota];
//            
//            [prefs setWebGLEnabled:YES];
            [prefs setOfflineWebApplicationCacheEnabled:YES];
            
            [prefs setDatabasesEnabled:YES];
            //[prefs setDeveloperExtrasEnabled:[[NSUserDefaults standardUserDefaults] boolForKey: @"developer"]];

            [prefs setDeveloperExtrasEnabled:YES];

            [prefs _setLocalStorageDatabasePath:dbPath];
            [prefs setLocalStorageEnabled:YES];
            
            [prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
            //[prefs setInvisibleAutoplayNotPermitted:YES];
            [prefs setMediaPlaybackRequiresUserGesture:YES];
            if ([prefs respondsToSelector:@selector(setImageControlsEnabled:)]) {
                [prefs setImageControlsEnabled:YES];
            }
            
            [prefs setShrinksStandaloneImagesToFit:YES];
           
            
            [self setPreferences:prefs];
        }
       // [self setTextSizeMultiplier:1.0f];
        [self setMaintainsBackForwardList:YES];
        [self setShouldUpdateWhileOffscreen:NO];
        //[prefs setVideoPluginProxyEnabled:NO];
        //[prefs setQTKitEnabled:NO];
        //[prefs setPlugInsEnabled:NO];
        
        //[self setApplicationNameForUserAgent:@"Odyssey/0.5 Version/9.0 Safari/9046A194A"];
        [self setApplicationNameForUserAgent:DEFAULT_USERAGENT_NAME];

        //[self performSelector:@selector(setPageSizeMultiplier:) withObject:[NSNumber numberWithFloat:1]];
        //[self performSelector:@selector(_setPageLength:) withObject:[NSNumber numberWithFloat:0.1]];
       // [self _scaleWebView:0.5 atOrigin:NSZeroPoint];
        [self _setUseFastImageScalingMode:NO];
        [self setPageSizeMultiplier:0.9];
        
        //[self _setCustomBackingScaleFactor:0.9];
    }
    return self;
}

-(BOOL)allowsVibrancy
{
    return NO;
}
-(BOOL)isOpaque
{
    return YES;
}

-(void)close
{
    [super close];
    [self stopLoading:self];
    [self.mainFrame stopLoading];
    self.resourceLoadDelegate  = nil;
    self.UIDelegate = nil;
    self.policyDelegate = nil;
    self.downloadDelegate = nil;
    self.frameLoadDelegate = nil;
    self.hostWindow = nil;
    
    [self setMaintainsBackForwardList:NO];
 //   [self setUsesPageCache:NO];
    [self removeFromSuperview];
    
    
    
}

-(void)viewDidHide
{
   
   [self removeFromSuperview];
    

}

-(void)viewDidUnhide
{
    

    NSWindow *win;
    win = self.hostWindow;
    
    if (!win) {
        
        id delegate = [NSApp delegate];
        ODController *ctl = [delegate performSelector:@selector(controller)];
        win = [ctl activeWindow];
    }
    
    [win.contentView addSubview:self positioned:NSWindowBelow relativeTo:nil];
//    [win.contentView addSubview:self];
    [self.window.windowController performSelector:@selector(updateTitle)];
    NSRect frame = self.window.contentView.frame;
    [self setFrameSize:NSMakeSize(NSWidth(frame), NSHeight(frame))];
    //[self setFrameOrigin:NSMakePoint(0, 0)];
    //[self setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
//    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    
    [self.window setInitialFirstResponder:self];
    
    [self setNeedsDisplay:YES];
    
 
    
}

@end
