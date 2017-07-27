//
//  NSString+Regex.h
//  QQLiveHD
//
//  Created by thomasliu on 12-5-18.
//  Copyright 2012 Tencent Inc. All rights reserved.
//

/**
 * NSString在正则表达式上的扩展
 */
@interface NSString(Regex)

/**
 * 用正则表达式匹配字符串
 *
 * @return 若匹配成功则返回YES
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern;

/**
 * 用正则表达式匹配字符串
 *
 * @return 若匹配成功则返回第一个找到的string
 */
- (NSString *)stringByRegex:(NSString *)pattern;

/**
 * 用正则表达式匹配字符串
 *
 * @return 若匹配成功则返回找到的字符串数组
 */
- (NSArray *)stringListByRegex:(NSString *)pattern;

/**
 * 用正则表达式替换字符串
 *
 * @param templateString 要替换成的字符串模板，形如 \1abc\2
 *
 * @return 返回替换后的新字符串
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templateString;

@end
