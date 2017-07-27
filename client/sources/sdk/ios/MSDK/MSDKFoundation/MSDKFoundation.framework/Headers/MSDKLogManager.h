//
//  MSDKLogManager.h
//  MSDKFoundation
//
//  Created by Luox on 8/9/16.
//  Copyright © 2016 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDKEnums.h"

#define LOG_REPORT_EVENTNAME        @"MSDKLogReport"
#define LOG_REPORT_ACTION           @"/logcollect/report_log/"
#define LOG_REPORT_CMD              6034
#define LOG_REPORT_CACHE_SIZE       16000

@interface MSDKLogManager : NSObject
{
    NSMutableString *_logCache;
}

@property (nonatomic, assign) BOOL bNeedMSDKLogReport;
@property (nonatomic, assign) ePlatform plat;
@property (nonatomic, strong) NSString *openId;

+ (instancetype)shareInstance;

- (void)reportLog:(NSString *) log;


@end
