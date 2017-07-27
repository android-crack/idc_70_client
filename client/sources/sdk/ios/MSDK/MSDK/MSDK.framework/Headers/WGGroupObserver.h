//
//  WGGroupObserver.h
//  MSDK
//
//  Created by 付亚明 on 7/30/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#ifndef MSDK_WGGroupObserver_h
#define MSDK_WGGroupObserver_h

#include <stdio.h>
#include <string>

/*! @brief 加群绑群类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGGroupObserver
{
public:
    /*! @brief 微信建群回调
     *
     * 将创建的操作结果通知上层App
     * @param GroupRet 创建结果
     * @return void
     */
    virtual void OnCreateWXGroupNotify(GroupRet& groupRet) = 0;
    
    /*! @brief 查询群成员回调
     *
     * 将查询的操作结果通知上层App
     * @param GroupRet 查询结果
     * @return void
     */
    virtual void OnQueryGroupInfoNotify(GroupRet& groupRet) = 0;
    
    /*! @brief 微信加群回调
     *
     * 将加群的操作结果通知上层App
     * @param GroupRet 加群结果
     * @return void
     */
    virtual void OnJoinWXGroupNotify(GroupRet& groupRet) = 0;
    
    //注：发送群消息回调走WGPlatformObserver OnShareNotify(ShareRet& shareRet);
    
    virtual ~WGGroupObserver() {};
    
};


#endif
