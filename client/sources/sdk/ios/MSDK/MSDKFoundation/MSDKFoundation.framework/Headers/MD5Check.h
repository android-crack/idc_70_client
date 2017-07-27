//
//  MD5Check.h
//  WGPlatform
//
//  Created by doufeifei on 14-6-11.
//  Copyright (c) 2014年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Check : NSObject
+ (NSString*)getFileMD5WithPath:(NSString*)path;
@end
