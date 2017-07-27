//
//  MSDKServiceObject.h
//  MSDKFoundation
//  各模块间声明Service的描述对象，
//  Created by fu chunhui on 14-11-7.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMsdkServiceResultList @"result"
#define kMsdkServiceError @"error"

typedef void (^MSDKServiceBlock)(NSDictionary *param);

@protocol MSDKServiceDelegate <NSObject>

@optional
//- (void)serviceDidStarted;
//- (void)serviceSuccess:(NSArray *)result;
//- (void)serviceFailed:()
@end

@interface MSDKServiceObject : NSObject

// service identifier
@property (nonatomic, strong)NSString *serviceID;
@property (nonatomic, assign) id<MSDKServiceDelegate>delegate;
@property (nonatomic, strong) MSDKServiceBlock sBlock;
@property (nonatomic, strong) MSDKServiceBlock fBlock;

- (void)callServiceBySucc:(MSDKServiceBlock)succBlock fail:(MSDKServiceBlock)failBlock params:(id)params,...;
- (BOOL)checkParams:(NSArray *)args;
- (BOOL)service;

@end
