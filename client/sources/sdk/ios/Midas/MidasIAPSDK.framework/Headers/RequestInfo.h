/*!
 @header RequestInfo.h
 @abstract 米大师苹果支付渠道SDK，头文件
 @author bladebao
 @version 1.5.2
 */

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

//苹果商品的几种类型
enum AppproductType : int
{
    Consumable=0,//消费类产品(单笔,游戏币)
    Non_Consumable,//非消费类产品
    Auto_Renewable_Subscriptions,//包月＋自动续费
    Free_Subscription,//免费
    Non_Renewing_Subscription,//包月+非自动续费
};

typedef enum AppproductType AppproductType;

@interface RequestInfo : NSObject

@property(nonatomic, retain) NSString * Openid;
@property(nonatomic, retain) NSString * OpenKey;
@property(nonatomic, retain) NSString * Session_id;
@property(nonatomic, retain) NSString * Session_type;
@property(nonatomic, retain) NSString * Pf;
@property(nonatomic, retain) NSString * Pfkey;

@property(nonatomic, retain) NSString * Appid;
@property(nonatomic, assign)AppproductType    ProductType;
@property(nonatomic, retain) NSString * Payitem;
@property(nonatomic, retain) NSString  * Zoneid;
@property(nonatomic, retain) NSString  * VarItem;
@property(nonatomic, assign) BOOL    IsDepositGameCoin;

@property(nonatomic,copy) NSString * Billno;

@property (nonatomic, retain) NSDictionary * context;
@property (nonatomic, assign) BOOL isReprovide; // 是否补发货

@property (nonatomic, readonly) NSMutableArray<NSString *> * provideProductIds; //这里存储的是成功支付或发货的所有物品id，票据校验接口存储的是票据中所有的物品id

// 发货失败的物品id，key是错误码，value是物品ID列表
// 错误码解释
// -1 发货失败，等待下次app启动补发货
// -2 票据过期，不会补发货
// -3 票据无效，不会补发货
@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSArray *> * dictFailedProductIds;

@end
