//
//  Common.h
//  WGPlatform
//
//  Created by fly chen on 2/21/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_Common_h
#define WGPlatform_Common_h
#include <string>
#include <vector>
#include "WGPublicDefine.h"

#ifdef ANDROID
#include <android/log.h>
#include <jni.h>

#define LOGI(fmt, ...)   __android_log_print(ANDROID_LOG_INFO, "WeGame  cpp", fmt, __VA_ARGS__)
#define LOGD(fmt, ...)   __android_log_print(ANDROID_LOG_DEBUG, "WeGame  cpp", fmt, __VA_ARGS__)
#define LOGW(fmt, ...)   __android_log_print(ANDROID_LOG_WARN, "WeGame  cpp", fmt, __VA_ARGS__)
#define LOGE(fmt, ...)   __android_log_print(ANDROID_LOG_ERROR, "WeGame  cpp", fmt, __VA_ARGS__)

typedef struct {
    std::string ip;
    int port;
} SchedulingInfo;
// 获取某个java对象的值(String), 再赋值给本地对象
#define JniGetAndSetStringField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "Ljava/lang/String;"); \
jstring j##fieldName##FieldValue = (jstring) (env->GetObjectField(jOriginObj, j##fieldName##FieldId)); \
if (j##fieldName##FieldValue == NULL) {\
    targetObj.fieldName = ""; \
} else { \
    char const * c##fieldName##FieldValue = env->GetStringUTFChars(j##fieldName##FieldValue, NULL); \
    targetObj.fieldName = c##fieldName##FieldValue; \
    env->ReleaseStringUTFChars(j##fieldName##FieldValue, c##fieldName##FieldValue); \
} \
env->DeleteLocalRef(j##fieldName##FieldValue);

#define JniGetAndSetIntField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "I"); \
targetObj.fieldName = (int) (env->GetIntField(jOriginObj, j##fieldName##FieldId));

// 获取某个java对象的值(long), 再赋值给本地对象
#define JniGetAndSetLongField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "J"); \
targetObj.fieldName = (int) (env->GetLongField(jOriginObj, j##fieldName##FieldId));

// 获取某个java对象的值(float), 再赋值给本地对象
#define JniGetAndSetFloatField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "F"); \
targetObj.fieldName = (int) (env->GetFloatField(jOriginObj, j##fieldName##FieldId));

// 获取某个java对象的值(boolean), 再赋值给本地对象
#define JniGetAndSetBooleanField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "Z"); \
targetObj.fieldName = (int) (env->GetBooleanField(jOriginObj, j##fieldName##FieldId));

// 获取某个java对象的值(double), 再赋值给本地对象
#define JniGetAndSetDoubleField(fieldName, fieldNameStr, jOriginClass, jOriginObj, targetObj) \
jfieldID j##fieldName##FieldId = env->GetFieldID(jOriginClass, fieldNameStr, "D"); \
targetObj.fieldName = (double) (env->GetDoubleField(jOriginObj, j##fieldName##FieldId));
#endif

#ifdef __APPLE__
typedef struct
{
    std::string openId;         //用户帐号id（account），例如openid、uin
    std::string openKey;        //用户session（skey具体值）
    std::string session_id;     //用户账户类型(uin还是openid)
    std::string session_type;   //session类型(skey)
    std::string payItem;        //结果描述（保留）
    std::string productId;      //物品id
    std::string pf;             //平台来源
    std::string pfKey;          //跳转到应用首页后，URL后会带该参数。由平台直接传给应用，应用原样传给平台
    bool isDepositGameCoin;     //是否是托管游戏币
    int productType;            //物品类型(0 单笔 ,游戏币 2 包月＋自动续费 3 包月＋非自动续费)
    int quantity;               //购买产品的数量
    std::string zoneId;         //游戏币字段
    std::string varItem;        //业务的扩展字段
    int changeKeyType;          //发货失败区分补发货失败和发货失败  since 1.3.5
    std::string billno;         //订单号
    std::string transactionIdentifier;       //since 1.8.1 productId
}IAPPayRequestInfo;


typedef struct
{
    std::string rate;        //平台类型
    std::vector<std::string> mplist;            //操作结果
    std::vector<std::string> mpValueList;
    std::vector<std::string> mpPresentList;
    std::string first_present_count;        //结果描述（保留）
    std::string beginTime;
    std::string endTime;
}IAPMpInfo;

#define AUTH_FILE    "WeGameSDKAuth.dat"
#endif

typedef struct {
    int type;
    std::string value;
    long long expiration;
}TokenRet;

typedef struct loginRet_ {
    int flag;               //返回标记，标识成功和失败类型
    std::string desc;       //返回描述
    int platform;           //当前登录的平台
    std::string open_id;
    std::vector<TokenRet> token;
    std::string user_id;    //用户ID，先保留，等待和微信协商
    std::string pf;
    std::string pf_key;
#ifdef __APPLE__
    loginRet_ ():flag(-1),platform(0){};
#endif
}LoginRet;

typedef void(*CallbackFun)(LoginRet lr);

typedef struct
{
    std::string key;
    std::string value;

}KVPair;

typedef struct
{
    int flag;                //错误码
    int platform;               //被什么平台唤起
    std::string media_tag_name; //wx回传得meidaTagName
    std::string open_id;        //qq传递的openid
    std::string desc;           //描述
    std::string lang;          //语言     目前只有微信5.1以上用，手Q不用
    std::string country;       //国家     目前只有微信5.1以上用，手Q不用
    std::string messageExt;    //游戏分享传入自定义字符串，平台拉起游戏不做任何处理返回         目前只有微信5.1以上用，手Q不用
    std::vector<KVPair> extInfo;  //游戏－平台携带的自定义参数手Q专用
}WakeupRet;

typedef struct
{
    int platform;           //平台类型
    int flag;            //操作结果
    std::string desc;       //结果描述（保留）
    std::string extInfo;   //游戏分享是传入的自定义字符串，用来标示分享
}ShareRet;

typedef struct
{
    int platform;           //平台类型
    int flag;            //操作结果
    std::string desc;       //结果描述（保留）
    std::string open_id;        //qq传递的openid
    std::string wx_card_list;	//card信息
    std::vector<KVPair> extInfo;  //游戏－平台携带的自定义参数手Q专用
}CardRet;

typedef struct
{
    std::string viewTag;   //Button点击的tag
    _eADType scene;   //暂停位还是退出位
} ADRet;

typedef struct
{
	 int platform;           //平台类型
	 int flag;            //操作结果
	 int errorCode;            //操作结果
	 std::string desc;       //结果描述（保留）
} RealNameAuthRet;

typedef struct
{
    std::string name;           //地点名称
    std::string addr;           //具体地址
    int distance;               //离此次定位地点的距离
}AddressInfo;

typedef struct {
    std::string nickName;         //昵称
    std::string openId;           //帐号唯一标示
    std::string gender;           //性别
    std::string pictureSmall;     //小头像
    std::string pictureMiddle;    //中头像
    std::string pictureLarge;     //datouxiang
    std::string provice;          //省份(老版本属性，为了不让外部app改代码，没有放在AddressInfo)
    std::string city;             //城市(老版本属性，为了不让外部app改代码，没有放在AddressInfo)
    bool        isFriend;         //是否好友
    int         distance;         //离此次定位地点的距离
    std::string lang;             //语言
    std::string country;          //国家
    std::string gpsCity;          //根据GPS信息获取到的城市
}PersonInfo;

typedef struct {
    int flag;     //查询结果flag，0为成功
    std::string desc;    // 描述
    std::vector<PersonInfo> persons;//保存好友或个人信息
    std::string extInfo; //游戏查询是传入的自定义字段，用来标示一次查询
}RelationRet;

typedef struct {
	int flag;
	std::string desc;
	double longitude;
	double latitude;
}LocationRet;

typedef struct
{
	eMSDK_SCREENDIR screenDir;      //横竖屏   1：横屏 2：竖屏
    std::string picPath;    //图片本地路径
//    ePicType type;         //图片类型
    std::string hashValue;  //图片hash值
}PicInfo;
typedef struct
{
    std::string msg_id;			//公告id
    std::string open_id;		//用户open_id
    std::string msg_url;		//公告跳转链接
    eMSG_NOTICETYPE msg_type;	//公告类型，eMSG_NOTICETYPE
    std::string msg_scene;		//公告展示的场景，管理端后台配置
	std::string start_time;		//公告有效期开始时间
	std::string end_time;		//公告有效期结束时间
	eMSG_CONTENTTYPE content_type;	//公告内容类型，eMSG_CONTENTTYPE
	std::string msg_order;		//优先级，数字越大，优先级越高
	//网页公告特殊字段
    std::string content_url;     //网页公告URL
    //图片公告特殊字段
    std::vector<PicInfo> picArray;    //图片数组
	//文本公告特殊字段
    std::string msg_title;		//公告标题
    std::string msg_content;	//公告内容
}NoticeInfo;

typedef struct
{
	std::string groupName; //群名称
	std::string fingerMemo; //群的相关简介
	std::string memberNum; //群成员数
	std::string maxNum; //该群可容纳的最多成员数
	std::string ownerOpenid; //群主openid
	std::string unionid; //与该QQ群绑定的公会ID
	std::string zoneid; //大区ID
	std::string adminOpenids; //管理员openid。如果管理员有多个的话，用“,”隔开，例如0000000000000000000000002329FBEF,0000000000000000000000002329FAFF

	//群openID
	std::string groupOpenid;    //和游戏公会ID绑定的QQ群的groupOpenid
	//加群用的群key
	std::string groupKey;    //需要添加的QQ群对应的key
}QQGroupInfo;

typedef struct
{
	std::string openIdList; //openList
	std::string memberNum; //群成员数
	std::string chatRoomURL; //群相关URL

}WXGroupInfo;

typedef struct
{
    int flag;               //MSDK错误码
    int errorCode;			//手Q平台错误码
    int platform;
    std::string desc;       //错误描述
    QQGroupInfo mQQGroupInfo;	//绑定的群相关信息
    WXGroupInfo mWXGroupInfo;	//绑定的群相关信息
}GroupRet;

struct LocalMessage
{
	LocalMessage():type(1),action_type(-1),icon_type(-1),lights(-1),ring(-1),vibrate(-1),style_id(-1),builderId(-1) {};
	int type;
	int action_type;
	int icon_type;
	int lights;
	int ring;
	int vibrate;
	int style_id;
	long builderId;
	std::string content;
	std::string custom_content;
	std::string activity;
	std::string packageDownloadUrl;
	std::string packageName;
	std::string icon_res;
	std::string date;
	std::string hour;
	std::string intent;
	std::string min;
	std::string title;
	std::string url;
	std::string ring_raw;
	std::string small_icon;
};

typedef struct
{
	 int provinceID;            	//省份id
	 eIDType identityType;          //证件类型
	 std::string identityNum;       //证件号码
	 std::string name;       		//名称
	 std::string city;       		//城市
}RealNameAuthInfo;

class WXMessageButton
{
public:
    WXMessageButton(std::string aName);
    virtual ~WXMessageButton();
#ifdef ANDROID
    virtual jobject getJavaObject() = 0;
#endif
#ifdef __APPLE__
    virtual std::string parserToJsonString() = 0;
#endif
protected:
//    eWXButtonType type; // 按钮类型
    std::string name; // 按钮名称
};

class ButtonApp : public WXMessageButton
{
public:
    ButtonApp(std::string aName, std::string aMessageExt);
    ~ButtonApp();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString();
#endif
protected:
    std::string messageExt; // 附加自定义信息，通过按钮拉起应用时会带回游戏
};

class ButtonWebview : public WXMessageButton
{
public:
    ButtonWebview(std::string aName, std::string aWebViewUrl);
    ~ButtonWebview();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString();
#endif
protected:
    std::string webViewUrl; // 点击按钮后要跳转的页面
};

class ButtonRankView : public WXMessageButton
{
public:
    ButtonRankView(std::string aName, std::string aTitle, std::string aButtonName, std::string aMessageExt);
    ~ButtonRankView();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString();
#endif
protected:
    std::string title; // 排行榜名称
    std::string rankViewButtonName; // 排行榜中按钮的名称
    std::string messageExt; // 附加自定义信息，通过排行榜中按钮拉起应用时会带回游戏
};

class WXMessageTypeInfo
{
public:
    WXMessageTypeInfo(std::string aPictureUrl);
    virtual ~WXMessageTypeInfo();
#ifdef ANDROID
    virtual jobject getJavaObject() = 0;
#endif
#ifdef __APPLE__
    virtual std::string parserToJsonString(eWXMessageType &type) = 0;
#endif
protected:
    std::string pictureUrl; // 在消息中心的消息图标Url（图片消息中，此链接则为图片URL）
};

class TypeInfoImage : public WXMessageTypeInfo
{
public:
    TypeInfoImage(std::string aPictureUrl, int aHeight, int aWidth);
    virtual ~TypeInfoImage();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    virtual std::string parserToJsonString(eWXMessageType &type);
#endif
protected:
    int height; // 图片高度
    int width; // 图片宽度
};

class TypeInfoVideo : public TypeInfoImage
{
public:
    TypeInfoVideo(std::string aPictureUrl, int aHeight, int aWidth, std::string aMediaUrl);
    ~TypeInfoVideo();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString(eWXMessageType &type);
#endif
protected:
    std::string mediaUrl; // 相比图片消息，链接消息多此mediaUrl表示视频URL
};

class TypeInfoLink : public WXMessageTypeInfo
{
public:
    TypeInfoLink(std::string aPictureUrl, std::string aTargetUrl);
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString(eWXMessageType &type);
#endif
protected:
    std::string targetUrl; // 链接消息的目标URL，点击消息拉起此链接
};

class TypeInfoText : public WXMessageTypeInfo
{
public:
    TypeInfoText();
#ifdef ANDROID
    virtual jobject getJavaObject();
#endif
#ifdef __APPLE__
    std::string parserToJsonString(eWXMessageType &type);
#endif
};
#endif


#ifdef ANDROID
#define ON_FUNC_INTER(func_name) \
		//__android_log_print(ANDROID_LOG_ERROR, "ON_FUNC_INTER ", "%s", func_name); \
		//printDumpReferenceTables(env);

#define ON_FUNC_OUT(func_name) \
		//__android_log_print(ANDROID_LOG_ERROR, "ON_FUNC_OUT ", "%s", func_name); \
		//printDumpReferenceTables(env);
#endif
