//
//  MSDKObject.h
//  MSDKFoundation
//
//  Created by fu chunhui on 14-11-18.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDKStructs.h"

@interface MSDKObject : NSObject

@end

@interface MSDKAnnoucementObject : MSDKObject

- (NoticeInfo)toNoticeInfo;
@end

@interface MSDKAdvertisementObject : MSDKObject

@end

@interface MSDKAdTapObject : MSDKObject
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) eADType adType;
@end

@interface MSDKADRet : MSDKObject
@property (nonatomic,assign) _eADType scene;
@property (nonatomic,strong) NSString * viewTag;
-(instancetype)initWithRet:(ADRet &)ret;
-(void)getRet:(ADRet &)ret;
@end

@interface MSDKLoginRet : MSDKObject
-(instancetype)initWithRet:(LoginRet &)ret;
-(void)getRet:(LoginRet &)ret;

@property (nonatomic,assign) int flag;
@property (nonatomic,strong) NSString * desc;
@property (nonatomic,assign) int platform;
@property (nonatomic,strong) NSString *  open_id;
@property (nonatomic,strong) NSMutableArray * token;
@property (nonatomic,strong) NSString *  user_id;    //用户ID，先保留，等待和微信协商
@property (nonatomic,strong) NSString *  pf;
@property (nonatomic,strong) NSString *  pf_key;
@end

@interface MSDKTokenRet : MSDKObject
@property (nonatomic,assign) int type;
@property (nonatomic,strong) NSString *  value;
@property (nonatomic,assign) long long expiration;
-(instancetype)initWithRet:(TokenRet &)ret;
-(void)getRet:(TokenRet &)ret;
@end

@interface MSDKWakeupRet : MSDKObject

@property (nonatomic,assign) int flag;                //错误码
@property (nonatomic,assign) int platform;               //被什么平台唤起
@property (nonatomic,strong) NSString *  media_tag_name; //wx回传得meidaTagName
@property (nonatomic,strong) NSString *  open_id;        //qq传递的openid
@property (nonatomic,strong) NSString *  desc;           //描述
@property (nonatomic,strong) NSString *  lang;          //语言     目前只有微信5.1以上用，手Q不用
@property (nonatomic,strong) NSString *  country;       //国家     目前只有微信5.1以上用，手Q不用
@property (nonatomic,strong) NSString *  messageExt;    //游戏分享传入自定义字符串，平台拉起游戏不做任何处理返回         目前只有微信5.1以上用，手Q不用
@property (nonatomic,strong) NSMutableDictionary * extInfo;
-(instancetype)initWithRet:(WakeupRet &)ret;
-(void)getRet:(WakeupRet &)ret;
@end




@interface MSDKShareRet : MSDKObject
@property (nonatomic,assign) int platform;           //平台类型
@property (nonatomic,assign) int flag;            //操作结果
@property (nonatomic,strong) NSString *  desc;       //结果描述（保留）
@property (nonatomic,strong) NSString *  extInfo;
-(instancetype)initWithRet:(ShareRet &)ret;
-(void)getRet:(ShareRet &)ret;
@end



@interface MSDKPersonInfo : MSDKObject

@property (nonatomic,strong) NSString *  nickName;         //昵称
@property (nonatomic,strong) NSString *  openId;           //帐号唯一标示
@property (nonatomic,strong) NSString *  gender;           //性别
@property (nonatomic,strong) NSString *  pictureSmall;     //小头像
@property (nonatomic,strong) NSString *  pictureMiddle;    //中头像
@property (nonatomic,strong) NSString *  pictureLarge;     //datouxiang
@property (nonatomic,strong) NSString *  provice;          //省份(老版本属性，为了不让外部app改代码，没有放在AddressInfo)
@property (nonatomic,strong) NSString *  city;             //城市(老版本属性，为了不让外部app改代码，没有放在AddressInfo)
@property (nonatomic,assign) bool        isFriend;         //是否好友
@property (nonatomic,assign) int         distance;         //离此次定位地点的距离
@property (nonatomic,strong) NSString *  lang;             //语言
@property (nonatomic,strong) NSString *  country;          //国家
@property (nonatomic,strong) NSString *  gpsCity;
-(instancetype)initWithRet:(PersonInfo &)ret;
-(void)getRet:(PersonInfo &)ret;
@end

@interface MSDKRelationRet : MSDKObject
@property (nonatomic,assign) int flag;     //查询结果flag，0为成功
@property (nonatomic,strong) NSString *  desc;    // 描述
@property (nonatomic,strong) NSMutableArray * persons;//保存好友或个人信息
@property (nonatomic,strong) NSString *  extInfo;
-(instancetype)initWithRet:(RelationRet &)ret;
-(void)getRet:(RelationRet &)ret;
@end

@interface MSDKLocationRet : MSDKObject
@property (nonatomic,assign) int flag;
@property (nonatomic,strong) NSString *  desc;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
-(instancetype)initWithRet:(LocationRet &)ret;
-(void)getRet:(LocationRet &)ret;

@end

@interface MSDKWXGroupInfo : MSDKObject

@property (nonatomic,copy) NSString *openIdList;         //群成员openId,以","分隔
@property (nonatomic,copy) NSString *memberNum;          //群成员数
@property (nonatomic,copy) NSString *chatRoomURL;        //创建（加入）群聊URL

@end

@interface MSDKQQGroupInfo : MSDKObject

@property (nonatomic,copy) NSString *groupName;          //群名称
@property (nonatomic,copy) NSString *fingerMemo;         //群的相关简介
@property (nonatomic,copy) NSString *memberNum;          //群成员数
@property (nonatomic,copy) NSString *maxNum;             //该群可容纳的最多成员数
@property (nonatomic,copy) NSString *ownerOpenid;        //群主openid
@property (nonatomic,copy) NSString *unionid;            //与该QQ群绑定的公会ID
@property (nonatomic,copy) NSString *zoneid;             //大区ID
@property (nonatomic,copy) NSString *adminOpenids;       //管理员openid。如果管理员有多个的话，用“,”隔开，例如0000000000000000000000002329FBEF,0000000000000000000000002329FAFF
@property (nonatomic,copy) NSString *groupOpenid;        //和游戏公会ID绑定的QQ群的groupOpenid
@property (nonatomic,copy) NSString *groupKey;           //需要添加的QQ群对应的key

@end

@interface MSDKGroupRet : MSDKObject

@property (nonatomic,assign) int flag;                       //0成功
@property (nonatomic,assign) int errorCode;                  //平台返回参数，当flag非0时需关注
@property (nonatomic,copy) NSString *desc;               //错误信息
@property (nonatomic,assign) int platform;                   //平台
@property (nonatomic,assign) MSDKWXGroupInfo *wxGroupInfo;        //微信群信息
@property (nonatomic,assign) MSDKQQGroupInfo *qqGroupInfo;        //QQ群信息

-(instancetype)initWithRet:(GroupRet &)ret;
-(void)getRet:(GroupRet &)ret;

@end

@interface MSDKWebviewRet : MSDKObject

@property (nonatomic,assign) int flag;                       //0成功
- (instancetype)initWithRet:(WebviewRet &)ret;
- (void)getRet:(WebviewRet &)ret;

@end

@interface MSDKRealNameAuthRet : MSDKObject

@property (nonatomic, assign) int flag;                       //0成功
@property (nonatomic, assign) int errorCode;
@property (nonatomic, assign) int platform;
@property (nonatomic, copy) NSString *desc;
- (instancetype)initWithRet:(RealNameAuthRet &)ret;
- (void)getRet:(RealNameAuthRet &)ret;

@end

