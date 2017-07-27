//
//  WGADObserver.h
//  MSDK
//
//  Created by Jason on 14/11/20.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#ifndef __MSDK__WGADObserver__
#define __MSDK__WGADObserver__

#include <stdio.h>

#include <string>

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

#endif /* defined(__MSDK__WGADObserver__) */
