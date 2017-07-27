//
//  WGRealNameAuthObserver.h
//  MSDK
//
//  Created by Mike on 5/26/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#ifndef WGRealNameAuthObserver_h
#define WGRealNameAuthObserver_h

/*! @brief RealNameAuth类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGRealNameAuthObserver
{
public:
    /*! @brief 实名认证回调
     *
     * 将实名认证的操作结果通知上层App
     * @param RealNameAuthRet 实名认证结果
     * @return void
     */
    virtual void OnRealNameAuthNotify(RealNameAuthRet& realNameAuthRet) = 0;
    
    virtual ~WGRealNameAuthObserver() {};
    
};


#endif /* WGRealNameAuthObserver_h */
