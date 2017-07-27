/*!
 @header APMidasApi.h
 @abstract 米大师苹果支付SDK，头文件
 @author bladebao
 @version 1.5.2
 */
#import <Foundation/Foundation.h>

@class MidasIAPBaseReq;
@class MidasIAPPayReq;
@class MidasIAPMpInfoReq;
@class MidasIAPPayResp;

extern NSString * MIDAS_IAP_ENV_DEV;
extern NSString * MIDAS_IAP_ENV_SANDBOX;
extern NSString * MIDAS_IAP_ENV_RELEASE;

extern NSString * MIDAS_IAP_LOCALE_LOCAL;
extern NSString * MIDAS_IAP_LOCALE_HK;
extern NSString * MIDAS_IAP_LOCALE_CA;

extern NSString * MIDAS_IAP_APP_EXTRA;
extern NSString * MIDAS_IAP_APP_DEFINE_INFO;
extern NSString * MIDAS_IAP_APP_RESERVE1;
extern NSString * MIDAS_IAP_APP_RESERVE2;
extern NSString * MIDAS_IAP_APP_RESERVE3;

/*!
 @protocol APMidasPayDelegate
 @abstract 米大师支付业务回调
 @author bladebao
 */
@protocol MidasIAPPayDelegate <NSObject>

/*!
 @method 
 @abstract 通过APMidasBaseReq及其子类传入的登录态失效，需要重新登录
 @discussion 业务侧重新登录并获取登录态后，重新发起支付请求
 @result 无
 @author bladebao
 */
- (void)needLogin;

/*!
 @method
   @abstract 米大师支付服务的返回结果接口
 @param resp 返回的结果对象，参见APMidasResp定义
 @result 无
 @author bladebao
 */
- (void)onResp:(MidasIAPPayResp *)resp;

@end


/*!
 @class APMidasApi
 @superclass NSObject
 @abstract 米大师支付SDK的API接口类
 @author bladebao
 */
@interface MidasIAPApi : NSObject

/*!
 @method
 @abstract 初始化，关系补发货的重要方法，在获取登陆态后调用，同initializeWithReq:environment:host:extra:，根据设置接入点或域名，二者调用一个即可
 @param req 传入必须的各项参数
 @param env 设置环境变量，如：MIDAS_IAP_ENV_RELEASE:现网环境，MIDAS_IAP_ENV_SANDBOX:沙箱，MIDAS_IAP_ENV_DEV:开发
 @param locale 目前仅支持MIDAS_IAP_LOCALE_LOCAL，MIDAS_IAP_LOCALE_HK，MIDAS_IAP_LOCALE_CA
 @param dictExtra 支持的key有 MIDAS_IAP_APP_EXTRA/MIDAS_IAP_APP_DEFINE_INFO/MIDAS_IAP_APP_RESERVE1/MIDAS_IAP_APP_RESERVE2/MIDAS_IAP_APP_RESERVE3，目前强制通过MIDAS_IAP_APP_EXTRA传入游戏IDIP的partition值，否则初始化失败
 @param delegate 补发货回调，不建议业务在此回调中做其他逻辑，仅供补发货成功后刷新余额使用
 @result 所有参数输入正确，返回YES，否则返回NO
 @author bladebao
 */
+ (BOOL)initializeWithReq:(MidasIAPBaseReq *)req
              environment:(NSString *)env
                   locale:(NSString *)locale
                    extra:(NSDictionary *)dictExtra
        reprovideDelegate:(id<MidasIAPPayDelegate>)delegate;

/*!
 @method
 @abstract 版本号API
 @result 返回形如1.5.0的版本号字符串
 @author bladebao
 */
+ (NSString *)getVersion;

/*!
 @method
 @abstract 打开调试日志，功能同IAPPayHelper类setIsEnLog
 @discussion 建议在接入调试时打开，但在发布时关闭
 @param bEnable YES 打开，NO 关闭
 @result 无
 @author bladebao
 */
+ (void)enableLog:(BOOL)bEnable;

/*!
 @method
 @abstract 判断当前iOS设备是否支持IAP支付
 @discussion 家长控制关闭iap购买时，返回NO，同时，部分越狱设备，也会返回NO，但不建议从此接口判断设备是否越狱
 @result YES:支持 NO:不支持
 @author bladebao
 */
+ (BOOL)isIAPEnable;

/*!
 @method
 @abstract 请求支付的API接口
 @discussion 只能传入APMidasBaseReq的子类实例，传入APMidasBaseReq类的实例，无法完成支付操作
 @param req 支付请求，参见APMidasBaseReq及其子类定义
 @param delegate 回调委托接口，不能为nil
 @result 无
 @author bladebao
 */
+ (void)launchPay:(MidasIAPBaseReq *)req delegate:(id<MidasIAPPayDelegate>)delegate;


/*!
 @method
 @abstract 米大师特殊cgi请求接口的回调(如拉取营销活动，openid换QQ号等)
 @discussion 只能传入APMidasBaseReq的子类实例，传入APMidasBaseReq类的实例，无法完成支付操作
 @param req 支付请求，参见APMidasBaseReq及其子类定义
 @param delegate 回调委托接口，不能为nil
 @result 无
 @author bladebao
 */
+ (void)launchNet:(MidasIAPBaseReq *)req delegate:(id<MidasIAPPayDelegate>)delegate;

/*!
 @method
 @abstract 注册米大师jsapi的API接口
 @discussion 针对每个需要米大师jsapi支持的webview，调用此方法即可，但只能同时支持一个webview，因为保存wvDele和ctxController的对象只能全局存在一个
 @param webView 需要支持的webview
 @param wvDele UIWebViewDelegate回调委托实现
 @param contextController用于展示界面上下文的视图控制器，不能为空
 @result 无
 @author bladebao
 */
+ (void)registerPay:(UIWebView *)webView webViewDelegate:(NSObject<UIWebViewDelegate> *)wvDele viewController:(UIViewController *)ctxController;

@end



