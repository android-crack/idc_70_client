//
//  MSDKXG.h
//  MSDKXG
//  MSDK Push相关功能函数
//  Created by Mike on 11/13/14.
//  Copyright (c) 2014 Tencent. All rights reserved.
//

#define MSDKXGFramework_Version @"2.15.1"

#import <Foundation/Foundation.h>

@interface MSDKXG : NSObject

+ (void)WGRegisterAPNSPushNotification:(NSDictionary*)dict;
+ (void)WGSuccessedRegisterdAPNSWithToken:(NSData *)data;
+ (void)WGFailedRegisteredAPNS;
+ (void)WGCleanBadgeNumber;
+ (void)WGReceivedMSGFromAPNSWithDict:(NSDictionary*) userInfo;

/**
 * 本地推送，最多支持64个
 * @param fireDate 本地推送触发的时间
 * @param alertBody 推送的内容
 * @param badge 角标的数字。如果不改变，则传递 -1
 * @param alertAction 替换弹框的按钮文字内容（默认为"启动"）
 * @param userInfo 自定义参数，可以用来标识推送和增加附加信息
 * @return none
 */
+(long)WGLocalNotification:(NSDate *)fireDate alertBody:(NSString *)alertBody badge:(int)badge alertAction:(NSString *)alertAction userInfo:(NSDictionary *)userInfo;

/**
 * 本地推送在前台推送。默认App在前台运行时不会进行弹窗，通过此接口可实现指定的推送弹窗。
 * @param notification 本地推送对象
 * @param userInfoKey 本地推送的标识Key
 * @param userInfoValue 本地推送的标识Key对应的值
 * @return none
 */
+(long)WGLocalNotificationAtFrontEnd:(UILocalNotification *)notification userInfoKey:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;

/**
 * 删除本地推送
 * @param userInfoKey 本地推送的标识Key
 * @param userInfoValue 本地推送的标识Key对应的值
 * @return none
 */
+(void)WGDelLocalNotification:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;

/**
 * 清除所有本地推送对象
 * @param none
 * @return none
 */
+(void)WGClearLocalNotifications;

/**
 * 可以针对不同的用户设置标签，如性别、年龄、学历、爱好等
 * @param tag 用户标签
 * @return none
 */
+(void)WGSetPushTag:(NSString *)tag;

/**
 * 删除设置的标签
 * @param tag 用户标签
 * @return none
 */
+(void)WGDeletePushTag:(NSString *)tag;

@end
