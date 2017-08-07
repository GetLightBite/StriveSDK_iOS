//
//  CameraController2.h
//  Aviato
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "AKPickerView.h"
#import <Foundation/Foundation.h>
#import "SessionHandler.h"
#import <UIKit/UIKit.h>

@interface CameraController : UIViewController <AKPickerViewDataSource, AKPickerViewDelegate>

- (void)seePreviewWithImage:(UIImage *)image;

@end
