#include "QSDK.h"
#include "../Midas/Interface/inc/APMidasInterface.h"
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import <MSDK/MSDK.h>
#import <MidasIAPSDK/MidasIAPApi.h>
#import <MidasIAPSDK/MidasIAPObject.h>

using namespace Tencent::Midas::IAP;

class QMSDKBridge: public WGPlatformObserver, public WGADObserver, public APMidasInterfaceObserver, public WGGroupObserver
{
public:
    static QMSDKBridge* sharedInstance();
    void setObServer();
    void initSDK(SDKPlatform platform);
    void login();
    void qrCodeLogin();
    bool switchUser(bool flag);
    void logout();
    const char* getAccessToken();
    const char* getOpenId();
    const char* getPayToken();
    const char* getUid();
    const char* getUdid();
    const char* getOfferId();
    const char* getSessionId();
    const char* getSessionType();
    const char* getPf();
    const char* getPfKey();
    bool isPlatformInstalled(SDKPlatform platform);
    void openURL(const char* url);
    void registerPay(const char *env);
    void getUserInfo();
    void getFriendsInfo();
    void pay(int uid, const char *order, const char* productId, const char* productName, float amount, const char* paydes);
    void reportEvent(const char* name, const char* body, bool isRealTime);
    void showNotice(const char *scene);//公告数据
    void hideScrollNotice();//隐藏公告栏
    const char* getNoticeData(const char *scene);
    void buglyLog(int level, const char* log);
    void getNearbyPersonInfo();
    void cleanLocation();
    void getLocationInfo();
    
    void bindQQGroup(const char* cUnionid, const char* cUnion_name, const char* cZoneid, const char* md5Str);
    void joinQQGroup(const char* cQQGroupNum, const char* cQQGroupKey);
    void addGameFriendToQQ(const char* cFopenid, const char* cDesc, const char* cMessage);
    
    void createWXGroup(const char* unionid, const char* chatRoomName, const char* chatRoomNickName);
    void joinWXGroup(const char* unionid, const char* chatRoomNickName);
    void queryWXGroupInfo(const char* unionID, const char* openIdLists);
    
    void feedback(const char* body);//反馈
    void openWeiXinDeeplink(const char* link);
    void getWakeupInfo();

    // MSDK
    void OnLoginNotify(LoginRet& loginRet);//登录回调
    void OnShareNotify(ShareRet& shareRet);//分享回调
    void OnWakeupNotify(WakeupRet& wakeupRet);//平台唤起回调
    void OnRelationNotify(RelationRet& relationRet);//查询关系链相关回调
    void OnLocationNotify(RelationRet &relationRet);//定位相关回调
    void OnLocationGotNotify(LocationRet& locationRet);//定位相关回调
    void OnFeedbackNotify(int flag,std::string desc);//反馈相关回调
    std::string OnCrashExtMessageNotify();//crash时的处理
    void OnADNotify(ADRet& adRet);//广告回调
    
    void OnCreateWXGroupNotify(GroupRet& groupRet); //微信建群回调
    void OnQueryGroupInfoNotify(GroupRet& groupRet); //查询群成员回调
    void OnJoinWXGroupNotify(GroupRet& groupRet); //微信加群回调
    
    //Midas
    void onOrderSuccess(const char * billno, const APMidasIAPRequestInfo& IAPRequestInfo);
    void onOrderFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code);
    void onIAPPaySuccess(const APMidasIAPRequestInfo& IAPRequestInfo);
    void onIAPPayFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code);
    void onDistributeGoodsSuccess(const APMidasIAPRequestInfo& IAPRequestInfo);
    void onDistributeGoodsFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code);
    void onRestorableProductRestoreSuccess(const APMidasIAPRequestInfo& IAPRequestInfo);
    void onRestorableProductRestoreFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code);
    void onGetRestorableProductFailure(const char * errorString, int code);
    void onGetProductInfoFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code);
    void onNetWorkError(int state, const APMidasIAPRequestInfo& IAPRequestInfo);
    void onLoginExpiry(const APMidasIAPRequestInfo& info);
    void canShowLoadingNow();
    void onParameterWrong(const char * errorMsg);
    void onGetRecommendedListSucceeded(const APMidasIAPRequestInfo & reqInfo, const char * recommendedListJsonString);
    void onGetRecommendedListFailure(const APMidasIAPRequestInfo & reqInfo, const char * errorMsg, int errorCode);
    
private:
    NSString *md5HexDigest(NSString* str);
    
private:
    std::string openId;
    std::string payToken;
    std::string accessToken;
    // weixin
    std::string refreshToken;
    std::string pf;
    std::string pf_key;
    SDKPlatform platform;
    std::string offerId;
    std::string sessionId;
    std::string sessionType;
    bool isBindQQGroup = false;
    const char* wakeup_data = "";
};
