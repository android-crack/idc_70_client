//
//  MSDKStructs.h
//  MSDKFoundation
//
//  Created by Jason on 14/11/6.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#ifndef MSDKFoundation_MSDKStructs_h
#define MSDKFoundation_MSDKStructs_h



#include <string>
#include <vector>
#include "MSDKEnums.h"

//using namespace std;

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
    std::string viewTag;   //Button点击的tag
    _eADType scene;   //暂停位还是退出位
} ADRet;

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

typedef struct {
    std::string openIdList;         //群成员openId,以","分隔
    std::string memberNum;          //群成员数
    std::string chatRoomURL;        //创建（加入）群聊URL
}WXGroupInfo;

typedef struct {
    std::string groupName;          //群名称
    std::string fingerMemo;         //群的相关简介
    std::string memberNum;          //群成员数
    std::string maxNum;             //该群可容纳的最多成员数
    std::string ownerOpenid;        //群主openid
    std::string unionid;            //与该QQ群绑定的公会ID
    std::string zoneid;             //大区ID
    std::string adminOpenids;       //管理员openid。如果管理员有多个的话，用“,”隔开，例如0000000000000000000000002329FBEF,0000000000000000000000002329FAFF
    //群openID
    std::string groupOpenid;        //和游戏公会ID绑定的QQ群的groupOpenid
    //加群用的群key
    std::string groupKey;           //需要添加的QQ群对应的key
}QQGroupInfo;

typedef struct {
    int flag;                       //0成功
    int errorCode;                  //平台返回参数，当flag非0时需关注
    std::string desc;               //错误信息
    int platform;                   //平台
    WXGroupInfo wxGroupInfo;        //微信群信息
    QQGroupInfo qqGroupInfo;        //QQ群信息
}GroupRet;

typedef struct {
    int flag;                       //0成功
}WebviewRet;

typedef struct {
    int flag;                       //0成功
    int errorCode;                  //平台返回参数，当flag非0时需关注
    std::string desc;               //错误信息
    int platform;                   //平台
}RealNameAuthRet;

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
    //网页公告特殊字段
    std::string content_url;     //网页公告URL
    //图片公告特殊字段
    std::vector<PicInfo> picArray;    //图片数组
    //文本公告特殊字段
    std::string msg_title;		//公告标题
    std::string msg_content;	//公告内容
    int msg_order;      //公告优先级，越大优先级越高，MSDK2.8.0版本新增
}NoticeInfo;

#ifdef __APPLE__
typedef struct
{
    std::string fireDate;		//本地推送触发的时间,格式yyyy-MM-dd HH:mm:ss
    std::string alertBody;		//推送的内容
    int badge;                  //角标的数字
    std::string alertAction;	//替换弹框的按钮文字内容（默认为"启动"）
    std::vector<KVPair> userInfo;//自定义参数，可以用来标识推送和增加附加信息
    std::string userInfoKey;	//本地推送在前台推送的标识Key
    std::string userInfoValue;  //本地推送在前台推送的标识Key对应的值
}LocalMessage;
#endif

typedef struct
{
    std::string name;           //姓名
    eIDType identityType;       //证件类型
    std::string identityNum;    //证件号码
    int province;               //省份
    std::string city;           //城市
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

