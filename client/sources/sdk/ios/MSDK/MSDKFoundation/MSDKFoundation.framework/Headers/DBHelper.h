//
//  DBHelper.h
//  WGFrameworkDemo
//
//  Created by fred on 13-8-1.
//  Copyright (c) 2013年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject
{
}



+ (DBHelper *)shareInstance;

- (id)initWithDBPath:(NSString*)databasePath;

- (BOOL)createTable: (NSDictionary *)schema;

- (BOOL)insert:(NSDictionary *)schema data:(NSDictionary *)data;

- (NSArray *)query:(NSString*)sql;
- (NSArray *)query: (NSString *)table target: (NSDictionary *)target condiction:(NSDictionary *)condiction order:(NSDictionary *)order;

- (BOOL)update:(NSDictionary *)schema newData:(NSDictionary *)data condiction:(NSDictionary *)condiction;

- (BOOL)delete:(NSString *)table condiction:(NSDictionary *)condiction;
- (BOOL)sqlUpdateOperation:(NSString *)sql arugments:(NSArray *)argument;

- (NSString *)tableSql:(NSString *)tableName;
@end