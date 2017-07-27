//
//  MSDKInterface.h
//  MSDK
//
//  Created by Jason on 14/11/17.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDKAuthModel.h"
#import "MSDKPermissionModel.h"
#import "MSDKCallbackModel.h"

@interface MSDKInterface : NSObject

+(instancetype)sharedInterface;

#pragma mark - check token
-(void)checkTokenWithNotify:(BOOL)notifyFlag
                        ret:(LoginRet &)ret
                 checkToken:(BOOL)checkToken
                      scene:(eMSDK_LoginScene)scene;
-(BOOL)isChecking;

#pragma mark – Public
#pragma mark – ParseURL
- (eFlag)parseUrl:(NSString *)urlPath;

#pragma mark – Share
-(BOOL)sendAppContent:(int)scene
                title:(unsigned char* )title
                 desc:(unsigned char*)desc
                  url:(unsigned char*)url
              imgData:(unsigned char*)imgData
           imgDataLen:(int)imgDataLen;
-(BOOL)sendAppContent:(int)scene
                title:(unsigned char* )title
                 desc:(unsigned char*)desc
                  url:(unsigned char*)url
         mediaTagName:(unsigned char*)mediaTagName
              imgData:(unsigned char*)imgData
           imgDataLen:(int)imgDataLen
           messageExt:(unsigned char*)messageExt;
-(BOOL)sendShareUrlContent:(int)scene
                     title:(unsigned char* )title
                      desc:(unsigned char*)desc
                       url:(unsigned char*)url
              mediaTagName:(unsigned char*)mediaTagName
                   imgData:(unsigned char*)imgData
                imgDataLen:(int)imgDataLen
                messageExt:(unsigned char*)messageExt;
-(BOOL)sendPhotoContent:(int)scene
           mediaTagName:(unsigned char*)mediaTagName
                imgData:(unsigned char*)imgData
             imgDataLen:(int)imgDataLen;
-(BOOL)sendPhotoContent:(int)scene
           mediaTagName:(unsigned char*)mediaTagName
                imgData:(unsigned char*)imgData
             imgDataLen:(int)imgDataLen
             messageExt:(unsigned char *)messageExt
          messageAction:(unsigned char *)messageAction;
-(BOOL)sendAudioContent:(int)scene
                  title:(unsigned char* )title
                   desc:(unsigned char*)desc
               musicUrl:(unsigned char*)musicUrl
           musicDataUrl:(unsigned char*)musicDataUrl
                 imgUrl:(unsigned char*)imgUrl;
-(BOOL)sendAudioContent:(int)scene
                  title:(unsigned char* )title
                   desc:(unsigned char*)desc
               musicUrl:(unsigned char*)musicUrl
           musicDataUrl:(unsigned char*)musicDataUrl
                imgData:(unsigned char*)imgData
             imgDataLen:(int)imgDataLen;
-(BOOL)sendAudioContent:(int)scene
                  title:(unsigned char* )title
                   desc:(unsigned char*)desc
               musicUrl:(unsigned char*)musicUrl
           musicDataUrl:(unsigned char*)musicDataUrl
                imgData:(unsigned char*)imgData
             imgDataLen:(int)imgDataLen
           mediaTagName:(unsigned char*)mediaTagName
             messageExt:(unsigned char*)messageExt;

#pragma mark - login
- (void)login;
- (void)qrCodeLogin:(ePlatform)platform useMSDKLayout:(BOOL)useMSDKLayout;

#pragma mark - 关系链相关
-(void)queryMyInfo;
-(void)queryMyGameFriendsInfo;

#pragma mark - 处理拉起
-(BOOL)handleOpenUrl:(NSURL *)url;
@end
