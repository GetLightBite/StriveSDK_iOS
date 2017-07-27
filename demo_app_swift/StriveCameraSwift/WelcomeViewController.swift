//
//  WelcomeViewController.swift
//  StriveCameraSwift
//
//  Created by Nightman on 7/24/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSpinner()
        self.view.backgroundColor = UIColor.init(red: 0.57,
                                                 green: 0.78,
                                                 blue: 0.77,
                                                 alpha: 1.0)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == AVAuthorizationStatus.authorized) {
            self.goToCamera()
        } else if (status == AVAuthorizationStatus.denied) {
            self.showCameraSettingWarning()
        } else {
            self.requestCameraPermission()
        }
    }
    
    func showCameraSettingWarning() {
        let alertController = UIAlertController.init(
            title: "Oops, we need the camera permission",
            message: "Go to your phone's Settings to grant us camera permission, then you'll be able to check out our demo! 🔥",
            preferredStyle: UIAlertControllerStyle.alert)
        let yesButton = UIAlertAction.init(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil)
        alertController.addAction(yesButton)
        self.present(alertController,
                     animated:true,
                     completion:nil)
    }

    func setupSpinner() {
        let spinner = UIActivityIndicatorView.init(
            activityIndicatorStyle: UIActivityIndicatorViewStyle.white
        )
        spinner.center = self.view.center
        spinner.startAnimating()
        self.view.addSubview(spinner)
    }
    
    func goToCamera() {
        let c = CameraController()
        self.navigationController?.pushViewController(c, animated: false)
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
            if response {
                DispatchQueue.main.async {
                    self.goToCamera()
                }
            } else {
                self.showCameraSettingWarning()
            }
        }
    }
}
