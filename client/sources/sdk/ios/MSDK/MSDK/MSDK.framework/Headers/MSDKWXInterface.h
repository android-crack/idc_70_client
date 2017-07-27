//
//  MSDKWXInterface.h
//  MSDK
//
//  Created by Jason on 14/11/13.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDKWXNetworkModel.h"
#import "MSDKInterface.h"


@interface MSDKWXInterface : MSDKInterface

//后端分享
-(void)sendShareWithDict:(NSDictionary *)dict;
-(void)sendMessageWithDict:(NSDictionary *)dict;

/*
 微信H5使用文档
 参数分为2部分：
 一、url中带参数，包括四个，type,channel,openid,access_token
 type 取值: normal,bigimg
 channel取值 1和0，1代表发送给朋友圈，0表示发送给好友(session)
 openid,access_token msdk生成。
 
 二、jsapi返回的参数
 示例：
 responseData = {
 title: 'test title',
 desc: 'test desc',
 local_url: 'test local_url',
 thumb_url: 'http://mmocgame.qpic.cn/wechatgame/mEMdfrX5RU301dFpDHFCxXoDCECfYiaeSOV64vBULEFVzlWjicyRNrC1drT2UWz25H/0',
 msg_type: 'IMAGE',
 sub_type: 'SHOW',
 ext_info: 'test ext_info',
 action_name: 'WECHAT_SNS_JUMP_SHOWRANK',
 media_tag_name: 'MSG_SHARE_MOMENT_HIGH_SCORE',
 thumb_media_id: 'z-pkjum5iIC3Oo6K0D5nzBSsYDOwLeM26OI5xsqMFXNXxrh7ejO8QIMYrSG7CaR5',
 content: 'test content',
 icon_url: 'http://mmocgame.qpic.cn/wechatgame/mEMdfrX5RU3uZS2DPHjgjMZEVAOwVZ9ovTytliapMYJD5mQfffyXsUBFSkINlxUVk/0',
 url: 'http://mmocgame.qpic.cn/wechatgame/mEMdfrX5RU3uZS2DPHjgjMZEVAOwVZ9ovTytliapMYJD5mQfffyXsUBFSkINlxUVk/0'
 };
 
 三、各场景下参数约束
 
 示例中的参数，在不同的场景下，传入不同的值，示例只是一个汇总。以下规范描述各场景下要传示例中的哪些参数：
 
 接口提供以下分享功能：
 1、分享给好友(session)
 1.1 分享给好友，采用media_id方式
 参数约束：
 type = normal || bigimg
 channel=0，
 
 msg_type = OPEN
 sub_type = INVITE || SHOW || HEART
 title = '界面展示的title'
 desc = '界面上展示的介绍'
 ext_info = '这里可有可无'
 action_name = '可有可无'
 media_tag_name = '可有可无'
 thumb_media_id = 界面上展示的小图media_id，必须要，生成得不对，直接会导致分享失败
 local_url = thumb_media_id对应的图片的 base64化的图片，采用png
 1.2 分享给好友，采用link方式
 type = normal || bigimg
 channel=0，
 
 msg_type = LINK
 sub_type = INVITE || SHOW || HEART
 title = '界面展示的title'
 desc = '界面上展示的介绍'
 url = '分享出去看，点击打开的链接'
 thumb_url = '界面上展示的小图的链接，分享出去后也用链接方式展示图片'
 local_url = thumb_url对应的图片的 base64化的图片，采用png
 
 1.3 分享给好友，仅发送文本
 type = normal || bigimg
 channel=0，
 
 msg_type = TEXT
 sub_type = INVITE || SHOW || HEART
 content = 要发给好友的文本。
 2、分享到朋友圈(timeline)
 2.1 分享朋友圈采用Link方式
 参数约束：
 type = normal || bigimg
 channel = 1
 
 msg_type = LINK
 sub_type = INVITE || SHOW || HEART
 desc = '发朋友圈的文本介绍'
 action_name = 'WECHAT_SNS_JUMP_SHOWRANK || WECHAT_SNS_JUMP_URL || WECHAT_SNS_JUMP_APP
 media_tag_name = "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 ext_info = 可有可无
 title = 朋友圈里的title
 url = 点击分享后的朋友圈后，要跳转的链接，通过webview打开新页面。
 icon_url = 缩略图
 local_url = icon_url对应的base64化图片
 
 2.2 分享朋友圈采用图片方式
 参数约束：
 type = normal || bigimg
 channel = 1
 
 msg_type = IMAGE
 sub_type = INVITE || SHOW || HEART
 desc = '发朋友圈的文本介绍'
 action_name = 'WECHAT_SNS_JUMP_SHOWRANK || WECHAT_SNS_JUMP_URL || WECHAT_SNS_JUMP_APP
 media_tag_name = "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 
 ext_info = '可有可无'
 media_id = '在此接口时，不用media_id，描述在这里'
 url = 分享出去后，其它用户点击打开的大图地址，这个大图是原生打开的。
 thumb_url = 分享出去后，展示的图片的缩略图url
 local_url = thumb_url对应的base64化图片
 */

//H5分享需要的参数
#define kWXH5ShareType          @"type"
#define vWXH5ShareTypeNormal    @"normal"
#define vWXH5ShareTypeBigImg    @"bigimg"
#define kWXH5ShareChannel       @"channel"
#define kWXH5ShareMsgType       @"msg_type"
#define vWXH5ShareMsgTypeOpen   @"OPEN"
#define vWXH5ShareMsgTypeLink   @"LINK"
#define vWXH5ShareMsgTypeText   @"TEXT"
#define vWXH5ShareMsgTypeImage  @"IMAGE"
#define kWXH5ShareSubType       @"sub_type"
#define vWXH5ShareSubTypeInvite @"INVITE"
#define vWXH5ShareSubTypeShow   @"SHOW"
#define vWXH5ShareSubTypeHeart  @"HEART"
#define kWXH5ShareTitle         @"title"
#define kWXH5ShareDesc          @"desc"
#define kWXH5ShareMessageExt    @"ext_into"
#define kWXH5ShareMessageAction @"action_name"
#define kWXH5ShareMediaID       @"thumb_media_id"
#define kWXH5ShareUrl           @"url"
#define kWXH5ShareLocalUrl      @"local_url"
#define kWXH5ShareThumbUrl      @"thumb_url"
#define kWXH5ShareContent       @"content"
#define kWXH5ShareMediaTagName  @"media_tag_name"
#define kWXH5ShareIconUrl       @"icon_url"

//Web分享
//Web结构化分享
-(BOOL)sendToWeixinWeb:(unsigned char*)title
                  desc:(unsigned char*)desc
               mediaId:(unsigned char*)mediaId
          mediaTagName:(unsigned char*)mediaTagName
          thumbImgData:(unsigned char*)thumbImgData
       thumbImgDataLen:(const int&)thumbImgDataLen
            messageExt:(unsigned char*)messageExt;
//Web结构化URL分享
-(BOOL)sendToWeixinWebWithUrl:(const eWechatScene&)scene
                        title:(unsigned char*)title
                         desc:(unsigned char*)desc
                          url:(unsigned char*)url
                  thumbImgUrl:(unsigned char*)thumbImgUrl
                 mediaTagName:(unsigned char*)mediaTagName
                 thumbImgData:(unsigned char*)thumbImgData
              thumbImgDataLen:(const int&)thumbImgDataLen
                   messageExt:(unsigned char*)messageExt;
//Web大图分享
-(BOOL)sendToWeixinWebWithPhoto:(const eWechatScene&)scene
                   mediaTagName:(unsigned char*)mediaTagName
                            url:(unsigned char*)url
                       thumbUrl:(unsigned char*)thumbUrl
                        imgData:(unsigned char*)imgData
                     imgDataLen:(const int&)imgDataLen;

//Web大图分享
-(BOOL)sendToWeixinWebWithPhoto:(const eWechatScene &)scene
                   mediaTagName:(unsigned char*)mediaTagName
                            url:(unsigned char*)url
                       thumbUrl:(unsigned char*)thumbUrl
                        imgData:(unsigned char*)imgData
                     imgDataLen:(const int&)imgDataLen
                     messageExt:(unsigned char*)messageExt
                  messageAction:(unsigned char*)messageAction;


//建群加群
- (void)createWXGroup:(unsigned char *)unionid
         chatRoomName:(unsigned char *)chatRoomName
     chatRoomNickName:(unsigned char *)chatRoomNickName;

- (void)joinWXGroup:(unsigned char *)unionid chatRoomNickName:(unsigned char *)chatRoomNickName;

- (void)queryWXGroupInfo:(unsigned char *)unionID openIdLists:(unsigned char *)openIdLists;

- (void)sendToWXGroup:(int)msgType
              subType:(int)subType
              unionID:(unsigned char *)unionID
                title:(unsigned char *)title
                 desc:(unsigned char *)desc
           messageExt:(unsigned char *)messageExt
         mediaTagName:(unsigned char *)mediaTagName
               imgUrl:(unsigned char *)imgUrl
          msdkExtInfo:(unsigned char *)msdkExtInfo;

- (void)openWeiXinDeeplink:(unsigned char*)link;


@end
