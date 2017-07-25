//
//  CameraController.m
//  Aviato
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import "CameraController.h"

@interface CameraController ()

@property (nonatomic) SessionHandler *sessionHandler;
@property (nonatomic) AKPickerView *pickerView;
@property (nonatomic) NSArray<UIImage *> *pickerImages;

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
    self.pickerView = [[AKPickerView alloc] init];
    [self.view addSubview:self.pickerView];

    if (self.pickerView) {
        return;
    }
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
                                            selectionImageSize/2 + pickerHeight - selectionImageSize + 5);
    [self.pickerView addSubview:selectionImageView];
    
    self.pickerView.fisheyeFactor = 0.0f;
    self.pickerView.pickerViewStyle = AKPickerViewStyleFlat;
    
    UIImage *monkeyImage = [UIImage imageNamed:@"coveredMouthMonkey"];
    UIImage *butterfly = [UIImage imageNamed:@"butterflyButton"];
    UIImage *mehFace = [UIImage imageNamed:@"mehFace"];
    UIImage *mask = [UIImage imageNamed:@"maskButton"];
    UIImage *bunny = [UIImage imageNamed:@"rabbit"];
    UIImage *plane = [UIImage imageNamed:@"planeButton"];
    UIImage *pizza = [UIImage imageNamed:@"bigNose"];
    UIImage *water = [UIImage imageNamed:@"bubbleFace"];
    UIImage *tiger = [UIImage imageNamed:@"tigerFace"];
    
    self.pickerImages = @[mehFace, butterfly, mask, bunny, plane, monkeyImage, tiger, water, pizza];
}

- (void)pauseVideo
{
    [self.sessionHandler stop];
    [self.pickerView removeFromSuperview];
}

- (void)resume
{
    self.sessionHandler = [SessionHandler new];
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

@end
