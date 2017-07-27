#include "QMSCSDKIOS.h"
#import "QMSCSdkBridge.h"
#include "crypto/CCCrypto.h"

QMSCSDKIOS::QMSCSDKIOS()
{
    m_start_handler = 0;
    m_voice_handler = 0;
    m_text_handler = 0;
    m_finish_handler = 0;
    m_err_handler = 0;
    m_play_finish_handler = 0;
}

void QMSCSDKIOS::init()
{
    [[QMSCSdkBridge GetInstance] initBridge];
}

void QMSCSDKIOS::startRecogn(int start_handler, int voice_handler, int text_handler, int finish_handler, int err_handler)
{
    m_start_handler = start_handler;
    m_voice_handler = voice_handler;
    m_text_handler = text_handler;
    m_finish_handler = finish_handler;
    m_err_handler = err_handler;
    [[QMSCSdkBridge GetInstance] startRecogn];
}

void QMSCSDKIOS::stopRecogn()
{
    [[QMSCSdkBridge GetInstance] stopRecogn];
}

void QMSCSDKIOS::cancelRecogn()
{
    [[QMSCSdkBridge GetInstance] cancelRecogn];
}

void QMSCSDKIOS::recognStartHandler(const char *result)
{
    if(m_start_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_start_handler, result);
    }
}

void QMSCSDKIOS::recognErrorHandler(const char *result)
{
    if(m_err_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_err_handler, result);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_err_handler);
        m_err_handler = 0;
    }
}

void QMSCSDKIOS::recognFinishHandler(const char *result)
{
    if(m_finish_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_finish_handler, result);
        
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_text_handler);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_voice_handler);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_start_handler);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_finish_handler);
        m_text_handler = 0;
        m_voice_handler = 0;
        m_start_handler = 0;
        m_finish_handler = 0;
    }
}

void QMSCSDKIOS::recognTextFinishHandler(const char *content)
{
    if(m_text_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_text_handler, content);
    }
}

void QMSCSDKIOS::recognVoiceFinishHandler(const char *voice)
{
    if(m_voice_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_voice_handler, voice);
    }
}

void QMSCSDKIOS::recognVoiceBack(const char *base64Char, int inputLength)
{
    int outputLength = inputLength * 2;
    char* output = static_cast<char*>(malloc(outputLength));
    int dataUsed = cocos2d::extra::CCCrypto::encodeBase64((unsigned char*)base64Char, inputLength, output, outputLength);
    output[ dataUsed ] = '\0';
     //强制在主线程回调
    recognVoiceFinishHandler(output);
    free(output);
}

void QMSCSDKIOS::playVoice(const char *data, int mFinishHandler)
{
    m_play_finish_handler = mFinishHandler;
    int inputLength = strlen(data);
    int outputLength = inputLength * 2;
    char* output = static_cast<char*>(malloc(outputLength));
    int dataUsed = cocos2d::extra::CCCrypto::decodeBase64(data, output, outputLength);
    
    if (dataUsed > 0 && dataUsed < outputLength)
    {
        NSData* voiceData = [NSData dataWithBytes:output length:dataUsed];
        [[QMSCSdkBridge GetInstance] playVoice:voiceData];
    }
    free(output);
}

void QMSCSDKIOS::stopVoice()
{
    [[QMSCSdkBridge GetInstance] stopVoice];
}

void QMSCSDKIOS::playFinishHandler()
{
    if(m_play_finish_handler)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_play_finish_handler, 1);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_play_finish_handler);
        m_play_finish_handler = 0;
    }
}

