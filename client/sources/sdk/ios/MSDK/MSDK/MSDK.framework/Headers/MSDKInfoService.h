//
//  MSDKInfoService.h
//  MSDK
//
//  Created by Jason on 14/11/17.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDKInfoService : NSObject

@property (nonatomic, assign) BOOL bNeedMSDKEventReport;

+ (id)sharedInstance;
+(int)getIphoneQQVersion;
+(void)logPlatformSDKVersion;
+(BOOL)IsPlatformSupportApi:(ePlatform) platformType;
+(BOOL)IsPlatformInstalled:(ePlatform) platformType;
+(void)OpenMSDKLog:(bool) enabled;
+(NSString *)GetChannelId;
+(NSString *)GetRegisterChannelId;


-(int)feedBack:(unsigned char*)gameId text:(unsigned char*)text;

-(void)EnableCrashReport:(BOOL)bRDMEnable MTAEnable:(BOOL)bMTAEnable;

-(void)ReportEvent:(unsigned char *)name eventList:(std::vector<KVPair>&)eventList isRealTime:(BOOL)isRealTime;
-(void)ReportEvent:(unsigned char*) name body:(unsigned char *) body isRealTime:(BOOL)isRealTime;

#pragma mark - url加密
+ (NSString *)getEncodeUrl:(unsigned char *)openUrl;

#pragma mark - bugly自定义日志
- (void)buglyLog:(eBuglyLogLevel)level log:(NSString *)log;

//上报info.plist中MSDK相关配置，MSDK初始化调用
- (void)reportMSDKRelatedConfiguration;
//联调日志上报
- (void)reportMSDKEvent:(unsigned char *)eventName eventFlag:(int)eventFlag eventMsg:(unsigned char *)eventMsg;

- (void)reportStat:(long)timeCost statName:(unsigned char *)statName retCode:(int)retCode retMsg:(unsigned char *)retMsg;

@end
