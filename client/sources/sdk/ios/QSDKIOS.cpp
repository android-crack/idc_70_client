#include "QSDK.h"
#ifdef QPLATFORM_MSDK
    #include "QMSDK.h"
#endif

void QSDK::init(SDKPlatform platform, int nHandler)
{
    m_Handler = nHandler;
    switch(platform)
    {
#ifdef QPLATFORM_MSDK
        case PLATFORM_GUEST:
        case PLATFORM_QQ:
        case PLATFORM_WEIXIN:
            m_sdk = QMSDK::sharedInstance();
            break;
#endif
        default:
            break;
    }
    
    if(m_sdk)
    {
        m_sdk->init(platform);
    }
}
