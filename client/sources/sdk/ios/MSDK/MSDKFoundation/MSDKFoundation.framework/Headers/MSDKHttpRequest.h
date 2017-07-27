//
//  MSDKHttpRequest.h
//  MSDKFoundation
//
//  Created by Jason on 14/11/17.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "MSDKStructs.h"
typedef void(^RespondSuccessCallback)(NSDictionary * respondDict);
typedef void(^RespondFailedCallback)(NSError * error, NSDictionary * respondDict);

@interface MSDKHttpRequest:ASIHTTPRequest<ASIHTTPRequestDelegate>

@property (nonatomic,strong) RespondSuccessCallback respondSuccessCallback;
@property (nonatomic,strong) RespondFailedCallback respondFailedCallback;

+(instancetype)GetRequestWithPlatform:(ePlatform)platform Action:(NSString *)action cmd:(NSInteger)cmd;

-(void)sendRequestWithLocalParameters:(NSArray *)localParametersArray localParametersProvider:(id)provider inputPerameters:(NSDictionary *)inputDict successCallback:(RespondSuccessCallback)successCallback failedCallback:(RespondFailedCallback)failedCallback;

+(NSString *)getCommonUrlStringByUrl:(NSString *)urlStr
                            platform:(int)nPlatform
                           algorithm:(NSString *)algoVersion
                               appId:(NSString *)appID
                              appKey:(NSString *)appKey;

- (void)send:(NSDictionary *)requestDict;
@end
