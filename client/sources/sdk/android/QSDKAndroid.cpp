//
//  QSDK.m
//  Q2
//
//  Created by xuchdong on 14-3-6.
//
//

#include "QSDK.h"
#include "QSDKAndroidBridge.h"

void QSDK::init(SDKPlatform platform, int nHandler)
{
    m_Handler = nHandler;
    m_sdk = QSDKAndroidBridge::getInstance();
    ((QSDKAndroidBridge *)m_sdk)->init(platform);
}
