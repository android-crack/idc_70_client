#include "QShareSDK.h"
#ifdef QPLATFORM_MSDK
    #import "MSDK/MSDK.h"
#endif

void QShareSDK::share(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    switch(platform)
    {
#ifdef QPLATFORM_MSDK
        case kSharePlatform_WECHAT:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringMediaTagName = [dictExtInfo objectForKey:@"mediaTagName"];
            const char* mediaTagName = [stringMediaTagName UTF8String];
            NSString* stringMessageExt = [dictExtInfo objectForKey:@"messageExt"];
            const char* messageExt = [stringMessageExt UTF8String];
            WGPlatform* plat = WGPlatform::GetInstance();
            
            std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(imgURL);
            NSString* _imgURL = [NSString stringWithUTF8String:filepath.c_str()];
            NSData* data = [NSData dataWithContentsOfFile:_imgURL];
//            UIImage *image = [UIImage imageNamed:_imgURL];
//            NSData *data = UIImagePNGRepresentation(image);
            plat->WGSendToWeixin(
                (unsigned char *)title,
                (unsigned char *)desc,
                (unsigned char *)mediaTagName,
                (unsigned char*)[data bytes],
                (int)[data length],
                (unsigned char *)messageExt);
            break;
        }
        case kSharePlatform_QQ:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringScene = [dictExtInfo objectForKey:@"scene"];
            int scene = [stringScene intValue];
            WGPlatform* plat = WGPlatform::GetInstance();
            
            std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(imgURL);
            NSString* _imgURL = [NSString stringWithUTF8String:filepath.c_str()];
            NSData* data = [NSData dataWithContentsOfFile:_imgURL];
            plat->WGSendToQQ(
                eQQScene(scene),
                (unsigned char *)title,
                (unsigned char *)desc,
                (unsigned char *)url,
                (unsigned char *)[data bytes],
                (int)[data length]);
            break;
        }
#endif
        default:
            break;
    }
}

void QShareSDK::shareToFriend(ShareSDKPlatform platform, const char *uid, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    switch(platform)
    {
#ifdef QPLATFORM_MSDK
        case kSharePlatform_WECHAT:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringExtInfo = [dictExtInfo objectForKey:@"extInfo"];
            const char* _extInfo = [stringExtInfo UTF8String];
            NSString* stringMediaTagName = [dictExtInfo objectForKey:@"mediaTagName"];
            const char* mediaTagName = [stringMediaTagName UTF8String];
            NSString* stringExtMsdkInfo = [dictExtInfo objectForKey:@"extMsdkInfo"];
            const char* extMsdkInfo = [stringExtMsdkInfo UTF8String];
            WGPlatform* plat = WGPlatform::GetInstance();
            plat->WGSendToWXGameFriend(
                (unsigned char *)uid,
                (unsigned char *)title,
                (unsigned char *)desc,
                (unsigned char *)"",
                (unsigned char *)_extInfo,
                (unsigned char *)mediaTagName,
                (unsigned char *)extMsdkInfo);
            break;
        }
        case kSharePlatform_QQ:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringAct = [dictExtInfo objectForKey:@"act"];
            int act = [stringAct intValue];
            NSString* stringMediaTagName = [dictExtInfo objectForKey:@"mediaTagName"];
            const char* mediaTagName = [stringMediaTagName UTF8String];
            NSString* stringExtMsdkInfo = [dictExtInfo objectForKey:@"extMsdkInfo"];
            const char* extMsdkInfo = [stringExtMsdkInfo UTF8String];
            WGPlatform* plat = WGPlatform::GetInstance();
            plat->WGSendToQQGameFriend(
                act,
                (unsigned char *)uid,
                (unsigned char *)title,
                (unsigned char *)desc,
                (unsigned char *)url,
                (unsigned char *)imgURL,
                (unsigned char *)desc,
                (unsigned char *)mediaTagName,
                (unsigned char *)extMsdkInfo);
            break;
        }
#endif
        default:
            break;
    }
}


void QShareSDK::shareWithPhoto(ShareSDKPlatform platform, const char *imgURL, const char *extInfo)
{
    switch(platform)
    {
#ifdef QPLATFORM_MSDK
        case kSharePlatform_WECHAT:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringScene = [dictExtInfo objectForKey:@"scene"];
            int scene = [stringScene intValue];
            NSString* stringMediaTagName = [dictExtInfo objectForKey:@"mediaTagName"];
            const char* mediaTagName = [stringMediaTagName UTF8String];
            NSString* stringMessageExt = [dictExtInfo objectForKey:@"messageExt"];
            const char* messageExt = [stringMessageExt UTF8String];
            NSString* stringMessageAction = [dictExtInfo objectForKey:@"messageAction"];
            const char* messageAction = [stringMessageAction UTF8String];
            WGPlatform* plat = WGPlatform::GetInstance();
            
            std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(imgURL);
            NSString* _imgURL = [NSString stringWithUTF8String:filepath.c_str()];
            NSData* data = [NSData dataWithContentsOfFile:_imgURL];
            
            //UIImage *image = [UIImage imageNamed:_imgURL];
            //NSData *data = UIImagePNGRepresentation(image);
            plat->WGSendToWeixinWithPhoto(
                (eWechatScene)scene,
                (unsigned char *)mediaTagName,
                (unsigned char *)[data bytes],
                (int)[data length],
                (unsigned char *)messageExt,
                (unsigned char *)messageAction);
            break;
        }
        case kSharePlatform_QQ:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringScene = [dictExtInfo objectForKey:@"scene"];
            int scene = [stringScene intValue];
            
            std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(imgURL);
            NSString* _imgURL = [NSString stringWithUTF8String:filepath.c_str()];
            NSData* data = [NSData dataWithContentsOfFile:_imgURL];
            
            WGPlatform* plat = WGPlatform::GetInstance();
            plat->WGSendToQQWithPhoto(
                (eQQScene)scene,
                (unsigned char *)[data bytes],
                (int)[data length]);
            break;
        }
#endif
        default:
            break;
    }
}

void QShareSDK::shareWithUrl(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo)
{
    switch(platform)
    {
#ifdef QPLATFORM_MSDK
        case kSharePlatform_WECHAT:
        {
            NSString* nssExtInfo = [NSString stringWithUTF8String:extInfo];
            NSData* dataExtInfo = [nssExtInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dictExtInfo = [NSJSONSerialization JSONObjectWithData:dataExtInfo options:NSJSONReadingAllowFragments error:&error];
            NSString* stringScene = [dictExtInfo objectForKey:@"scene"];
            int scene = [stringScene intValue];
            NSString* stringMediaTagName = [dictExtInfo objectForKey:@"mediaTagName"];
            const char* mediaTagName = [stringMediaTagName UTF8String];
            NSString* stringMessageExt = [dictExtInfo objectForKey:@"messageExt"];
            const char* messageExt = [stringMessageExt UTF8String];
            WGPlatform* plat = WGPlatform::GetInstance();
            
            std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(imgURL);
            NSString* _imgURL = [NSString stringWithUTF8String:filepath.c_str()];
            NSData* data = [NSData dataWithContentsOfFile:_imgURL];

            plat->WGSendToWeixinWithUrl(
                (eWechatScene)scene,
                (unsigned char *)title,
                (unsigned char *)desc,
                (unsigned char *)url,
                (unsigned char *)mediaTagName,
                (unsigned char *)[data bytes],
                (int)[data length],
                (unsigned char *)messageExt);
            break;
        }
#endif
        default:
            break;
    }
}
