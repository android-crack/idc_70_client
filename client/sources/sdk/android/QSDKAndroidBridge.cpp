#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include "QSDKAndroidBridge.h"

#include <jni.h>
#include <dlfcn.h>
#include <android/log.h>
#include "platform/android/jni/JniHelper.h"
#define  LOG_TAG    "CRASH"
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)


static const char *QSDK_CLASS = "com/qtz/utils/sdk/QTZJavaSDK";
static QSDKAndroidBridge* s_sharedQSDKAndroidBridge = NULL;


QSDKAndroidBridge* QSDKAndroidBridge::getInstance()
{
    if (s_sharedQSDKAndroidBridge == NULL)
    {
        s_sharedQSDKAndroidBridge = new QSDKAndroidBridge();
    }
    return s_sharedQSDKAndroidBridge;
}


void QSDKAndroidBridge::init(SDKPlatform platform)
{
    mPlatform = platform;
    QSDK::sharedQSDK()->initHandle(0);
}


void QSDKAndroidBridge::login()
{
    JniMethodInfo minfo;
	bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, "login", "(I)V");
	if (isHave)
    {
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, mPlatform);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
}


void QSDKAndroidBridge::logout()
{
    executeJavaVoidFunction("logout");
}


const char* QSDKAndroidBridge::getStringFromFunction(const char* funcName)
{
    JniMethodInfo minfo;
    std::string ret = "";

    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, funcName, "()Ljava/lang/String;");
    if (isHave)
    {
        jstring str = (jstring)minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
        minfo.env->DeleteLocalRef(minfo.classID);
        ret = JniHelper::jstring2string(str);
        minfo.env->DeleteLocalRef(str);
    }
    return ret.c_str();
}


void QSDKAndroidBridge::executeJavaVoidFunction(const char* funcName)
{
    JniMethodInfo minfo;

    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, funcName, "()V");
    if (isHave)
    {
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID);
        minfo.env->DeleteLocalRef( minfo.classID );
    }   
}


const char* QSDKAndroidBridge::getAccessToken()
{
    return getStringFromFunction("getAccessToken");
}


const char* QSDKAndroidBridge::getPayToken()
{
    return getStringFromFunction("getPayToken");
}


const char* QSDKAndroidBridge::getPf()
{
    return getStringFromFunction("getPf");
}


const char* QSDKAndroidBridge::getPfKey()
{
    return getStringFromFunction("getPfKey");
}


const char* QSDKAndroidBridge::getOpenId()
{
    return getStringFromFunction("getOpenId");
}


const char* QSDKAndroidBridge::getUid()
{
    return getStringFromFunction("getUid");
}


const char* QSDKAndroidBridge::getUdid()
{
    return getStringFromFunction("getUdid");
}


const char* QSDKAndroidBridge::getExtraInfo()
{
    return getStringFromFunction("getExtraInfo");
}


void QSDKAndroidBridge::getUserInfo()
{
    executeJavaVoidFunction("getUserInfo");
}


void QSDKAndroidBridge::getFriendsInfo()
{
    executeJavaVoidFunction("getFriendsInfo");
}

void QSDKAndroidBridge::pay(int uid, const char *order, const char *productId, const char *productName, float amount, const char *paydes)
{
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, "pay", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;FLjava/lang/String;)V" );
    if (isHave)
    {
        jstring strOrder = minfo.env->NewStringUTF(order);
        jstring strProductId = minfo.env->NewStringUTF(productId);
        jstring strProductName = minfo.env->NewStringUTF(productName);
        jstring strPaydes = minfo.env->NewStringUTF(paydes);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, uid, strOrder, strProductId, strProductName, amount, strPaydes);

        minfo.env->DeleteLocalRef(minfo.classID);
        minfo.env->DeleteLocalRef(strOrder);
        minfo.env->DeleteLocalRef(strProductId);
        minfo.env->DeleteLocalRef(strProductName);
        minfo.env->DeleteLocalRef(strPaydes);
    }
}


void QSDKAndroidBridge::reportEvent(const char* name, const char* body, bool isRealTime)
{
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, "reportEvent", "(Ljava/lang/String;Ljava/lang/String;Z)V");
    if (isHave)
    {
        jstring strName = minfo.env->NewStringUTF(name);
        jstring strBody = minfo.env->NewStringUTF(body);
        minfo.env->CallStaticVoidMethod( minfo.classID, minfo.methodID, strName, strBody, isRealTime );

        minfo.env->DeleteLocalRef( minfo.classID );
        minfo.env->DeleteLocalRef( strName );
        minfo.env->DeleteLocalRef( strBody );
    }   
}


void QSDKAndroidBridge::showNotice(const char *scene)
{
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, "showNotice", "(Ljava/lang/String;)V" );
    if (isHave)
    {
        jstring strScene = minfo.env->NewStringUTF(scene);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, strScene);

        minfo.env->DeleteLocalRef(minfo.classID);
        minfo.env->DeleteLocalRef(strScene);
    }
}


void QSDKAndroidBridge::hideScrollNotice()
{
    executeJavaVoidFunction("hideScrollNotice");
}


void QSDKAndroidBridge::buglyLog(int level, const char* log)
{
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo, QSDK_CLASS, "buglyLog", "(ILjava/lang/String;)V" );
    if (isHave)
    {
        jstring strLog = minfo.env->NewStringUTF(log);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, level, strLog);

        minfo.env->DeleteLocalRef(minfo.classID);
        minfo.env->DeleteLocalRef(strLog);
    }
}
