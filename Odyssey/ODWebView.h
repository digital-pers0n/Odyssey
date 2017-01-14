//
//  ODWebView.h
//  OD
//
//  Created by Terminator on 9/23/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebView (WebViewPrivate)

-(void)_scaleWebView:(float)scale atOrigin:(NSPoint)origin;
- (void)_setUseFastImageScalingMode:(BOOL)flag;
- (void)_setCustomBackingScaleFactor:(CGFloat)overrideScaleFactor;
- (BOOL)usesPageCache;
- (void)setUsesPageCache:(BOOL)usesPageCache;
/*!
 @method setPageSizeMultiplier:
 @abstract Change the zoom factor of the page in views managed by this webView.
 @param multiplier A fractional percentage value, 1.0 is 100%.
 */    
- (void)setPageSizeMultiplier:(float)multiplier;

/*!
 @method pageSizeMultiplier
 @result The page size multipler.
 */    
- (float)pageSizeMultiplier;

@end

@interface WebPreferences (WebPreferencesPrivate)

-(NSString *)_localStorageDatabasePath;

@end
@interface ODWebView : WebView

@end
