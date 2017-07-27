//
//  WGWebviewObserver.h
//  MSDK
//
//  Created by Mike on 4/12/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#ifndef WGWebviewObserver_h
#define WGWebviewObserver_h

/*! @brief Webview类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGWebviewObserver
{
public:
    /*! @brief Webview回调
     *
     * 将创建的操作结果通知上层App
     * @param WebviewRet 创建结果
     * @return void
     */
    virtual void OnWebviewNotify(WebviewRet& webviewRet) = 0;
    
    virtual ~WGWebviewObserver() {};
    
};



#endif /* WGWebviewObserver_h */
