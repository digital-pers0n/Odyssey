//
//  ODWebDownloadData.m
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODWebDownloadData.h"
@import WebKit;

@interface ODWebDownloadData () <WebDownloadDelegate>
{
    //NSMutableDictionary *_data;
    WebDownload *_download;
    NSURLRequest *_initialRequest;
    NSURLResponse *_downloadResponse;
    
    NSString *_destination;
    NSString *_filename;
    
    int _bytesReceived;
    float _percentComplete;
    long long _expectedLength;
    
    BOOL _completed;
    NSError *_error;
}




@end

@implementation ODWebDownloadData


-(id)initWithURL:(NSURL *)url destination:(NSString *)path
{
    self = [super init];
    if (self) {
        
        self->_completed = NO;
        self->_destination = path;
        self->_initialRequest = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        
        // Create the download with the request and start loading the data.
        self->_download = [[WebDownload alloc] initWithRequest:self->_initialRequest delegate:self];
        [self->_download setDeletesFileUponFailure:NO];
       
        if (!self->_download) {
            NSLog(@"initWithURL:destination: - error\npath:%@\nurl:%@\nrequest:%@", path, url, self->_initialRequest);
            // Inform the user that the download failed.
        }
        
    }
    
    return self;
}

-(void)resume
{
    _download = [[WebDownload alloc] initWithResumeData:_download.resumeData delegate:self path:_filename];
}

-(NSString *)description
{
    NSString *result;
    
    if (!self.error) {
        
        if (_filename) {
            
            NSString *bytes;
            if (_expectedLength != NSURLResponseUnknownLength) {
                
                bytes = [NSByteCountFormatter stringFromByteCount:_expectedLength countStyle:NSByteCountFormatterCountStyleFile];
            }
            
            if (!_completed) {
                
                
                NSString *received;
                
                received = [NSByteCountFormatter stringFromByteCount:_bytesReceived countStyle:NSByteCountFormatterCountStyleFile];
                if (bytes) {
                    
                    received = [NSString stringWithFormat:@"%@ %@", received, bytes];
                }
                
                result = [NSString stringWithFormat:@"%@ %.1f%% - %@", received, _percentComplete, _filename];
                
                
            } else {
                
                result = [NSString stringWithFormat:@"%@ - %@", bytes, _filename];
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

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType
{
    return NO;
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    
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
}

- (void)download:(NSURLDownload *)download willResumeWithResponse:(NSURLResponse *)response fromByte:(long long)startingByte
{
    _downloadResponse = response;
    _bytesReceived = (int)startingByte;
    
}

- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse
{
    // downloadResponse is an instance variable defined elsewhere.
    _downloadResponse = aDownloadResponse;
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    // Reset the progress, this might be called multiple times.
    // bytesReceived is an instance variable defined elsewhere.
    _bytesReceived = 0;
    
    // Store the response to use later.
    [self setDownloadResponse:response];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
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
}
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Dispose of any references to the download object
    // that your app might keep.
    
    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    _error = error;
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    // Dispose of any references to the download object
    // that your app might keep.
    if (_expectedLength == NSURLResponseUnknownLength) {
        _expectedLength = _bytesReceived;
    }
    
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
    _completed = YES;
}
@end
