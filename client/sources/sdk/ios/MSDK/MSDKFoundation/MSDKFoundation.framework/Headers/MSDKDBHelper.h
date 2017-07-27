//
//  MSDKDBHelper.h
//  WGFrameworkDemo
//
//  Created by doufeifei on 13-10-15.
//  Copyright (c) 2013年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHelper.h"

@interface MSDKDBHelper : NSObject
@property (nonatomic, retain) DBHelper *dbHelper;
@property (nonatomic, retain) NSDictionary *schema;
@property (nonatomic, retain) NSString *tableName;
@property (nonatomic, retain) NSDictionary *structure;

+ (id)shareInstance;

- (NSArray *)query:(NSString*)sql;
- (NSArray *)query:(NSDictionary *)target condiction:(NSDictionary *)condiction order:(NSDictionary *)order;

- (BOOL)insert:(NSDictionary *)data;

- (BOOL)update:(NSDictionary *)data condiction:(NSDictionary *)condiction;

- (BOOL)deleteWith: (NSDictionary *)condiction;
- (BOOL)updateWith:(NSDictionary *)dictData;

/**
 * 数据迁移过程。
 * 适用于表字段没有增加或删除，只是字段类型变化情况下的迁移
 */
- (void)migrateTable;
@end
