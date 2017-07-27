//
//  IATViewController.h
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-28.
//
//

#import "QMSCSdkBridge.h"
#include "QMSCSDK.h"

typedef struct Wavehead
{
    /****RIFF WAVE CHUNK*/
    unsigned char a[4];     //四个字节存放'R','I','F','F'
    long int b;             //整个文件的长度-8;每个Chunk的size字段，都是表示除了本Chunk的ID和SIZE字段外的长度;
    unsigned char c[4];     //四个字节存放'W','A','V','E'
    /****RIFF WAVE CHUNK*/
    /****Format CHUNK*/
    unsigned char d[4];     //四个字节存放'f','m','t',''
    long int e;             //16后没有附加消息，18后有附加消息；一般为16，其他格式转来的话为18
    short int f;            //编码方式，一般为0x0001;
    short int g;            //声道数目，1单声道，2双声道;
    int h;                  //采样频率;
    unsigned int i;         //每秒所需字节数;
    short int j;            //每个采样需要多少字节，若声道是双，则两个一起考虑;
    short int k;            //即量化位数
    /****Format CHUNK*/
    /***Data Chunk**/
    unsigned char p[4];     //四个字节存放'd','a','t','a'
    long int q;             //语音数据部分长度，不包括文件头的任何部分
} WaveHead;//定义WAVE文件的文件头结构体


@interface QMSCSdkBridge()

@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) NSMutableData *pcmData;
@property (nonatomic,strong) NSTimer *timer;

@end

static QMSCSdkBridge *sharedQMSCSDKBridge = nil;

@implementation QMSCSdkBridge

+(QMSCSdkBridge *)GetInstance
{
    if (sharedQMSCSDKBridge == nil)
    {
        sharedQMSCSDKBridge = [[QMSCSdkBridge alloc] init];
    }
    return sharedQMSCSDKBridge;
}

#pragma mark - 视图生命周期
-(void)initBridge
{
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"58526b22"];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    [self initRecognizer];
    
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //设置听写模式
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
    //设置最长录音时间
    [_iFlySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //设置后端点
    [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
    //设置前端点
    [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
    //网络等待时间
    [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
    //设置采样率，推荐使用16K
    [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
    //设置语言
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant LANGUAGE_CHINESE] forKey:[IFlySpeechConstant LANGUAGE]];
    //设置方言
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant ACCENT_MANDARIN] forKey:[IFlySpeechConstant ACCENT]];
        //            }else if ([instance.language isEqualToString:[IATConfig english]]) {
        //                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //            }
        //设置是否返回标点符号
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant ASR_PTT_NODOT] forKey:[IFlySpeechConstant ASR_PTT]];
        
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant TYPE_CLOUD] forKey:[IFlySpeechConstant ENGINE_TYPE]];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
}

/**
 启动听写
 *****/
- (void)startRecogn {
    
    NSLog(@"%s[IN]",__func__);
    self.isCanceled = NO;
    _speech_text = @"";
    
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer startListening];
}

/**
 停止录音
 *****/
- (void)stopRecogn {
    
    NSLog(@"%s",__func__);
    [_iFlySpeechRecognizer stopListening];
}

/**
 取消听写
 *****/
- (void)cancelRecogn {
    
    NSLog(@"%s",__func__);
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
}


/**
 解析听写json格式的数据
 params例如：
 {"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"w":"白日","sc":0}]},{"bg":0,"cw":[{"w":"依山","sc":0}]},{"bg":0,"cw":[{"w":"尽","sc":0}]},{"bg":0,"cw":[{"w":"黄河入海流","sc":0}]},{"bg":0,"cw":[{"w":"。","sc":0}]}]}
 ****/
- (NSString *)stringFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //返回的格式必须为utf8的,否则发生未知错误
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        return;
    }
//    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
}



/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    QMSCSDK::getInstance()->recognStartHandler("OK");
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    NSString *text ;
        
    if (self.isCanceled) {
        text = @"识别取消";
            
    } else if (error.errorCode == 0 ) {
        if (_result.length == 0) {
            text = @"无识别结果";
        }else {
            text = @"识别成功";
            //清空识别结果
            //_result = nil;
        }
    }else {
        text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
        QMSCSDK::getInstance()->recognErrorHandler([text UTF8String]);
    }
    NSLog(@"%@",text);
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result = [[NSString stringWithFormat:@"%@%@", _speech_text, resultString] retain];
    NSString * resultFromJson =  [self stringFromJson:resultString];
    _speech_text = [[NSString stringWithFormat:@"%@%@", _speech_text, resultFromJson] retain];
    
    if (isLast){
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        NSString* dataFilePath = [NSString stringWithFormat:@"%@/%@",cachesDir,@"iat.pcm"];
        
        NSFileManager* fm=[NSFileManager defaultManager];
        if([fm fileExistsAtPath:dataFilePath]){
            //读取某个文件
            NSData *voiceData = [fm contentsAtPath:dataFilePath];
            UInt32 length = (UInt32)[voiceData length];
            NSData* encodeData = EncodePCMToRawSpeex((char*)[voiceData bytes], length, 1, 16);
            
            const char* base64Char = (const char*) [encodeData bytes];
            NSLog(@"base64Char(json)：%s",  base64Char);
            int inputLength = [encodeData length];
            QMSCSDK::getInstance()->recognVoiceBack(base64Char, inputLength);
        }
        NSLog(@"听写结果(json)：%@测试",  _speech_text);
        QMSCSDK::getInstance()->recognTextFinishHandler([_speech_text UTF8String]);
        QMSCSDK::getInstance()->recognFinishHandler("end");
    }
    //NSLog(@"isLast=%d,_textView.text=%@",isLast,_speech_text);
}


/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}
//////////////////////////////////////////////////////////////

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    
}

/**
 *  回调音频的错误码
 *
 *  @param recoder 录音器
 *  @param error   错误码
 */
- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}

/**
 *  回调录音音量
 *
 *  @param power 音量值
 */
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    
}

///////////////////////播放语音///////////////////////////////////


-(void)initWithData:(NSData *)data sampleRate:(long)sample
{
    if (data == nil) {
        return;
    }

    [self writeWaveHead:data sampleRate:sample];
    NSLog(@"nihao");
}


/**
 *
 *  写wave音频头,写完回调 onAudioLoaded 函数
 *
 */
- (void)writeWaveHead:(NSData *)audioData sampleRate:(long)sampleRate{
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    self.pcmData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [self.pcmData appendData:audioData];
    
    NSError *err = nil;
    self.player = [[AVAudioPlayer alloc]initWithData:self.pcmData error:&err];
    if (err)
    {
        NSLog(@"%@",err.localizedDescription);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    
}

- (void)playVoice:(NSData*) data
{
    
    if (self.isPlaying)
    {
        NSLog(@"pcmPlayer isPlaying");
        return;
    }
    self.isPlaying = YES;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    char *buf = (char *)[data bytes];
    SpeexHeader *speexHeader = (SpeexHeader *)buf;
    int sampleRate = speexHeader->rate;
    NSData* decodeData = DecodeSpeexToWAVE(data);
    [self initWithData:decodeData sampleRate:16000];
    
    self.player.volume=1;
    if ([self.pcmData length] > 44)
    {
        self.player.meteringEnabled = YES;
        NSLog(@"音频持续时间是%f",self.player.duration);
        
        BOOL ret = [self.player play];
        NSLog(@"play ret=%d",ret);
    }
    else
    {
        self.isPlaying = NO;
        NSLog(@"音频数据为空");
    }
    
}

- (void)stopVoice
{
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.player stop];
        self.player.currentTime = 0;
    }
}


#pragma mark speechRecordDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"in pcmPlayer audioPlayerDidFinishPlaying");//
    
    self.isPlaying=NO;
    QMSCSDK::getInstance()->playFinishHandler();
}


//////////////////////////////////////////////////////////////////////

@end
