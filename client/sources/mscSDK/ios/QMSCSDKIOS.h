#ifndef __QMSCSDKIOS_H__
#define __QMSCSDKIOS_H__

#include "QMSCSDK.h"
//#import "SpeexCodec.h"

class QMSCSDKIOS: public QMSCSDK
{
public:
    QMSCSDKIOS();
    virtual void init();
    virtual void startRecogn(int start_handler, int voice_handler, int text_handler, int finish_handler, int err_handler);
    virtual void stopRecogn();
    virtual void cancelRecogn();
    
    virtual void playVoice(const char *voice, int mFinishHandler);
    virtual void stopVoice();
    
    void recognStartHandler(const char *result);
    void recognErrorHandler(const char *result);
    void recognFinishHandler(const char *result);
    void recognTextFinishHandler(const char *content);
    void recognVoiceFinishHandler(const char *voice);
    void playFinishHandler();
    
    void recognVoiceBack(const char *encodeData, int inputLength);
    
private:
    int m_start_handler;
    int m_voice_handler;
    int m_text_handler;
    int m_finish_handler;
    int m_err_handler;
    int m_play_finish_handler;
};

#endif
