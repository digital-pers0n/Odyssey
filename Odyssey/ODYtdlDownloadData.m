//
//  ODYtdlDownloadData.m
//  Odyssey
//
//  Created by Terminator on 5/1/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODYtdlDownloadData.h"

#define YTDL_PATH @"/usr/local/bin/youtube-dl"

@interface ODYtdlDownloadData () 
{
    NSTask *_downloadTask;
    NSFileHandle *_fileHandle;
}

@end

@implementation ODYtdlDownloadData

-(id)initWithURL:(NSURL *)url destination:(NSString *)path format:(NSString *)format
{
    self = [super init];
    if (self) {
        
        _completed = NO;
        _destination = path;
        _URL = url;
        _filename = url.relativeString;
        
        //_downloadTask = [NSTask launchedTaskWithLaunchPath:YTDL_PATH arguments:args];
        _downloadTask = [self _newTask];
        _downloadTask.arguments = @[@"-f", format, url.absoluteString];
        _downloadTask.currentDirectoryPath = path;
        NSPipe *outPipe = [[NSPipe alloc] init];
        _downloadTask.standardOutput = outPipe;
        NSPipe *errorPipe = [[NSPipe alloc] init];
        _downloadTask.standardError = errorPipe;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_downloadTask launch];
        });
        
        
    }
    
    return self;
}

-(NSString *)info
{
    NSString *result;
    NSRange range;
    //    NSData *data = _fileHandle.readDataToEndOfFile;
    if (_error) {
        result = _error.localizedDescription;
    } else {
        
        NSData *data = [[_downloadTask.standardOutput fileHandleForReading] readDataToEndOfFile];
        NSArray *stdoutput = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
        for (NSString *string in stdoutput) {
            range = [string rangeOfString:@"[ffmpeg] Merging formats into "];
            if (range.length) {
                _destination = [string substringWithRange:NSMakeRange(range.length, string.length)];
                break;
            } else {
                range = [string rangeOfString:@"[download] Destination: "];
                if (range.length) {
                    _destination = [string substringWithRange:NSMakeRange(range.length, string.length)];
                     break;
                }
               
            }
        }
        if (!_completed) {
            result = stdoutput.lastObject;
        } else {
            result = @"Download Finished";
        }
    }
    
    
    return result;
}

-(void)stop
{
    if (!_completed) {
        [_downloadTask terminate];
        //  [_fileHandle closeFile];
    }
    
}

-(void)resume
{
    if (!_completed) {
        NSArray *args = _downloadTask.arguments;
        _downloadTask = [self _newTask];
        _downloadTask.arguments = args;
        _downloadTask.currentDirectoryPath = _destination;
        NSPipe *outPipe = [[NSPipe alloc] init];
        _downloadTask.standardOutput = outPipe;
        NSPipe *errorPipe = [[NSPipe alloc] init];
        _downloadTask.standardError = errorPipe;
        
        [_downloadTask launch];
    }
}

-(void)downloadTaskDidFinish:(NSNotification *)notification
{
    int status = _downloadTask.terminationStatus;
    if (status) {
        
        NSPipe *errorPipe = _downloadTask.standardError;
        NSString *errorString = [[NSString alloc] initWithData:[errorPipe.fileHandleForReading readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        errorString = [NSString stringWithFormat:@"youtube-dl: Download Failed %@", errorString];
        
        NSDictionary *errorDictionary = @{ NSLocalizedFailureReasonErrorKey : errorString};
        _error = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:errorDictionary];
    } else {
        _completed = YES;
        NSLog(@"youtube-dl: downloadDidFinish");
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:_downloadTask];
}

-(NSTask *)_newTask
{
    NSTask *result = [[NSTask alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidFinish:) name:NSTaskDidTerminateNotification object:result];
    result.launchPath = YTDL_PATH;
    //    _fileHandle = [NSFileHandle fileHandleWithStandardOutput];
    //    result.standardOutput = _fileHandle;
    
    //    [_downloadTask setStandardOutput:outPipe];
    
    //    NSPipe *errorPipe = [[NSPipe alloc] init];
    //    _downloadTask.standardError = errorPipe;
    //    [_downloadTask setStandardError:errorPipe];
    
    return result;
}

@end
