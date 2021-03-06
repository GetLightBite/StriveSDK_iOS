![Alt Text](http://i.imgur.com/c6zm4tN.gif)

# StriveSDK: Augmented Reality Face Filters SDK for iOS

StriveSDK for iOS makes it dead simple to add live effects to your app’s camera experience. With one line of code, you’ll help users instantly look more photogenic, creative, and comfortable with the camera.


In this repo, you'll find:
- Strive.framework: use this to bring augmented reality face filters to your app.
- demo_app_objc & demo_app_swift: Demo projects that showcases how to use this SDK. Download these, add your SDK key, and run these in release mode[1] to see our filters in action.
- tutorial_app_objc & tutorial_app_swift: Tutorial projects you can use to follow along the integration instructions below.

1. Look at step 4 of the tutorial below to learn how to run in Release mode

## Get an SDK Key

You'll need one of these, get one here by selecting a plan: [http://www.strivesdk.com](http://www.strivesdk.com). 

:rotating_light: :rotating_light: We'll only be offering *free SDK keys* for the next 24 hours :rotating_light: :rotating_light:


## Guide

Follow along with your own project, or use the Tutorial project we've setup (more info below).

## Step 1. Installation

### i) Clone this repo to download the framework file, alongside demo and tutorial Xcode projects:

```bash
git clone https://github.com/GetLightBite/StriveSDK_iOS.git
open StriveSDK_ios
```
- You'll find our framework at: `demo_app_swift/Strive.framework`
- We have tutorial projects in both Swift and Objective-C. Open either one to get started
    - Swift version is at `tutorial_app_swift/StriveCameraSwiftTutorial.xcodeproj`
    - Objective-C version is at `tutorial_app_objc/StriveCameraTutorial.xcodeproj`


### ii) Drag `Strive.framework` into your project. Make sure "Copy items if needed" is checked. It may take ~10 seconds for the framework to appear in the project directory.
![Alt Text](http://imgur.com/RvQLqJf.gif)


### iii) In  Project Settings, go to `General tab > Embedded Binaries`. Click the `+` icon and add in Strive.framework.  Do the same in `Linked Frameworks and Libraries` if it's not there automatically.
![Alt Text](http://i.imgur.com/90EojmL.gif)


### iv) Go to the `Build Settings tab`, search for `bitcode`, and set `Enable Bitcode` to `NO`.
![Alt Text](http://imgur.com/CNdcDIc.gif)

### v) (Swift-Only) You'll need a Bridging Header to use Strive, since it's written in Objective-C.

Our tutorial app already has one, but if you're using your own project here's how you can add one: [http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/](http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/)

Add this line of code to import Strive accrosss your whole project
> In the Swift Tutorial App, look for `StriveCameraSwift-Bridging-Header.h` in the project directory, under `StriveCameraSwiftTutorial/StriveCameraSwift`.

```objective-c
// ... other imports

#import <Strive/Strive.h> // add this line at mark 0.a, near line 7
```

## Step 2. Initialization

Locate your app delegate and initialize the framework in your *application:didFinishLaunchingWithOptions* method. 

You'll need an SDK Key, you can get one here by selecting a plan: [https://www.strivesdk.com](https://www.strivesdk.com).

**Swift**
> Swift: In the tutorial app, this would be at the top of AppDelegate.swift
```swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // ...other initialization code

    // =======
    // add the following 3 lines at mark 1.a, near line 19
    let striveKey = "INSERT_YOUR_KEY_HERE" // Get one at http://striveSDK.com by selecting a plan
    StriveInstance.setup(withKey: striveKey)
    StriveInstance.shared().prepare()
    // =======

    return true
}
```

**Objective-C**
> Obj-C: In the tutorial app, this would be at the top of AppDelegate.m
```objective-c
@import Strive; // add this line at marker 1.a, near line 11

...

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ...other initialization code

    // =======
    NSString *striveKey = @"INSERT_KEY_HERE"; // add these lines at marker 1.b, near line 30
    [StriveInstance setupWithKey:striveKey];
    [[StriveInstance shared] prepare]; // optional, speeds up filter setup later
    // =======

    return YES;
}
```

## Step 3. Integration

Go to the controller where you configured your camera settings.

:rotating_light: :rotating_light: These instructions should work if you're using AVFoundation or any library that's a light wrapper around it (like OpenTok's camera implementation). If not, shoot me a note at (seb x strivesdk x com) and I'll be happy to help. :rotating_light: :rotating_light:

### i) Create a StriveInstance property

**Swift**
> Swift: In the tutorial app, this would be in `SessionHandler.swift`
```swift

@interface YourCameraClass ()

    // other properties

    let strive = StriveInstance.shared() // add this at marker 2.a, near line 19


@end

```

**Objective-C**
> Obj-C: In the tutorial app, this would be in `SessionHandler.m`
```objective-c
@import Strive; // add this line at marker 2.a, near line 11


@interface YourCameraClass ()

// other properties

@property (nonatomic) StriveInstance *strive; // add this line at marker 2.b, near line 27


@end

```

### ii) (Objective-C only) Initialize your class' StriveInstance property. This should be done as early in this object's lifecycle (ie. viewDidLoad for UIViewController subclasses, or in the init method for NSObject subclasses).

**Objective-C**
```objective-c

- (id)init
{
    self = [super init];
    if (self) {
        // ... initializing other things

        self.strive = [StriveInstance shared]; // add this line at marker 2.c, near line 44
    }
    return self;
}
```

> Swift: We already initialized in the previous step

### iii) Configure the camera to use the 32BGRA pixel format, portrait orientation, and mirroring


**Swift**
```swift
        let videoDataOutput = AVCaptureVideoDataOutput()
        
        videoDataOutput.alwaysDiscardsLateVideoFrames=true

        // =========
        // add the next line at marker 2.b, near line 41
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)] // !!! make sure to use 32BGRA for the pixel format
        // =========
        
        videoDataOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
        captureSession.beginConfiguration()
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if (captureSession.canAddInput(input)){
            captureSession.addInput(input)
        }
        if (captureSession.canAddOutput(videoDataOutput)){
            captureSession.addOutput(videoDataOutput)
            
            let cnx : AVCaptureConnection? = videoDataOutput.connections.first as? AVCaptureConnection
            cnx?.videoOrientation = AVCaptureVideoOrientation.portrait // !!! make sure to use portrait orientation
            cnx?.isVideoMirrored = true // !!! make sure mirror the video stream for the front camera
        }

```
**Objective-C**
```objective-c
- (void)yourMethodWhereYouConfigureCamera

    // ...

    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];

    // =-=-=-=-=
    // Add the next 2 lines at marker 2.d, near line 70
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]}; // !!! make sure to use 32BGRA for the pixel format
    videoDataOutput.videoSettings = outputSettings; 
    // =-=-=-=-=

    if ([_captureSession canAddOutput:videoDataOutput]) {
        [_captureSession addOutput:videoDataOutput];
        AVCaptureConnection *cnx = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        cnx.videoOrientation = AVCaptureVideoOrientationPortrait; // !!! make sure to use Portrait mode
        cnx.videoMirrored = YES; // !!! mirroring on front camera is recommended
    }
    // ...
}
```


### iv) Start passing frames to Strive to see augmented reality in action! Specify which filter you'd like to see, and provide a callback function that accepts the newly processed frames.


**Swift**
```swift

func captureOutput(_ captureOutput: AVCaptureOutput!,
                   didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                   from connection: AVCaptureConnection!) {        

    // =-=-=-=-=
    // Replace the existing code with the next 8 lines at marker 2.c, near line 115
    let f = STVFilter.butterfly
    // let f : STVFilter = STVFilter(rawValue: selectedIndex)! // (optional) use this definition of f to enable the user to pick the line
    self.strive!.apply(f,
                       sampleBuffer: sampleBuffer,
                       completion: { (sbb : CMSampleBuffer?) -> Void in
                        if (sbb != nil) {
                            self.layer.enqueue(sbb!)
                        }
    })
    // =-=-=-=-=
}

```

**Objective-C**
```objective-c

- (void)captureOutput:(AVCaptureOutput *)captureOutput // line 110 in tutorial app
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // =-=-=-=-=
    // Add the next 8 lines at marker 2.e, near line 115
    STVFilter filter = STVFilterButterfly; // don't worry, we have more effects ;)
    // (optional) If you're following the tutorial, uncomment the next line to let users pick the filter
    // filter = self.selectedIndex;
    [self.strive applyFilter:filter
                 sampleBuffer:sampleBuffer
                   completion:^(CMSampleBufferRef sampleBuffer) {
                       [self.layer enqueueSampleBuffer:sampleBuffer];
                   }];
    // =-=-=-=-=
}

```

## Step 4. Switch Release mode

To get a more perspective look at our filters in action, build the app in Release mode. Go to `Product > Scheme > Edit Scheme`. Then change the `Build Configuration` to `Release`, and un-check `Debug Executable`.

![Alt Text](http://i.imgur.com/UJS3rt6.gif)

You'll see the experience users get, without Xcode's debugging overhead slowing down the frame rate.

## Step 5. Celebrate

Build and Run the app, open up a bottle of champagne, and celebrate!

![Alt Text](https://media.giphy.com/media/rjkJD1v80CjYs/giphy.gif)
