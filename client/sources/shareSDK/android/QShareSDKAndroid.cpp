#include "QShareSDK.h"
#include <jni.h>
#include "platform/android/jni/JniHelper.h"

using namespace::cocos2d;
static const char *SHARESDK_CLASS = "com/qtz/utils/share/QTZShareSDK";

void QShareSDK::shareWithPhoto(ShareSDKPlatform platform, const char *imgURL, const char *extInfo)
{
	JniMethodInfo methodInfo;

    bool isHave = JniHelper::getStaticMethodInfo( methodInfo, SHARESDK_CLASS, "shareWithPhoto", "(ILjava/lang/String;Ljava/lang/String;)V");
    if ( isHave ) {
    	jstring jstrImgURL = methodInfo.env->NewStringUTF(imgURL);
    	jstring jstrExtInfo = methodInfo.env->NewStringUTF(extInfo);
        methodInfo.env->CallStaticVoidMethod( methodInfo.classID, methodInfo.methodID, platform, jstrImgURL, jstrExtInfo);
        methodInfo.env->DeleteLocalRef(jstrImgURL);
        methodInfo.env->DeleteLocalRef(jstrExtInfo);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}else
	{
		QShareSDK::getInstance()->shareCallback(-1,"interface [shareWithPhoto] not support");
	}
}

void QShareSDK::share(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    JniMethodInfo methodInfo;

    bool isHave = JniHelper::getStaticMethodInfo( methodInfo, SHARESDK_CLASS, "share", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if ( isHave ) {
    	jstring jstrTitle = methodInfo.env->NewStringUTF(title);
    	jstring jstrDesc = methodInfo.env->NewStringUTF(desc);
    	jstring jstrURL = methodInfo.env->NewStringUTF(url);
    	jstring jstrImgURL = methodInfo.env->NewStringUTF(imgURL);
    	jstring jstrExtInfo = methodInfo.env->NewStringUTF(extInfo);
        methodInfo.env->CallStaticObjectMethod( methodInfo.classID, methodInfo.methodID, platform, jstrTitle, jstrDesc, jstrURL, jstrImgURL, jstrExtInfo);
        methodInfo.env->DeleteLocalRef(jstrTitle);
        methodInfo.env->DeleteLocalRef(jstrURL);
        methodInfo.env->DeleteLocalRef(jstrDesc);
        methodInfo.env->DeleteLocalRef(jstrImgURL);
        methodInfo.env->DeleteLocalRef(jstrExtInfo);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}else
	{
        QShareSDK::getInstance()->shareCallback(-1,"interface [share] not support");
	}
}
    
void QShareSDK::shareToFriend(ShareSDKPlatform platform, const char *uid, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    JniMethodInfo methodInfo;

    bool isHave = JniHelper::getStaticMethodInfo( methodInfo, SHARESDK_CLASS, "shareToFriend", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if ( isHave ) {
    	jstring jstrUid = methodInfo.env->NewStringUTF(uid);
    	jstring jstrTitle = methodInfo.env->NewStringUTF(title);
    	jstring jstrDesc = methodInfo.env->NewStringUTF(desc);
    	jstring jstrURL = methodInfo.env->NewStringUTF(url);
    	jstring jstrImgURL = methodInfo.env->NewStringUTF(imgURL);
    	jstring jstrExtInfo = methodInfo.env->NewStringUTF(extInfo);
        methodInfo.env->CallStaticVoidMethod( methodInfo.classID, methodInfo.methodID, platform, jstrUid, jstrTitle, jstrDesc, jstrURL, jstrImgURL, jstrExtInfo);
        methodInfo.env->DeleteLocalRef(jstrUid);
        methodInfo.env->DeleteLocalRef(jstrTitle);
        methodInfo.env->DeleteLocalRef(jstrURL);
        methodInfo.env->DeleteLocalRef(jstrDesc);
        methodInfo.env->DeleteLocalRef(jstrImgURL);
        methodInfo.env->DeleteLocalRef(jstrExtInfo);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}else
	{
		QShareSDK::getInstance()->shareCallback(-1,"interface [shareToFriend] not support");
	}
}

void QShareSDK::shareWithUrl(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    JniMethodInfo methodInfo;

    bool isHave = JniHelper::getStaticMethodInfo( methodInfo, SHARESDK_CLASS, "shareWithUrl", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if ( isHave ) {
        jstring jstrTitle = methodInfo.env->NewStringUTF(title);
        jstring jstrDesc = methodInfo.env->NewStringUTF(desc);
        jstring jstrURL = methodInfo.env->NewStringUTF(url);
        jstring jstrImgURL = methodInfo.env->NewStringUTF(imgURL);
        jstring jstrExtInfo = methodInfo.env->NewStringUTF(extInfo);
        methodInfo.env->CallStaticObjectMethod( methodInfo.classID, methodInfo.methodID, platform, jstrTitle, jstrDesc, jstrURL, jstrImgURL, jstrExtInfo);
        methodInfo.env->DeleteLocalRef(jstrTitle);
        methodInfo.env->DeleteLocalRef(jstrURL);
        methodInfo.env->DeleteLocalRef(jstrDesc);
        methodInfo.env->DeleteLocalRef(jstrImgURL);
        methodInfo.env->DeleteLocalRef(jstrExtInfo);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
    }else
    {
        QShareSDK::getInstance()->shareCallback(-1,"interface [shareWithUrl] not support");
    }
}
