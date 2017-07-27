//
//  MTAFeedback.h
//  TA-SDK
//
//  Created by tyzual on 10/30/15.
//  Copyright © 2015 WQY. All rights reserved.
//

#import "MTA.h"

/**
 *  用户反馈结构
 */
@interface MTAFeedBack : NSObject

/**
 *  反馈id
 */
@property (nonatomic, retain) NSNumber* feedBackId;

/**
 *  用户名
 */
@property (nonatomic, retain) NSString* userName;

/**
 *  反馈时间
 */
@property (nonatomic, retain) NSDate* date;

/**
 *  反馈内容
 */
@property (nonatomic, retain) NSString* content;
@end


@interface MTA(MTAFeedBack)
/**
 *  用户反馈相关接口
 */

/**
 *  发送用户反馈
 *
 *  @param strContent 反馈内容
 *  @param screenhot  屏幕截图
 *  @param cb         回调
 *					  回调函数中bSuccess为YES表示操作成功,NO为操作失败
 *					  msg为服务器返回的相关信息
 */
+(void) postFeedBackFiles:(NSString*)strContent screenshot:(UIImage *)screenhot callback:(void(^)(BOOL bSuccess, NSString* msg))cb;

/**
 *  获取用户反馈
 *
 *  @param offset  获取的偏移量,0表示从最新发送的那一条开始获取
 *  @param numLine 获取条数
 *  @param cb      回调
 *					  回调函数中bSuccess为YES表示操作成功,NO为操作失败
 *					  msg为服务器返回的相关信息
 *					  如果获取成功,datas为获取到的用户反馈
 */
+(void) getFeedBackMessage:(uint32_t)offset numLine:(uint32_t)numLine callback:(void(^)(BOOL bSuccess, NSString* msg, NSArray<MTAFeedBack*>* datas))cb;

/**
 *  回复用户反馈
 *
 *  @param fbId    回复的反馈id
 *  @param content 回复的内容
 *  @param cb      回调
 *					  回调函数中bSuccess为YES表示操作成功,NO为操作失败
 *					  msg为服务器返回的相关信息
 */
+(void) replyFeedBackMessage:(NSNumber*)fbId content:(NSString*)content callback:(void(^)(BOOL bSuccess, NSString* msg))cb;

@end