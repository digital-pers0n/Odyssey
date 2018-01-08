//
//  ODYtdlDownloadData.h
//  Odyssey
//
//  Created by Terminator on 5/1/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODYtdlDownloadData : NSObject

-(instancetype)initWithURL:(NSURL *)url destination:(NSString *)path format:(NSString *)format; // e.g. format = @"137+140";

@property (readonly) NSString *destination;
@property (readonly) NSString *filename;
@property (readonly) NSURL *URL;
@property (readonly, getter=isCompleted) BOOL completed;
@property (readonly) NSError *error;
-(void)resume;
-(void)stop;
-(NSString *)info;

@end
