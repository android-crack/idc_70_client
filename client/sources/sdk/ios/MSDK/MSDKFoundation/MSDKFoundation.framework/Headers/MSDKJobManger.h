//
//  MSDKJobManger.h
//  WGPlatform
//
//  Created by doufeifei on 14-5-19.
//  Copyright (c) 2014年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MSDKJob;
@interface MSDKJobManger : NSObject
+ (MSDKJobManger *)sharedInstance;
- (void)startTimer;
- (void)stopTimer;
- (void)addJob:(MSDKJob *)job;
- (void)removeJob:(NSString *)jobId;
- (void)registerJobManger;
@end
