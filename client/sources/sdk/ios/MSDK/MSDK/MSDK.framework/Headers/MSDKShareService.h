//
//  MSDKShareService.h
//  MSDK
//
//  Created by Jason on 14/11/14.
//  Copyright (c)2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDKShareService : MSDKServiceObject

#pragma mark - WX Share

/**
 * @param title 结构化消息的标题
 * @param desc 结构化消息的概要信息
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param thumbImgData 结构化消息的缩略图
 * @param thumbImgDataLen 结构化消息的缩略图数据长度
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixin:(unsigned char*)title
                 desc:(unsigned char*)desc
         mediaTagName:(unsigned char*)mediaTagName
         thumbImgData:(unsigned char*)thumbImgData
       thumbImgDataLen:(const int&)thumbImgDataLen
           messageExt:(unsigned char*)messageExt
                    ;

/**
 * @param title 微信Web结构化消息的标题,bigimg模式下可为空，normal模式下不为空
 * @param desc  微信Web结构化消息的概要信息
 * @param mediaID 图片的id 通过uploadToWX接口获取
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不能超过10M)
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWeb:(unsigned char*)title
                    desc:(unsigned char*)desc
                 mediaId:(unsigned char*)mediaId
            mediaTagName:(unsigned char*)mediaTagName
            thumbImgData:(unsigned char*)thumbImgData
         thumbImgDataLen:(const int&)thumbImgDataLen
              messageExt:(unsigned char*)messageExt;

/**
 * @param title 结构化消息的标题
 * @param desc 结构化消息的概要信息
 * @param url 分享的URL
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param thumbImgData 结构化消息的缩略图
 * @param thumbImgDataLen 结构化消息的缩略图数据长度
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWithUrl:(const eWechatScene&)scene
                           title:(unsigned char*)title
                           desc:(unsigned char*)desc
                           url:(unsigned char*)url
                           mediaTagName:(unsigned char*)mediaTagName
                           thumbImgData:(unsigned char*)thumbImgData
                           thumbImgDataLen:(const int&)thumbImgDataLen
                  messageExt:(unsigned char*)messageExt
                           ;

/**
 * @param title Web结构化消息的标题
 * @param desc Web结构化消息的概要信息
 * @param url Web分享的URL
 * @param mediaID 图片的id 通过uploadToWX接口获取
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param thumbImgData Web结构化消息的缩略图
 * @param thumbImgDataLen Web结构化消息的缩略图数据长度
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWebWithUrl:(const eWechatScene&)scene
                          title:(unsigned char*)title
                           desc:(unsigned char*)desc
                            url:(unsigned char*)url
                    thumbImgUrl:(unsigned char*)thumbImgUrl
                   mediaTagName:(unsigned char*)mediaTagName
                   thumbImgData:(unsigned char*)thumbImgData
                thumbImgDataLen:(const int&)thumbImgDataLen
                     messageExt:(unsigned char*)messageExt;

/**
 * @param scene 指定分享到朋友圈, 或者微信会话, 可能值和作用如下:
 *   WechatScene_Session: 分享到微信会话
 *   WechatScene_Timeline: 分享到微信朋友圈
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不能超过10M)
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWithPhoto:(const eWechatScene&)scene
                             mediaTagName:(unsigned char*)mediaTagName
                       imgData:(unsigned char*)imgData
                    imgDataLen:(const int&)imgDataLen;


/**
 * @param scene 指定分享到朋友圈, 或者微信会话, 可能值和作用如下:
 *   WechatScene_Session: 分享到微信会话
 *   WechatScene_Timeline: 分享到微信朋友圈
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param url 分享出去后，其它用户点击打开的大图地址，这个大图是原生打开的。
 * @param thumbUrl 分享出去后，展示的图片的缩略图url
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不能超过10M)
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWebWithPhoto:(const eWechatScene&)scene
                     mediaTagName:(unsigned char*)mediaTagName
                              url:(unsigned char*)url
                         thumbUrl:(unsigned char*)thumbUrl
                          imgData:(unsigned char*)imgData
                       imgDataLen:(const int&)imgDataLen;
/**
 * @param scene 指定分享到朋友圈, 或者微信会话, 可能值和作用如下:
 *   WechatScene_Session: 分享到微信会话
 *   WechatScene_Timeline: 分享到微信朋友圈
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不能超过10M)
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @param messageAction scene为1(分享到微信朋友圈)的情况下才起作用
 *   WECHAT_SNS_JUMP_SHOWRANK       跳排行
 *   WECHAT_SNS_JUMP_URL            跳链接
 *   WECHAT_SNS_JUMP_APP           跳APP
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWithPhoto:(const eWechatScene &)scene
                  mediaTagName:(unsigned char*)mediaTagName
                       imgData:(unsigned char*)imgData
                             imgDataLen:(const int&)imgDataLen
                             messageExt:(unsigned char*)messageExt
                             messageAction:(unsigned char*)messageAction
                             ;


/**
 * @param scene 指定分享到朋友圈, 或者微信会话, 可能值和作用如下:
 *   WechatScene_Session: 分享到微信会话
 *   WechatScene_Timeline: 分享到微信朋友圈
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param url 分享出去后，其它用户点击打开的大图地址，这个大图是原生打开的。
 * @param thumbUrl 分享出去后，展示的图片的缩略图url
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不能超过10M)
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @param messageAction scene为1(分享到微信朋友圈)的情况下才起作用
 *   WECHAT_SNS_JUMP_SHOWRANK       跳排行
 *   WECHAT_SNS_JUMP_URL            跳链接
 *   WECHAT_SNS_JUMP_APP           跳APP
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWebWithPhoto:(const eWechatScene &)scene
                     mediaTagName:(unsigned char*)mediaTagName
                              url:(unsigned char*)url
                         thumbUrl:(unsigned char*)thumbUrl
                          imgData:(unsigned char*)imgData
                       imgDataLen:(const int&)imgDataLen
                       messageExt:(unsigned char*)messageExt
                    messageAction:(unsigned char*)messageAction;


/**
 * 此接口类似WGSendToQQGameFriend, 此接口用于分享消息到微信好友, 分享必须指定好友openid
 * @param fOpenId 好友的openid
 * @param title 分享标题
 * @param description 分享描述
 * @param mediaId 图片的id 通过uploadToWX接口获取
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 */
-(BOOL)WGSendToWXGameFriend:(unsigned char*)fopenid
                          title:(unsigned char*)title
                          description:(unsigned char*)description
                          mediaId:(unsigned char*)mediaId
                          messageExt:(unsigned char*)messageExt
                          mediaTagName:(unsigned char*)mediaTagName
                          ;
/**
 * 此接口类似WGSendToQQGameFriend, 此接口用于分享消息到微信好友, 分享必须指定好友openid
 * @param fOpenId 好友的openid
 * @param title 分享标题
 * @param description 分享描述
 * @param mediaId 图片的id 通过uploadToWX接口获取
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param msdkExtInfo 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏
 */
-(BOOL)WGSendToWXGameFriend:(unsigned char*)fopenid
                          title:(unsigned char*)title
                          description:(unsigned char*)description
                          mediaId:(unsigned char*)mediaId
                          messageExt:(unsigned char*)messageExt
                          mediaTagName:(unsigned char*)mediaTagName
                          msdkExtInfo:(unsigned char*)msdkExtInfo
                          ;
/**
 * 此接口会分享消息到微信游戏中心内的消息中心，这种消息主要包含两部分，消息体和附加按钮，消息体主要包含展示内容
 * 附加按钮主要定义了点击以后的跳转动作（拉起APP，拉起页面、拉起排行榜），消息类型和按钮类型可以任意组合
 * @param fopenid 好友的openid
 * @param title 游戏消息中心分享标题
 * @param content 游戏消息中心分享内容
 * @param pInfo 消息体，这里可以传入四种消息类型，均为WXMessageTypeInfo的子类：
 * 		TypeInfoImage: 图片消息（下面的几种属性全都要填值）
 * 			std::string pictureUrl; // 图片缩略图
 * 			int height; // 图片高度
 * 			int width; // 图片宽度
 * 		TypeInfoVideo: 视频消息（下面的几种属性全都要填值）
 * 			std::string pictureUrl; // 视频缩略图
 * 			int height; // 视频高度
 * 			int width; // 视频宽度
 * 			std::string mediaUrl; // 视频链接
 * 		TypeInfoLink: 链接消息（下面的几种属性全都要填值）
 * 			std::string pictureUrl; // 在消息中心的消息图标Url（图片消息中，此链接则为图片URL)
 * 			std::string targetUrl; // 链接消息的目标URL，点击消息拉起此链接
 * 		TypeInfoText: 文本消息
 *
 * @param pButton 按钮效果，这里可以传入三种按钮类型，均为WXMessageButton的子类：
 * 		ButtonApp: 拉起应用（下面的几种属性全都要填值）
 * 			std::string name; // 按钮名称
 * 			std::string messageExt; // 附加自定义信息，通过按钮拉起应用时会带回游戏
 * 		ButtonWebview: 拉起web页面（下面的几种属性全都要填值）
 * 			std::string name; // 按钮名称
 * 			std::string webViewUrl; // 点击按钮后要跳转的页面
 * 		ButtonRankView: 拉起排行榜（下面的几种属性全都要填值）
 * 			std::string name; // 按钮名称
 * 			std::string title; // 排行榜名称
 * 			std::string rankViewButtonName; // 排行榜中按钮的名称
 * 			td::string messageExt; // 附加自定义信息，通过排行榜中按钮拉起应用时会带回游戏
 * @param msdkExtInfo 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏
 *  @return 参数异常或未登陆
 */
-(BOOL)WGSendMessageToWechatGameCenter:(unsigned char*)fopenid
                                     title:(unsigned char*)title
                                     content:(unsigned char*)content
                                     pInfo:(WXMessageTypeInfo *)pInfo
                                     pButton:(WXMessageButton *)pButton
                                     msdkExtInfo:(unsigned char*)msdkExtInfo
                                     ;
/**
 * 把音乐消息分享给微信好友
 * @param scene 指定分享到朋友圈, 或者微信会话, 可能值和作用如下:
 *   WechatScene_Session: 分享到微信会话
 *   WechatScene_Timeline: 分享到微信朋友圈 (此种消息已经限制不能分享到朋友圈)
 * @param title 音乐消息的标题
 * @param desc	音乐消息的概要信息
 * @param musicUrl	音乐消息的目标URL
 * @param musicDataUrl	音乐消息的数据URL
 * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也会带回此值, 可以用于区分分享来源
 "MSG_INVITE";                   // 邀请
 "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
 "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
 "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
 "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
 "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
 "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
 "MSG_friend_exceed"         // 超越炫耀
 "MSG_heart_send"            // 送心
 * @param imgData 原图文件数据
 * @param imgDataLen 原图文件数据长度(图片大小不z能超过10M)
 * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
 * @param messageAction scene为WechatScene_Timeline(分享到微信朋友圈)的情况下才起作用
 *   WECHAT_SNS_JUMP_SHOWRANK       跳排行,查看排行榜
 *   WECHAT_SNS_JUMP_URL            跳链接,查看详情
 *   WECHAT_SNS_JUMP_APP            跳APP,玩一把
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToWeixinWithMusic:(const eWechatScene&)scene
                             title:(unsigned char*)title
                             desc:(unsigned char*)desc
                             musicUrl:(unsigned char*)musicUrl
                             musicDataUrl:(unsigned char*)musicDataUrl
                             mediaTagName:(unsigned char*)mediaTagName
                             imgData:(unsigned char*)imgData
                             imgDataLen:(const int&)imgDataLen
                             messageExt:(unsigned char*)messageExt
                             messageAction:(unsigned char*)messageAction
                             ;

#pragma mark - QQ Share
/**
 * @param act 好友点击分享消息拉起页面还是直接拉起游戏, 传入 1 拉起游戏, 传入 0, 拉起targetUrl
 * @param fopenid 好友的openId
 * @param title 分享的标题
 * @param summary 分享的简介
 * @param targetUrl 跳转目标页面, 通常为游戏的详情页
 * @param imageUrl 分享缩略图URL
 * @param previewText 可选, 预览文字
 * @param gameTag 可选, 此参数必须填入如下值的其中一个
 MSG_INVITE                //邀请
 MSG_FRIEND_EXCEED       //超越炫耀
 MSG_HEART_SEND          //送心
 MSG_SHARE_FRIEND_PVP    //PVP对战
 */
-(BOOL)WGSendToQQGameFriend:(int)act
                          fopenid:(unsigned char*)fopenid
                          title:(unsigned char*)title
                          summary:(unsigned char*)summary
                          targetUrl:(unsigned char*)targetUrl
                          imgUrl:(unsigned char*)imgUrl
                          previewText:(unsigned char*)previewText
                          gameTag:(unsigned char*)gameTag
                          ;

/**
 * @param act 好友点击分享消息拉起页面还是直接拉起游戏, 传入 1 拉起游戏, 传入 0, 拉起targetUrl
 * @param fopenid 好友的openId
 * @param title 分享的标题
 * @param summary 分享的简介
 * @param targetUrl 内容的跳转url，填游戏对应游戏中心详情页，
 * @param imageUrl 分享缩略图URL
 * @param previewText 可选, 预览文字
 * @param gameTag 可选, 此参数必须填入如下值的其中一个
 MSG_INVITE                //邀请
 MSG_FRIEND_EXCEED       //超越炫耀
 MSG_HEART_SEND          //送心
 MSG_SHARE_FRIEND_PVP    //PVP对战
	* @param extMsdkInfo 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏，游戏可以用extInfo区分request
	*/
-(BOOL)WGSendToQQGameFriend:(int)act
                          fopenid:(unsigned char*)fopenid
                          title:(unsigned char*)title
                          summary:(unsigned char*)summary
                          targetUrl:(unsigned char*)targetUrl
                          imgUrl:(unsigned char*)imgUrl
                          previewText:(unsigned char*)previewText
                          gameTag:(unsigned char*)gameTag
                          msdkExtInfo:(unsigned char*)msdkExtInfo
                          ;
/**
 * 把音乐消息分享到手Q会话
 * @param scene eQQScene:
 * 			QQScene_QZone : 分享到空间
 * 			QQScene_Session：分享到会话
 * @param title 结构化消息的标题
 * @param desc 结构化消息的概要信息
 * @param musicUrl      点击消息后跳转的URL
 * @param musicDataUrl  音乐数据URL（例如http:// ***.mp3）
 * @param imgUrl 		分享消息缩略图URL，可以为本地路径(直接填路径，例如：/sdcard/ ***test.png)或者网络路径(例如：http:// ***.jpg)，本地路径要放在sdcard
 * @return void
 *   通过游戏设置的全局回调的OnShareNotify(ShareRet& shareRet)回调返回数据给游戏, shareRet.flag值表示返回状态, 可能值及说明如下:
 *     eFlag_Succ: 分享成功
 *     eFlag_Error: 分享失败
 */
-(BOOL)WGSendToQQWithMusic:(const eQQScene&)scene
                         title:(unsigned char*)title
                         desc:(unsigned char*)desc
                         musicUrl:(unsigned char*)musicUrl
                         musicDataUrl:(unsigned char*)musicDataUrl
                         imgUrl:(unsigned char*)imgUrl
                         ;

/**  分享内容到QQ
 *
 * 分享时调用
 * @param scene QQScene_QZone:空间，默认弹框 QQScene_Session:好友
 * @param title 标题
 * @param desc 内容
 * @param url  内容的跳转url，填游戏对应游戏中心详情页
 * @param imgData 图片文件数据
 * @param imgDataLen 数据长度
 * @return void
 */
-(BOOL)WGSendToQQ:(const eQQScene&)scene
                title:(unsigned char*)title
                desc:(unsigned char*)desc
                url:(unsigned char*)url
                imgData:(unsigned char*)imgData
                imgDataLen:(const int&)imgDataLen
                ;

/*
 * 分享时调用
 * @param QQScene_QZone:空间, 默认弹框 QQScene_Session:好友
 * @param imgData 图片文件数据
 * @param imgDataLen 数据长度
 */
-(BOOL)WGSendToQQWithPhoto:(const eQQScene&)scene
                         imgData:(unsigned char*)imgData
                         imgDataLen:(const int&)imgDataLen
                         ;

/**
 * 打开微信deeplink（deeplink功能的开通和配置请联系微信游戏中心）
 * @param link 具体跳转deeplink，可填写为：
 *             INDEX：跳转微信游戏中心首页
 *             DETAIL：跳转微信游戏中心详情页
 *             LIBRARY：跳转微信游戏中心游戏库
 *             具体跳转的url （需要在微信游戏中心先配置好此url）
 */
- (void)WGOpenWeiXinDeeplink:(unsigned char*)link;




@end
