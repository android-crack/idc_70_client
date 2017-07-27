//
//  MSDKCryptTool.h
//  MSDK
//
//  Created by Jason on 14/11/7.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDKCryptTool : NSObject

+(NSString *)md5HexDigest:(NSString *)string;

+ (NSString *)md5HexDigest16Bytes:(NSString *)string;

+(NSString *)md5DecimalismDigest:(NSString *)string;

//加密数据方法
+ (NSData *)cryptData:(NSData *)srcData;
//加密数据方法
+ (NSData *)cryptData:(NSData *)srcData key:(NSString *)key;

+ (NSData *)decryptData:(NSData *)srcData;

+ (NSData *)decryptData:(NSData *)srcData key:(NSString *)key;

+ (NSString *)encryptUseDES:(NSString *)plainText;

+ (NSString *)decryptUseDES:(NSString *)cipherString;

+ (NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;

+ (NSString *)decryptUseDES:(NSString *)cipherString key:(NSString*)key;

//票据加、解密
+ (NSString *)encryptToken:(NSString *)toEncryptToken key:(NSString *)key;

+ (NSString *)decryptToken:(NSString *)toDecryptToken key:(NSString *)key;

@end
