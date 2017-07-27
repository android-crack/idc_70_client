/*!
 @header APMidasInterface.h
 @abstract 米大师IAP支付SDK的C++接入类，头文件
 @author bladebao
 @version 1.00 2014/09/28 Creation
 @copyright Copyright (c) 2014 Tencent. All rights reserved.
 */
#include <string>
#include <vector>
#include <map>

namespace Tencent
{
namespace Midas
{
namespace IAP
{

// ======================= struct definition ========================
typedef struct
{
    std::string openId;         //用户帐号id（account），例如openid、uin
    std::string openKey;        //用户session（skey具体值）
    std::string session_id;     //用户账户类型(uin还是openid)
    std::string session_type;   //session类型(skey)
    std::string payItem;        //结果描述（保留）
    std::vector<std::string> providedProductIds;      //已发货的物品id
    // 发货失败的物品id，key是错误码，value是物品ID
    // 错误码解释
    // -1 发货失败，等待下次app启动补发货
    // -2 票据过期，不会补发货
    // -3 票据无效，不会补发货
    std::map<int, std::vector<std::string> > failedProductIds; // 未成功支付的物品ID
    std::string pf;             //平台来源
    std::string pfKey;          //跳转到应用首页后，URL后会带该参数。由平台直接传给应用，应用原样传给平台
    bool isDepositGameCoin;     //是否是托管游戏币
    int productType;            //物品类型(0 单笔 ,游戏币 2 包月＋自动续费 3 包月＋非自动续费)
    std::string zoneId;         //分区字段
    std::string varItem;        //业务的扩展字段
    std::string billno;         //订单号
    bool isReprovide;           //是否补发货
} APMidasIAPRequestInfo;

// ======================= observer definition ========================
/*!
 @class APMidasInterfaceObserver
 @abstract 米大师IAP支付SDK的C++接入类的回调通知接口虚基类，供业务侧接收回调通知
 @author bladebao
 */
class APMidasInterfaceObserver
{
public:
    //下单成功回调
    virtual void onOrderSuccess(const char * billno, const APMidasIAPRequestInfo& IAPRequestInfo) = 0;
    //下单失败回调
    virtual void onOrderFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code) = 0;
    
    //苹果支付成功回调
    virtual void onIAPPaySuccess(const APMidasIAPRequestInfo& IAPRequestInfo) = 0;
    //苹果支付失败回调
    virtual void onIAPPayFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code) = 0;
    
    //发货成功回调
    virtual void onDistributeGoodsSuccess(const APMidasIAPRequestInfo& IAPRequestInfo) = 0;
    //发货失败回调
    virtual void onDistributeGoodsFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code) = 0;
    
    // 非消耗型商品回调，可以选择性实现，非纯虚函数
    //补发货成功回调(针对非消耗性商品)
    virtual void onRestorableProductRestoreSuccess(const APMidasIAPRequestInfo& IAPRequestInfo) {}
    //补发货失败回调(针对非消耗性商品)
    virtual void onRestorableProductRestoreFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorMessage, int code) {}
    //读取补发商品信息失败
    virtual void onGetRestorableProductFailure(const char * errorString, int code) {}
    
    //拉取产品信息失败回调此接口，目前errorString暂时为空，code始终为-1（1.0.1版本）
    virtual void onGetProductInfoFailure(const APMidasIAPRequestInfo& IAPRequestInfo, const char * errorString, int code) = 0;
    
    //网络错误，参数：具体在进行哪一步的时候发生网络错误
    //1.下单 2 苹果支付 3 发货
    virtual void onNetWorkError(int state, const APMidasIAPRequestInfo& IAPRequestInfo) = 0;
    
    //登陆态失效回调
    virtual void onLoginExpiry(const APMidasIAPRequestInfo& info) = 0;
    
    // 这个回调调用后，可以显示loading锁屏了，选择性的实现即可
    virtual void canShowLoadingNow() {}
    
    // 参数输入错误，打印log的回调
    virtual void onParameterWrong(const char * errorMsg) {}
    
    
    // 获取推荐个数列表
    virtual void onGetRecommendedListSucceeded(const APMidasIAPRequestInfo & reqInfo, const char * recommendedListJsonString) = 0;
    virtual void onGetRecommendedListFailure(const APMidasIAPRequestInfo & reqInfo, const char * errorMsg, int errorCode) = 0;
};


extern const char * KEY_APP_EXTRA; // 应用扩展信息key
extern const char * KEY_APP_EXTEND_INFO; // 应用透传的扩展信息key
extern const char * KEY_APP_RESERVE_1; // 应用定义的额外信息1
extern const char * KEY_APP_RESERVE_2; // 应用定义的额外信息2
extern const char * KEY_APP_RESERVE_3; // 应用定义的额外信息3
    
    
extern const char * KEY_UPLOAD_DEVICE_INFO_SCENE; // 上传设备信息场景
    
// ======================= interface definition ========================
/*!
 @class APMidasInterface
 @abstract 米大师IAP支付SDK的C++接入类，供业务侧使用跨平台的C++代码使用，本类为方法类，切勿实例化
 @author bladebao
 */
class APMidasInterface
{
public:
    
    static APMidasInterface * GetInstance();
    
    /*!
     @abstract 判断当前iOS设备是否支持IAP支付，家长控制关闭iap购买时，返回false，同时，部分越狱设备，也会返回false，但是不可用此接口的返回值作为是否越狱设备的判断标准
     @return true 支持，false 不支持
     */
    bool IsSupprotIapPay();
    
    /*!
     @abstract 设置支付log开关
     @param enabled true:打开 false:关闭
     */
    void SetIapEnalbeLog(bool enabled);
    
    /*!
     @abstract 获取当前MidasSDK的版本号，该版本号是由midas SDK的版本号和接入组件的版本号合并而成
     */
    const char * GetVersion();
    
    /*!
     @abstract 设置连接支付服务器片区
     @param locale 片区，"local" 中国内地，"hongkong" 香港 (海外版本使用)
     @return 无
     */
    void SetLocale(const char * locale);
    
    /*!
     @abstract 注册回调接口
     */
    void RegisterCallbackHandler(const APMidasInterfaceObserver * handler);
    
    /*!
     @abstract 取消回调接口注册，在回调对象析构前调用，不然会造成野指针问题
     */
    void UnRegisterCallbackHandler(const APMidasInterfaceObserver * handler);
    
    /*!
     @abstract 注册支付组件，必须在app获取到登陆态的情况下，尽早调用，如放在获取登陆态成功的回调中，或者放在appDidFinishLaunch:WithOption中, since 1.0.2（Midas SDK 1.3.7）
     @param offerId     必填参数 申请到的offerId
     @param openId      必填参数 填openId 的值
     @param openKey     必填参数 手Q：paytoken 微信：accesstoken
     @param sessionId   必填参数 手Q："openid"  微信："wechatid"
     @param sessionType 必填参数 手Q："kp_actoken"  微信："wc_actoken"
     @param pf          调用MSDK中WGGetPf()获取，如果没有接入MSDK，请使用以往的方式来获取此参数
     @param pfKey       调用MSDK中WGGetPfKey()获取，如果没有接入MSDK，请使用以往的方式来获取此参数
     @param environment 必填参数，@"test"用于沙箱测试环境，@"release"用于现网正式环境
     @param custom      用于业务透传，可以填null，如果不为null，则会与pf拼接起来（形如pf-custom）做为最终的pf，如果pf中已包含此段，就不必再传
     @param extendsInfos 业务传递的特别字段，key和value都必须为字符串，key是上面定义的k开头的字符，value如果是BOOL型，则用“0”和“1”表示，如果是数字，则用数字字符串表示“0”，“1”，以此类推
     */
    void RegisterPay(const char * offerId, const char * openId,
                     const char * openKey, const char * sessionId,
                     const char * sessionType, const char * pf,
                     const char * pfKey, const char * environment,
                     const char * custom, const std::map<const char *, const char *>& extendsInfos);
    
    /*!
     @abstract 直接支付接口，请在调用IsSupprotIapPay()接口返回true之后，再调用此接口，不然即使用户开启了家长控制，
               也可以完成支付（家长控制只是苹果的一个标志位，并不影响支付的过程，仅供开发商做一个判断）
     @param offerId 同RegisterPay
     @param openId 同RegisterPay
     @param openKey 同RegisterPay
     @param sessionId 同RegisterPay
     @param sessionType 同RegisterPay
     @param payItem 1.如果是 单笔 直接由业务自己订 2.如果是包月 字符串 是 开月的月数 3如果是游戏币,则是充值个数
     @param productId 苹果的产品id
     @param pf 同RegisterPay
     @param pfKey 同RegisterPay
     @param isDepositGameCoin 是否是托管的游戏币类型
     @param productType 苹果产品的类型 见APMidasPayReqInfo 的productType(0.消费类产品 1.非消费类产品 2.包月+自动续费 3.免费 4.包月+非自动续费)
     @param zoneId 分区信息
     @param varItem 应用端的扩展字段，透传给业务
     @param custom      用于业务透传，可以填null，如果不为null，则会与pf拼接起来（形如pf-custom）做为最终的pf，如果pf中已包含此段，就不必再传
     */
    void Pay(const char * offerId, const char * openId,
             const char * openKey, const char * sessionId,
             const char * sessionType, const char * payItem,
             const char * productId, const char * pf,
             const char * pfKey, bool isDepositGameCoin,
             uint32_t productType, const char * zoneId,
             const char * varItem, const char * custom);
    
    /*!
     @abstract 出于尽量简化游戏侧调用方式的考虑，在sdk内部检测最上层的viewcontroller来展示界面，但由于业务侧前端技术的复杂性，万一无法获取到最上层的vc，
               或者获取到的vc是错误的，则通过此接口设置调用vc，注意sdk内部不负责维护parent的生命周期，请在使用营销活动界面时，保证parent对象不被析构，
               且在parent析构前，需要调用此函数，将parent设置成NULL
     @param parent 父视图控制器，一般为打开打开界面的入口所在的vc，注意必须是UIViewController或其子类，不然可能会crash
     */
    void SetParentViewController(void * parent); // since 1.0.2(Midas SDK 1.3.7)

    /*!
     @abstract 用于非消耗型商品，自动续费型订阅，和免费型订阅的恢复，一般情况下用不到，如果您需要使用，请咨询midas
     */
    void RestoreCompletedTransactions(const char * offerId,
                                      const char * openId,
                                      const char * openKey,
                                      const char * sessionId,
                                      const char * sessionType,
                                      const char * pf,
                                      const char * pfKey,
                                      const char * zoneId,
                                      const char * varItem,
                                      const char * custom);
    
    /*!
     @abstract 拉取推荐购买数量列表，目前仅支持游戏币模式，即isDepositGameCoin = true，productType = 0，传入其他类型会报错
     */
    void LaunchRecommendedList(const char * offerId, const char * openId,
                               const char * openKey, const char * sessionId,
                               const char * sessionType, const char * pf,
                               const char * pfKey, bool isDepositGameCoin,
                               uint32_t productType, const char * zoneId,
                               const char * varItem, const char * custom);
    
    /*!
     @abstract 上传设备信息
     @param info 额外需要上传的信息，目前支持的key值如KEY_SCENE
     */
    void UploadDeviceInfo(const std::map<std::string, std::string> & info);
    
private:
    APMidasInterface();
    APMidasInterface(const APMidasInterface &);
    void operator=(const APMidasInterface &);
    ~APMidasInterface();
};
    
}}}
