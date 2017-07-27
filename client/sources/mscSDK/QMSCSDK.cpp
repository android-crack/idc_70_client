#include "QMSCSDK.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    #include "QMSCSDKIOS.h"
#endif

static QMSCSDK* p_mscQmscSDK =   NULL;

QMSCSDK* QMSCSDK::getInstance()
{
    if ( p_mscQmscSDK == NULL ) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        p_mscQmscSDK = new QMSCSDKIOS();
#else
        p_mscQmscSDK = new QMSCSDK();
#endif
    }
    return p_mscQmscSDK;
}
