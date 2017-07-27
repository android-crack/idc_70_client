#ifndef __QMSDK__
#define __QMSDK__

#include "QSDK.h"

class QMSDK : public QSDKCommon
{
public:
    static QMSDK* sharedInstance();
    void init(SDKPlatform platform);
    void login();
    void qrCodeLogin();
    bool switchUser(bool flag);
    void logout();
    const char* getAccessToken();
    const char* getPayToken();
    const char* getPf();
    const char* getPfKey();
    const char* getOpenId();
    const char* getUid();
    const char* getUdid();
    const char* getExtraInfo();
    static bool isPlatformInstalled(SDKPlatform platform);
    static void openURL(const char* url);
    void getUserInfo();
    void getFriendsInfo();
    void pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes);
    static void reportEvent(const char* name, const char* body, bool isRealTime);
    static void registerPay(const char *env);
    static void showNotice(const char *scene);
    static void hideScrollNotice();//隐藏公告栏
    static const char* getNoticeData(const char *scene);
    static void buglyLog(int level, const char* log);
    void getNearbyPersonInfo();
    void cleanLocation();
    void getLocationInfo();
    
    void bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str);
    void joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey);
    void addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage);
    
    void createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName);
    void joinWXGroup(const char* unionid, const char* chatRoomNickName);
    void queryWXGroupInfo(const char* unionID, const char* openIdLists);

    void feedback(const char* body);//反馈
    void openWeiXinDeeplink(const char* link);
    static void getWakeupInfo();
};

#endif


