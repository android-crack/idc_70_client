//
//  MSDKJobProtocol.h
//  WGPlatform
//
//  Created by doufeifei on 14-5-19.
//  Copyright (c) 2014年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSDKJobProtocol <NSObject>

@required
@property (assign, nonatomic) NSInteger lastUpdateTime;
@property (assign, nonatomic) NSInteger terminal;
@property (retain, nonatomic) NSString *jobId;
@property (assign, nonatomic) BOOL isRequesting;
- (void)doMyJob;
- (id)init;
@end
