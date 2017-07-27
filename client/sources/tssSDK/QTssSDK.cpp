#include "QTssSDK.h"

using namespace::cocos2d;

static QTssSDK* p_tssQTssSDK =   NULL;

QTssSDK* QTssSDK::getInstance()
{
    if ( p_tssQTssSDK == NULL ) {
        p_tssQTssSDK = new QTssSDK();
    }
    return p_tssQTssSDK;
}

void QTssSDK::setHandler(int handler)
{
    m_iHandle = handler;
}

void QTssSDK::callback(int code, const char *msg)
{
    if(m_iHandle)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_iHandle, code, msg);
    }
}
