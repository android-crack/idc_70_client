#ifndef __QSDK_H__
#define __QSDK_H__

#include "cocos2d.h"
#if CC_LUA_ENGINE_ENABLED > 0
extern "C" {
#include "lua.h"
}
#include "CCLuaEngine.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#endif

using namespace cocos2d;

typedef enum
{
    PLATFORM_NONE,
    PLATFORM_GUEST,
    PLATFORM_QQ,
    PLATFORM_WEIXIN,
}SDKPlatform;

typedef enum
{
    MIDAS_ORDER,
    MIDAS_PAY,
    MIDAS_DISTRIBUTE_GOODS,
    MIDAS_RESTORABLE_PRODUCT,
    MIDAS_GET_RESTORABLE_PRODUCT,
    MIDAS_GET_PRODUCT_INFO,
    MIDAS_NET_WORK,
    MIDAS_LOGIN_EXPIRY,
    MIDAS_GET_RECOMMEND_LIST,
    MIDAS_LOGIN_FAIL = 10000,
}SDKMidasType;

typedef enum
{
    SDK_EVENT_INIT,
    SDK_EVENT_LOGIN,
    SDK_EVENT_LOGOUT,
    SDK_EVENT_PAY,
    SDK_EVENT_USER_INFO,
    SDK_EVENT_FRIEND_INFO,
    SDK_EVENT_NEARBY_PERSON_INFO,
    SDK_EVENT_LOCATION_INFO,
    SDK_EVENT_CREATE_WXGROUP,
    SDK_EVENT_JOIN_WXGROUP,
    SDK_EVENT_QUERY_WXGROUP,
    SDK_EVENT_SHARE_NOTICE,//QQ加入群，会通过share回调
    
}SDKEventType;


class QSDKCommon
{
public:
    virtual void init(SDKPlatform platform) = 0;
    virtual void login() = 0;
    virtual void qrCodeLogin(){}
    virtual bool switchUser(bool flag){return false;}
    virtual void logout() = 0;
    virtual const char* getAccessToken() = 0;
    virtual const char* getPayToken() = 0;
    virtual const char* getPf() = 0;
    virtual const char* getPfKey() = 0;
    virtual const char* getOpenId() = 0;
    virtual const char* getUid() = 0;
    virtual const char* getUdid() = 0;
    virtual const char* getExtraInfo() = 0;
    virtual void getUserInfo(){}
    virtual void getFriendsInfo(){}
    virtual void pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes) = 0;
    virtual void getNearbyPersonInfo(){}
    virtual void cleanLocation(){}
    virtual void getLocationInfo(){}
    virtual void bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str){}
    virtual void joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey){}
    virtual void addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage){}

    virtual void createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName){}
    virtual void joinWXGroup(const char* unionid, const char* chatRoomNickName){}
    virtual void queryWXGroupInfo(const char* unionID, const char* openIdLists){}
    virtual void feedback(const char* body){}//反馈
    virtual void openWeiXinDeeplink(const char* link){}
};

class QSDK
{
public:
    static QSDK* sharedQSDK();
    
    QSDK();
    virtual ~QSDK();
    void init(SDKPlatform platform, int nHandler);
    void login();
    void qrCodeLogin();
    bool switchUser(bool flag);
    void logout();
    const char* getUid();
    const char* getOpenId();
    const char* getAccessToken();
    const char* getPayToken();
    const char* getPf();
    const char* getPfKey();
    const char* getUdid();
    const char* getExtraInfo();
    bool isPlatformInstalled(SDKPlatform platform);
    void getUserInfo();
    void getFriendsInfo();
    void openURL(const char* url);
    void pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes);
    void reportEvent(const char* name, const char* body, bool isRealTime);
    void registerPay(const char *env);
    void showNotice(const char *scene);
    void hideScrollNotice();
    const char* getNoticeData(const char *scene);
    void buglyLog(int level, const char* log);
    void getNearbyPersonInfo();
    void cleanLocation();
    void getLocationInfo();
    void feedback(const char* body);//反馈
    void openWeiXinDeeplink(const char* link);
    
    void bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str);
    void joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey);
    void addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage);

    void createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName);
    void joinWXGroup(const char* unionid, const char* chatRoomNickName);
    void queryWXGroupInfo(const char* unionID, const char* openIdLists);
    void getWakeupInfo(int nHandler);
    
    //callback
    void commonHandle(int event, int code, const char* msg);
    void initHandle(bool isSuccess);
    void loginHandle(bool isSuccess, const char* msg);
    void logoutHandle(bool isSuccess);
    void payHandle(bool isSuccess, const char* msg);
    void userInfoHandle(bool isSuccess, const char* msg);
    void friendsInfoHandle(bool isSuccess, const char* msg);
    void nearbyPersonInfoHandler(bool isSuccess, const char* msg);
    void getLocationInfoHandler(bool isSuccess, const char* msg);
    
    void onCreateWXGroup(bool isSuccess, const char* msg);
    void onJoinWXGroup(bool isSuccess, const char* msg);
    void onQueryWXGroupInfo(bool isSuccess, const char* msg);
    void onBindQQGroupHandler(int code, const char* msg);
    bool onWakeupDdataHandler(const char* msg);
    
private:
    void executeSDKEvent(CCLuaValueDict eventDict);
private:
    int m_Handler;
    int m_wakeup_handler;
    QSDKCommon* m_sdk;
};

#endif
