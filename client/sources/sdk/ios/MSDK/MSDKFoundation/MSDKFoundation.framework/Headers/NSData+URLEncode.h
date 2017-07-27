//
//  WGCommonMethods.h
//  WGFrameworkDemo
//
//  Created by fred on 13-7-16.
//  Copyright (c) 2013年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_URLEncode)

- (NSString *)stringWithoutURLEncoding;
- (NSString *)stringWithURLEncoding;
- (NSData *) dataWithoutURLDecoding;
- (NSString *)toHexString;
@end
