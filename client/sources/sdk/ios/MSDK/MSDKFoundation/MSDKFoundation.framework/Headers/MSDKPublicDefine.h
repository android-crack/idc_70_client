//
// MSDKPublicDefine.h
// MSDKFoundation
//
// Created by Jason on 14/11/25.
// Copyright (c) 2014年 Tencent. All rights reserved.
//

#ifndef MSDKFoundation_MSDKPublicDefine_h
#define MSDKFoundation_MSDKPublicDefine_h

#define MSDK_VERSION @"2.15.1i"

//crash场景
#pragma mark - crash scene
/************* 应用状态 *************/
//
#define MSDK_FRONT @"MSDKFront"
//后台运行中
#define MSDK_BACK @"MSDKBack"
//切换到后台中
#define MSDK_GOBACK @"MSDKGoBack"
//切换回前台中
#define MSDK_GOFRONT @"MSDKGoFront"
//退出游戏中
#define MSDK_EXIST @"MSDKExist"

/************* MSDK相关场景 *************/
//默认状态
#define MSDK_DEFAULT @"MSDKDefault"
//初始化MSDK中
#define MSDK_INIT @"MSDKInit"
//设置回调
#define MSDK_OBSERVER @"MSDKObserver"
//登陆中
#define MSDK_LOGIN @"MSDKLogin"
//登出中
#define MSDK_LOGOUT @"MSDKLogout"
//更新中
#define MSDK_UPDATE @"MSDKUpdate"
//分享中
#define MSDK_SHARE @"MSDKShare"

/************* 支付相关场景 *************/
//拉起支付
#define PAY_LAUNCHER @"MSDKPayLauncher"
//付款
#define PAY_ING @"MSDKPayIng"
//支付结束，回调游戏
#define PAY_NOTIFY @"MSDKPayNotify"

/************* 登陆相关场景 *************/
#define GAME_Login @"MSDKGameLogin"

/************* 游戏游戏对局场景场景 *************/
//单局游戏开始前准备
#define GAME_PRE @"MSDKGamePre"
//单局游戏游戏进行中
#define GAME_ING @"MSDKGameIng"
//单局游戏游戏暂停中
#define GAME_PAUSE @"MSDKGamePause"
//单局游戏结束结算中
#define GAME_CALCULATE @"MSDKGameCalculate"

/************* 游戏购买道具场景 *************/
//购买道具
#define ITEM_PURCHASE @"MSDKItemPurchase"

/************* 游戏联网对战场景 *************/
//联网对战准备
#define PV_PRE @"MSDKPvPre"
//联网对战进行中
#define PV_ING @"MSDKPvIng"
//联网对战进行中
#define PV_PAUSE @"MSDKPvPause"
//联网对战结束结算中
#define PV_CALCULATE @"MSDKPvCalculate"


#pragma mark - Constants
#define kOneDaySeconds 86400
#define kCNULL ""
#define kNSNULL @""

#pragma mark - Network Return Json Keys
#define kFlagError -1
#define ASIHTTPREQUEST_TIMEOUT 15

#pragma mark - Platform Id
#define kWenXin @"wechat" //微信
#define kQQ @"qq_m" //手机QQ
#define kQzone @"qzone_m" //手机Qzone
#define kMobile @"mobile" //手机qq游戏大厅
#define kDesktop @"desktop_m" //默认桌面启动

#pragma mark - Platform Id Suffix
#define kQQAcount @"_qq"
#define kWXAcount @"_wx"
#define kGuestAcount @"_guest"


#pragma mark - Important For All Modules
#define kopenId @"openId"
#define kplatform @"platform"
#define kpf @"pf"
#define kpfKey @"pfKey"
#define kflag @"flag"
#define kaccessTokenType @"accessTokenType"
#define kaccessTokenValue @"accessTokenValue"
#define kaccessTokenExpiration @"accessTokenExpiration"
#define krefreshTokenType @"refreshTokenType"
#define krefreshTokenValue @"refreshTokenValue"
#define krefreshTokenExpiration @"refreshTokenExpiration"
#define kupdateTime @"updateTime"
#define kuser_id @"user_id"
#define kpayTokenType @"payTokenType"
#define kpayTokenValue @"payTokenValue"
#define kpayTokenExpiration @"payTokenExpiration"
#define CHANNEL_DENGTA @"CHANNEL_DENGTA"
#define kminopenid @"openid"
#define kappid @"appid"
#define kMatID @"matid"
#define kaccesstoken @"accessToken"
#define kqqAccessToken @"qqAccessToken"
#define kchannelid @"channel"
#define kofferid @"offerid"
#define kos @"os"
#define kOsVersion @"osVersion"
#define ksucess @"success"
#define kret @"ret"
#define kpermissionjsom @"funcs"
#define kOtherPermissionJson @"otherFuncs"
#define kregChannel @"regChannel"
#define krefreshToken @"refreshToken"
#define kexpired @"expired"
#define kMSDK_OfferIdKey @"MSDK_OfferId"
#define kCrashReportEnabled @"crashReportEnabled"
#define kCurrentReportOpenId @"currentReportOpenId"
#define kuserId @"userid"
#define kMSDKExtInfo @"msdkExtInfo"
#define kuser_openid @"user_openid"
#define kExtOpenid @"openid"
#define kExtPlatform @"platform"
#define kExtAtoken @"atoken"
#define kExtPtoken @"ptoken"
#define kExtPfKey @"pfkey"
#define kMSDKDeviceToken @"msdkDeviceToken"
#define kTokenCheckedFlag @"checkTokenFlag"
#define kNeedNameAuth @"needNameAuth"
#define kUserNickName @"userNickname"

#pragma mark - JobId
#define kMSDKTokenJobId @"MSDKTokenJobId"
#define kMSDKAnnouncementJobId @"MSDKAnnouncementJobId"
#define kMSDKAdJobId @"MSDKAdJobId"
#define kMSDKPicDownloadJobId @"MSDKPicDownloadJobId"

#pragma mark - Annoucement
#define kMSDKAnnouncementScene @"MSDKAnnouncementScene"
#define kMSDKAnnouncementClose @"MSDKAnnouncementClose"
#define kMSDKAnnouncementOnlyData @"MSDKAnnouncementOnlyData"

#pragma mark - WebView
#define kAccType @"acctype"
#define kPlatId @"platid"
#define kAccessTokenUnderLine @"access_token"
#define kPayTokenUnderLine @"pay_token"
#define kMsdkEncodeParam @"msdkEncodeParam"
#define kVersionKey @"version"
#define kTimeStampKey @"timestamp"
#define kSigKey @"sig"
#define kEncodeKey @"encode"
#define kAlgorithmKey @"algorithm"

#pragma mark - LocalMessage
#define kFireDate       @"fireDate"
#define kAlertBody      @"alertBody"
#define kBadge          @"badge"
#define kAlertAction    @"alertAction"
#define kUserInfo       @"userInfo"
#define kUserInfoKey    @"userInfoKey"
#define kUserInfoValue  @"userInfoValue"
#define kFunctionCmd    @"functionCmd"
#define kPushTagKey     @"pushTagKey"

#pragma mark - logReport
#define kLogReportTimeCost       @"timeCost"
#define kLogReportRetCode        @"retCode"
#define kLogReportRetMsg         @"retMsg"
#define kLogReportRequestUrl     @"RequestUrl"
#define kLogReportNotification   @"LogReportNotification"

//这里的设计变更:kMSDKTokenJobTerminal作为job定时器间隔，以1分钟为准
//在运行检查票据的任务时，根据上次检查成功的间隔（kMSDKTokenCheckTerminal）决定是否进行检查；
//而在进入后台后，检查成功的间隔会清空，这意味着进入后台的时间大于kMSDKTokenJobTerminal，回到前台则会检查票据
#define kMSDKTokenJobTerminal 1*60
#define kMSDKTokenCheckTerminal 30*60

#define kMSDKAnnouncementTerminal 15*60
#define kMSDKJobOuttime 30
#define kMSDKPicDownloadTerminal 30
#define kMSDKJobLoopTime 5*60

#pragma mark - Permissions
#define kWGLoginQQ @"WGLoginQQ" //QQ登录
#define kWGLoginWX @"WGLoginWX"
#define kWGSendToQQ @"WGSendToQQ"// 分享到QQ
#define kWGSendToWeixin @"WGSendToWeixin" // 分享到微信
#define kWGSendToWeixinWithPhoto @"WGSendToWeixinWithPhoto" // 分享到微信
#define kWGRefreshWXToken @"WGRefreshWXToken"//刷新微信
#define kWGPushMSDK @"WGPushMSDK"//MSDK推送
#define kWGShareQQByWeb @"WGShareQQByWeb"//手Q web分享权限
#define kWGShareWxByWeb @"WGShareWxByWeb"//微信 web分享权限
#define kWGWebViewQQEntrance @"WGWebViewQQEntrance" //内置浏览器的QQ分享入口
#define kWGWebViewWXEntrance @"WGWebViewWXEntrance" //内置浏览器的WX分享入口

#pragma mark - Share Service Keys
#define kMSDKShare_Key_scene @"scene"
#define kMSDKShare_Key_title @"title"
#define kMSDKShare_Key_desc @"desc"
#define kMSDKShare_Key_url @"url"
#define kMSDKShare_Key_imgUrl @"imgUrl"
#define kMSDKShare_Key_musicUrl @"musicUrl"
#define kMSDKShare_Key_musicDataUrl @"musicDataUrl"
#define kMSDKShare_Key_mediaTagName @"mediaTagName"
#define kMSDKShare_Key_thumbImgData @"thumbImgData"
#define kMSDKShare_Key_thumbImgDataLen @"thumbImgDataLen"
#define kMSDKShare_Key_imgData @"imgData"
#define kMSDKShare_Key_imgDataLen @"imgDataLen"
#define kMSDKShare_Key_messageExt @"messageExt"
#define kMSDKShare_Key_messageAction @"messageAction"

#pragma mark - Permission Service Keys
#define kMSDKPermission_Key_isPermitted @"isPermitted"
#define kMSDKPermission_Key_permission @"permission"

#pragma mark - Callback Notification Names
#define MSDKOnLoginSuccessNotify @"kMsdkLoginSuccessed"
#define MSDKOnLoginFailedNotify @"MSDKOnLoginFailedNotify"
#define MSDKOnLogOutNotify @"MSDKOnLogOutNotify"
#define MSDKOnShareSuccessNotify @"MSDKOnShareSuccessNotify"
#define MSDKOnShareFailedNotify @"MSDKOnShareFailedNotify"
#define MSDKOnWakeupNotify @"MSDKOnWakeupNotify"
#define MSDKOnRelationNotify @"MSDKOnRelationNotify"
#define MSDKOnLocationNotify @"MSDKOnLocationNotify"
#define MSDKOnLocationGotNotify @"MSDKOnLocationGotNotify"
#define MSDKOnFeedbackNotify @"MSDKOnFeedbackNotify"
#define MSDKOnCrashExtMessageNotify @"MSDKOnCrashExtMessageNotify"
#define MSDKAdTapNotification @"MSDKAdTapNotification"

#endif
