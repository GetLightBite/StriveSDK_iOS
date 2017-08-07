//
//  StriveInstance.h
//
//  Created by Nightman on 3/8/17.
//  Copyright © 2017 Strive Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, STVFilter) {
    STVFilterNone = 0,
    STVFilterButterfly = 1,
    STVFilterGoldenMask = 2,
    STVFilterBunny = 3,
    STVFilterMesh = 4,
    STVFilterMonkey = 5,
    STVFilterCheetah = 6,
    STVFilterBubbleHead = 7,
    STVFilterDistortedFace = 8,
    STVFilterIrishMoji1 = 9,
    STVFilterIrishMoji2 = 10,
    STVFilterIrishMoji3 = 11
};

@interface StriveInstance : NSObject

+ (StriveInstance *)setupWithKey:(NSString *)key;
+ (StriveInstance *)shared;
- (void)prepare;

- (void)applyFilter:(STVFilter)filterCode
       sampleBuffer:(CMSampleBufferRef)sampleBuffer
         completion:(void(^)(CMSampleBufferRef sampleBuffer))completion;

@end
