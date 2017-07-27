//
//  AnaModel.h
//  Analytics Framework
//
//  Created by dong kerry on 11-12-22.
//  Copyright (c) 2011年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnaDevicesUtil : NSObject {
}

+(NSString*) localWiFiMac;
+ (NSString *)model;
+(long long)getRamSize;
+ (float) getTotalSpace;
+(long long)getRomSize;
+(NSString*) getCpuTypeStr;
+(NSString *)getRosultion;
+(NSString*) getAPN;
+(NSString*) getUserDefineId;
+(NSString*) getChannelId;
+(BOOL) activeWWAN;
+(NSDictionary*) createAppLaunchEventParam:(NSString*)openID;
+(BOOL) activeWLAN;
+(BOOL) networkAvaliable;
+(BOOL) is2G;
+(NSString*) localIPAddress;
@end
