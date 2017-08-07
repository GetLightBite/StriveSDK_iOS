//
//  PreviewController.m
//  StriveCamera
//
//  Created by Nightman on 8/6/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "PreviewController.h"

@interface PreviewController ()

@end

@implementation PreviewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBackButton];
    [self setupImage];
}

- (void)setupImage
{
    UIImageView *imageView = [UIImageView new];
    imageView.frame = self.view.frame;
    imageView.image = self.image;
    [self.view insertSubview:imageView
                     atIndex:0];
}

- (void)setupBackButton
{
    UIButton *closeButton = [UIButton new];
    closeButton.frame = CGRectMake(20, 40, 45, 45);
    [closeButton setImage:[UIImage imageNamed:@"whiteXButton"]
                 forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(tappedClose)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)tappedClose
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
