#ifndef __QSDK_ANDROID_BRIDGE_H__
#define __QSDK_ANDROID_BRIDGE_H__ 

#include "QSDK.h"


class QSDKAndroidBridge : public QSDKCommon
{
    public:
        void init(SDKPlatform platform);
        void login();
        void logout();
        const char* getAccessToken();
        const char* getPayToken();
        const char* getPf();
        const char* getPfKey();
        const char* getOpenId();
        const char* getUid();
        const char* getUdid();
        const char* getExtraInfo();
        void getUserInfo();
        void getFriendsInfo();
        void pay(int uid, const char *order, const char *productId, const char *productName, float amount, const char *paydes);
        void reportEvent(const char* name, const char* body, bool isRealTime);

        void showNotice(const char *scene);
        void hideScrollNotice();
        void buglyLog(int level, const char* log);

        static QSDKAndroidBridge* getInstance();

    private:
        void executeJavaVoidFunction(const char* funcName);
        const char* getStringFromFunction(const char* funcName);

    private:
        SDKPlatform mPlatform;
};

#endif   //__QSDK_ANDROID_BRIDGE_H__

