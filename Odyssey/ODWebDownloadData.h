//
//  ODWebDownloadData.h
//  Odyssey
//
//  Created by Terminator on 12/17/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODWebDownloadData : NSObject

-(id)initWithURL:(NSURL *)url destination:(NSString *)path;

@property (readonly) NSURLDownload *download;
@property (readonly) int bytesReceived;
@property (readonly) float percentComplete;
@property (readonly) long long expectedLength;

@property (readonly) NSString *destination;
@property (readonly) NSString *filename;
@property (readonly) NSURLRequest *initialRequest;

@property (readonly, getter=isCompleted) BOOL completed;
@property (readonly)NSError *error;


-(void)resume;

@end
