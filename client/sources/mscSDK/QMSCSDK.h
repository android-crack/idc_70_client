#ifndef __QMSCSDK_H__
#define __QMSCSDK_H__

#include "cocos2d.h"
extern "C" {
#include "lua.h"
#include "tolua_fix.h"
}

using namespace cocos2d;

class QMSCSDK
{
public:
    static QMSCSDK* getInstance();
    
    virtual void init(){}
    virtual void startRecogn(int start_handler, int voice_handler, int text_handler, int finish_handler, int err_handler){}
    virtual void stopRecogn(){}
    virtual void cancelRecogn(){}
    
    virtual void playVoice(const char *voice, int mFinishHandler){}
    virtual void stopVoice(){}
    
    virtual void recognStartHandler(const char *result){}
    virtual void recognErrorHandler(const char *result){}
    virtual void recognFinishHandler(const char *result){}
    virtual void recognTextFinishHandler(const char *content){}
    virtual void recognVoiceFinishHandler(const char *voice){}
    virtual void playFinishHandler(){}
    
    virtual void recognVoiceBack(const char *encodeData, int inputLength){}
};

#endif
