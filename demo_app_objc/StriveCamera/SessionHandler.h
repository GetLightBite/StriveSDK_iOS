//
//  SessionHandler.h
//  Aviato
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CameraController.h"
#import <Foundation/Foundation.h>

@class CameraController;
@interface SessionHandler : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVSampleBufferDisplayLayer *layer;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL takePhoto;
@property (nonatomic) CameraController *camera;

- (void)openSession;
- (void)start;
- (void)stop;

@end
