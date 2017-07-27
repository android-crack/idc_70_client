#include "QSDK.h"
#import "QMSDKBridge.h"
#import "AppController.h"
#import "MSDK/MSDK.h"
#include "QShareSDK.h"

static QMSDKBridge* m_Instance;

QMSDKBridge* QMSDKBridge::sharedInstance()
{
    if (m_Instance == NULL){
        m_Instance = new QMSDKBridge();
    }
    return m_Instance;
}

void QMSDKBridge::setObServer()
{
    WGPlatform* plat = WGPlatform::GetInstance();
    // for testing
    //plat->WGOpenMSDKLog(true);
    plat->WGSetObserver(this);
    plat->WGEnableCrashReport(true, true);
    plat->WGSetGroupObserver(this);
}

void QMSDKBridge::initSDK(SDKPlatform platform)
{
    this->platform = platform;
}

void QMSDKBridge::login()
{
    WGPlatform* plat = WGPlatform::GetInstance();

    LoginRet ret;
    plat->WGGetLoginRecord(ret);

    if(PLATFORM_QQ == platform)
    {
        if(this->isPlatformInstalled(PLATFORM_QQ) && ret.flag == eFlag_Succ && ret.platform == ePlatform_QQ)
        {//未安装QQ的话每次都拉起，不处理本地票据
            plat->WGLogin();
            return;
        }
        
        this->logout();
        plat->WGSetPermission(eOPEN_ALL);
        plat->WGLogin(ePlatform_QQ);
    }
    else if(PLATFORM_WEIXIN == platform)
    {
        if (ret.platform == ePlatform_Weixin && (ret.flag == eFlag_Succ || ret.flag == eFlag_WX_AccessTokenExpired))
        {
            plat->WGLogin();
            return;
        }
        this->logout();
        plat->WGLogin(ePlatform_Weixin);
    }
    else if(PLATFORM_GUEST == platform)
    {
        this->logout();
        plat->WGSetPermission(eOPEN_ALL);
        plat->WGLogin(ePlatform_Guest);
    }
}

void QMSDKBridge::qrCodeLogin()
{
    WGPlatform* plat = WGPlatform::GetInstance();
    if(PLATFORM_QQ == platform)
    {
        plat->WGQrCodeLogin(ePlatform_QQ);
    }
    else if(PLATFORM_WEIXIN == platform)
    {
        plat->WGQrCodeLogin(ePlatform_Weixin);
    }
}

bool QMSDKBridge::switchUser(bool flag)
{
    bool result = WGPlatform::GetInstance()->WGSwitchUser(flag);
    if(result == false)
    {
        this->logout();
    }
    return result;
}

void QMSDKBridge::logout()
{
    WGPlatform::GetInstance()->WGLogout();
}

const char* QMSDKBridge::getAccessToken()
{
    return accessToken.c_str();
}

const char* QMSDKBridge::getPayToken()
{
    return payToken.c_str();
}


const char* QMSDKBridge::getOpenId()
{
    return openId.c_str();
}

const char* QMSDKBridge::getUid()
{
    return "";
}

const char* QMSDKBridge::getUdid()
{
    return "";
}

const char* QMSDKBridge::getOfferId()
{
    return offerId.c_str();
}

const char* QMSDKBridge::getSessionId()
{
    return sessionId.c_str();
}

const char* QMSDKBridge::getSessionType()
{
    return sessionType.c_str();
}

const char* QMSDKBridge::getPf()
{
    return pf.c_str();
}

const char* QMSDKBridge::getPfKey()
{
    return pf_key.c_str();
}

bool QMSDKBridge::isPlatformInstalled(SDKPlatform platform)
{
    if(PLATFORM_QQ == platform)
    {
        return WGPlatform::GetInstance()->WGIsPlatformInstalled(ePlatform_QQ);
    }
    else if(PLATFORM_WEIXIN == platform)
    {
        return WGPlatform::GetInstance()->WGIsPlatformInstalled(ePlatform_Weixin);
    }
    return true;
}

void QMSDKBridge::openURL(const char *url)
{
    WGPlatform* plat = WGPlatform::GetInstance();
    plat->WGOpenUrl((unsigned char*)url);
}

void QMSDKBridge::getUserInfo()
{
    WGPlatform *plat = WGPlatform::GetInstance();
    if(PLATFORM_QQ == platform)
    {
        plat->WGQueryQQMyInfo();
    }
    else if(PLATFORM_WEIXIN == platform)
    {
        plat->WGQueryWXMyInfo();
    }
}

void QMSDKBridge::getFriendsInfo()
{
    WGPlatform *plat = WGPlatform::GetInstance();
    if(PLATFORM_QQ == platform)
    {
        plat->WGQueryQQGameFriendsInfo();
    }
    else if(PLATFORM_WEIXIN == platform)
    {
        plat->WGQueryWXGameFriendsInfo();
    }
}

void QMSDKBridge::showNotice(const char *scene)
{
    
    WGPlatform *plat = WGPlatform::GetInstance();
    plat->WGShowNotice((unsigned char*)scene);
}

void QMSDKBridge::hideScrollNotice()
{
    WGPlatform *plat = WGPlatform::GetInstance();
    plat->WGHideScrollNotice();
}

const char* QMSDKBridge::getNoticeData(const char *scene)
{
    WGPlatform *plat = WGPlatform::GetInstance();
    std::vector<NoticeInfo> notices = plat->WGGetNoticeData((unsigned char*)scene);
    NSMutableArray* notice_data = [[NSMutableArray alloc] init];
    for (int i = 0; i < notices.size(); i++)
    {
        
        NoticeInfo logInfo = notices[i];
        NSLog(@"openid==%s",logInfo.msg_scene.c_str());
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithUTF8String:logInfo.start_time.c_str()],
                                @"startTime",
                                [NSString stringWithUTF8String:logInfo.end_time.c_str()],
                                @"endTime",
                                [NSString stringWithUTF8String:logInfo.msg_content.c_str()],
                                @"content",
                                [NSString stringWithUTF8String:logInfo.open_id.c_str()],
                                @"openId",
                                [NSString stringWithUTF8String:logInfo.msg_title.c_str()],
                                @"title",
                                [NSString stringWithUTF8String:logInfo.msg_scene.c_str()],
                                @"scene",
                                [NSString stringWithUTF8String:logInfo.msg_id.c_str()],
                                @"noticeId",
                                [NSString stringWithUTF8String:logInfo.content_url.c_str()],
                                @"NoticeContentWebUrl",
                                nil];
        [notice_data addObject:data];
        [notice_data addObject:data];
    }
    NSData* nsNoticeData = [NSJSONSerialization dataWithJSONObject:notice_data options:NSJSONWritingPrettyPrinted error:nil];
    NSString* noticeJson = [[NSString alloc] initWithData:nsNoticeData encoding:NSUTF8StringEncoding];
    return [noticeJson UTF8String];
}

void QMSDKBridge::getNearbyPersonInfo()
{
    WGPlatform::GetInstance()->WGGetNearbyPersonInfo();
}

void QMSDKBridge::cleanLocation()
{
    WGPlatform::GetInstance()->WGCleanLocation();
}

void QMSDKBridge::getLocationInfo()
{
    WGPlatform::GetInstance()->WGGetLocationInfo();
}


void QMSDKBridge::bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str)
{
    WGPlatform::GetInstance()->WGBindQQGroup((unsigned char*)cUnionid, (unsigned char*)cUnion_name, (unsigned char*)cZoneid, (unsigned char*)md5Str);
}

void QMSDKBridge::joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey)
{
    isBindQQGroup = true;
    WGPlatform::GetInstance()->WGJoinQQGroup((unsigned char*)cQQGroupNum, (unsigned char*)cQQGroupKey);
}

void QMSDKBridge::addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage)
{
    WGPlatform::GetInstance()->WGAddGameFriendToQQ((unsigned char*)cFopenid, (unsigned char*)cDesc, (unsigned char*)cMessage);
}

void QMSDKBridge::createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName)
{
    WGPlatform::GetInstance()->WGCreateWXGroup((unsigned char*)unionid, (unsigned char*)chatRoomName, (unsigned char*)chatRoomNickName);
}

void QMSDKBridge::joinWXGroup(const char* unionid, const char* chatRoomNickName)
{
    WGPlatform::GetInstance()->WGJoinWXGroup((unsigned char*)unionid, (unsigned char*)chatRoomNickName);
}

void QMSDKBridge::queryWXGroupInfo(const char* unionID, const char* openIdLists)
{
    WGPlatform::GetInstance()->WGQueryWXGroupInfo((unsigned char*)unionID, (unsigned char*)openIdLists);
}

void QMSDKBridge::feedback(const char* body)
{
    WGPlatform::GetInstance()->WGFeedback((unsigned char*)body);
}

void QMSDKBridge::openWeiXinDeeplink(const char* link)
{
    WGPlatform::GetInstance()->WGOpenWeiXinDeeplink((unsigned char*)link);
}

void QMSDKBridge::getWakeupInfo()
{
    QSDK::sharedQSDK()->onWakeupDdataHandler(wakeup_data);
    wakeup_data = "";
}

void QMSDKBridge::OnLoginNotify(LoginRet& loginRet)
{
    switch(loginRet.flag)
    {
        case eFlag_Succ://login success
            openId = loginRet.open_id;
            offerId = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"MSDK_OfferId"] UTF8String];
            pf = loginRet.pf;
            pf_key = loginRet.pf_key;
            
            if(ePlatform_QQ == loginRet.platform)
            {
                for(int i=0; i<loginRet.token.size(); i++)
                {
                    TokenRet* pToken = & loginRet.token[i];
                    if(eToken_QQ_Pay == pToken->type)
                    {
                        payToken = pToken->value;
                    }
                    else if (eToken_QQ_Access == pToken->type)
                    {
                        accessToken = pToken->value;
                    }
                }
                sessionId = "openid";
                sessionType = "kp_actoken";
                QSDK::sharedQSDK()->loginHandle(true, "");
            }
            else if (ePlatform_Weixin == loginRet.platform)
            {
                for(int i=0; i<loginRet.token.size(); i++)
                {
                    TokenRet* pToken = & loginRet.token[i];
                    if(eToken_WX_Access == pToken->type)
                    {
                        accessToken = pToken->value;
                        payToken = pToken->value;
                    }
                    else if (eToken_WX_Refresh == pToken->type)
                    {
                        refreshToken = pToken->value;
                    }
                }
                sessionId = "hy_gameid";
                sessionType = "wc_actoken";
                QSDK::sharedQSDK()->loginHandle(true, "");
            }
            
            else if (ePlatform_Guest == loginRet.platform)
            {
                for(int i=0; i<loginRet.token.size(); i++)
                {
                    TokenRet* pToken = & loginRet.token[i];
                    if(eToken_Guest_Access == pToken->type)
                    {
                        accessToken = pToken->value;
                        payToken = pToken->value;
                    }
                }
                sessionId = "hy_gameid";
                sessionType = "st_dummy";
                QSDK::sharedQSDK()->loginHandle(true, "");
            }
            break;
        case eFlag_NeedRealNameAuth://实名制
            break;
        default:
            this->logout();
            //login fail
            NSString* failMsg = [NSString stringWithFormat:@"%d", loginRet.flag];
            QSDK::sharedQSDK()->loginHandle(false, [failMsg UTF8String]);
            break;
    }
}

void QMSDKBridge::OnShareNotify(ShareRet& shareRet)
{
    if(isBindQQGroup == true)
    {
        isBindQQGroup = false;
        QSDK::sharedQSDK()->onBindQQGroupHandler(shareRet.flag, shareRet.desc.c_str());
        return;
    }
    if (eFlag_Succ == shareRet.flag)
    {
        QShareSDK::getInstance()->shareCallback(0, "share success");
    }
    else
    {
        QShareSDK::getInstance()->shareCallback(shareRet.flag, shareRet.desc.c_str());
    }
}

void QMSDKBridge::OnWakeupNotify(WakeupRet& wakeupRet)
{
    WGPlatform* plat = WGPlatform::GetInstance();
    
    LoginRet ret;
    plat->WGGetLoginRecord(ret);
    
    const char* vip = "no";
    if(wakeupRet.platform == ePlatform_Weixin && wakeupRet.messageExt == "WX_GameCenter")
    {
        vip = "yes";
    }else if (wakeupRet.platform == ePlatform_QQ)
    {
        for (int i = 0; i < wakeupRet.extInfo.size(); i++)
        {
            KVPair pair = wakeupRet.extInfo[i];
            if(pair.key == "launchfrom")
            {
                if( pair.value == "sq_gamecenter")
                {
                    vip = "yes";
                }
                break;
            }
        }
    }

    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:ret.platform],
                                @"old_platform",
                                [NSNumber numberWithInt:wakeupRet.platform],
                                @"platform",
                                [NSNumber numberWithInt:wakeupRet.flag],
                                @"flag",
                                [NSString stringWithUTF8String:vip],
                                @"vip",
                                nil];
    NSData* resultData = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString* resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    bool result = QSDK::sharedQSDK()->onWakeupDdataHandler([resultStr UTF8String]);
    if(result == false)
    {
        wakeup_data = [resultStr UTF8String];
    }
    NSLog(@"MSDKDemo:wakeupRet  %d  %s", wakeupRet.flag, wakeupRet.desc.c_str());
    
    switch (wakeupRet.flag) {
        case eFlag_Succ:
            NSLog(@"MSDKDemo:唤醒成功");
            break;
        case eFlag_NeedLogin:
            NSLog(@"MSDKDemo:异帐号发生，需要进入登录页");
            this->logout();
            break;
        case eFlag_UrlLogin:
            NSLog(@"MSDKDemo:异帐号发生，通过外部拉起登录成功");
            break;
        case eFlag_NeedSelectAccount:
            NSLog(@"MSDKDemo:异帐号发生，需要提示用户选择");
            break;
        case eFlag_AccountRefresh:
            NSLog(@"MSDKDemo:外部帐号和已登录帐号相同，使用外部票据更新本地票据");
            break;
        default:
            this->logout();
            NSLog(@"MSDKDemo:wakeupRet  %d  %s", wakeupRet.flag, wakeupRet.desc.c_str());
            break;
    }
}

void QMSDKBridge::OnRelationNotify(RelationRet &relationRet)
{
    NSLog(@"relation callback");
    NSMutableArray* friends = [[NSMutableArray alloc] init];
    for (int i = 0; i < relationRet.persons.size(); i++)
    {
        PersonInfo logInfo = relationRet.persons[i];
        NSLog(@"nikename == %s",logInfo.nickName.c_str());
        NSLog(@"openid==%s",logInfo.openId.c_str());
        NSDictionary *person = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithUTF8String:logInfo.nickName.c_str()],
                                @"nickName",
                                [NSString stringWithUTF8String:logInfo.openId.c_str()],
                                @"openId",
                                [NSString stringWithUTF8String:logInfo.gender.c_str()],
                                @"gender",
                                [NSString stringWithUTF8String:logInfo.pictureSmall.c_str()],
                                @"pictureSmall",
                                [NSString stringWithUTF8String:logInfo.pictureMiddle.c_str()],
                                @"pictureMiddle",
                                [NSString stringWithUTF8String:logInfo.pictureLarge.c_str()],
                                @"pictureLarge",
                                [NSString stringWithUTF8String:logInfo.provice.c_str()],
                                @"province",
                                [NSString stringWithUTF8String:logInfo.city.c_str()],
                                @"city",
                                [NSNumber numberWithInt:logInfo.isFriend ? 1 : 0],
                                @"isFriend",
                                [NSNumber numberWithInt:logInfo.distance],
                                @"distance",
                                [NSString stringWithUTF8String:logInfo.lang.c_str()],
                                @"lang",
                                [NSString stringWithUTF8String:logInfo.country.c_str()],
                                @"country",
                                [NSString stringWithUTF8String:logInfo.gpsCity.c_str()],
                                @"gpsCity",
                                nil];
        [friends addObject:person];
        // user
        if(logInfo.openId == "")
        {
            NSData* userInfoData = [NSJSONSerialization dataWithJSONObject:person options:NSJSONWritingPrettyPrinted error:nil];
            NSString* userInfoJson = [[NSString alloc] initWithData:userInfoData encoding:NSUTF8StringEncoding];
            QSDK::sharedQSDK()->userInfoHandle(true, [userInfoJson UTF8String]);
            return;
        }
    }
    NSData* friendsData = [NSJSONSerialization dataWithJSONObject:friends options:NSJSONWritingPrettyPrinted error:nil];
    NSString* friendsJson = [[NSString alloc] initWithData:friendsData encoding:NSUTF8StringEncoding];
    QSDK::sharedQSDK()->friendsInfoHandle(true, [friendsJson UTF8String]);
}

void QMSDKBridge::OnLocationNotify(RelationRet &relationRet)
{
    NSLog(@"relation callback");
    if (relationRet.flag == eFlag_Succ)
    {
        NSMutableArray* friends = [[NSMutableArray alloc] init];
        for (int i = 0; i < relationRet.persons.size(); i++)
        {
            PersonInfo logInfo = relationRet.persons[i];
            NSLog(@"nikename == %s",logInfo.nickName.c_str());
            NSLog(@"openid==%s",logInfo.openId.c_str());
            NSDictionary *person = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSString stringWithUTF8String:logInfo.nickName.c_str()],
                                    @"nickName",
                                    [NSString stringWithUTF8String:logInfo.openId.c_str()],
                                    @"openId",
                                    [NSString stringWithUTF8String:logInfo.gender.c_str()],
                                    @"gender",
                                    [NSString stringWithUTF8String:logInfo.pictureSmall.c_str()],
                                    @"pictureSmall",
                                    [NSString stringWithUTF8String:logInfo.pictureMiddle.c_str()],
                                    @"pictureMiddle",
                                    [NSString stringWithUTF8String:logInfo.pictureLarge.c_str()],
                                    @"pictureLarge",
                                    [NSString stringWithUTF8String:logInfo.provice.c_str()],
                                    @"province",
                                    [NSString stringWithUTF8String:logInfo.city.c_str()],
                                    @"city",
                                    [NSNumber numberWithInt:logInfo.isFriend ? 1 : 0],
                                    @"isFriend",
                                    [NSNumber numberWithInt:logInfo.distance],
                                    @"distance",
                                    [NSString stringWithUTF8String:logInfo.lang.c_str()],
                                    @"lang",
                                    [NSString stringWithUTF8String:logInfo.country.c_str()],
                                    @"country",
                                    [NSString stringWithUTF8String:logInfo.gpsCity.c_str()],
                                    @"gpsCity",
                                    nil];
            [friends addObject:person];
        }
        NSData* friendsData = [NSJSONSerialization dataWithJSONObject:friends options:NSJSONWritingPrettyPrinted error:nil];
        NSString* friendsJson = [[NSString alloc] initWithData:friendsData encoding:NSUTF8StringEncoding];
        QSDK::sharedQSDK()->nearbyPersonInfoHandler(true, [friendsJson UTF8String]);
    }
    else
    {
        NSString* failMsg = [NSString stringWithFormat:@"%d", relationRet.flag];
        QSDK::sharedQSDK()->nearbyPersonInfoHandler(false, [failMsg UTF8String]);
    }
}

void QMSDKBridge::OnLocationGotNotify(LocationRet& locationRet)
{
    if(locationRet.flag == eFlag_Succ)
    {
        NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:locationRet.longitude],
                                    @"longitude",
                                    [NSNumber numberWithDouble:locationRet.latitude],
                                    @"latitude",
                                    nil];
        NSData* resultData = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
        NSString* resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        QSDK::sharedQSDK()->getLocationInfoHandler(true, [resultStr UTF8String]);
    }
    else
    {
        NSString* failMsg = [NSString stringWithFormat:@"%d", locationRet.flag];
        QSDK::sharedQSDK()->getLocationInfoHandler(false, [failMsg UTF8String]);
    }
}

void QMSDKBridge::OnFeedbackNotify(int flag,std::string desc)
{
}

std::string QMSDKBridge::OnCrashExtMessageNotify()
{
    return "message";
}

void QMSDKBridge::OnADNotify(ADRet& adRet)
{
}
/*! @brief 微信建群回调
 *
 * 将创建的操作结果通知上层App
 * @param GroupRet 创建结果
 * @return void
 */
void QMSDKBridge::OnCreateWXGroupNotify(GroupRet& groupRet)
{
    if (groupRet.flag == eFlag_Succ)
    {
        QSDK::sharedQSDK()->onCreateWXGroup(true, "success");
    }
    else
    {
        QSDK::sharedQSDK()->onCreateWXGroup(false, groupRet.desc.c_str());
    }
}

/*! @brief 查询群成员回调
 *
 * 将查询的操作结果通知上层App
 * @param GroupRet 查询结果
 * @return void
 */
void QMSDKBridge::OnQueryGroupInfoNotify(GroupRet& groupRet)
{
//    NSLog(@"MyObserver OnQueryGroupInfoNotify flag:%d errorCode:%d desc:%@ openIdLists:%@ memberCount:%@",groupRet.flag, groupRet.errorCode, [NSString stringWithCString:groupRet.desc.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:groupRet.wxGroupInfo.openIdList.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:groupRet.wxGroupInfo.memberNum.c_str() encoding:NSUTF8StringEncoding]);
    if (groupRet.flag == eFlag_Succ)
    {
        NSLog(@"查询群成员成功");
    }
    else
    {
        QSDK::sharedQSDK()->onCreateWXGroup(false, groupRet.desc.c_str());
    }
}

/*! @brief 微信加群回调
 *
 * 将加群的操作结果通知上层App
 * @param GroupRet 加群结果
 * @return void
 */

void QMSDKBridge::OnJoinWXGroupNotify(GroupRet& groupRet)
{
    if (groupRet.flag == eFlag_Succ)
    {
        QSDK::sharedQSDK()->onCreateWXGroup(true, "success");
    }
    else
    {
        QSDK::sharedQSDK()->onCreateWXGroup(false, groupRet.desc.c_str());
    }
}


//Midas相关

//注册midas  env
////MIDAS_IAP_ENV_SANDBOX;
//MIDAS_IAP_ENV_RELEASE;//发布用MIDAS_IAP_ENV_RELEASE
void QMSDKBridge::registerPay(const char *env)
{
    NSLog(@"QMSDKBridge::registerPay()注册midas");
    APMidasInterface *midas = APMidasInterface::GetInstance();
    midas->SetIapEnalbeLog(true);
    midas->RegisterCallbackHandler(this);
    
    std::map<const char *, const char *> extInfos;
    extInfos[KEY_APP_EXTRA] = "1";
    
    midas->SetLocale("local");
    
    midas->RegisterPay(getOfferId(), getOpenId(), getPayToken(), getSessionId(), getSessionType(), getPf(), getPfKey(), env, {}, extInfos);
}

//支付
void QMSDKBridge::pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes)
{
    NSLog(@"======QMSDKBridge::pay===============" );
    APMidasInterface *midas = APMidasInterface::GetInstance();
    if(!midas->IsSupprotIapPay())
    {
        NSLog(@"callback:IsSupprotIapPay is not");
        return;
    }
    AppController* app = (AppController*) [[UIApplication sharedApplication] delegate];
    UIViewController* viewController = [app getViewController];
    midas->SetParentViewController(viewController);
    NSString* nssAmount = [NSString stringWithFormat:@"%d", int(amount)];
    const char* cAmount = [nssAmount UTF8String];
    
    NSString* ext_info = [NSString stringWithUTF8String:paydes];
    NSData* data_body = [ext_info dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictBody = [NSJSONSerialization JSONObjectWithData:data_body options:NSJSONReadingAllowFragments error:&error];
    
    NSNumber* numberType = [dictBody objectForKey:@"type"];
    uint32_t productType = AP_MIDAS_IAP_PRODUCT_CONSUMABLE;
    
    bool isDepositGameCoin = true;
    if([numberType isEqualToNumber:[[NSNumber alloc] initWithInt:1]])
    {
        NSString* serviceday = [dictBody objectForKey:@"serviceday"];
        const char* day = [serviceday UTF8String];
        
        isDepositGameCoin = false;
        productType = AP_MIDAS_IAP_PRODUCT_NAT_RENEW_SUBS;
        cAmount = day;
    }
    
    NSString* stringZoneId = [dictBody objectForKey:@"zoneId"];
    const char* zoneId = [stringZoneId UTF8String];
    
    midas->Pay(getOfferId(), getOpenId(), getPayToken(), getSessionId(), getSessionType(), cAmount, productId, getPf(), getPfKey(), isDepositGameCoin, productType, zoneId, order, order);
}

//下单成功回调
void QMSDKBridge::onOrderSuccess(const char * billno, const APMidasIAPRequestInfo& IAPRequestInfo)
{
    NSLog(@"callback:order succ");
}

//下单失败回调
void QMSDKBridge::onOrderFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_ORDER];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
    NSLog(@"callback:order fail");
}

//苹果支付成功回调
void QMSDKBridge::onIAPPaySuccess(const APMidasIAPRequestInfo& IAPRequestInfo)
{
    NSLog(@"callback: ipa pay succ");
}

//苹果支付失败回调
void QMSDKBridge::onIAPPayFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_PAY];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
    NSLog(@"callback: iap pay fail, error info:%s, code:%d", errorString, code);
}


//发货成功回调
void QMSDKBridge::onDistributeGoodsSuccess(const APMidasIAPRequestInfo& IAPRequestInfo)
{
    NSMutableArray* successProducts = [[NSMutableArray alloc] init];
    for(size_t i = 0; i < IAPRequestInfo.providedProductIds.size(); i++)
    {
        NSString* productId = [NSString stringWithUTF8String:IAPRequestInfo.providedProductIds[i].c_str()];
        [successProducts addObject:productId];
    }
    
    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithUTF8String:IAPRequestInfo.openId.c_str()],
                                @"openId",
                                [NSString stringWithUTF8String:IAPRequestInfo.varItem.c_str()],
                                @"tradeNo",
                                [NSString stringWithUTF8String:IAPRequestInfo.pf.c_str()],
                                @"pf",
                                [NSString stringWithUTF8String:IAPRequestInfo.pfKey.c_str()],
                                @"pfKey",
                                [NSString stringWithUTF8String:payToken.c_str()],
                                @"payToken",
                                [NSString stringWithUTF8String:accessToken.c_str()],
                                @"accessToken",
                                successProducts,
                                @"productIds",
                                nil];
    NSData* resultData = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString* resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    QSDK::sharedQSDK()->payHandle(true, [resultStr UTF8String]);
    NSLog(@"callback: iap pay succ");
}

//发货失败回调
void QMSDKBridge::onDistributeGoodsFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_DISTRIBUTE_GOODS];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
    NSLog(@"callback: distribute fail");
}


//补发货成功回调(针对非消耗性商品)
void QMSDKBridge::onRestorableProductRestoreSuccess(const APMidasIAPRequestInfo& IAPRequestInfo)
{
    NSLog(@"callback: 补发货成功回调(针对非消耗性商品)");
}

//补发货失败回调(针对非消耗性商品)
void QMSDKBridge::onRestorableProductRestoreFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_RESTORABLE_PRODUCT];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
}

//读取补发商品信息失败
void QMSDKBridge::onGetRestorableProductFailure(const char * errorString, int code)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_GET_RESTORABLE_PRODUCT];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
}

//拉取产品信息失败回调此接口，目前errorString暂时为空，code始终为-1（1.0.1版本）
void QMSDKBridge::onGetProductInfoFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code)
{
    NSLog(@"callback: get iap product info fail");
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_GET_PRODUCT_INFO];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
}

//网络错误，参数：具体在进行哪一步的时候发生网络错误
//1.下单 2 苹果支付 3 发货
void QMSDKBridge::onNetWorkError(int state, const APMidasIAPRequestInfo& IAPRequestInfo)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_NET_WORK];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
    NSLog(@"callback: network error");
}

//登陆态失效回调
void QMSDKBridge::onLoginExpiry(const APMidasIAPRequestInfo& info)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_LOGIN_FAIL];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
    NSLog(@"callback:login expire");
}

void QMSDKBridge::canShowLoadingNow()
{
    NSLog(@"now you can show loading");
}

// 参数输入错误，打印log的回调
void QMSDKBridge::onParameterWrong(const char * errorMsg)
{
    NSLog(@"%s", errorMsg);
}

// 获取推荐个数列表
void QMSDKBridge::onGetRecommendedListSucceeded(const APMidasIAPRequestInfo & reqInfo, const char * recommendedListJsonString)
{
    NSLog(@"goodsinfo=%s",recommendedListJsonString);
}

void QMSDKBridge::onGetRecommendedListFailure(const APMidasIAPRequestInfo & reqInfo, const char * errorMsg, int errorCode)
{
    NSString* failMsg = [NSString stringWithFormat:@"%d", MIDAS_GET_RECOMMEND_LIST];
    QSDK::sharedQSDK()->payHandle(false, [failMsg UTF8String]);
}

//灯塔事件
void QMSDKBridge::reportEvent(const char* name, const char* body, bool isRealTime)
{
    unsigned char* _name = (unsigned char*)name;
    
    std::vector<KVPair> eventLists;
    NSString* nssBody = [NSString stringWithUTF8String:body];
    NSData* dataBody = [nssBody dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictBody = [NSJSONSerialization JSONObjectWithData:dataBody options:NSJSONReadingAllowFragments error:&error];
    for(NSString* key in dictBody)
    {
        NSString* value = [dictBody objectForKey:key];
        KVPair pair;
        pair.key = std::string([key UTF8String]);
        pair.value = std::string([value UTF8String]);
        eventLists.push_back(pair);
    }
    
    WGPlatform::GetInstance()->WGReportEvent(_name, eventLists, isRealTime);
}

void QMSDKBridge::buglyLog(int level, const char* log)
{
    WGPlatform::GetInstance()->WGBuglyLog((eBuglyLogLevel)level, (unsigned char*)log);
}


//32位md5加密
NSString* QMSDKBridge::md5HexDigest(NSString* str)
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}




