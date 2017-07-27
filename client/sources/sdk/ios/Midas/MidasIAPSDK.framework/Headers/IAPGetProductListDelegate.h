/*!
 @header IAPGetProductListDelegate.h
 @abstract 米大师苹果支付渠道SDK，头文件
 @author bladebao
 @version 1.5.2
 */

#import <Foundation/Foundation.h>

@protocol IAPGetProductListDelegate <NSObject>

-(void)onLaunProductListFinish:(RequestInfo*)info withJsoninfo:(NSString*)goodsinfo;

-(void)onLaunProductListFailue:(RequestInfo*)info withErrorMessage:(NSString*)errorMessage withErrorCode:(int)code;

@end
