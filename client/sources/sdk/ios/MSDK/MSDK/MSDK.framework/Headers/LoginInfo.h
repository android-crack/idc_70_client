//
//  LoginInfo.h
//  WGPlatform
//  用于获取登录数据的辅助类，用户一般使用WGPlatform::GetInstance()->WGGetLoginRecord(LoginRet &ret)即可
//  这是方便反射机制获取登录信息，特意独立写出的类
//  Created by fu chunhui on 14-8-19.
//  Copyright (c) 2014年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject

/**
 应用的appId，登录后返回登录平台配置的appId，否则返回配置的qqAppID|wxAppId
 */
@property (nonatomic, retain, readonly)NSString *appId;

/**
 用户登录后获得的openId，未登录为nil
 */
@property (nonatomic, retain, readonly)NSString *openId;

/**
 用户登录的平台，wechat:1 QQ:2 none:0
 */
@property (nonatomic, assign, readonly)NSInteger platform;

/**
 用户登录后获得的accessToken，未登录为nil
 */
@property (nonatomic, retain, readonly)NSString *accessToken;

/**
 用户登录后获得的accessToken失效时间，未登录为nil
 */
@property (nonatomic, assign, readonly)NSTimeInterval accessTokenExpireTime;

/**
 用户登录后获得的pf，未登录时为nil
 */
@property (nonatomic, retain, readonly) NSString * pf;

/**
 用户登录后获得的pfKey，未登录时为nil
 */
@property (nonatomic, retain,readonly) NSString * pfKey;

/**
 用户登录微信后获得的refreshToken，未登录或登录QQ时为nil
 */
@property (nonatomic, retain, readonly)NSString *refreshToken;

/**
 用户登录微信后获得的refreshToken失效时间，未登录或登录QQ时为nil
 */
@property (nonatomic, assign, readonly)NSTimeInterval refreshTokenExpireTime;

/**
 用户登录QQ后获得的payToken，未登录或登录微信时为nil
 */
@property (nonatomic, retain, readonly)NSString *payToken;

/**
 用户登录QQ后获得的payToken失效时间，未登录或登录微信时为nil
 */
@property (nonatomic, assign, readonly)NSTimeInterval payTokenExpireTime;


@end
