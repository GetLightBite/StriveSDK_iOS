//
//  SessionHandler.m
//  Strive
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "SessionHandler.h"
#import <UIKit/UIKit.h>

@interface SessionHandler ()

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) dispatch_queue_t captureSessionQueue;
@property (nonatomic) dispatch_queue_t faceQueue;

@property (nonatomic) NSInteger frameCount;
@property (nonatomic) NSDate *startTime;

@property (nonatomic) AVAssetWriterInput* writerInput;
@property (nonatomic) AVAssetWriter *videoWriter;
@property NSInteger framesWritten;
@property NSInteger framesSeen;

@end

@implementation SessionHandler

- (id)init
{
    self = [super init];
    if (self) {
        _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
        _faceQueue = dispatch_queue_create("face_queue", NULL);

        self.layer = [AVSampleBufferDisplayLayer new];
        self.framesWritten = 0;
        self.framesSeen = 0;
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
    [self.layer enqueueSampleBuffer:sampleBuffer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
}

@end
