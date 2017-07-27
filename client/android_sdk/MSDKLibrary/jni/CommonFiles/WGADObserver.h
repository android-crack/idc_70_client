//
//  WGPlatformObserver.h
//  WGPlatform
//
//  Created by fly chen on 2/22/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_WGADObserver_h
#define WGPlatform_WGADObserver_h

#include <string>
#include "WGCommon.h"

/*! @brief 广告通知类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGADObserver
{
public:
    virtual void OnADNotify(ADRet& adRet) = 0;

#ifdef ANDROID
    virtual void OnADBackPressedNotify(ADRet& adRet) = 0;
#endif

	virtual ~WGADObserver() {};
	
};

#endif
