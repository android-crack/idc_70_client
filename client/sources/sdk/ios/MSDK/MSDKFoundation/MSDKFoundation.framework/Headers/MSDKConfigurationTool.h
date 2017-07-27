//
//  MSDKConfigurationTool.h
//  MSDK
//
//  Created by fu chunhui on 15/4/28.
//  Copyright (c) 2015年 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDKConfigurationTool : NSObject

+(MSDKConfigurationTool*)sharedInstance;

#pragma mark - MSDK配置
- (NSString *)msdkUrl;

#pragma mark - 微信内置web分享相关配置
- (NSString *)wxWebShareUrl;

#pragma mark - Qos网络加速相关配置
- (NSUInteger)qosServerPort;
- (NSString *)qosServerHost;

#pragma mark - 内置浏览器相关配置
- (BOOL)isWebviewShareOn;
- (NSString *)amsUrl;

#pragma mark - 公告相关配置
- (BOOL)getNoticedFromInfo;
- (NSInteger)getNoticeTimeFromInfo;

#pragma mark - 推送相关配置
- (NSString *)xgServerHost;
- (BOOL)isPushOn;
- (NSString *)getPushServerUrlFromInfo;

#pragma mark - 日志相关配置
- (BOOL)shouldLogToFile;

#pragma mark - 票据相关配置
- (BOOL)shouldStartAutoRefreshJob;


- (id)valueForParam:(NSString *)key;
@end
