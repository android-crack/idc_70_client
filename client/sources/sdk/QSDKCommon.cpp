#include "QSDK.h"
#ifdef QPLATFORM_MSDK
    #include "QMSDK.h"
#endif

static QSDK* m_sharedQSDK = NULL;

QSDK* QSDK::sharedQSDK()
{
    if (m_sharedQSDK == NULL)
    {
        m_sharedQSDK = new QSDK();
    }
    return m_sharedQSDK;
}

QSDK::QSDK()
{
    m_sdk = NULL;
    m_Handler = 0;
    m_wakeup_handler = 0;
}

QSDK::~QSDK()
{
 
}

void QSDK::login()
{
    if(m_sdk)
    {
        m_sdk->login();
    }
}

void QSDK::qrCodeLogin()
{
    if(m_sdk)
    {
        m_sdk->qrCodeLogin();
    }
}

bool QSDK::switchUser(bool flag)
{
    if(m_sdk)
    {
        return m_sdk->switchUser(flag);
    }
    return false;
}

void QSDK::logout()
{
    if(m_sdk)
    {
        m_sdk->logout();
    }
}

const char* QSDK::getUid()
{
    if(m_sdk)
    {
        return m_sdk->getUid();
    }
    return 0;
}

const char* QSDK::getAccessToken()
{
    if(m_sdk)
    {
        return m_sdk->getAccessToken();
    }
    return "";
}

const char* QSDK::getOpenId()
{
    if(m_sdk)
    {
        return m_sdk->getOpenId();
    }
    return "";
}

const char* QSDK::getUdid()
{
    if(m_sdk)
    {
        return m_sdk->getUdid();
    }
    return "";
}

const char* QSDK::getPayToken()
{
    if(m_sdk)
    {
        return m_sdk->getPayToken();
    }
    return "";
}

const char* QSDK::getPf()
{
    if(m_sdk)
    {
        return m_sdk->getPf();
    }
    return "";
}

const char* QSDK::getPfKey()
{
    if(m_sdk)
    {
        return m_sdk->getPfKey();
    }
    return "";
}

const char* QSDK::getExtraInfo()
{
    if(m_sdk)
    {
        return m_sdk->getExtraInfo();
    }
    return "";
}

void QSDK::getUserInfo()
{
    if(m_sdk)
    {
        m_sdk->getUserInfo();
    }
}

void QSDK::getFriendsInfo()
{
    if(m_sdk)
    {
        m_sdk->getFriendsInfo();
    }
}


bool QSDK::isPlatformInstalled(SDKPlatform platform)
{
#ifdef QPLATFORM_MSDK
    return QMSDK::isPlatformInstalled(platform);
#endif
    return true;
}

void QSDK::openURL(const char *url)
{
    if(!url)
    {
        return;
    }
#ifdef QPLATFORM_MSDK
    QMSDK::openURL(url);
#endif
}


void QSDK::pay(int uid, const char *order, const char *productId, const char *productName, float amount, const char *paydes)
{
    if(!productId)
    {
        return;
    }
    if(m_sdk)
    {
        m_sdk->pay(uid, order, productId, productName, amount, paydes);
    }
}

void QSDK::reportEvent(const char* name, const char* body, bool isRealTime)
{
#ifdef QPLATFORM_MSDK
    QMSDK::reportEvent(name, body, isRealTime);
#endif
}

void QSDK::registerPay(const char *env)
{
#ifdef QPLATFORM_MSDK
    return QMSDK::registerPay(env);
#endif
}

void QSDK::showNotice(const char *scene)
{
#ifdef QPLATFORM_MSDK
    QMSDK::showNotice(scene);
#endif
}

void QSDK::hideScrollNotice()
{
#ifdef QPLATFORM_MSDK
    QMSDK::hideScrollNotice();
#endif
}

const char* QSDK::getNoticeData(const char *scene)
{
#ifdef QPLATFORM_MSDK
    return QMSDK::getNoticeData(scene);
#endif
    return "";
}

void QSDK::buglyLog(int level, const char* log)
{
#ifdef QPLATFORM_MSDK
    QMSDK::buglyLog(level, log);
#endif
}

void QSDK::getNearbyPersonInfo()
{
    if(m_sdk)
    {
        m_sdk->getNearbyPersonInfo();
    }
}

void QSDK::cleanLocation()
{
    if(m_sdk)
    {
        m_sdk->cleanLocation();
    }
}

void QSDK::getLocationInfo()
{
    if(m_sdk)
    {
        m_sdk->getLocationInfo();
    }
}


void QSDK::bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str)
{
    if(m_sdk)
    {
        m_sdk->bindQQGroup(cUnionid, cUnion_name, cZoneid, md5Str);
    }
}

void QSDK::joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey)
{
    if(m_sdk)
    {
        m_sdk->joinQQGroup(cQQGroupNum, cQQGroupKey);
    }
}

void QSDK::addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage)
{
    if(m_sdk)
    {
        m_sdk->addGameFriendToQQ(cFopenid, cDesc, cMessage);
    }
}

void QSDK::createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName)
{
    if(m_sdk)
    {
        m_sdk->createWXGroup(unionid, chatRoomName, chatRoomNickName);
    }
}

void QSDK::joinWXGroup(const char* unionid, const char* chatRoomNickName)
{
    if(m_sdk)
    {
        m_sdk->joinWXGroup(unionid, chatRoomNickName);
    }
}

void QSDK::queryWXGroupInfo(const char* unionID, const char* openIdLists)
{
    if(m_sdk)
    {
        m_sdk->queryWXGroupInfo(unionID, openIdLists);
    }
}

void QSDK::feedback(const char* body)
{
    if(m_sdk)
    {
        m_sdk->feedback(body);
    }
}

void QSDK::openWeiXinDeeplink(const char* link)
{
    if(m_sdk)
    {
        m_sdk->openWeiXinDeeplink(link);
    }
}

void QSDK::getWakeupInfo(int nHandler)
{
    m_wakeup_handler = nHandler;
#ifdef QPLATFORM_MSDK
    QMSDK::getWakeupInfo();
#endif
}

////////////////////////////////////////////////////////////////////

//callback
void QSDK::executeSDKEvent(CCLuaValueDict eventDict)
{
    CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
    stack->pushCCLuaValueDict(eventDict);
    stack->executeFunctionByHandler(m_Handler, 1);
}

void QSDK::initHandle(bool isSuccess)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_INIT);
    event["result"] = CCLuaValue::booleanValue(isSuccess);
    executeSDKEvent(event);
}

void QSDK::commonHandle(int iEvent, int code, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(iEvent);
    event["isSuccess"] = CCLuaValue::intValue(code);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}


void QSDK::loginHandle(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_LOGIN);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::logoutHandle(bool isSuccess)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_LOGOUT);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    executeSDKEvent(event);
}

void QSDK::payHandle(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_PAY);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::userInfoHandle(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_USER_INFO);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::friendsInfoHandle(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_FRIEND_INFO);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::nearbyPersonInfoHandler(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_NEARBY_PERSON_INFO);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::getLocationInfoHandler(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_LOCATION_INFO);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::onCreateWXGroup(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_CREATE_WXGROUP);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::onJoinWXGroup(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_JOIN_WXGROUP);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::onQueryWXGroupInfo(bool isSuccess, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_QUERY_WXGROUP);
    event["isSuccess"] = CCLuaValue::booleanValue(isSuccess);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

void QSDK::onBindQQGroupHandler(int code, const char* msg)
{
    CCLuaValueDict event;
    event["eventType"] = CCLuaValue::intValue(SDK_EVENT_SHARE_NOTICE);
    event["code"] = CCLuaValue::booleanValue(code);
    event["msg"] = CCLuaValue::stringValue(msg);
    executeSDKEvent(event);
}

bool QSDK::onWakeupDdataHandler(const char* msg)
{
    if(m_wakeup_handler)
    {
        CCLuaValueDict event;
        event["msg"] = CCLuaValue::stringValue(msg);
        CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
        stack->pushCCLuaValueDict(event);
        stack->executeFunctionByHandler(m_wakeup_handler, 1);
        return true;
    }
    return false;
}
