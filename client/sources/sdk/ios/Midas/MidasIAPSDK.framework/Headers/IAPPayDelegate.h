/*!
 @header IAPPayDelegate.h
 @abstract 米大师苹果支付渠道SDK，头文件
 @author bladebao
 @version 1.5.2
 */

#import <Foundation/Foundation.h>
#import "RequestInfo.h"

@protocol IAPPayDelegate <NSObject>

@optional

/*!
 @method
 @abstract 此时可以打开loading
 @discussion loading在各个回调失败处关闭即可，否则在最终发货成功后才关闭
 @result 无
 @author bladebao
 */
- (void)canShowLoadingNow;

//参数不合法
-(void)parameterWrong:(NSString*)parameterLog;

//log的回调
-(void)log:(NSString*)message;

//登陆态失效
-(void)onLoginExpiry:(RequestInfo*)info;

//下单成功回调
-(void)onOrderFinish:(NSString*)billno withRequestInfo:(RequestInfo*)info;

//下单失败回调(业务错误)

-(void)onOrderFailue:(RequestInfo*)info withErrorMessage:(NSString*)errorMessage withErrorCode:(int)code;

//苹果支付成功回调

-(void)onIAPPaymentSucess:(RequestInfo*)info;

//拉取货物产品信息失败
//针对拉取产品的时候产品数量为0的时候
-(void)onGetProductInfoFailue:(RequestInfo*)info;

//苹果支付失败回调

-(void)onIAPPayFailue:(RequestInfo*)info  withError:(NSError*)error;

//发货成功回调

-(void)onDistributeGoodsFinish:(RequestInfo*)info;

//发货失败回调(业务错误)
//如果code=10001 则需要补发,其他错误则不需要
-(void)onDistributeGoodsFailue:(RequestInfo*)info withErrorMessage:(NSString*)errorMessage withErrorCode:(int)code;


//网络错误，参数：具体在进行哪一步的时候发生网络错误
//1.下单 2 苹果支付 3 发货 4.恢复非消耗性物品失败 5.拉取营销信息网络错误
-(void)onNetWorkEorror:(int)state withRequestInfo:(RequestInfo*)info;


/*******************补发回调用********************/
//读取补发商品信息失败
-(void)getrestoreInfoFailue:(NSError*)error;

//补发货成功回调(针对非消耗性商品)
-(void)onRestorNon_ConsumableFinish:(RequestInfo*)info;

//补发货失败回调(针对非消耗性商品)
-(void)onRestorNon_ConsumableFailue:(RequestInfo*)info withErrorMessage:(NSString*)errorMessage withErrorCode:(int)code;

/*******************补发回调用********************/

@end
