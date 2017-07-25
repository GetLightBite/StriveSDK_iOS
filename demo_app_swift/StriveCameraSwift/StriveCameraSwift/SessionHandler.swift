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
    var captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    let strive = StriveInstance()

    
    func openSession() {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.front)
        var device : AVCaptureDevice? = nil
        for deviceCandidate in (deviceDiscoverySession?.devices)! {
            if(deviceCandidate.position == AVCaptureDevicePosition.front){
                device = deviceCandidate
            }
        }
        
        var input : AVCaptureDeviceInput? = nil
        do{
            input = try AVCaptureDeviceInput(device: device)
        }catch{
            print("exception!");
            return
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput();
        
        let settingsDict = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.videoSettings = settingsDict
        videoDataOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
        
        captureSession.beginConfiguration()

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if(captureSession.canAddInput(input)){
            captureSession.addInput(input);
        }

        if(captureSession.canAddOutput(videoDataOutput)){
            captureSession.addOutput(videoDataOutput);
            
            let cnx : AVCaptureConnection? = videoDataOutput.connections.first as? AVCaptureConnection
            cnx?.videoOrientation = AVCaptureVideoOrientation.portrait
            cnx?.isVideoMirrored = true
        }
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

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
