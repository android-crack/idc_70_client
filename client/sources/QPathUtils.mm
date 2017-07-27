//
//  Q2Utils.m
//  zlsg
//
//  Created by xuchdong on 14-9-5.
//
//

#import "QPathUtils.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation QPathUtils

+ (NSString *)getADID:(NSString *)dict
{
    NSString *aid = @"";
    if( [[UIDevice currentDevice].systemVersion doubleValue] >=6.0f ){
        aid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return aid;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSDictionary *)dict
{
    NSURL* URL = [NSURL fileURLWithPath:[dict objectForKey:@"filepath"]];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
