/*!
 @header WGPlatform.h
 @abstract 向外界开放的接口
 @author haywoodfu
 @version 1.00 2013/11/20 Creation
 */
#ifndef __WGPLATFORM_H__
#define __WGPLATFORM_H__

#ifdef _WIN32
#define WG_DEPRECATED(_version)
#else
#define WG_DEPRECATED(_version) __attribute__((deprecated))
#endif

#include <string>
#include "WGPlatformObserver.h"
#include "WGADObserver.h"
#include "WGGroupObserver.h"
#include "WGWebviewObserver.h"
#include "WGRealNameAuthObserver.h"

/**
 * WeGame接口函数
 *
 * 该类封装了WeGame的外部接口
 */
class WGPlatform {
private:
    static WGPlatform * m_pInst;
    unsigned int m_nPermissions;
    WGPlatformObserver* m_pObserver;
    
    WGPlatform();
    virtual ~WGPlatform();
    
public:
    static WGPlatform* GetInstance();
    std::string registerChannelId;
    
    WGPlatformObserver* GetObserver() const;
    WGADObserver* GetADObserver() const;
    WGGroupObserver* GetGroupObserver() const;
    WGWebviewObserver* GetWebviewObserver() const;
    WGRealNameAuthObserver* GetRealNameAuthObserver() const;
    /**
     * 广告回调设置
     */
    void WGSetADObserver(WGADObserver* pADObserver);
    /**
     *   OnLoginNotify: 登陆回调
     *   OnShareNotify: 分享回调
     *   OnWakeupNotify: 被唤起回调
     *   OnRelationNotify: 关系链查询回调
     * @param pObserver 游戏传入的全局回调对象
     */
    void WGSetObserver(WGPlatformObserver* pObserver);
    
    /**
     *   OnCreateWXGroupNotify: 创建微信群回调
     *   OnQueryGroupInfoNotify: 查询群信息回调
     *   OnJoinWXGroupNotify: 加入微信群回调
     * @param pGroupObserver 游戏传入的全局回调对象
     */
    void WGSetGroupObserver(WGGroupObserver* pGroupObserver);
    
    /**
     *   OnWebviewNotify: 内置浏览器回调
     * @param pWebviewObserver 游戏传入的全局回调对象
     */
    void WGSetWebviewObserver(WGWebviewObserver* pWebviewObserver);
    
    
    /**
     * @param loginRet 返回的记录
     * @return 返回值为平台id, 类型为ePlatform, 返回ePlatform_None表示没有登陆记录
     *   loginRet.platform(类型为ePlatform)表示平台id, 可能值为ePlatform_QQ, ePlatform_Weixin, ePlatform_None.
     *   loginRet.flag(类型为eFlag)表示当前本地票据的状态, 可能值及说明如下:
     *     eFlag_Succ: 授权票据有效
     *     eFlag_QQ_AccessTokenExpired: 手Q accessToken已经过期, 显示授权界面, 引导用户重新授权
     *     eFlag_WX_AccessTokenExpired: 微信accessToken票据过期，需要调用WGRefreshWXToken刷新
     *     eFlag_WX_RefreshTokenExpired: 微信refreshToken, 显示授权界面, 引导用户重新授权
     *   ret.token是一个Vector<TokenRet>, 其中存放的TokenRet有type和value, 通过遍历Vector判断type来读取需要的票据. type类型定义如下:
     *   	eToken_QQ_Access = 1,
     eToken_QQ_Pay,
     eToken_WX_Access,
     eToken_WX_Refresh,
     *
     * 注意: 游戏通过此接口获取到的票据以后必须传到游戏Server, 通过游戏Server调用MSDK后端验证票据接口验证票据有效以后才能让用户进入游戏.
     */
    int WGGetLoginRecord(LoginRet& loginRet);
    
    /**
     * @param platform 游戏传入的平台类型, 可能值为: ePlatform_QQ, ePlatform_Weixin
     * @return void
     *   通过游戏设置的全局回调的OnLoginNotify(LoginRet& loginRet)方法返回数据给游戏
     *     loginRet.platform表示当前的授权平台, 值类型为ePlatform, 可能值为ePlatform_QQ, ePlatform_Weixin
     *     loginRet.flag值表示返回状态, 可能值(eFlag枚举)如下：
     *       eFlag_Succ: 返回成功, 游戏接收到此flag以后直接读取LoginRet结构体中的票据进行游戏授权流程.
     *       eFlag_QQ_NoAcessToken: 手Q授权失败, 游戏接收到此flag以后引导用户去重新授权(重试)即可.
     *       eFlag_QQ_UserCancel: 用户在授权过程中
     *       eFlag_QQ_LoginFail: 手Q授权失败, 游戏接收到此flag以后引导用户去重新授权(重试)即可.
     *       eFlag_Login_NetworkErr: 手Q/WX授权过程中出现网络错误, 游戏接收到此flag以后引导用户去重新授权(重试)即可.
     *     loginRet.token是一个Vector<TokenRet>, 其中存放的TokenRet有type和value, 通过遍历Vector判断type来读取需要的票据. type(TokenType)类型定义如下:
     *       eToken_QQ_Access,
     *       eToken_QQ_Pay,
     *       eToken_WX_Access,
     *       eToken_WX_Refresh
     */
    void WGLogin(ePlatform platform = ePlatform_None);
    
    /**
     * @param platform 游戏传入的平台类型, 可能值为: ePlatform_QQ, ePlatform_Weixin
     * @return void
     * 通过游戏设置的全局回调的OnLoginNotify(LoginRet& loginRet)方法返回数据给游戏
     */
    void WGQrCodeLogin(ePlatform platform);
    
    /**
     * @return bool 返回值已弃用, 全都返回true
     */
    bool WGLogout();
    
    /**
     * @param permissions ePermission枚举值 或 运算的结果, 表示需要的授权项目
     * @return void
     */
    void WGSetPermission(int permissions);
    
    
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
    void WGSendToWeixin(
                        unsigned char* title,
                        unsigned char* desc,
                        unsigned char* mediaTagName,
                        unsigned char* thumbImgData,
                        const int& thumbImgDataLen,
                        unsigned char* messageExt
                        );
    
    
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
    void WGSendToWeixinWeb(
                           unsigned char *title,
                           unsigned char *desc,
                           unsigned char *mediaId,
                           unsigned char *mediaTagName,
                           unsigned char *imgData,
                           const int &imgDataLen,
                           unsigned char* messageExt
                           )WG_DEPRECATED(2.12.0);
    
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
    void WGSendToWeixinWithUrl(
                               const eWechatScene& scene,
                               unsigned char* title,
                               unsigned char* desc,
                               unsigned char* url,
                               unsigned char* mediaTagName,
                               unsigned char* thumbImgData,
                               const int& thumbImgDataLen,
                               unsigned char* messageExt
                               );
    
    
    /**
     * @param title Web结构化消息的标题
     * @param desc Web结构化消息的概要信息
     * @param url Web分享的URL
     * @param thumbImgUrl 界面上展示的小图的链接，分享出去后也用链接方式展示图片
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
    void WGSendToWeixinWebWithUrl(
                                  const eWechatScene& scene,
                                  unsigned char* title,
                                  unsigned char* desc,
                                  unsigned char* url,
                                  unsigned char *thumbImgUrl,
                                  unsigned char* mediaTagName,
                                  unsigned char* thumbImgData,
                                  const int& thumbImgDataLen,
                                  unsigned char* messageExt
                                  )WG_DEPRECATED(2.12.0);
    
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
    void WGSendToWeixinWithPhoto(
                                 const eWechatScene& scene,
                                 unsigned char* mediaTagName,
                                 unsigned char* imgData,
                                 const int& imgDataLen
                                 );
    
    
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
    void WGSendToWeixinWebWithPhoto(
                                    const eWechatScene& scene,
                                    unsigned char* mediaTagName,
                                    unsigned char *url,
                                    unsigned char *thumbUrl,
                                    unsigned char* imgData,
                                    const int& imgDataLen
                                    )WG_DEPRECATED(2.12.0);
    
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
    void WGSendToWeixinWithPhoto(
                                 const eWechatScene &scene,
                                 unsigned char *mediaTagName,
                                 unsigned char *imgData,
                                 const int &imgDataLen,
                                 unsigned char *messageExt,
                                 unsigned char *messageAction
                                 );
    
    
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
    void WGSendToWeixinWebWithPhoto(
                                    const eWechatScene &scene,
                                    unsigned char *mediaTagName,
                                    unsigned char *url,
                                    unsigned char *thumbUrl,
                                    unsigned char *imgData,
                                    const int &imgDataLen,
                                    unsigned char *messageExt,
                                    unsigned char *messageAction
                                    )WG_DEPRECATED(2.12.0);
    
    /**
     * 用户反馈接口, 反馈内容查看http://mcloud.ied.com/queryLogSystem/ceQuery.html?token=07899ab75c30e499d5b33181c2d8ddc7&gameid=0&projectid=ce
     * @param game 游戏名称, 游戏使用自己app的名称即可
     * @param txt 反馈内容
     */
    int WGFeedback(unsigned char* game, unsigned char* txt);
    
    /**
     * 用户反馈接口, 反馈内容查看链接(Tencent内网):
     * 		http://mcloud.ied.com/queryLogSystem/ceQuery.html?token=545bcbcfada62a4d84d7b0ee8e4b44bf&gameid=0&projectid=ce
     * @param body 反馈的内容, 内容由游戏自己定义格式, SDK对此没有限制
     * @return 通过OnFeedbackNotify回调反馈接口调用结果
     */
    void WGFeedback(unsigned char* body);
    
    /**
     * @param bRDMEnable 是否开启RDM的crash异常捕获上报
     * @param bMTAEnable 是否开启MTA的crash异常捕获上报
     */
    void WGEnableCrashReport(bool bRDMEnable, bool bMTAEnable);
    
    /**
     * 自定义数据上报, 此接口仅支持一个key-value的上报, 从1.3.4版本开始, 建议使用void WGReportEvent( unsigned char* name, std::vector<KVPair>& eventList, bool isRealTime)
     * @param name 事件名称
     * @param body 事件内容
     * @param isRealTime 是否实时上报
     * @return void
     */
    void WGReportEvent(
                       unsigned char* name,
                       unsigned char * body,
                       bool isRealTime
                       ) WG_DEPRECATED(1.3.4);
    
    /**
     * @param name 事件名称
     * @param eventList 事件内容, 一个key-value形式的vector
     * @param isRealTime 是否实时上报
     * @return void
     */
    void WGReportEvent(
                       unsigned char* name,
                       std::vector<KVPair>& eventList,
                       bool isRealTime
                       );
    
    /**
     * 返回MSDK版本号
     * @return MSDK版本号
     */
    const std::string WGGetVersion();
    
    /**
     * 如果没有再读assets/channel.ini中的渠道号, 故游戏测试阶段可以自己写入渠道号到assets/channel.ini用于测试.
     * IOS返回plist中的CHANNEL_DENGTA字段
     * @return 安装渠道
     */
    const std::string WGGetChannelId();
    
    /**
     * @return APP版本号
     */
    const std::string WGGetPlatformAPPVersion(ePlatform platform);
    
    /**
     * @return 注册渠道
     */
    const std::string WGGetRegisterChannelId();
    
    /**
     * 此接口用于刷新微信的accessToken
     * refreshToken的用途就是刷新accessToken, 只要refreshToken不过期就可以通过refreshToken刷新accessToken。
     * 有两种情况需要刷新accessToken,
     * @return void
     *   通过游戏设置的全局回调的OnLoginNotify(LoginRet& loginRet)方法返回数据给游戏
     *     因为只有微信平台有refreshToken, loginRet.platform的值只会是ePlatform_Weixin
     *     loginRet.flag值表示返回状态, 可能值(eFlag枚举)如下：
     *       eFlag_WX_RefreshTokenSucc: 刷新票据成功, 游戏接收到此flag以后直接读取LoginRet结构体中的票据进行游戏授权流程.
     *       eFlag_WX_RefreshTokenFail: WGRefreshWXToken调用过程中网络出错, 刷新失败, 游戏自己决定是否需要重试 WGRefreshWXToken
     */
    void WGRefreshWXToken();
    
    /**
     * @param platformType 游戏传入的平台类型, 可能值为: ePlatform_QQ, ePlatform_Weixin
     * @return 平台的支持情况, false表示平台不支持授权, true则表示支持
     */
    bool WGIsPlatformInstalled(ePlatform platformType);
    
    /**
     * 检查平台是否支持SDK API接口
     * @param platformType 游戏传入的平台类型, 可能值为: ePlatform_QQ, ePlatform_Weixin
     * @return 平台的支持情况, false表示平台不支持授权, true则表示支持
     */
    bool WGIsPlatformSupportApi(ePlatform platformType);
    
    /**
     * 获取pfkey，pfKey由msdk 服务器加密生成，支付过程校验
     * @return 返回当前pf加密后对应fpKey字符串
     */
    const std::string WGGetPfKey();
    
    /**
     *  输出msdk依赖平台版本号
     */
    void WGLogPlatformSDKVersion();//log出msdk用到的各sdk版本号
    
    /**
     * 获取自己的QQ资料
     * @return void
     *   此接口的调用结果通过OnRelationNotify(RelationRet& relationRet) 回调返回数据给游戏,
     *   RelationRet对象的persons属性是一个Vector<PersonInfo>, 取第0个即是用户的个人信息.
     *   手Q授权的用户可以获取到的个人信息包含:
     *   nickname, openId, gender, pictureSmall, pictureMiddle, pictureLarge, gpsCity, 其他字段为空.
     *   其中gpsCity字段为玩家所在城市信息，只有游戏调用过 WGGetNearbyPersonInfo 或者 WGGetLocationInfo
     *   接口后，这个字段才有相应信息。
     */
    bool WGQueryQQMyInfo();
    
    /**
     * 获取QQ好友信息, 回调在OnRelationNotify中,
     * 其中RelationRet.persons为一个Vector, Vector中的内容即使好友信息, QQ好友信息里面province和city为空
     * @return void
     * 此接口的调用结果通过OnRelationNotify(RelationRet& relationRet)
     *   回调返回数据给游戏, RelationRet对象的persons属性是一个Vector<PersonInfo>,
     *   其中的每个PersonInfo对象即是好友信息,
     *   好友信息包含: nickname, openId, gender, pictureSmall, pictureMiddle, pictureLarge
     */
    bool WGQueryQQGameFriendsInfo();
    
    /**
     *   回调在OnRelationNotify中,其中RelationRet.persons为一个Vector, Vector的第一项即为自己的资料
     *   个人信息包括nickname, openId, gender, pictureSmall, pictureMiddle, pictureLarge, provice, city, gpsCity
     *   其中gpsCity字段为玩家所在城市信息，只有游戏调用过 WGGetNearbyPersonInfo 或者 WGGetLocationInfo
     *   接口后，这个字段才有相应信息。
     */
    bool WGQueryWXMyInfo();
    
    /**
     * 获取微信好友信息, 回调在OnRelationNotify中,
     *   回调在OnRelationNotify中,其中RelationRet.persons为一个Vector, Vector中的内容即为好友信息
     *   好友信息包括nickname, openId, gender, pictureSmall, pictureMiddle, pictureLarge, provice, city
     */
    bool WGQueryWXGameFriendsInfo();

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
    bool WGSendToQQGameFriend(
                              int act,
                              unsigned char* fopenid,
                              unsigned char *title,
                              unsigned char *summary,
                              unsigned char *targetUrl,
                              unsigned char *imgUrl,
                              unsigned char* previewText,
                              unsigned char* gameTag
                              );
    
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
    bool WGSendToQQGameFriend(
                              int act,
                              unsigned char* fopenid,
                              unsigned char *title,
                              unsigned char *summary,
                              unsigned char *targetUrl,
                              unsigned char *imgUrl,
                              unsigned char* previewText,
                              unsigned char* gameTag,
                              unsigned char* msdkExtInfo
                              );
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
    bool WGSendToWXGameFriend(
                              unsigned char *fOpenId,
                              unsigned char *title,
                              unsigned char *description,
                              unsigned char *mediaId,
                              unsigned char* messageExt,
                              unsigned char *mediaTagName
                              );
    
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
    bool WGSendToWXGameFriend(
                              unsigned char* fOpenId,
                              unsigned char* title,
                              unsigned char* description,
                              unsigned char* mediaId,
                              unsigned char* messageExt,
                              unsigned char* mediaTagName,
                              unsigned char* msdkExtInfo
                              );
    /**
     *  @since 2.0.0
     *  此接口用于已经登录过的游戏, 在用户再次进入游戏时使用, 游戏启动时先调用此接口, 此接口会尝试到后台验证票据
     *  此接口会通过OnLoginNotify将结果回调给游戏, 本接口只会返回两种flag, eFlag_Local_Invalid和eFlag_Succ,
     *  如果本地没有票据或者本地票据验证失败返回的flag为eFlag_Local_Invalid, 游戏接到此flag则引导用户到授权页面授权即可.
     *  如果本地有票据并且验证成功, 则flag为eFlag_Succ, 游戏接到此flag则可以直接使用sdk提供的票据, 无需再次验证.
     *  @return void
     *   Callback: 验证结果通过我OnLoginNotify返回
     */
    void WGLoginWithLocalInfo();
    
    /*
     * @param scene 公告场景ID，不能为空
     */
    void WGShowNotice(unsigned char *scene);
    
    /**
     * 隐藏滚动公告
     */
    void WGHideScrollNotice();
    
    /**
     *  @param openUrl 要打开的url
     */
    void WGOpenUrl(unsigned char * openUrl);
    
    /**
     *  @param openUrl 要打开的url
     *  @param screenDir 内置浏览器支持的屏幕方向
     */
    void WGOpenUrl(unsigned char * openUrl, eMSDK_SCREENDIR screenDir)WG_DEPRECATED(2.15.0);
    
    /*
     * 从本地数据库读取指定scene下指定type的当前有效公告
     * @param sence 这个参数和公告管理端的“公告栏”对应
     * @return NoticeInfo结构的数组，NoticeInfo结构如下：
     typedef struct
     {
     std::string msg_id;			//公告id
     std::string open_id;		//用户open_id
     std::string msg_url;		//公告跳转链接
     eMSG_NOTICETYPE msg_type;	//公告类型，eMSG_NOTICETYPE
     std::string msg_scene;		//公告展示的场景，管理端后台配置
     std::string start_time;		//公告有效期开始时间
     std::string end_time;		//公告有效期结束时间
     eMSG_CONTENTTYPE content_type;	//公告内容类型，eMSG_CONTENTTYPE
     //网页公告特殊字段
     std::string content_url;     //网页公告URL
     //图片公告特殊字段
     std::vector<PicInfo> picArray;    //图片数组
     //文本公告特殊字段
     std::string msg_title;		//公告标题
     std::string msg_content;	//公告内容
     }NoticeInfo;
     */
    std::vector<NoticeInfo> WGGetNoticeData(unsigned char *scene);
    
    /**
     *  打开AMS营销活动中心
     *
     *  @param params 可传入附加在URL后的参数，长度限制256.格式为"key1=***&key2=***",注意特殊字符需要urlencode。
     *                不能和MSDK将附加在URL的固定参数重复，列表如下：
     *                参数名            说明	        值
     *                timestamp	       请求的时间戳
     *                appid 	       游戏ID
     *                algorithm	       加密算法标识	v1
     *                msdkEncodeParam  密文
     *                version	       MSDK版本号	    例如1.6.2i
     *                sig	           请求本身的签名
     *                encode	       编码参数	    1
     *  @return eFlag 返回值，正常返回eFlag_Succ；如果params超长返回eFlag_UrlTooLong
     */
    bool WGOpenAmsCenter(unsigned char* params) WG_DEPRECATED(1.3.4);
    /**
     *  获取附近人的信息
     *  @return 回调到OnLocationNotify
     *  @return void
     *   通过游戏设置的全局回调的OnLocationNofity(RelationRet& rr)方法返回数据给游戏
     *     rr.platform表示当前的授权平台, 值类型为ePlatform, 可能值为ePlatform_QQ, ePlatform_Weixin
     *     rr.flag值表示返回状态, 可能值(eFlag枚举)如下：
     * 			eFlag_LbsNeedOpenLocationService: 需要引导用户开启定位服务
     *  		eFlag_LbsLocateFail: 定位失败, 可以重试
     *  		eFlag_Succ: 获取附近的人成功
     *  		eFlag_Error:  定位成功, 但是请求附近的人失败, 可重试
     *     rr.persons是一个Vector, 其中保存了附近玩家的信息
     */
    void WGGetNearbyPersonInfo();
    
    /**
     *  @return 回调到OnLocationNotify
     *  @return void
     *   通过游戏设置的全局回调的OnLocationNofity(RelationRet& rr)方法返回数据给游戏
     *     rr.platform表示当前的授权平台, 值类型为ePlatform, 可能值为ePlatform_QQ, ePlatform_Weixin
     *     rr.flag值表示返回状态, 可能值(eFlag枚举)如下：
     *  		eFlag_Succ: 清除成功
     *  		eFlag_Error: 清除失败
     */
    bool WGCleanLocation();
    
    /**
     *  获取当前玩家位置信息。
     *  @return 回调到OnLocationGotNotify
     *  @return void
     *   通过游戏设置的全局回调的OnLocationGotNotify(LocationRet& rr)方法返回数据给游戏
     *     rr.platform表示当前的授权平台, 值类型为ePlatform, 可能值为ePlatform_QQ, ePlatform_Weixin
     *     rr.flag值表示返回状态, 可能值(eFlag枚举)如下：
     *  		eFlag_Succ: 获取成功
     *  		eFlag_Error: 获取失败
     *     rr.longitude 玩家位置经度，double类型
     *     rr.latitude 玩家位置纬度，double类型
     */
    bool WGGetLocationInfo();
    
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
    bool WGSendMessageToWechatGameCenter(
                                         unsigned char* fOpenid,
                                         unsigned char* title,
                                         unsigned char* content,
                                         WXMessageTypeInfo *pInfo,
                                         WXMessageButton *pButton,
                                         unsigned char* msdkExtInfo
                                         );
    
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
    void WGSendToWeixinWithMusic(
                                 const eWechatScene& scene,
                                 unsigned char* title,
                                 unsigned char* desc,
                                 unsigned char* musicUrl,
                                 unsigned char* musicDataUrl,
                                 unsigned char *mediaTagName,
                                 unsigned char *imgData,
                                 const int &imgDataLen,
                                 unsigned char *messageExt,
                                 unsigned char *messageAction
                                 );
    
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
    void WGSendToQQWithMusic(
                             const eQQScene& scene,
                             unsigned char* title,
                             unsigned char* desc,
                             unsigned char* musicUrl,
                             unsigned char* musicDataUrl,
                             unsigned char* imgUrl
                             );

    /**
     *  通过外部拉起的URL登陆。该接口用于异帐号场景发生时，用户选择使用外部拉起帐号时调用。
     *  登陆成功后通过onLoginNotify回调
     *
     *  @param flag 为YES时表示用户需要切换到外部帐号，此时该接口会使用上一次保存的异帐号登陆数据登陆。登陆成功后通过onLoginNotify回调；如果没有票据，或票据无效函数将会返回NO，不会发生onLoginNotify回调。
     *              为NO时表示用户继续使用原帐号，此时删除保存的异帐号数据，避免产生混淆。
     *
     *  @return 如果没有票据，或票据无效将会返回NO；其它情况返回YES
     */
    bool WGSwitchUser(bool flag);
    
    /**
     * 打开暂停位和退出位广告
     */
    void WGShowAD(const _eADType& scene);
    
    /**
     * 关闭暂停位和退出位广告
     */
    void WGCloseAD(const _eADType& scene);
    
    
    ePlatform m_currentPlatformType;
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
    void WGSendToQQ(
                    const eQQScene& scene,
                    unsigned char* title, 
                    unsigned char* desc, 
                    unsigned char* url, 
                    unsigned char* imgData, 
                    const int& imgDataLen
                    );
    /*
     *
     * 分享时调用
     * @param QQScene_QZone:空间, 默认弹框 QQScene_Session:好友
     * @param imgData 图片文件数据
     * @param imgDataLen 数据长度
     */
    void WGSendToQQWithPhoto(
                             const eQQScene& scene,
                             unsigned char* imgData, 
                             const int& imgDataLen
                             );
    /**
     * 获取pf, 用于支付, 和pfKey配对使用
     * @return pf
     */
    const std::string WGGetPf();
    
    /**
     *  获取paytoken有效期
     *
     *  @return paytoken有效期 seconds
     */
    int WGGetPaytokenValidTime();
    /**
     *
     *  @return 手Q版本号
     typedef enum QQVersion
     {
     kQQVersion3_0,
     kQQVersion4_0,      //支持sso登陆
     kQQVersion4_2_1,    //ios7兼容
     kQQVersion4_5,      //4.5版本，wpa会话
     kQQVersion4_6,      //4.6版本，sso登陆信令通道切换
     } QQVersion;
     */
    int WGGetIphoneQQVersion();//获取手Q版本号
    /**
     *
     *  @param enabled true:打开 false:关闭
     */
    void WGOpenMSDKLog(bool enabled);
    /**
     * 游戏群绑定：游戏公会/联盟内，公会会长可通过点击“绑定”按钮，拉取会长自己创建的群，绑定某个群作为该公会的公会群
     * @param cUnionid 公会ID，opensdk限制只能填数字，字符可能会导致绑定失败
     * @param cUnion_name 公会名称
     * @param cZoneid 大区ID，opensdk限制只能填数字，字符可能会导致绑定失败
     * @param cSignature 游戏盟主身份验证签名，生成算法为openid_appid_appkey_公会id_区id 做md5.
     * 					   如果按照该方法仍然不能绑定成功，可RTX 咨询 OpenAPIHelper
     *
     */
    void WGBindQQGroup(unsigned char* cUnionid, unsigned char* cUnion_name,
                       unsigned char* cZoneid, unsigned char* cSignature);
    
    /**
     * 游戏内加群,公会成功绑定qq群后，公会成员可通过点击“加群”按钮，加入该公会群
     * @param cQQGroupNum 公会群号，绑群成功后游戏(工会会长)可到 http://qun.qq.com 获取
     * @param cQQGroupKey 需要添加的QQ群对应的key，绑群成功后游戏(工会会长)可到 http://qun.qq.com 获取
     */
    void WGJoinQQGroup(unsigned char* cQQGroupNum, unsigned char* cQQGroupKey);
    
    /**
     * 游戏内加好友
     * @param cFopenid 需要添加好友的openid
     * @param cDesc 要添加好友的备注
     * @param cMessage 添加好友时发送的验证信息
     */
    void WGAddGameFriendToQQ(unsigned char* cFopenid, unsigned char* cDesc,
                             unsigned char* cMessage);
    /**
     *  获取游客模式下的id
     *
     *
     */
    std::string WGGetGuestID();
    
    /**
     *  刷新游客模式下的id
     *
     *
     */
    void WGResetGuestID();
    
    
    /**
     * 创建微信群聊
     * 微信策略：群一旦建立，不可解绑和删除
     * @param unionid 公会ID
     * @param chatRoomName 公会名称(群名称)
     * @param chatRoomNickName 玩家名称(群里展示)
     */
    void WGCreateWXGroup(
                         unsigned char* unionid,
                         unsigned char* chatRoomName,
                         unsigned char* chatRoomNickName
                         );
    
    /**
     * 加入微信群聊
     * @param unionid 公会ID
     * @param chatRoomNickName 玩家名称(群里展示)
     */
    void WGJoinWXGroup(
                       unsigned char* unionid,
                       unsigned char* chatRoomNickName
                       );
    
    
    /**
     * 查询微信群聊成员信息
     * @param unionID 公会ID
     * @param openIdLists 公会成员openid,以","分隔
     */
    void WGQueryWXGroupInfo(
                            unsigned char* unionID,
                            unsigned char* openIdLists
                            );
    
    
    /**
     * 发送微信群消息
     * @param msgType 消息类型：
     1:open
     2:link(未实现)
     3:voice(未实现)
     4:text(未实现)
     * @param subType 子类型：
     1:邀请(填1)
     2:炫耀,
     3:赠送
     4:索要
     * @param unionID 公会ID
     * @param title 标题
     * @param desc 描述
     * @param mediaTagName 请根据实际情况填入下列值的一个, 此值会传到微信供统计用
     "MSG_INVITE";                   // 邀请
     "MSG_SHARE_MOMENT_HIGH_SCORE";    //分享本周最高到朋友圈
     "MSG_SHARE_MOMENT_BEST_SCORE";    //分享历史最高到朋友圈
     "MSG_SHARE_MOMENT_CROWN";         //分享金冠到朋友圈
     "MSG_SHARE_FRIEND_HIGH_SCORE";     //分享本周最高给好友
     "MSG_SHARE_FRIEND_BEST_SCORE";     //分享历史最高给好友
     "MSG_SHARE_FRIEND_CROWN";          //分享金冠给好友
     "MSG_friend_exceed"         // 超越炫耀
     "MSG_heart_send"            // 送心
     * @param imgUrl 图片CDN url
     * @param messageExt 游戏分享是传入字符串，通过此消息拉起游戏会通过 OnWakeUpNotify(WakeupRet ret)中ret.messageExt回传给游戏
     * @param msdkExtInfo 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏
     */
    void WGSendToWXGroup(
                         const int& msgType,
                         const int& subType,
                         unsigned char* unionID,
                         unsigned char* title,
                         unsigned char* desc,
                         unsigned char* messageExt,
                         unsigned char* mediaTagName,
                         unsigned char* imgUrl,
                         unsigned char* msdkExtInfo
                        );
    
    
    /*
     * 加密Url，返回票据加密后的url
     * @param openUrl 需要增加加密参数的url
     */
    const std::string WGGetEncodeUrl(unsigned char * openUrl);
    
    /**
     * 设置游戏当前所处的场景开始点
     * @param cGameStatus 场景值，MSDK提供的场景值请参考GameStatus的定义，游戏也可以自定义场景参数
     */
    void WGStartGameStatus(unsigned char* cGameStatus);
    
    /**
     * 设置游戏当前所处的场景结束点
     * @param cGameStatus 场景值，MSDK提供的场景值请参考GameStatus的定义，游戏也可以自定义场景参数
     * @param succ 游戏对该场景执行结果的定义，例如成功、失败、异常等。
     * @param errorCode 游戏该场景异常的错误码，用户标识或者记录该场景失败具体是因为什么原因
     */
    void WGEndGameStatus(unsigned char* cGameStatus, int succ, int errorCode);
    
    /**
     * 添加本地推送，仅当游戏在后台时有效
     * @param LocalMessage 推送消息结构体，其中该接口
     *  必填参数为：
     *  fireDate;		//本地推送触发的时间
     *  alertBody;		//推送的内容
     *  badge;          //角标的数字
     *  可选参数为：
     *  alertAction;	//替换弹框的按钮文字内容（默认为"启动"）
     *  userInfo;       //自定义参数，可以用来标识推送和增加附加信息
     *  无用参数为：
     *  userInfoKey;	//本地推送在前台推送的标识Key
     *  userInfoValue;  //本地推送在前台推送的标识Key对应的值
     */
    long WGAddLocalNotification(LocalMessage &localMessage);
    
    /**
     * 添加本地推送，游戏在前台有效
     * @param LocalMessage 推送消息结构体，其中该接口
     *  必填参数为：
     *  alertBody;		//推送的内容
     *  userInfoKey;	//本地推送在前台推送的标识Key
     *  userInfoValue;  //本地推送在前台推送的标识Key对应的值
     *  无用参数为：
     *  fireDate;		//本地推送触发的时间
     *  badge;          //角标的数字
     *  alertAction;	//替换弹框的按钮文字内容（默认为"启动"）
     *  userInfo;       //自定义参数，可以用来标识推送和增加附加信息
     */
    long WGAddLocalNotificationAtFront(LocalMessage &localMessage);
    
    /**
     * 删除本地前台推送
     * @param LocalMessage 推送消息结构体，其中该接口
     *  必填参数为：
     *  userInfoKey;	//本地推送在前台推送的标识Key
     *  userInfoValue;  //本地推送在前台推送的标识Key对应的值
     *  无用参数为：
     *  fireDate;		//本地推送触发的时间
     *  alertBody;		//推送的内容
     *  badge;          //角标的数字
     *  alertAction;	//替换弹框的按钮文字内容（默认为"启动"）
     *  userInfo;       //自定义参数，可以用来标识推送和增加附加信息
     */
    void WGClearLocalNotification(LocalMessage &localMessage);
    
    /**
     * 清空所有未生效的本地推送
     */
    void WGClearLocalNotifications();
    
    /**
     * 可以针对不同的用户设置标签，如性别、年龄、学历、爱好等
     * @param tag 用户标签
     * @return none
     */
    void WGSetPushTag(unsigned char* tag);
    
    /**
     * 删除设置的标签
     * @param tag 用户标签
     * @return none
     */
    void WGDeletePushTag(unsigned char* tag);
    
    /**
     * 打开微信deeplink（deeplink功能的开通和配置请联系微信游戏中心）
     * @param link 具体跳转deeplink，可填写为：
     *             INDEX：跳转微信游戏中心首页
     *             DETAIL：跳转微信游戏中心详情页
     *             LIBRARY：跳转微信游戏中心游戏库
     *             具体跳转的url （需要在微信游戏中心先配置好此url）
     */
    void WGOpenWeiXinDeeplink(unsigned char* link);
    
    /**
     * 上报日志到bugly
     * @param level 日志级别:
     * 	eBuglyLogLevel_S (0), //Silent
     *  eBuglyLogLevel_E (1), //Error
     *  eBuglyLogLevel_W (2), //Warning
     *  eBuglyLogLevel_I (3), //Info
     *  eBuglyLogLevel_D (4), //Debug
     *  eBuglyLogLevel_V (5); //Verbose
     *
     * @param log 日志内容
     *
     *  该日志会在crash发生时进行上报，上报日志最大30K
     */
    void WGBuglyLog(eBuglyLogLevel level, unsigned char* log);
    
    /**
     *   OnRealNameAuthNotify: 实名认证回调
     * @param pRealNameAuthObserver 游戏传入的全局回调对象
     */
    void WGSetRealNameAuthObserver(WGRealNameAuthObserver* pRealNameAuthObserver);

    /**
     * 实名认证
     * @param RealNameAuthInfo 实名认证信息结构体
     *  typedef struct
     *   {
     *       std::string name;           //姓名
     *       eIDType identityType;       //证件类型
     *       std::string identityNum;    //证件号码
     *       int province;               //省份
     *       std::string city;           //城市
     *   }RealNameAuthInfo;
     *  其中该接口必填参数为：
     *  name;           //姓名
     *  identityType;   //证件类型
     *  identityNum;    //证件号码
     *  选填参数为：
     *  province;		//省份
     *  city;           //城市
     */
    void WGRealNameAuth(RealNameAuthInfo &authInfo);
    
};
#endif

