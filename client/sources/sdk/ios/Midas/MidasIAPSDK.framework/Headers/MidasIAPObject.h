/*!
 @header MidasIAPObject.h
 @abstract 米大师苹果支付SDK对象和枚举定义，头文件
 @author bladebao
 @version 1.5.2
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 * SDK Version : 1.5.2
 */

/*!
 @enum APMidasRespResultCode
 @abstract 米大师SDK返回码
 @constant AP_MIDAS_RESP_RESULT_ERROR 错误
 @constant AP_MIDAS_RESP_RESULT_OK 成功
 @constant AP_MIDAS_RESP_RESULT_CANCEL 取消
 @constant AP_MIDAS_RESP_RESULT_PARAM_ERROR 参数错误
 @constant AP_MIDAS_RESP_RESULT_NET_ERROR 网络错误
 @constant AP_MIDAS_RESP_RESULT_IAP_ERROR IAP支付失败
 @constant AP_MIDAS_RESP_RESULT_IAP_NEED_REBOOT IAP需要重启补发
 @author bladebao
 */
typedef enum : SInt32
{
    AP_MIDAS_RESP_RESULT_ERROR                  = -1,
    AP_MIDAS_RESP_RESULT_OK                     = 0,
    AP_MIDAS_RESP_RESULT_CANCEL                 = 1,
    AP_MIDAS_RESP_RESULT_PARAM_ERROR            = 2,
    AP_MIDAS_RESP_RESULT_NET_ERROR              = 3,
    AP_MIDAS_RESP_RESULT_IAP_ERROR              = 4,
    AP_MIDAS_RESP_RESULT_IAP_NEED_REBOOT        = 5,
} APMidasRespResultCode;

/*!
 @enum APMidasIapProductType
 @abstract 米大师IAP支付物品类型，根据iTC中苹果的物品类型映射而来
 @constant AP_MIDAS_IAP_PRODUCT_CONSUMABLE 消耗型，一般对应于钻石等
 @constant AP_MIDAS_IAP_PRODUCT_N_CONSUMABLE 非消耗型，比较少用，如果想支持此种类型，请先咨询米大师
 @constant AP_MIDAS_IAP_PRODUCT_AT_RENEW_SUBS 自动续费订阅型，视频、杂志、图书、动漫等才能接入，接入前也请先咨询米大师
 @constant AP_MIDAS_IAP_PRODUCT_FREE_SUBS 免费订阅型，目前暂不支持
 @constant AP_MIDAS_IAP_PRODUCT_NAT_RENEW_SUBS 非自动续费订阅型，目前公司主要的包月、月卡均采用此种类型的商品
 @author bladebao
 */
typedef enum : SInt32
{
    AP_MIDAS_IAP_PRODUCT_CONSUMABLE             = 0,
    AP_MIDAS_IAP_PRODUCT_N_CONSUMABLE           = 1,
    AP_MIDAS_IAP_PRODUCT_AT_RENEW_SUBS          = 2,
    AP_MIDAS_IAP_PRODUCT_FREE_SUBS              = 3,
    AP_MIDAS_IAP_PRODUCT_NAT_RENEW_SUBS         = 4
} APMidasIapProductType;

/*!
 @enum MidasIAPUIType
 @abstract 米大师IAP界面类型
 @constant MIDAS_IAP_UI_DEFAULT 默认界面，只有loading和少量错误提示，防止业务没有做锁屏保护而导致用户重复购买
 @constant MIDAS_IAP_UI_FULL 全程带有米大师商城页和结果页，以及营销活动展示等界面
 @author bladebao
 */
typedef enum : SInt32
{
    MIDAS_IAP_UI_DEFAULT                        = 0,
    MIDAS_IAP_UI_FULL                           = 1,
} MidasIAPUIType;

/*!
 @class MidasIAPBaseReq
 @superclass NSObject
 @abstract 米大师IAP支付SDK支付请求基类
 @author bladebao
 */
@interface MidasIAPBaseReq : NSObject

/*!
 @property offerId
 @abstract 支付账户Id，米大师支付后台申请到的账户Id
 @author bladebao
 */
@property (nonatomic, copy) NSString * offerId;

/*!
 @property openId
 @abstract 用户登录的openId
 @author bladebao
 */
@property (nonatomic, copy) NSString * openId;

/*!
 @property openKey
 @abstract 用户登录的session
 @author bladebao
 */
@property (nonatomic, copy) NSString * openKey;

/*!
 @property sessionId
 @abstract openId对应的session类型，如uin等
 @author bladebao
 */
@property (nonatomic, copy) NSString * sessionId;

/*!
 @property sessionType
 @abstract openKey对应的的sessionType，如skey，t_skey，openKey等
 @author bladebao
 */
@property (nonatomic, copy) NSString * sessionType;

/*!
 @property zoneId
 @abstract 分区
 @author bladebao
 */
@property (nonatomic, copy) NSString * zoneId;

/*!
 @property pf
 @abstract 平台来源，一般是平台+注册渠道+版本+安装渠道+业务标识（自定义）
 @author bladebao
 */
@property (nonatomic, copy) NSString * pf;

/*!
 @property pfKey
 @abstract 由平台来源和openKey根据规则生成的密钥，对于公司自研应用固定为“pfKey”
 @author bladebao
 */
@property (nonatomic, copy) NSString * pfKey;

/*!
 @property depositGameCoin
 @abstract 是否托管游戏币
 @author bladebao
 */
@property (nonatomic, assign) BOOL depositGameCoin;

/*!
 @property varItem
 @abstract varItem字段，给他人购买时使用，传入provide_uin=openId&provide_no_type=sessionId
 @author bladebao
 */
@property (nonatomic, copy) NSString * varItem;

/*!
 @property extend
 @abstract 扩展字段
 @author bladebao
 */
@property (nonatomic, copy) NSString * extend;

/*!
 @property extend
 @abstract 扩展字段
 @author bladebao
 */
@property (nonatomic, strong) NSDictionary * dictExtend;

/*!
 @property
 @abstract 检查参数
 @author bladebao
 @result 参数正确返回true,否则返回false
 */
- (BOOL)validateParams;

@end


/*!
 @class MidasIAPPayReq
 @superclass MidasIAPBaseReq
 @abstract 米大师IAP支付SDK支付请求类
 @author bladebao
 */
@interface MidasIAPPayReq : MidasIAPBaseReq

/*!
 @property productId
 @abstract 物品ID
 @author bladebao
 */
@property (nonatomic, copy) NSString * productId;

/*!
 @property productType
 @abstract 商品类型，参见APMidasIapProductType定义
 @author bladebao
 */
@property (nonatomic, assign) APMidasIapProductType productType;

/*!
 @property saveValue
 @abstract 充值个数，当充值游戏币时，输入游戏币数量，包月时输入月数，月卡时输入天数，道具按照 道具ID*道具单价（角）*数量 的格式
 @author bladebao
 */
@property (nonatomic, copy) NSString * saveValue;

/*!
 @property resImg
 @abstract 表示充值物品（如包月、游戏币）的图片资源，建议分辨率为32x32，或者64x64（retina下）
 @author bladebao
 */
@property (nonatomic, strong) UIImage * resImg;

/*!
 @property resData 和resImg，优先使用resData
 @abstract 表示充值物品（如包月、游戏币）的图片资源，建议分辨率为32x32，或者64x64（retina下）
 @author bladebao
 */
@property (nonatomic, copy) NSString * resData;

/*!
 @property contextController
 @abstract 用于展示界面上下文的视图控制器，不能为空
 @author bladebao
 */
@property (nonatomic, weak) UIViewController * contextController;

/*!
 @property showMidasUI
 @abstract 米大师界面类型，默认为MIDAS_IAP_UI_DEFAULT
 @author bladebao
 */
@property (nonatomic, assign) MidasIAPUIType midasUIType;

@end



/*!
 @class MidasIAPMpInfoReq
 @superclass MidasIAPBaseReq
 @abstract 米大师拉取特殊cgi请求
 @author bladebao
 */
@interface MidasIAPMpInfoReq : MidasIAPBaseReq

@end

/*!
 @class MidasIAPRestoreReq
 @superclass MidasIAPBaseReq
 @abstract 米大师恢复非消耗型物品请求
 @author bladebao
 */
@interface MidasIAPRestoreReq : MidasIAPBaseReq

/*!
 @property contextController
 @abstract 用于展示界面上下文的视图控制器，不能为空
 @author bladebao
 */
@property (nonatomic, weak) UIViewController * contextController;

/*!
 @property showMidasUI
 @abstract 米大师界面类型，默认为MIDAS_IAP_UI_DEFAULT
 @author bladebao
 */
@property (nonatomic, assign) MidasIAPUIType midasUIType;

@end

/*!
 @class MidasIAPProductInfoReq
 @superclass MidasIAPBaseReq
 @abstract 米大师物品信息请求类，从苹果请求物品信息
 @author bladebao
 */
@interface MidasIAPProductInfoReq : MidasIAPBaseReq

/*!
 @property useCache
 @abstract 是否使用上次请求的缓存，如果是NO，则每次重新请求网络，否则采用上次的缓存，如果缓存不存在，也重新从网络侧取
 @author bladebao
 */
@property (nonatomic, assign) BOOL useCache;

/*!
 @property productIds
 @abstract 需要请求基本信息的物品ID列表
 @author bladebao
 */
@property (nonatomic, readonly) NSMutableSet<NSString *> * productIds;

@end

/*!
 @class MidasIAPPayResp
 @superclass NSObject
 @abstract 米大师支付SDK应答类
 @author bladebao
 */
@interface MidasIAPPayResp : NSObject

/*!
 @property resultCode
 @abstract 应答结果码，参见APMidasRespResultCode定义
 @author bladebao
 */
@property (nonatomic, assign) APMidasRespResultCode resultCode;

/*!
 @property resultInnerCode
 @abstract 内部错误码
 @author bladebao
 */
@property (nonatomic, copy) NSString * resultInnerCode;

/*!
 @property resultMsg
 @abstract 结果消息字符串
 @author bladebao
 */
@property (nonatomic, copy) NSString * resultMsg;

/*!
 @property respString
 @abstract CGI直接调用时，返回
 @author bladebao
 */
@property (nonatomic, copy) NSString * respString;

/*!
 @property successProductIds
 @abstract 成功完成支付并发货的物品ID
 @author bladebao
 */
@property (nonatomic, strong) NSArray * successProductIds;

/*!
 @property failedProductIds
 @abstract 发货失败的物品ID
 @disscussion key是错误码，value是物品ID队列
              // 错误码解释
              // -1/10001/5002 发货失败，等待下次app启动补发货
              // 其他错误码 支付失败/发货失败，不补发
 @author bladebao
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> * failedProductIds;

/*!
 @method
 @abstract 类方法，方便生成APMidasResp类实例
 @param retCode 同属性resultCode
 @param inCodeStr 同属性resultInnerCode
 @param retMsg 同属性resultMsg
 @param respString CGI直接返回的报文，在launchNet接口时使用
 @result 返回初始化后的APMidasResp类实例
 @author bladebao
 */
+ (instancetype)respWithResultCode:(APMidasRespResultCode)retCode
                         innerCode:(NSString *)inCodeStr
                         resultMsg:(NSString *)retMsg
                        respString:(NSString *)respString;

@end





