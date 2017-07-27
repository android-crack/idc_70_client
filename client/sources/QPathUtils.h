//
//  Q2Utils.h
//  zlsg
//
//  Created by xuchdong on 14-9-5.
//
//

#import <Foundation/Foundation.h>

@interface QPathUtils : NSObject

+ (NSString *)getADID:(NSString *)dict;
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSDictionary *)dict;

@end
