//
//  ODDownloadData.m
//  Odyssey
//
//  Created by Terminator on 4/20/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODDownloadData.h"
@import WebKit;

@interface ODDownloadData () <WebDownloadDelegate>
{
    WebDownload *_download;
    NSURLRequest *_initialRequest;
    NSURLResponse *_downloadResponse;
    NSByteCountFormatter *_byteFormatter;
    
    NSString *_destination;
    NSString *_filename;
    
    int _bytesReceived;
    float _percentComplete;
    long long _expectedLength;
    
    BOOL _completed;
    NSError *_error;
    
    dispatch_source_t _updateTimer;
}


@end

@implementation ODDownloadData

-(id)initWithURL:(NSURL *)url destination:(NSString *)path
{
    self = [super init];
    if (self) {
        
        _completed = NO;
        _destination = path;
        _URL = url;
        _initialRequest = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:128.0];
        
        // Create the download with the request and start loading the data.
        _download = [[WebDownload alloc] initWithRequest:_initialRequest delegate:self];
        [_download setDeletesFileUponFailure:NO];
        
        _byteFormatter = [[NSByteCountFormatter alloc] init];
        //_byteFormatter.adaptive = NO;
        _byteFormatter.zeroPadsFractionDigits = YES;
        _byteFormatter.allowsNonnumericFormatting = NO;
        
        if (!_download) {
            NSLog(@"initWithURL:destination: - error\npath:%@\nurl:%@\nrequest:%@", path, url, _initialRequest);
            // Inform the user that the download failed.
        }
        
    }
    
    return self;
}

-(void)stop
{
    [_download cancel];
}

-(void)resume
{
    _completed = NO;
    _error = nil;
    NSData *resumeData = _download.resumeData;
    if (resumeData) {
         _download = [[WebDownload alloc] initWithResumeData:resumeData delegate:self path:_destination];
    } else {
        _download = [[WebDownload alloc] initWithRequest:_initialRequest delegate:self];
    }
   
    if (!_download) {
        NSLog(@"resume - error\npath:%@\nurl:%@\nrequest:%@", _filename, _initialRequest.URL, _initialRequest);
        // Inform the user that the download failed.
    }
    [_delegate downloadDataDidUpdate:self];
}

-(NSString *)info
{
    NSString *result;
    
    if (!_error) {
        
        if (_filename) {
            
            NSString *bytes;
            if (_expectedLength != NSURLResponseUnknownLength && _expectedLength != 0) {
                
                //bytes = [NSByteCountFormatter stringFromByteCount:_expectedLength countStyle:NSByteCountFormatterCountStyleFile];
                bytes = [_byteFormatter stringFromByteCount:_expectedLength];
            }
        
            
            if (!_completed) {
                
                NSString *received;
               // received = [NSByteCountFormatter stringFromByteCount:_bytesReceived countStyle:NSByteCountFormatterCountStyleFile];
                received = [_byteFormatter stringFromByteCount:_bytesReceived];
                
                if (bytes.length) {
                    
                    received = [NSString stringWithFormat:@"%@ of %@", received, bytes];
                }
                
                result = [NSString stringWithFormat:@"%@ : %.1f%%", received, _percentComplete];
                
                
            } else {
                
                result = [NSString stringWithFormat:@"%@ - Completed", bytes];
            }
        } else {
            
            result = @"Preparing...";
        }
    } else {
        
        result = _error.localizedDescription;
    }
    
    return result;
}

#pragma mark - Download Delegate

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType {
    return NO;
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename {
    
    NSString *destinationFilename;
    _filename = filename;
    if (_destination) {
        
        
        destinationFilename = [_destination stringByAppendingPathComponent:filename];
        
    } else {
        
        NSString *homeDirectory = NSHomeDirectory();
        
        
        destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Downloads"]
                               stringByAppendingPathComponent:filename];  
    }
    
    _destination = destinationFilename;
    [download setDestination:destinationFilename allowOverwrite:NO];
    [_delegate downloadDataDidUpdate:self];
}

- (void)download:(NSURLDownload *)download willResumeWithResponse:(NSURLResponse *)response fromByte:(long long)startingByte {
    _downloadResponse = response;
    _bytesReceived = (int)startingByte;
    [_delegate downloadDataDidUpdate:self];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response {
    // Reset the progress, this might be called multiple times.
    // bytesReceived is an instance variable defined elsewhere.
    _bytesReceived = 0;
    
    // Store the response to use later.
    _downloadResponse = response;
    [_delegate downloadDataDidUpdate:self];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length {
    _expectedLength = [_downloadResponse expectedContentLength];
    
    _bytesReceived = _bytesReceived + (int)length;
    
    if (_expectedLength != NSURLResponseUnknownLength) {
        // If the expected content length is
        // available, display percent complete.
        _percentComplete = (_bytesReceived/(float)_expectedLength)*100.0;
        // NSLog(@"Percent complete - %f",_percentComplete);
    } else {
        // If the expected content length is
        // unknown, just log the progress.
        //NSLog(@"Bytes received - %d",_bytesReceived);
    }
    static int updates = 0;
    if (updates > 4) {
         [_delegate downloadDataDidUpdate:self];
        updates = 0;
    } else {
        updates++;
    }
    
}
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
    // Dispose of any references to the download object
    // that your app might keep.
    
    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    _error = error;
    [_delegate downloadDataDidUpdate:self];
}

- (void)downloadDidFinish:(NSURLDownload *)download {
    // Dispose of any references to the download object
    // that your app might keep.
    if (_expectedLength == NSURLResponseUnknownLength) {
        _expectedLength = _bytesReceived;
    }
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
    NSString *string = [NSString stringWithFormat:@"display notification \"%@\" with title \"Finished '%@'\"", _URL, _filename];
    //system([string cStringUsingEncoding:NSUTF8StringEncoding]);
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:string];
    [script executeAndReturnError:nil];
    _completed = YES;
    [_delegate downloadDataDidUpdate:self];
}


@end
