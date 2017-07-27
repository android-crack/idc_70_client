/*!
 @header IAPPayHelper.h
 @abstract 米大师苹果支付渠道SDK，头文件
 @author bladebao
 @version 1.5.2
 */

#import <Foundation/Foundation.h>
#import "IAPPayDelegate.h"
#import "RequestInfo.h"
#import "IAPGetProductListDelegate.h"

extern NSString * kAppExtra;
extern NSString * kAppDefineInfo;
extern NSString * kAppReserve1;
extern NSString * kAppReserve2;
extern NSString * kAppReserve3;

extern NSString * kUploadDeviceInfoScene;

@interface IAPPayHelper : NSObject

@property (nonatomic, weak) id<IAPPayDelegate> Delegate;
@property (nonatomic, weak) id<IAPGetProductListDelegate> GetProductDelagate;

/*!
 @method
 @brief 判断当前iOS设备是否支持IAP支付
 @return YES:支持 NO:不支持
 @note 家长控制关闭iap购买时，返回NO，同时，部分越狱设备，也会返回NO，但不建议从此接口判断设备是否越狱
 */
+ (BOOL)judgeIsCanPay;

/*!
 @method
 @brief 返回当前SDK的版本号
 @return 版本号字符串
 */
+ (NSString *)getVersion;

/*!
 @method
 @brief 设置是否输出运行日志
 @param openid  OpenID字符串
 @param openKey 登陆态字符串
 @return 无
 @note openid:传入QQ号明文或者开放平台返回的OpenID字符串
 */
+ (void)setIsEnLog:(BOOL)isEnable;

/*!
 @method
 @brief 设置连接支付服务器片区
 @param local 片区
 @return 无
 @note local: @"local" 中国内地
 @"hongkong" 香港 (海外版本使用)
 */
+ (void)setLocal:(NSString *)local;

/*!
 @method
 @abstract 隐藏Loading（不建议）
 @discussion 防止用户多次重复购买，特加入loading
 @author bladebao
 */
+ (void)hideLoading:(BOOL)hide;

/*!
 @brief 获取支付单例
 @return 返回IAPPayHelper类的实例，注意，不要尝试释放这个实例，不然会导致支付失败甚至crash
 */
+ (IAPPayHelper *)getIntanceIapHelp;

/*!
 @method
 @brief 注册回调监听，同时设置业务自定义字段
 @param offerid 业务在计平注册的业务ID
 @param openid 用户登录的openid
 @param openKey 用户登录的openkey
 @param sessionId openid对应的sessionId
 @param sessionType openKey对应的sessionType
 @param pf 平台标识
 @param pfKey pfKey
 @param env 支付环境，开发、测试可以填test，现网发布记得一定改成release
 @param dictExtra 业务传递的特别字段，key和value都必须为字符串，key是上面定义的k开头的字符，value如果是BOOL型，则用“0”和“1”表示，如果是数字，则用数字字符串表示“0”，“1”，以此类推
 @return 如果env不是下面所列的三种，则注册失败，需要重新注册
 @note 在获取登陆态时注册一次即可，不要每次在pay之前调用，会引起下单失败，返回错误码900
 */
- (BOOL)registerPay:(NSString*)offerid
         withOpenid:(NSString*)openid
        withOpenKey:(NSString*)openKey
      withSessionId:(NSString*)sessionId
    withSessionType:(NSString*)sessionType
             withPf:(NSString*)pf
          withPfkey:(NSString*)pfKey
            withEnv:(NSString*)env
          withExtra:(NSDictionary *)dictExtra;

/*!
 @method
 @abstract 设置父视图控制器，在每次调用LaunchPay方法前调用
 @discussion 在内部无法获取到正确的controller来打开界面时，在外部传入
 @param parent 父视图控制器
 @result 无
 @author bladebao
 */
- (void)setParentViewController:(UIViewController *)parent; // since 1.3.7

/*!
 @method
 @brief 支付接口
 @param offerid 业务在计平注册的业务ID
 @param openid 用户登录的openid
 @param openKey 用户登录的openkey
 @param sessionId openid对应的sessionId
 @param sessionType openKey对应的sessionType
 @param pf 平台标识
 @param pfKey pfKey
 @param payItem 如果应用使用道具购买类支付模式，该参数由应用方按照“物品ID*单价（单位“角”）*数量”定义；如果应用使用包月类支付模式，传开通包月的月数 （QQ会员这类）；如果游戏币支付模式,传充值游戏币的个数；如果应用使用月卡类支付模式，传开通月卡天数
 @param productId 在RDM或者iTC中注册的商品ID
 @param isDepositGameCoin 是否是托管游戏币，游戏币类型填YES，其他填NO
 @param productType 商品类型，参见枚举AppproducType(0.消费类产品 1.非消费类产品 2.包月+自动续费 3.免费 4.包月+非自动续费)
 @param zoneId 分区
 @param varItem 额外参数，特殊营销活动使用，如神秘商店
 @return 无
 @note 调用这个接口前，业务请自行loading锁屏，知道有失败的回调，或最终发货成功的回调再取消loading，防止用户重复点击，造成支付失败或crash，另外，不要在此函数前调用registerPay，会导致失败
 */
- (void)            pay:(NSString*)offerid
             withOpenid:(NSString*)openid
            withOpenKey:(NSString*)openKey
          withSessionId:(NSString*)sessionId
        withSessionType:(NSString*)sessionType
                 withPf:(NSString*)pf
              withPfkey:(NSString*)pfKey
            withPayItem:(NSString*)payItem
          withProductId:(NSString*)productId
  withIsDepositGameCoin:(Boolean)isDepositGameCoin
        withProductType:(AppproductType)productType
             withZoneId:(NSString*)zoneId
            withVarItem:(NSString*)varItem;

/*!
 @method
 @brief 拉起商品列表以及对应的营销信息
 @param 无
 @return 无
 */
- (void)LaunchGoodsList:(NSString*)offerid
             withOpenid:(NSString*)openid
            withOpenKey:(NSString*)openKey
          withSessionId:(NSString*)sessionId
        withSessionType:(NSString*)sessionType
                 withPf:(NSString*)pf
              withPfkey:(NSString*)pfKey
             withZoneId:(NSString*)zoneId
            withVarItem:(NSString*)varItem
  withIsDepositGameCoin:(Boolean)isDepositGameCoin
        withProductType:(AppproductType)productType;

/*!
 @method
 @brief 针对非消耗性商品的接口重新请求发货
 @param info 支付请求信息
 @note info参数的构造方法需参考RequestInfo.h
 */
- (void)restoreCompletedTransactions:(NSString*)offerid
                          withOpenid:(NSString*)openid
                         withOpenKey:(NSString*)openKey
                       withSessionId:(NSString*)sessionId
                     withSessionType:(NSString*)sessionType
                              withPf:(NSString*)pf
                           withPfkey:(NSString*)pfKey
                          withZoneId:(NSString*)zoneId
                         withVarItem:(NSString*)varItem;

/*!
 @method
 @abstract 上传设备信息
 @discussion 在不同场景下上传设备信息
 @param info 需要上传的key和value键值，key目前仅支持@"scene"，value为业务定义，如@"login"等，key和value都必须为NSString类型，否则不予上传
 @result 无
 @author bladebao
 */
- (void)uploadDeviceInfo:(NSDictionary *)info;

@end
