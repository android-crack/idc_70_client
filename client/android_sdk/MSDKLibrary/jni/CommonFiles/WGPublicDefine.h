//
//  PublicDefine.h
//  WGPlatform
//
//  Created by fly chen on 2/25/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_PublicDefine_h
#define WGPlatform_PublicDefine_h

#ifdef ANDROID
#include <exception>
#include <string>
#include <jni.h>
#endif

#define DEPRECATED(_version) __attribute__((deprecated))

typedef enum _ePlatform
{
    ePlatform_None,
    ePlatform_Weixin,          
    ePlatform_QQ
#ifdef ANDROID
	,
    ePlatform_WTLogin,
    ePlatform_QQHall
#endif

#ifdef __APPLE__
    ,
    ePlatform_Guest = 5
#endif
}ePlatform;

typedef enum _eFlag
{
    eFlag_Succ              = 0,
    eFlag_QQ_NoAcessToken   = 1000,     //QQ&QZone login fail and can't get accesstoken
    eFlag_QQ_UserCancel     = 1001,     //QQ&QZone user has cancelled login process (tencentDidNotLogin)
    eFlag_QQ_LoginFail      = 1002,     //QQ&QZone login fail (tencentDidNotLogin)
    eFlag_QQ_NetworkErr     = 1003,     //QQ&QZone networkErr
    eFlag_QQ_NotInstall     = 1004,     //QQ is not install
    eFlag_QQ_NotSupportApi  = 1005,     //QQ don't support open api
    eFlag_QQ_AccessTokenExpired = 1006, // QQ Actoken失效, 需要重新登陆
    eFlag_QQ_PayTokenExpired = 1007,    // QQ Pay token过期
    eFlag_QQ_UnRegistered = 1008,    // 没有在qq注册
    eFlag_QQ_MessageTypeErr = 1009,    // QQ消息类型错误
    eFlag_QQ_MessageContentEmpty = 1010,    // QQ消息为空
    eFlag_QQ_MessageContentErr = 1011,     // QQ消息不可用（超长或其他）

    eFlag_WX_NotInstall     = 2000,     //Weixin is not installed
    eFlag_WX_NotSupportApi  = 2001,     //Weixin don't support api
    eFlag_WX_UserCancel     = 2002,     //Weixin user has cancelled
    eFlag_WX_UserDeny       = 2003,     //Weixin User has deny
    eFlag_WX_LoginFail      = 2004,     //Weixin login fail
    eFlag_WX_RefreshTokenSucc = 2005, // Weixin 刷新票据成功
    eFlag_WX_RefreshTokenFail = 2006, // Weixin 刷新票据失败
    eFlag_WX_AccessTokenExpired = 2007, // Weixin AccessToken失效, 此时可以尝试用refreshToken去换票据
    eFlag_WX_RefreshTokenExpired = 2008, // Weixin refresh token 过期, 需要重新授权
    eFlag_Error				= -1,
    eFlag_Local_Invalid = -2, // 本地票据无效, 要游戏现实登陆界面重新授权
	eFlag_LbsNeedOpenLocationService = -4, // 需要引导用户开启定位服务
	eFlag_LbsLocateFail = -5, // 定位失败
    eFlag_UrlTooLong = -6,     // for WGOpenUrl
    
    eFlag_NeedLogin = 3001,     //需要进入登陆页
    eFlag_UrlLogin = 3002,    //使用URL登陆成功
    eFlag_NeedSelectAccount = 3003, //需要弹出异帐号提示
    eFlag_AccountRefresh = 3004, //通过URL将票据刷新
    eFlag_Checking_Token = 5001 //添加正在检查token的逻辑
#ifdef ANDROID
    ,
    eFlag_NotInWhiteList = -3, // 不在白名单
    eFlag_NeedRealNameAuth = 3005, // 需要实名认证，  错误码与ios保持统一
    eFlag_Need_Realname_Auth = 3005 // 需要实名认证 ，兼容之前的版本的错误码
#endif
#ifdef __APPLE__
    ,
    eFlag_InvalidOnGuest = -7, //该功能在Guest模式下不可使用
    eFlag_Guest_AccessTokenInvalid = 4001, //Guest的票据失效
    eFlag_Guest_LoginFailed = 4002,  //Guest模式登录失败
    eFlag_Guest_RegisterFailed = 4003  //Guest模式注册失败
    //    eFlag_Guest_
#endif
}eFlag;


typedef enum _eShare
{
    eShare_Succ              = 0,
}eShare;

typedef enum _eTokenType
{
    eToken_QQ_Access = 1, // 手Q accessToken
    eToken_QQ_Pay,	// 手Q payToken
    eToken_WX_Access, // 微信accessToken
    eToken_WX_Code, // 微信code, 已弃用
    eToken_WX_Refresh, // 微信refreshToken
    eToken_Guest_Access // Guest模式下的票据
}eTokenType;

typedef enum _eWXMessageType
{
    eWXMessageType_Text = 1,
    eWXMessageType_Image,      //图片
    eWXMessageType_Video,      //视频
    eWXMessageType_Link,       //链接
}eWXMessageType;//WX GameCenter 消息类型

typedef enum _eWXButtonType
{
    eWXButtonType_Rank = 1,//跳排行榜
    eWXButtonType_App,     //唤起app
    eWXButtonType_Web,     //跳网页
}eWXButtonType;//button响应类型

typedef enum _ePermission
{
    eOPEN_NONE                              = 0,
    eOPEN_PERMISSION_GET_USER_INFO          = 0x2,
    eOPEN_PERMISSION_GET_SIMPLE_USER_INFO   = 0x4,
    eOPEN_PERMISSION_ADD_ALBUM              = 0x8, 
    eOPEN_PERMISSION_ADD_IDOL               = 0x10,
    eOPEN_PERMISSION_ADD_ONE_BLOG           = 0x20,
    eOPEN_PERMISSION_ADD_PIC_T              = 0x40,
    eOPEN_PERMISSION_ADD_SHARE              = 0x80,
    eOPEN_PERMISSION_ADD_TOPIC              = 0x100,
    eOPEN_PERMISSION_CHECK_PAGE_FANS        = 0x200,
    eOPEN_PERMISSION_DEL_IDOL               = 0x400,
    eOPEN_PERMISSION_DEL_T                  = 0x800,
    eOPEN_PERMISSION_GET_FANSLIST           = 0x1000,
    eOPEN_PERMISSION_GET_IDOLLIST           = 0x2000,
    eOPEN_PERMISSION_GET_INFO               = 0x4000,
    eOPEN_PERMISSION_GET_OTHER_INFO         = 0x8000,
    eOPEN_PERMISSION_GET_REPOST_LIST        = 0x10000,
    eOPEN_PERMISSION_LIST_ALBUM             = 0x20000,
    eOPEN_PERMISSION_UPLOAD_PIC             = 0x40000,
    eOPEN_PERMISSION_GET_VIP_INFO           = 0x80000,
    eOPEN_PERMISSION_GET_VIP_RICH_INFO          = 0x100000,
    eOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO = 0x200000,
    eOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO      = 0x400000,
    eOPEN_PERMISSION_GET_APP_FRIENDS            = 0x800000,
    eOPEN_ALL                                   = 0xffffff,
}ePermission;

#ifdef ANDROID
static inline jstring StringFromStdString(JNIEnv *env, char const* str){
	return  env->NewStringUTF(str);

    /*jbyteArray array = env->NewByteArray(str.size());
    env->SetByteArrayRegion(array, 0, str.size(), (const jbyte*)str.c_str());
    jstring strEncode = env->NewStringUTF("UTF-8");
    jclass cls = env->FindClass("java/lang/String");
    jmethodID ctor = env->GetMethodID(cls, "<init>", "([BLjava/lang/String;)V");
    jstring object = (jstring) env->NewObject(cls, ctor, array, strEncode);
    env->DeleteLocalRef(array);
    env->DeleteLocalRef(strEncode);
    env->DeleteLocalRef(cls);
    return object;*/
}
static inline void printDumpReferenceTables(JNIEnv *env){
	jclass vm_class = env->FindClass("dalvik/system/VMDebug");
	jmethodID dump_mid = env->GetStaticMethodID (vm_class, "dumpReferenceTables", "()V");
	env->CallStaticVoidMethod (vm_class, dump_mid);
	env->DeleteLocalRef(vm_class);
}
#endif

typedef enum _eWechatScene
{
    WechatScene_Session  = 0,
    WechatScene_Timeline = 1,
}eWechatScene;

typedef enum _eQQScene
{
    QQScene_QZone  = 1,//默认弹出分享到Qzone的弹框
    QQScene_Session = 2,//默认弹出分享给好友的弹框
}eQQScene;

typedef enum _eIDType{
	eIDType_IDCards = 0,			// 身份证
	eIDType_HKMacaoPass = 1,		// 港澳通行证
	eIDType_HKMacaoTaiwanID = 2,	// 港澳台身份证
	eIDType_Passport = 3,			// 护照
	eIDType_PoliceCertificate = 4,	// 军警证
}eIDType;

typedef enum _eADType
{
	Type_Pause  = 1, // 暂停位广告
	Type_Stop = 2, // 退出位广告
}eADType;

typedef enum _eMSG_NOTICETYPE
{
    eMSG_NOTICETYPE_ALERT = 0,
    eMSG_NOTICETYPE_SCROLL = 1,
    eMSG_NOTICETYPE_ALL = 2,
}eMSG_NOTICETYPE;

typedef enum _eMSG_CONTENTTYPE
{
    eMSG_CONTENTTYPE_TEXT = 0,  //文本公告
    eMSG_CONTENTTYPE_IMAGE = 1,  //图片公告
    eMSG_CONTENTTYPE_WEB = 2,  //网页公告
}eMSG_CONTENTTYPE;

typedef enum _eMSDK_SCREENDIR {
	eMSDK_SCREENDIR_SENSOR = 0,   //横竖屏
	eMSDK_SCREENDIR_PORTRAIT = 1,   //竖屏
	eMSDK_SCREENDIR_LANDSCAPE = 2,   //横屏
}eMSDK_SCREENDIR;

typedef enum _ePicType
{
    ePicType_NONE = 0,
    ePicType_PNG = 1,
    ePicType_JPG = 2,
    ePicType_GIF = 3,
}ePicType;


enum RealNameAuthErrCode {
	eErrCode_SystemError = 1,         //系统错误
	eErrCode_NoAuth = 2,              //没有权限
	eErrCode_RequestFrequently = 3,   //访问频繁，稍后再试
	eErrCode_NoRecord = 4,            //没有该记录
	eErrCode_AlreadyRegisted = 5,     //用户已注册
	eErrCode_BindCountLimit = 6,      //证件绑定超过限制
	eErrCode_UserNoRegist = 7,        //用户没注册(修改时可能返回)
	eErrCode_InvalidParam = 100,        //非法参数输入
	eErrCode_InvalidIDCard = 101,       //非法的身份证，当证件类型为身份证时会校验
	eErrCode_InvalidBirth = 102,       //非法的生日，当证件为非身份证时会校验
	eErrCode_InvalidChineseName = 103, //非法的中文名字
	eErrCode_InvalidToken = 104       //token过期或不合法
};

#ifdef ANDROID
typedef enum _ApiName {
    eApiName_WGSendToQQWithPhoto = 0,
    eApiName_WGJoinQQGroup = 1,
    eApiName_WGAddGameFriendToQQ = 2,
    eApiName_WGBindQQGroup = 3
}eApiName;

enum TMSelfUpdateUpdateInfo
{
    STATUS_OK = 0,  // 检查成功
    STATUS_CHECKUPDATE_FAILURE=1, // 查询更新失败
    STATUS_CHECKUPDATE_RESPONSE_IS_NULL=2, // 查询响应为空

    UpdateMethod_NoUpdate = 0,  // 无更新包
    UpdateMethod_Normal=1, // 有全量更新包
    UpdateMethod_ByPatch=2 // 有省流量更新包
};

enum TMAssistantDownloadTaskState {
    DownloadSDKTaskState_WAITING    = 1,
    DownloadSDKTaskState_DOWNLOADING    = 2,
    DownloadSDKTaskState_PAUSED = 3,
    DownloadSDKTaskState_SUCCEED    = 4,
    DownloadSDKTaskState_FAILED = 5,
    DownloadSDKTaskState_DELETE = 6,
    //LOWWER_VERSION_INSTALLED  = 2,
    //UN_INSTALLED  = 1,
    //ALREADY_INSTALLED = 0
};

enum TMSelfUpdateTaskState {
    SelfUpdateSDKTaskState_SUCCESS  = 0,
    SelfUpdateSDKTaskState_DOWNLOADING  = 1,
    SelfUpdateSDKTaskState_FAILURE  = 2
};
enum TMYYBInstallState {
    LOWWER_VERSION_INSTALLED    = 2,
    UN_INSTALLED    = 1,
    ALREADY_INSTALLED   = 0
};

enum TMAssistantDownloadErrorCode {
    //DownloadSDK_START_FAILED_BUSY = 5,
    //DownloadSDK_START_FAILED_EXISTED  = 4,
    //DownloadSDK_START_FAILED_NETWORK_NOT_CONNECTED    = 1,
    //DownloadSDK_START_FAILED_ONLY_FOR_WIFI    = 2,
    //DownloadSDK_START_FAILED_PARAMETERS_INVALID   = 3,
    //DownloadSDK_START_SUCCEED = 0,
    DownloadSDKErrorCode_CLIENT_PROTOCOL_EXCEPTION  = 732,
    DownloadSDKErrorCode_CONNECT_TIMEOUT    = 601,
    DownloadSDKErrorCode_HTTP_LOCATION_HEADER_IS_NULL   = 702,
    DownloadSDKErrorCode_INTERRUPTED    = 600,
    DownloadSDKErrorCode_IO_EXCEPTION   = 606,
    DownloadSDKErrorCode_NONE   = 0,
    DownloadSDKErrorCode_PARSER_CONTENT_FAILED  = 704,
    DownloadSDKErrorCode_RANGE_NOT_MATCH    = 706,
    DownloadSDKErrorCode_REDIRECT_TOO_MANY_TIMES    = 709,
    DownloadSDKErrorCode_RESPONSE_IS_NULL   = 701,
    DownloadSDKErrorCode_SET_RANGE_FAILED   = 707,
    DownloadSDKErrorCode_SOCKET_EXCEPTION   = 605,
    DownloadSDKErrorCode_SOCKET_TIMEOUT = 602,
    DownloadSDKErrorCode_SPACE_NOT_ENOUGH   = 730,
    DownloadSDKErrorCode_TOTAL_SIZE_NOT_SAME    = 705,
    DownloadSDKErrorCode_UNKNOWN_EXCEPTION  = 604,
    DownloadSDKErrorCode_UNKNOWN_HOST   = 603,
    DownloadSDKErrorCode_URL_EMPTY  = 731,
    DownloadSDKErrorCode_URL_HOOK   = 708,
    DownloadSDKErrorCode_URL_INVALID    = 700,
    DownloadSDKErrorCode_WRITE_FILE_FAILED  = 703,
    DownloadSDKErrorCode_WRITE_FILE_NO_ENOUGH_SPACE = 710,
    DownloadSDKErrorCode_WRITE_FILE_SDCARD_EXCEPTION    = 711
};
#endif

enum eBuglyLogLevel {
	eBuglyLogLevel_S = 0, //Silent
	eBuglyLogLevel_E = 1, //Error
	eBuglyLogLevel_W = 2, //Warning
	eBuglyLogLevel_I = 3, //Info
	eBuglyLogLevel_D = 4, //Debug
	eBuglyLogLevel_V = 5 //Verbose
};

#endif
