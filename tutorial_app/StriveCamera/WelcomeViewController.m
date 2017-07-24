//
//  WelcomeViewController.m
//  Aviato
//
//  Created by Nightman on 4/19/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSpinner];

    self.view.backgroundColor = [UIColor colorWithRed:0.57
                                                green:0.78
                                                 blue:0.77
                                                alpha:1.0];

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self goToCamera];
    } else if(status == AVAuthorizationStatusDenied){
        [self showAlert:@"Oops, we need the camera permission"
                message:@"Go to your phone's Settings to grant us camera permission, then you'll be able to check out our demo! 🔥"];
    } else {
        [self requestCameraPermission];
    }
}

- (void)setupSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
}

- (void)requestCameraPermission
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goToCamera];
                });
            } else {
                [self showAlert:@"Oops, we need the camera permission"
                        message:@"Go to your phone's Settings to grant us camera permission, then you'll be able to check out our demo! 🔥"];
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
        [self showAlert:@"Oops, looks like you're running an old version of iOS"
                message:@"This demo works with iOS 7 and beyond! Update iOS to see it in action 😎"];
    }
}

- (void)goToCamera
{
    CameraController *cc = [CameraController new];
    [self.navigationController pushViewController:cc animated:NO];
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    [alert addAction:yesButton];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}
@end
