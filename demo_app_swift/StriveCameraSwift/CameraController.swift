//
//  CameraController.swift
//  StriveCameraSwift
//
//  Created by Nightman on 7/24/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

import UIKit

class CameraController: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource {
    var sessionHandler : SessionHandler = SessionHandler()
    let pickerView = AKPickerView()
    var pickerImages : [UIImage] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.resume()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.pauseVideo()
    }
    
    func setupPicker() {
        self.view.addSubview(self.pickerView)
        if (self.pickerView.delegate != nil) {
            return
        }
        let pickerHeight = 100
        let pickerBottomMargin = 50
        let viewSize = self.view.frame.size
        
        let pickerY = Int(viewSize.height) - pickerHeight - pickerBottomMargin
        let pickerFrame = CGRect.init(
            x: 0,
            y: pickerY,
            width: Int(viewSize.width),
            height: pickerHeight
        )
        self.pickerView.frame = pickerFrame
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        let selectionImageSize = 85
        let selectionFrame = CGRect.init(
            x: 0,
            y: 0,
            width: selectionImageSize,
            height: selectionImageSize)
        let selectionImageView = UIImageView.init(frame: selectionFrame)
        selectionImageView.image = UIImage.init(named:"selectorCircle")
        let x = Int(viewSize.width/2)
        let y = selectionImageSize/2 + pickerHeight - selectionImageSize + 5
        selectionImageView.center = CGPoint.init(x: x, y: y)
        self.pickerView.addSubview(selectionImageView)
        
        self.pickerView.fisheyeFactor = 0
        self.pickerView.pickerViewStyle = AKPickerViewStyle.styleFlat

        let monkeyImage = UIImage.init(named:"coveredMouthMonkey")
        let butterfly = UIImage.init(named:"butterflyButton")
        let mehFace = UIImage.init(named:"mehFace")
        let mask = UIImage.init(named:"maskButton")
        let bunny = UIImage.init(named:"rabbit")
        let plane = UIImage.init(named:"planeButton")
        let pizza = UIImage.init(named:"bigNose")
        let water = UIImage.init(named:"bubbleFace")
        let tiger = UIImage.init(named:"tigerFace")

        self.pickerImages = [mehFace!, butterfly!, mask!, bunny!, plane!, monkeyImage!, tiger!, water!, pizza!]
    }
    
    func pauseVideo() {
        self.sessionHandler.stop()
        self.pickerView.removeFromSuperview()
    }
    
    
    func resume() {
        self.sessionHandler = SessionHandler()
        self.sessionHandler.openSession()
        
        let layer = self.sessionHandler.layer
        layer.frame = self.view.frame
        self.view.layer.addSublayer(layer)
        self.view.layoutIfNeeded()
        
        self.setupPicker()
    }

    // Mark: AKPickerView Methods

    func numberOfItems(in pickerView: AKPickerView!) -> UInt {
        return UInt(self.pickerImages.count)
    }
    
    func pickerView(_ pickerView: AKPickerView!, imageForItem item: Int) -> UIImage! {
        let image = self.pickerImages[item]
        let imageSize = self.view.frame.size.width/5
        let newHeight = image.size.height * (imageSize/image.size.width)
        
        let newSize = CGSize.init(width: imageSize, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func pickerView(_ pickerView: AKPickerView!, didSelectItem item: Int) {
        self.sessionHandler.selectedIndex = item
    }
}
