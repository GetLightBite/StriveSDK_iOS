//
//  SessionHandler.h
//  Aviato
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface SessionHandler : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVSampleBufferDisplayLayer *layer;
@property (nonatomic) NSInteger selectedIndex;

- (void)openSession;
- (void)start;
- (void)stop;

@end
