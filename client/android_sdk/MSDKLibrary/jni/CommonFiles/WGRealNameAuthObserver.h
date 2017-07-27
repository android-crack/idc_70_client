//
//  WGPlatformObserver.h
//  WGPlatform
//
//  Created by fly chen on 2/22/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_WGRealNameAuthObserver_h
#define WGPlatform_WGRealNameAuthObserver_h

#include <string>
#include "WGCommon.h"

/*! @brief 实名认证通知类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGRealNameAuthObserver
{
public:
    virtual void OnRealNameAuthNotify(RealNameAuthRet& authRet) = 0;

	virtual ~WGRealNameAuthObserver() {};
	
};

#endif
