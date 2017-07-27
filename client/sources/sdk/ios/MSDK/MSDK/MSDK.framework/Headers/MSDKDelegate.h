//
//  MSDKDelegate.h
//  MSDK
//
//  Created by Jason on 14/11/25.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

/*
MSDK回调代理 使用方法与WGPlatformObserver相同 若同时使用Delegate与Observer，则只有Observer会收到回调
*/
@protocol MSDKDelegate <NSObject>
@required

-(void)OnLoginWithLoginRet:(MSDKLoginRet *)ret;

-(void)OnWakeUpWithWakeUpRet:(MSDKWakeupRet *)ret;

-(void)OnShareWithShareRet:(MSDKShareRet *)ret;

-(void)OnRelationWithRelationRet:(MSDKRelationRet *)ret;

-(void)OnLocationWithRelationRet:(MSDKRelationRet *)ret;

-(void)OnLocationGotWithLocationRet:(MSDKLocationRet *)ret;

-(void)OnFeedBackWithFlag:(int)flag andDesc:(NSString *)desc;

-(NSString *)OnCrashExtMessage;

@optional
-(void)OnADWithADRet:(MSDKADRet *)ret;

//加绑群
- (void)OnCreateWXGroupNotify:(MSDKGroupRet *)ret;
- (void)OnQueryGroupInfoNotify:(MSDKGroupRet *)ret;
- (void)OnJoinWXGroupNotify:(MSDKGroupRet *)ret;

- (void)OnWebviewNotify:(MSDKWebviewRet *)ret;
- (void)OnRealNameAuthNotify:(MSDKRealNameAuthRet *)ret;

@end

