//
//  MSDKPrivateEnums.h
//  MSDKFoundation
//
//  Created by Mike on 5/20/16.
//  Copyright © 2016 HaywoodFu. All rights reserved.
//

#ifndef MSDKPrivateEnums_h
#define MSDKPrivateEnums_h


typedef enum _eMSDK_LoginScene
{
    eMSDK_LoginScene_None = 0, //未知
    eMSDK_LoginScene_First = 1, //首次登录
    eMSDK_LoginScene_Auto = 2, //自动登录
    eMSDK_LoginScene_TimingCheck = 3, //定时检查登录
    eMSDK_LoginScene_WakeupWithToken = 4 //带票据的第三方登陆
}eMSDK_LoginScene;

typedef enum _eMSDKRealNameAuthOperate
{
    eMSDKRealNameAuthOperate_UserGiveUp = 1, //用户放弃实名认证返回首页
    eMSDKRealNameAuthOperate_UserSubmitButFailed, //用户提交了资料但是失败了最后返回了首页
    eMSDKRealNameAuthOperate_UserHadComeToAuthPage, //用户到达了实名认证界面
    eMSDKRealNameAuthOperate_Success,   //用户实名认证成功
}eMSDKRealNameAuthOperate;

typedef enum _eMSDKRealNameAuthSwitch
{
    eMSDKRealNameAuthSwitch_Default = 0, //实名认证成功后直接返回首页，不做其他操作
    eMSDKRealNameAuthSwitch_AutoLogin, //实名认证成功后返回首页且主动调自动登录
    eMSDKRealNameAuthSwitch_Custom, //游戏自定义UI
}eMSDKRealNameAuthSwitch;

#endif /* MSDKPrivateEnums_h */
