#ifndef __QTSSSDK_H__
#define __QTSSSDK_H__

#include "cocos2d.h"
using namespace cocos2d;

class QTssSDK
{
private:
    int m_iHandle;
    
public:
    static QTssSDK* getInstance();
    
    virtual void initTssSdk();
    void setHandler(int handler);
    void send_server_data(const char* data);
    virtual void setUserInfo(int platform, const char* open_id, int world_id, const char* uid);
    virtual void setGameStatusFrontground();
    virtual void setGameStatusBackground();
    
    void callback(int code, const char *msg);
};

#endif
