//
//  SessionHandler.m
//  Strive
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "SessionHandler.h"
#import <UIKit/UIKit.h>

#import <Strive/Strive.h>

@interface SessionHandler ()

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) dispatch_queue_t captureSessionQueue;
@property (nonatomic) StriveInstance *strive;

@end

@implementation SessionHandler

- (id)init
{
    self = [super init];
    if (self) {
        _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);

        self.layer = [AVSampleBufferDisplayLayer new];
        
        self.strive = [StriveInstance shared];
    }
    return self;
}

- (void)openSession
{
    NSError *error = nil;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *_videoDevice = videoDevices.lastObject;
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            _videoDevice = device;
            break;
        }
    }
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!videoDeviceInput)
    {
        NSLog(@"Unable to obtain video device input, error: %@", error);
        return;
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    videoDataOutput.videoSettings = outputSettings;

    [videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];

    [_captureSession beginConfiguration];

    // CoreImage wants BGRA pixel format
    
    // create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;

    if ([_captureSession canAddInput:videoDeviceInput]) {
        [_captureSession addInput:videoDeviceInput];
    }
    if ([_captureSession canAddOutput:videoDataOutput]) {
        [_captureSession addOutput:videoDataOutput];
        AVCaptureConnection *cnx = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        cnx.videoOrientation = AVCaptureVideoOrientationPortrait;
        cnx.videoMirrored = YES;
    }
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

- (void)start
{
    if (!_captureSession) {
        [self openSession];
    } else {
        [_captureSession startRunning];
    }
}

- (void)stop;
{
    if (_captureSession) {
        [_captureSession stopRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (self.selectedIndex == 0) {
        [self.layer enqueueSampleBuffer:sampleBuffer];
        return;
    }

    STVFilter f = self.selectedIndex;
    [self.strive applyFilter:f
                 sampleBuffer:sampleBuffer
                   completion:^(CMSampleBufferRef sampleBuffer) {
                       [self.layer enqueueSampleBuffer:sampleBuffer];
                   }];
}

@end
