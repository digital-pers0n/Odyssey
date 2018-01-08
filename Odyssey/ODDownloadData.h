//
//  ODDownloadData.h
//  Odyssey
//
//  Created by Terminator on 4/20/17.
//  Copyright © 2017 home. All rights reserved.
//

@import Cocoa;

@protocol ODDownloadDataDelegate;

@interface ODDownloadData : NSObject

-(id)initWithURL:(NSURL *)url destination:(NSString *)path;
@property id <ODDownloadDataDelegate> delegate;

@property (readonly) NSURLDownload *download;
@property (readonly) int bytesReceived;
@property (readonly) float percentComplete;
@property (readonly) long long expectedLength;

@property (readonly) NSString *destination;
@property (readonly) NSString *filename;
@property (readonly) NSURL *URL;
@property (readonly) NSURLRequest *initialRequest;

@property (readonly, getter=isCompleted) BOOL completed;
@property (readonly) NSError *error;


-(void)resume;
-(void)stop;
-(NSString *)info;

@end

@protocol ODDownloadDataDelegate <NSObject>

- (void)downloadDataDidUpdate:(ODDownloadData *)data;

@end


