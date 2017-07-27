//
//  MSDKLogger.h
//  WGPlatform
//
//  Created by fu chunhui on 14-5-26.
//  Copyright (c) 2014年 tencent.com. All rights reserved.
//

#ifndef MSDKFoundation_MSDKLogger_h
#define MSDKFoundation_MSDKLogger_h

#import <Foundation/Foundation.h>

#ifndef MSDKLOG
#define MSDKLOG(xx, ...) [[MSDKLogger sharedInstance] msdkLog:[NSString stringWithFormat:@"%s*** " xx, __PRETTY_FUNCTION__, ##__VA_ARGS__]]
#endif

@interface MSDKLogger : NSObject

@property (nonatomic,assign) BOOL enableLog;
@property (nonatomic,assign) BOOL instantReport;
@property (nonatomic,strong) NSString * openId;
@property (nonatomic,strong) NSString * appId;

+(MSDKLogger*)sharedInstance;
- (void)msdkLog:(NSString *)format;
-(void)ReportLocalLog;
@end

#endif
