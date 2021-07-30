//
//  ODKWindowController.mm
//  Odyssey
//
//  Created by Terminator on 2021/7/27.
//  Copyright © 2021年 home. All rights reserved.
//

#import "ODKWindowController.h"
#import <WebKit/WebKit.h>


#if MAC_OS_X_VERSION_MIN_REQUIRED >= 110000
#define MAC_OS_1100_BUILD 1
#else
#define MAC_OS_1100_BUILD 0
#endif

namespace {
NSPasteboardType ODKPasteboardTypeFileURL() noexcept {
#if MAC_OS_1100_BUILD
    return NSPasteboardTypeFileURL;
#else
    return NSPasteboardType(kUTTypeFileURL);
#endif
}

NSPasteboardType ODKPasteboardTypeURL() noexcept {
#if MAC_OS_1100_BUILD
    return NSPasteboardTypeURL;
#else
    return NSPasteboardType(kUTTypeURL);
#endif
}
} // anonymous namespace

@interface ODKWindowController () <NSWindowDelegate, NSDraggingDestination> {
    WKWebView *_webView;
}

@end

@implementation ODKWindowController

- (NSNibName)windowNibName {
    return self.className;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    auto wk = [[WKWebView alloc] initWithFrame:{{}, {640, 480}}];
    auto win = self.window;
    win.contentView = wk;
    _webView = wk;
    [win registerForDraggedTypes:@[ ODKPasteboardTypeFileURL(),
                                    ODKPasteboardTypeURL() ]];
}

//MARK: - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    auto pboard = sender.draggingPasteboard;
    if ([pboard.types containsObject:ODKPasteboardTypeFileURL()]
        || [pboard.types containsObject:ODKPasteboardTypeURL()]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    auto pb = sender.draggingPasteboard;
    NSArray<NSURL*> *urls = [pb readObjectsForClasses:@[NSURL.class]
                                              options:nil];
    if (urls.count) {
        auto url = urls.firstObject;
        if ([url isFileURL]) {
            url = [url filePathURL];
            [_webView loadFileURL:url allowingReadAccessToURL:url];
        } else {
            auto req = [NSURLRequest requestWithURL:url];
            [_webView loadRequest:req];
        }
        return YES;
    }
    return NO;
}

@end
