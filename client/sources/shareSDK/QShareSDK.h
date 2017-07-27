#ifndef __QSHARESDK_H__
#define __QSHARESDK_H__

#include "cocos2d.h"
using namespace cocos2d;

typedef enum
{
    kSharePlatform_NONE = 0,
    kSharePlatform_QQ = 2,
    kSharePlatform_WECHAT,
}ShareSDKPlatform;

class QShareSDK
{
private:
    int m_iHandle;
    
private:
    void shareWithPhoto(ShareSDKPlatform platform, const char *imgURL, const char *extInfo); 

    void share(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo);
    
    void shareToFriend(ShareSDKPlatform platform, const char *uid, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo);
    
    void shareWithUrl(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo);

public:
    static QShareSDK* getInstance();
    QShareSDK();
    static const char* saveScreenToFile(const char *filename, const CCRect& rect = CCRectZero);

    void shareWithPhoto(ShareSDKPlatform platform, const char *imgURL, const char *extInfo, int handler); 

    void share(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler);
    
    void shareToFriend(ShareSDKPlatform platform, const char *uid, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler);

    void shareWithUrl(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler);
    
    void shareCallback(int code, const char *msg);
};

#endif
