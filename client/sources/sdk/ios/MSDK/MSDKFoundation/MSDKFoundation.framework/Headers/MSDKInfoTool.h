//
//  MSDKInfoTool.h
//  MSDK
//
//  Created by Jason on 14/11/7.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDKFoundation.h"

@interface MSDKInfoTool : NSObject
#pragma mark - Background Time
+ (void)registerBackgroundEvent;
#pragma mark – Comprehensive Info
+ (NSDictionary *)getDeviceInfo;
+ (NSString *)getCurrentDeviceModel;
#pragma mark – Plist Info

+(NSString *)getMSDKKey;
+(NSString *)getAppKeyByPlatform:(int)platform;
+(NSString *)getAppIdByPlatform:(int)platform;
+(NSString *)getPlatformIdByPlatform:(int)platform;
+(NSString *)getPlatStrByType:(ePlatform)platform;
+(NSString *)getMSDKServerUrlFromInfo;
+(NSString *)getPushServerUrlFromInfo;
+(NSString *)getChannelId;
+(NSString *)getOfferId;
+(NSString *)getGuestAppIdWithoutPrefix;
+(NSString *)getTypeStringWith:(eWXMessageType)type;
+(NSString *)getAPN;
+(NSString *)idfaString;

#pragma mark – UserDefault Info
+ (NSString*)stringWithUUID;

#pragma mark - 微信内置web分享相关配置
+ (NSString *)wxWebShareUrl;

#pragma mark - Qos网络加速相关配置
+ (NSUInteger)qosServerPort;
+ (NSString *)qosServerHost;

#pragma mark - 内置浏览器相关配置
+ (BOOL)isWebviewShareOn;
+ (NSString *)getAMSServerUrlFromInfo;

#pragma mark - 公告相关配置
+ (BOOL)getNoticedFromInfo;
+ (NSInteger)getNoticeTimeFromInfo;

#pragma mark - 推送相关配置
+ (NSString *)xgServerHost;
+(BOOL)isPushOn;

#pragma mark - 日志相关配置
+ (BOOL)shouldLogToFile;

#pragma mark - 票据相关配置
/**
 * 是否进行票据自动刷新
 *
 */
+ (BOOL)shouldStartAutoRefreshJob;

#pragma mark - 实名认证配置
+ (int)realNameAuthSwitch;



@end
