//
//  IATViewController.h
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-28.
//
//

#import <UIKit/UIKit.h>
#import "iflyMSC/iflyMSC.h"
#import "SpeexCodec.h"
#import <Foundation/Foundation.h>
#import<AVFoundation/AVFoundation.h>


@class IFlyDataUploader;
@class IFlySpeechRecognizer;
@class IFlyPcmRecorder;
/**
 语音听写demo
 使用该功能仅仅需要四步
 1.创建识别对象；
 2.设置识别参数；
 3.有选择的实现识别回调；
 4.启动识别
 */
@interface QMSCSdkBridge : NSObject<IFlySpeechRecognizerDelegate,IFlyPcmRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象

@property (nonatomic, strong) NSString *speech_text;

@property (nonatomic, strong) NSString * result;
@property (nonatomic, assign) BOOL isCanceled;

@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入
@property (nonatomic,assign) BOOL isStreamRec;//是否是音频流识别
@property (nonatomic,assign) BOOL isBeginOfSpeech;//是否返回BeginOfSpeech回调

+(QMSCSdkBridge *)GetInstance;
/**
 解析JSON数据
 ****/
- (NSString *)stringFromJson:(NSString*)params;

- (void)initBridge;
- (void)startRecogn;
- (void)stopRecogn;
- (void)cancelRecogn;


/**
 * 初始化播放器，并传入音频数据
 *
 * data   音频数据
 * sample 音频pcm文件采样率，支持8000和16000两种
 ****/
-(void)initWithData:(NSData *)data sampleRate:(long)sample;


/**
 开始播放
 ****/
- (void)playVoice:(NSData*) data;



/**
 停止播放
 ****/
- (void)stopVoice;




/**
 是否在播放状态
 ****/
@property (nonatomic,assign) BOOL isPlaying;

@end

