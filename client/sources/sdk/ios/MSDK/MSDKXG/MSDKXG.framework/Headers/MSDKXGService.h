//
//  MSDKXGService.h
//  MSDKXG
//
//  Created by 付亚明 on 9/11/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <MSDKFoundation/MSDKFoundation.h>

@interface MSDKXGService : MSDKServiceObject

+ (void)registerAPNSPushNotification:(NSDictionary*)dict;
+ (void)successedRegisterdAPNSWithToken:(NSData *)data;
+ (void)failedRegisteredAPNS;
+ (void)cleanBadgeNumber;
+ (void)receivedMSGFromAPNSWithDict:(NSDictionary*)userInfo;
+ (void)registerXGWithLoginInfo;

+ (long)localNotification:(NSDate *)fireDate alertBody:(NSString *)alertBody badge:(int)badge alertAction:(NSString *)alertAction userInfo:(NSDictionary *)userInfo;
+ (long)localNotificationAtFrontEnd:(UILocalNotification *)notification userInfoKey:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;
+ (void)delLocalNotification:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;
+ (void)clearLocalNotifications;
+ (NSString *)xgSdkVersion;
+(void)setPushTag:(NSString *)tag;
+(void)deletePushTag:(NSString *)tag;

@end
