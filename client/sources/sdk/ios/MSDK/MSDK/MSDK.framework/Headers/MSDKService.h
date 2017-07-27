//
//  MSDKService.h
//  MSDK
//
//  Created by Jason on 14/11/18.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGPlatformObserver.h"
#import "WGADObserver.h"
#import "WGGroupObserver.h"
#import "WGWebviewObserver.h"
#import "WGRealNameAuthObserver.h"
#import "MSDKDelegate.h"

@interface MSDKService : NSObject

/*!
 @method
 @abstract 初始化MSDK服务. Start MSDK Service
 @discussion 在程序每次启动时必须调用此方法. MUST be called when app Starts
*/
+(void)StartService;

/*!
 @method
 @abstract 设置全局回调对象. Set service callback observer
 @discussion 在使用MSDK服务前设置回调对象，接收服务返回值. MUST call at least once before using any services
 @param observer 全局回调对象. service callback observer
 */
+(void)setObserver:(WGPlatformObserver *)observer;

/*!
 @method
 @abstract 获取全局回调对象 Get service callback observer
 @result 全局回调对象 service callback observer
 */
+(WGPlatformObserver *)getObserver;

/*!
 @method
 @abstract 处理外部拉起. Handle Open Url
 @discussion 必须在application: handleOpenURL:调用. MUST be called in application: handleOpenURL:
 @param url 传入的url. The url passed in
 */
+(BOOL)handleOpenUrl:(NSURL *)url;


/*!
 @method
 @abstract 获取广告回调对象 Get AD service callback observer
 @result 全局广告对象 AD service callback observer
 */
+(WGADObserver *)getADObserver;

/*!
 @method
 @abstract 设置广告回调对象. Set AD service callback observer
 @discussion 在使用MSDK服务前设置回调对象，接收服务返回值. MUST call at least once before using AD services
 @param observer 广告回调对象. AD service callback observer
 */
+(void)setADObserver:(WGADObserver *)observer;


/*!
 @method
 @abstract 获取群回调对象 Get Group service callback observer
 @result 全局群对象 Group service callback observer
 */
+(WGGroupObserver *)getGroupObserver;

/*!
 @method
 @abstract 设置群回调对象. Set Group service callback observer
 @discussion 在使用MSDK服务前设置回调对象，接收服务返回值. MUST call at least once before using Group services
 @param observer 群回调对象. Group service callback observer
 */
+(void)setGroupObserver:(WGGroupObserver *)observer;

/*!
 @method
 @abstract 获取浏览器回调对象 Get Webview service callback observer
 @result 全局浏览器回调对象 Webview service callback observer
 */
+(WGWebviewObserver *)getWebviewObserver;

/*!
 @method
 @abstract 设置浏览器回调对象. Set Webview service callback observer
 @discussion 在使用MSDK内置浏览器服务前设置回调对象，接收服务返回值. MUST call at least once before using Webview services
 @param observer 内置浏览器回调对象. Webview service callback observer
 */
+(void)setWebviewObserver:(WGWebviewObserver *)observer;

/*!
 @method
 @abstract 获取实名认证回调对象 Get RealNameAuth service callback observer
 @result 全局实名认证回调对象 RealNameAuth service callback observer
 */
+(WGRealNameAuthObserver *)getRealNameAuthObserver;

/*!
 @method
 @abstract 设置实名认证回调对象. Set RealNameAuth service callback observer
 @discussion 在使用MSDK实名认证服务前设置回调对象，接收服务返回值. MUST call at least once before using RealNameAuth services
 @param observer 实名认证回调对象. RealNameAuth service callback observer
 */
+(void)setRealNameAuthObserver:(WGRealNameAuthObserver *)observer;

/*!
 @method
 @abstract 设置回调代理. Set AD service callback delegate
 @discussion 在使用MSDK服务前设置回调对象，接收服务返回值. MUST call at least once before using any services
 @param delegate 回调代理. AD service callback delegate
 */
+(void)setMSDKDelegate:(id<MSDKDelegate>)delegate;




@end
