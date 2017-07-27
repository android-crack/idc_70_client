#include "tss_sdk.h"
#include "QSDK.h"
#include "QTssSDK.h"
//#include "pthread.h"

// 不能实现send_data_to_svr函数
bool send_data_to_svr_ex(const struct TssSdkAntiDataInfo *anti_data)
{
    return false;
}

void send_sdk_data_to_svr_if_nessary()
{
    struct TssSdkAntiDataInfo *anti_data = (struct TssSdkAntiDataInfo *)
    tss_get_report_data();
    if (anti_data != NULL)
    {
        //TODO:（请参考SDK接入包中的接入教程：在 full\doc\客户端\接入指引\安全SDK接入目录 下）
        
        //将anti_data->anti_data_原封不动发送到游戏服务器，
        //再由游戏服务器将收到的数据转交给svr sdk
        
        //其中，anti_data->anti_data_的长度为anti_data->anti_data_len_
        //anti_data->anti_data_为二进制数据，不是字符串，会有以'\0'开头的数据
        
        NSUInteger length = (NSUInteger)anti_data->anti_data_len_;
        NSData* data = [NSData dataWithBytes:anti_data->anti_data_ length:length];
        NSString* base64String = [data base64EncodedStringWithOptions:0];
        // 强制在主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            QTssSDK::getInstance()->callback(0, [base64String UTF8String]);
        });
        tss_del_report_data(anti_data);
    }
}

double tv2d(const struct timeval *tv)
{
    return tv->tv_sec + (double)tv->tv_usec / 1000000L;
}

int need_get_data(struct timeval *t1, struct timeval *t2)
{
    double d1 = tv2d(t1);
    double d2 = tv2d(t2);
    return d2 - d1 >= 3;
}

/*
//可以实现函数send_data_to_svr
bool send_data_to_svr(const struct TssSdkAntiDataInfo *anti_data)
{
    if (anti_data != NULL)
    {
        //TODO:
        
        //将anti_data->anti_data_原封不动发送到游戏服务器，
        //再由游戏服务器将收到的数据转交给svr sdk
        
        //其中，anti_data->anti_data_的长度为anti_data->anti_data_len_
        //anti_data->anti_data_为二进制数据，不是字符串，会有以'\0'开头的数据
        
        //注意：该函数必须保证线程安全，SDK将在不同的子线程中调用该函数
    }
    return true;
}
*/

void* send_data_thread(void* param)
{
    struct timespec sp;
    sp.tv_sec = 0;
    sp.tv_nsec = 1000000;
    
    struct timeval t3 = {0};
    struct timeval t4 = {0};
    
    while (1)
    {
        nanosleep(&sp, NULL);
        
        gettimeofday(&t4, NULL);
        if (need_get_data(&t3, &t4))
        {
            t3.tv_sec = t4.tv_sec;
            t3.tv_usec = t4.tv_usec;
            
            send_sdk_data_to_svr_if_nessary();
        }
        
    }
    //return NULL;
}

void onQQLogin(const char* open_id, int world_id, const char* uid)
{
    struct TssSdkUserInfoEx info = {0};
    info.size_ = sizeof(info);
    
    info.entry_id_ = ENTRY_ID_QZONE;
    
    info.app_id_.type_ = APP_ID_TYPE_STR;
    const char* app_id = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"QQAppID"] UTF8String];
    strncpy(info.app_id_.app_id_str_, app_id, sizeof(info.app_id_.app_id_str_));
    
    
    info.uin_.type_ = UIN_TYPE_STR;
    strncpy(info.uin_.uin_str_, open_id, sizeof(info.uin_.uin_str_));
    
    info.world_id_ = world_id;
    strcpy(info.role_id_, uid);
    
    tss_sdk_setuserinfo_ex(&info);
}

void onWeChatLogin(const char* open_id, int world_id, const char* uid)
{
    struct TssSdkUserInfoEx info = {0};
    info.size_ = sizeof(info);
    
    info.entry_id_ = ENTRY_ID_MM;
    
    info.app_id_.type_ = APP_ID_TYPE_STR;
    //replace with your own wechat app id
    const char* app_id = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"WXAppID"] UTF8String];
    strncpy(info.app_id_.app_id_str_, app_id, sizeof(info.app_id_.app_id_str_));
    
    info.uin_.type_ = UIN_TYPE_STR;
    strncpy(info.uin_.uin_str_, open_id, sizeof(info.uin_.uin_str_));
    
    info.world_id_ = world_id;
    strcpy(info.role_id_, uid);
    
    tss_sdk_setuserinfo_ex(&info);
}

void QTssSDK::initTssSdk()
{
    struct TssSdkInitInfo info = {0};
    info.game_id_ = 2611;
    info.size_ = sizeof(info);

    info.send_data_to_svr_ = NULL;
    pthread_t tid;
    // 不能实现send_data_to_svr函数，需要启动一个线程定时发送数据
    pthread_create(&tid, NULL, send_data_thread, NULL);
    tss_sdk_init(&info);
}

void QTssSDK::setUserInfo(int platform, const char* open_id, int world_id, const char* uid)
{
    if(platform == PLATFORM_QQ)
    {
        onQQLogin(open_id, world_id, uid);
    }
    else if(platform == PLATFORM_WEIXIN)
    {
        onWeChatLogin(open_id, world_id, uid);
    }
}

void QTssSDK::setGameStatusFrontground()
{
    struct TssSdkGameStatusInfo info = {0};
    info.size_ = sizeof(info);
    info.game_status_ = GAME_STATUS_FRONTEND;
    tss_sdk_setgamestatus(&info);
}

void QTssSDK::setGameStatusBackground()
{
    struct TssSdkGameStatusInfo info = {0};
    info.size_ = sizeof(info);
    info.game_status_ = GAME_STATUS_BACKEND;
    tss_sdk_setgamestatus(&info);
}

void QTssSDK::send_server_data(const char *data)
{
    NSString* base64String = [NSString stringWithUTF8String:data];
    NSData* byteNSData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSUInteger size = [byteNSData length] / sizeof(unsigned char);
    unsigned char* byteData = (unsigned char*)[byteNSData bytes];
    struct TssSdkAntiDataInfo info = {0};
    info.anti_data_ = byteData;
    info.anti_data_len_ = (unsigned short)size;
    tss_sdk_rcv_anti_data(&info);
}

