//
//  MSDKRelationService.h
//  MSDK
//
//  Created by Jason on 14/11/14.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDKRelationService : NSObject

-(void)queryMyInfo;

-(void)queryMyGameFriendsInfo;

- (void)bindGroup:(NSString *)signature
          unionId:(NSString *)unionId
           zoneId:(NSString *)zoneId
   appDisplayName:(NSString *)appName;

- (void)joinQQGroup:(NSString *)groupNum groupKey:(NSString *)groupKey;

- (void)addFriend:(NSString *)openId remark:(NSString *)remark description:(NSString *)desc subId:(NSString *)subId;


//微信建群加群
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

@end
