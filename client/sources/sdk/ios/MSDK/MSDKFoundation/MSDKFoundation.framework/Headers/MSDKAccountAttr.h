//
//  MSDKAccountAttr.h
//  MSDK
//
//  Created by fu chunhui on 15/5/21.
//  Copyright (c) 2015年 HaywoodFu. All rights reserved.
//

#import <MSDKFoundation/MSDKFoundation.h>

@interface MSDKAccountAttr : MSDKDBHelper

//注册渠道信息相关
- (void)saveRegChannel:(NSString *)rId openId:(NSString *)openId;
- (NSString *)getRegChannel:(NSString *)openId ;
@end
