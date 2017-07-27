#include "QMSDK.h"
#include "QMSDKBridge.h"

static QMSDK* m_Instance;
QMSDK* QMSDK::sharedInstance()
{
    if (m_Instance == NULL){
        m_Instance = new QMSDK();
    }
    return m_Instance;
}

void QMSDK::init(SDKPlatform platform)
{
    QMSDKBridge::sharedInstance()->initSDK(platform);
    QSDK::sharedQSDK()->initHandle(true);
}

void QMSDK::login()
{
    QMSDKBridge::sharedInstance()->login();
}

void QMSDK::qrCodeLogin()
{
    QMSDKBridge::sharedInstance()->qrCodeLogin();
}

bool QMSDK::switchUser(bool flag)
{
    return QMSDKBridge::sharedInstance()->switchUser(flag);
}

void QMSDK::logout()
{
    QMSDKBridge::sharedInstance()->logout();
}

const char* QMSDK::getAccessToken()
{
    return QMSDKBridge::sharedInstance()->getAccessToken();
}

const char* QMSDK::getOpenId()
{
    return QMSDKBridge::sharedInstance()->getOpenId();
}

const char* QMSDK::getUid()
{
    return QMSDKBridge::sharedInstance()->getUid();
}

const char* QMSDK::getUdid()
{
    return QMSDKBridge::sharedInstance()->getUdid();
}

const char* QMSDK::getPayToken()
{
    return QMSDKBridge::sharedInstance()->getPayToken();
}

const char* QMSDK::getPf()
{
    return QMSDKBridge::sharedInstance()->getPf();
}

const char* QMSDK::getPfKey()
{
    return QMSDKBridge::sharedInstance()->getPfKey();
}

const char* QMSDK::getExtraInfo()
{
    return "";
}

bool QMSDK::isPlatformInstalled(SDKPlatform platform)
{
    return QMSDKBridge::sharedInstance()->isPlatformInstalled(platform);
}

void QMSDK::openURL(const char* url)
{
    QMSDKBridge::sharedInstance()->openURL(url);
}

void QMSDK::getUserInfo()
{
    QMSDKBridge::sharedInstance()->getUserInfo();
}

void QMSDK::getFriendsInfo()
{
    QMSDKBridge::sharedInstance()->getFriendsInfo();
}

void QMSDK::pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes)
{
    QMSDKBridge::sharedInstance()->pay(uid, order, productId, productName, amount, paydes);
}

void QMSDK::reportEvent(const char* name, const char* body, bool isRealTime)
{
    QMSDKBridge::sharedInstance()->reportEvent(name, body, isRealTime);
}

void QMSDK::registerPay(const char *env)
{
    QMSDKBridge::sharedInstance()->registerPay(env);
}

void QMSDK::showNotice(const char *scene)
{
    QMSDKBridge::sharedInstance()->showNotice(scene);
}

void QMSDK::hideScrollNotice()//隐藏公告栏
{
    QMSDKBridge::sharedInstance()->hideScrollNotice();
}

const char* QMSDK::getNoticeData(const char *scene)
{
    return QMSDKBridge::sharedInstance()->getNoticeData(scene);
}

void QMSDK::buglyLog(int level, const char* log)
{
    QMSDKBridge::sharedInstance()->buglyLog(level, log);
}

void QMSDK::getNearbyPersonInfo()
{
    QMSDKBridge::sharedInstance()->getNearbyPersonInfo();
}

void QMSDK::cleanLocation()
{
    QMSDKBridge::sharedInstance()->cleanLocation();
}

void QMSDK::getLocationInfo()
{
    QMSDKBridge::sharedInstance()->getLocationInfo();
}


void QMSDK::bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str)
{
    QMSDKBridge::sharedInstance()->bindQQGroup(cUnionid, cUnion_name, cZoneid, md5Str);
}

void QMSDK::joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey)
{
    QMSDKBridge::sharedInstance()->joinQQGroup(cQQGroupNum, cQQGroupKey);
}

void QMSDK::addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage)
{
    QMSDKBridge::sharedInstance()->addGameFriendToQQ(cFopenid, cDesc, cMessage);
}

void QMSDK::createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName)
{
    QMSDKBridge::sharedInstance()->createWXGroup(unionid, chatRoomName, chatRoomNickName);
}

void QMSDK::joinWXGroup(const char* unionid, const char* chatRoomNickName)
{
    QMSDKBridge::sharedInstance()->joinWXGroup(unionid, chatRoomNickName);
}

void QMSDK::queryWXGroupInfo(const char* unionID, const char* openIdLists)
{
    QMSDKBridge::sharedInstance()->queryWXGroupInfo(unionID, openIdLists);
}

void QMSDK::feedback(const char* body)
{
    QMSDKBridge::sharedInstance()->feedback(body);
}

void QMSDK::openWeiXinDeeplink(const char* link)
{
    QMSDKBridge::sharedInstance()->openWeiXinDeeplink(link);
}

void QMSDK::getWakeupInfo()
{
    QMSDKBridge::sharedInstance()->getWakeupInfo();
}



