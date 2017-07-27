//
//  BeaconLogInterface.h
//  Beacon
//
//  Created by tencent on 16/1/19.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "BeaconLogPublicDefines.h"

@interface BeaconLogInterface : NSObject

/**
 * 本地log上报
 */
// 设置applog上报时的userid, 方便查询 (可不设置, 如需设置请在上报前)
+ (void)setAppLogUserId:(NSString *)userId;
// 上报log
+ (void)doUploadAppLogRecords;
+ (void)doUploadAppLogRecordsWithResult:(void(^)(BOOL result, NSError *error))result;

// 记录log 非实时上报
+ (BOOL)onAppLogUploadAction:(NSString *)logInfo;
// 记录log isRealTime:是否实时上报
+ (BOOL)onAppLogUploadAction:(NSString *)logInfo isRealTime:(BOOL)isRealTime;
// 参数savePath已失效,此接口与上个接口一样
+ (BOOL)onAppLogUploadAction:(NSString *)logInfo isRealTime:(BOOL)isRealTime savePath:(NSString *)savePath;
//设置开启关闭log模块，默认开启
+ (void)setAppLogUploadUsable:(BOOL)enable;
// 设置log保存天数(单位:天, 默认7天)
+ (void)setAppLogMaxSaveDay:(int)maxSaveDay;
// 设置log文件数(单位:个, 默认50个)
+ (void)setAppLogMaxFileNum:(int)maxFileNum;
// 设置log单个文件大小(单位:K, 默认512K)
+ (void)setAppLogMaxFileSize:(int)maxFileSize;
// 设置log日上报流量(单位:M, 默认10M)
+ (void)setAppLogMaxDayFlow:(int)maxDayFlow;
// 设置app自定义日志文件总大小(单位:M, 默认20M)
+ (void)setAppLogFileTotalMaxSize:(int)maxSize;

/**
 * 设置AppLog存储目录
 * @param appLogDirPathType AppLog存储目录类型，默认为Cache目录
 */
+ (void)setAppLogDirPath:(AppLogDirPathType)appLogDirPathType;

@end
