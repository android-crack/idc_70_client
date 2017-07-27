//
//  MSDKAuthService.h
//  MSDK
//
//  Created by Jason on 14/11/13.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MSDKAuthService : NSObject

-(void)login:(ePlatform)platform;
- (void)qrCodeLogin:(ePlatform)platform useMSDKLayout:(BOOL)useMSDKLayout;
-(void)loginWithLocalInfo:(BOOL)switchUser;
-(void)logout;

-(void)resetGuestId;
-(NSString *)getGuestId;

-(void)setPermission:(int)permissions;
-(void)refreshWXToken;

-(ePlatform)loadLoginInfo:(LoginRet &)ret;
-(BOOL)switchUser:(BOOL) flag;
@end
