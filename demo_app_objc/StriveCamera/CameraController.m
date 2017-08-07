//
//  CameraController.m
//  Aviato
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "CameraController.h"
#import "PreviewController.h"

@interface CameraController ()

@property (nonatomic) SessionHandler *sessionHandler;
@property (nonatomic) AKPickerView *pickerView;
@property (nonatomic) NSArray<UIImage *> *pickerImages;
@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation CameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    [self resume];

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resume];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self pauseVideo];
}

- (void)setupPicker
{

    if (self.pickerView) {
        [self.view addSubview:self.pickerView];
        return;
    }
    self.pickerView = [[AKPickerView alloc] init];

    NSInteger pickerHeight = 100;
    NSInteger pickerBottomMargin = 50;
    NSInteger pickerY = self.view.frame.size.height - pickerHeight - pickerBottomMargin;
    CGRect pickerFrame = CGRectMake(0,
                                    pickerY,
                                    self.view.frame.size.width,
                                    pickerHeight);
    self.pickerView.frame = pickerFrame;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    UIImageView *selectionImageView = [UIImageView new];
    NSInteger selectionImageSize = 85;
    selectionImageView.frame = CGRectMake(0,
                                          0,
                                          selectionImageSize,
                                          selectionImageSize);
    selectionImageView.image = [UIImage imageNamed:@"selectorCircle"];
    selectionImageView.center = CGPointMake(self.view.frame.size.width/2,
                                            selectionImageSize/2 + pickerHeight - selectionImageSize - 2);
    [self.pickerView addSubview:selectionImageView];
    
    self.pickerView.fisheyeFactor = 0.0f;
    self.pickerView.pickerViewStyle = AKPickerViewStyleFlat;
    
    UIButton *takePhotoButton = [UIButton new];
    takePhotoButton.backgroundColor = [UIColor clearColor];
    takePhotoButton.frame = CGRectMake(0, 0, 55, 55);
    takePhotoButton.center = selectionImageView.center;
    [takePhotoButton addTarget:self
                        action:@selector(tappedTakePicture)
              forControlEvents:UIControlEventTouchUpInside];
    [self.pickerView addSubview:takePhotoButton];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = takePhotoButton.center;
    [self.spinner stopAnimating];
    [self.pickerView addSubview:self.spinner];

    UIImage *mehFace = [UIImage imageNamed:@"mehFace"];
    UIImage *irish1 = [UIImage imageNamed:@"irish1"];
    UIImage *irish2 = [UIImage imageNamed:@"irish2"];
    UIImage *irish3 = [UIImage imageNamed:@"irish3"];
    
    self.pickerImages = @[mehFace, irish3, irish1, irish2];
}

- (void)pauseVideo
{
    [self.sessionHandler stop];
    [self.pickerView removeFromSuperview];
}

- (void)resume
{
    self.sessionHandler = [SessionHandler new];
    self.sessionHandler.camera = self;
    [self.sessionHandler openSession];

    AVSampleBufferDisplayLayer *layer = self.sessionHandler.layer;
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    [self.view layoutIfNeeded];

    [self setupPicker];
}

# pragma mark - AKPickerView Methods

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
    return self.pickerImages.count;
}

- (UIImage *)pickerView:(AKPickerView *)pickerView
           imageForItem:(NSInteger)item
{
    UIImage *image = self.pickerImages[item];
    NSInteger imageSize = self.view.frame.size.width/5;
    NSInteger newHeight = image.size.height * (imageSize/image.size.width);

    CGSize newSize = CGSizeMake(imageSize, newHeight);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)pickerView:(AKPickerView *)pickerView
     didSelectItem:(NSInteger)item
{
    self.sessionHandler.selectedIndex = item;
}

# pragma mark - User Actions

- (void)tappedTakePicture
{
    self.sessionHandler.takePhoto = YES;
    [self.spinner startAnimating];
}

- (void)seePreviewWithImage:(UIImage *)image
{
    PreviewController *previewController = [PreviewController new];
    previewController.image = image;
    [self presentViewController:previewController
                       animated:YES
                     completion:^{
                         [self.spinner stopAnimating];
                     }];
}

@end
