//
//  WGPlatformObserver.h
//  WGPlatform
//
//  Created by fly chen on 2/22/13.
//  Copyright (c) 2013 tencent.com. All rights reserved.
//

#ifndef WGPlatform_WGPlatformObserver_h
#define WGPlatform_WGPlatformObserver_h


/*! @brief WGPlatform通知类
 *
 * SDK通过通知类和外部调用者通讯
 */
class WGPlatformObserver
{
public:
	/*! @brief 登录回调
	 *
	 * 登录时通知上层App，并传递结果
	 * @param loginRet 参数
	 * @return void
	 */
	virtual void OnLoginNotify(LoginRet& loginRet) = 0;
    
    
	/*! @brief 分享结果
	 *
	 * 将分享的操作结果通知上层App
	 * @param shareRet 分享结果
	 * @return void
	 */
	virtual void OnShareNotify(ShareRet& shareRet) = 0;
    
    
	/*! @brief 被其他应用拉起
	 *
	 *被其他平台拉起
	 * @param wakeupRet  唤起参数
	 * @return void
	 */
	virtual void OnWakeupNotify(WakeupRet& wakeupRet) = 0;
    
    
    virtual void OnRelationNotify(RelationRet& relationRet) = 0;
    
    virtual void OnLocationNotify(RelationRet& relationRet) = 0;

    virtual void OnLocationGotNotify(LocationRet& locationRet) = 0;

    virtual void OnFeedbackNotify(int flag, std::string desc) = 0;
    
    virtual std::string OnCrashExtMessageNotify() = 0;

	virtual ~WGPlatformObserver() {};
	

};

#endif
