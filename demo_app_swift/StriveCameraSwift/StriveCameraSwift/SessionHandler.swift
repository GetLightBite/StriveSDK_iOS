//
//  SessionHandler.swift
//  StriveCameraSwift
//
//  Created by Nightman on 7/24/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class SessionHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    let layer = AVSampleBufferDisplayLayer()
    var selectedIndex = 0
    let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    let strive = StriveInstance()

    
    func openSession() {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.front)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.front){
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        let videoDataOutput = AVCaptureVideoDataOutput();
                        
                        let settingsDict = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
                        videoDataOutput.videoSettings = settingsDict
                        videoDataOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
                        
                        captureSession.beginConfiguration()
                        
                        captureSession.sessionPreset = AVCaptureSessionPresetHigh

                        if(captureSession.canAddOutput(videoDataOutput)){
                            captureSession.addOutput(videoDataOutput);
                            
                            let cnx = videoDataOutput.connection(withMediaType: "AVMediatTypeVideo")
                            cnx?.videoOrientation = AVCaptureVideoOrientation.portrait
                            cnx?.isVideoMirrored = true
                            
                            captureSession.commitConfiguration()
                            captureSession.startRunning()
                        }
                    }
                }
                catch{
                    print("exception!");
                }
            }
        }
    }
    /*
    func openSession33() {
        var error : Error;
        let devices = AVCaptureDevice.devices().filter{ ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == AVCaptureDevicePosition.front }
        let videoDevice = devices.first as? AVCaptureDevice
        if videoDevice != nil  {
            let videoDeviceInput = try AVCaptureDeviceInput.init(device: videoDevice)
            if (videoDeviceInput == nil) {
//                print(@"Unable to obtain video device input, error: %@", error)
                return
            }
            if (captureSession.canAddInput(videoDeviceInput)) {
                captureSession.addInput(videoDeviceInput)
            }
        }

    }

    func openSession2() {
        let devices = AVCaptureDevice.devices().filter{ ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == AVCaptureDevicePosition.front }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            var error : Error
            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            let aPixelFormat = NSNumber(int: kCVPixelFormatType_32BGRA)
            let settingsDict = NSDictionary(aPixelFormat,
                forKey:  "numberWithUnsignedInt:kCVPixelFormatType_32BGRA")
            videoDataOutput.outputSettings = settingsDict
            
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer.bounds = view.bounds
                previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
                cameraPreview.layer.addSublayer(previewLayer)
                cameraPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"saveToCamera:"))
                view.addSubview(cameraPreview)
            }
        }
    }
 */

    func start() {
        if self.captureSession == nil {
            self.openSession()
        } else {
            self.captureSession.startRunning()
        }
    }
    
    func stop() {
        if self.captureSession != nil {
            self.captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        if (selectedIndex == 0) {
            self.layer.enqueue(sampleBuffer)
            return;
        }
        
        let f : STVFilter = STVFilter(rawValue: selectedIndex)!
        self.strive.apply(f,
                          sampleBuffer: sampleBuffer) { (CMSampleBuffer) in
                            self.layer.enqueue(sampleBuffer)
        }
    }
    
}
