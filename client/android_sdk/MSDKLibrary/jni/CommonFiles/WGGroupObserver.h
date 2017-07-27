//
//  WGPlatformObserver.h
//  WGPlatform
//
//  Created by fly chen on 2/22/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_WGGroupObserver_h
#define WGPlatform_WGGroupObserver_h

#include <string>
#include "WGCommon.h"

/*! @brief 广告通知类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGGroupObserver
{
public:
    virtual void OnQueryGroupInfoNotify(GroupRet& groupRet) = 0;
    virtual void OnBindGroupNotify(GroupRet& groupRet) = 0;
    virtual void OnUnbindGroupNotify(GroupRet& groupRet) = 0;
    virtual void OnQueryGroupKeyNotify(GroupRet& groupRet) = 0;
    virtual void OnJoinWXGroupNotify(GroupRet& groupRet) = 0;
    virtual void OnCreateWXGroupNotify(GroupRet& groupRet) = 0;
	virtual ~WGGroupObserver() {};
	
};

#endif
