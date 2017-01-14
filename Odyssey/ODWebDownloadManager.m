//
//  ODWebDownloadManager.m
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebDownloadManager.h"
#import "ODWebDownloadData.h"
#import "ODWebDownloadView.h"

@import WebKit;

@interface ODWebDownloadManager () <WebDownloadDelegate>
{
    NSMenuItem *_saveImage;
    NSMutableArray *_downloads;
    ODWebDownloadView *_ctl;
    
}


@end

@implementation ODWebDownloadManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_downloads = [NSMutableArray new];
        
        self->_saveImage = [[NSMenuItem alloc] initWithTitle:@"Save Image" action:@selector(saveImage:) keyEquivalent:@""];
        self->_saveImage.target = self;
        self->_saveImage.tag = 1000;
        
        self->_ctl = [[ODWebDownloadView alloc] init];
        
        
    }
    return self;
}



+(id)sharedManager
{   
    static ODWebDownloadManager *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[ODWebDownloadManager alloc] init];
    });
    return result;
}

-(NSArray *)downloads
{
    return _downloads;
}

-(NSMenuItem *)saveImage
{
    return _saveImage;
}

-(void)showDownloads
{
    [_ctl.view setNeedsDisplay:YES];
    [_ctl showPopover];
}

#pragma mark - Actions

-(void)removeAll
{
    for (ODWebDownloadData *data in [_downloads copy]) {
        if (![data isCompleted]) {
            [data.download cancel];
            
        }
        
        [_downloads removeObject:data];
    }
}

-(void)removeDownloadAtIndex:(NSUInteger)idx
{
    
    ODWebDownloadData *data = [_downloads objectAtIndex:idx];
    if (![data isCompleted]) {
        [data.download cancel];
    }
    
    [_downloads removeObject:data];
    
}

-(void)resumeDownloadAtIndex:(NSUInteger)idx
{
    NSUInteger count = _downloads.count;
    if (count && idx <= (count - 1)) {
        
        ODWebDownloadData *data = [_downloads objectAtIndex:idx];
        if (![data isCompleted]) {
            [data resume];
        }
        
    }
}

-(void)pauseDownloadAtIndex:(NSUInteger)idx
{
    NSUInteger count = _downloads.count;
    if (count && idx <= (count - 1)) {
        
        ODWebDownloadData *data = [_downloads objectAtIndex:idx];
        if (![data isCompleted]) {
            [data.download cancel];
        }
        
    }
}

- (void)startDownloadingURL:(id)sender
{
    // Create the request.
   
    //NSString *url = [[repObj objectForKey:@"WebElementLinkURL"] absoluteString];
    NSURL *url;
    
    if ([sender respondsToSelector:@selector(representedObject)]) {
        
        NSDictionary *repObj = [sender representedObject];
        long tag = [sender tag];
        switch (tag) {
            case WebMenuItemTagDownloadImageToDisk:
                url = [repObj objectForKey:WebElementImageURLKey];
                break;
            case WebMenuItemTagDownloadLinkToDisk:
                url = [repObj objectForKey:WebElementLinkURLKey];
                break;
            case 2043:
                url = [repObj objectForKey:@"WebElementMediaURL"];
                break;
                
                
            default:
                break;
        }
        
    } else {
        url = [sender isKindOfClass:[NSString class]] ? [NSURL URLWithString:sender] : sender;
        
//        if ([sender isKindOfClass:[NSString class]]) {
//            
//             url = [NSURL URLWithString:sender];
//            
//        } else {
//            
//            url = sender;
//        }
       
    }
    

//    if ([sender tag] == WebMenuItemTagDownloadImageToDisk) {
//        url = [repObj objectForKey:@"WebElementImageURL"];
//    } else {
//        url = [repObj objectForKey:@"WebElementLinkURL"];
//    }
//    
//    if ([sender tag] == 2043) {
//        url = [repObj objectForKey:@"WebElementMediaURL"];
//    }
    
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    
    destinationFilename = [homeDirectory stringByAppendingPathComponent:@"Downloads"];
    
    ODWebDownloadData *data = [[ODWebDownloadData alloc] initWithURL:url destination:destinationFilename];
    
    //[_downloads addObject:data];
    [_downloads insertObject:data atIndex:0];
    
}


-(void)saveImage:(id)sender
{
    
    
    //    
    //NSDictionary *repObj = [sender representedObject];
    
    WebResource *rsc =  [sender representedObject];
    
    NSURL *url = rsc.URL; //[repObj objectForKey:@"WebElementImageURL"];
    //       
    //   
    //    DOMHTMLImageElement *frame = [repObj objectForKey:@"WebElementDOMNode"]; 
    
    // WebFrame *frm = [repObj objectForKey:@"WebElementFrame"];
    //[[frm dataSource] subresourceForURL:url];
    NSData *imageData = [rsc data];
    //    [ writeToFile:@"/tmp/testdata.jpg" atomically:YES];
    //    
    NSString * name = [url lastPathComponent];
    
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Downloads"]
                           stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilename]) {
        [imageData writeToFile:destinationFilename atomically:YES];
    } else {
        NSDate *date = [NSDate date];
        NSString *newName = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
        newName = [newName stringByReplacingOccurrencesOfString:@"," withString:@""];
        newName = [newName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        newName = [newName stringByReplacingOccurrencesOfString:@":" withString:@"."];
        NSString *nameExtension = [name pathExtension];
        newName = [NSString stringWithFormat:@"%@-%@.%@", [name stringByDeletingPathExtension], newName, nameExtension];
        destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Downloads"]
                               stringByAppendingPathComponent:newName];
        [imageData writeToFile:destinationFilename atomically:YES];
    }
    
}
@end
