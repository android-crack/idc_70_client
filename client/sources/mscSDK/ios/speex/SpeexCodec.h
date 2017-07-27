//
//  SpeexCodec.h
//  TEST_Speex_001
//
//  Created by cai xuejun on 12-9-4.
//  Copyright (c) 2012年 caixuejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ogg.h"
#import "os_types.h"
#import "speex.h"
#import "speex_bits.h"
#import "speex_buffer.h"
#import "speex_callbacks.h"
#import "speex_config_types.h"
#import "speex_echo.h"
#import "speex_header.h"
#import "speex_jitter.h"
#import "speex_preprocess.h"
#import "speex_stereo.h"
#import "speex_types.h"

#define FRAME_SIZE 160 // PCM音频8khz*20ms -> 8000*0.02=160
#define MAX_NB_BYTES 200
#define SPEEX_SAMPLE_RATE 8000 //暂时弃用，改为动态设置

typedef struct
{
	char chChunkID[4];
	int nChunkSize;
}XCHUNKHEADER;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
}WAVEFORMAT;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
	short nExSize;
}WAVEFORMATX;

typedef struct
{
	char chRiffID[4];
	int nRiffSize;
	char chRiffFormat[4];
}RIFFHEADER;

typedef struct
{
	char chFmtID[4];
	int nFmtSize;
	WAVEFORMAT wf;
}FMTBLOCK;

@interface SpeexCodec : NSObject

int EncodeWAVEFileToSpeexFile(const char* pchWAVEFilename, const char* pchAMRFileName, int nChannels, int nBitsPerSample);

int DecodeSpeexFileToWAVEFile(const char* pchAMRFileName, const char* pchWAVEFilename);

NSData* DecodeSpeexToWAVE(NSData* data);
NSData* EncodeWAVEToSpeex(NSData* data, int nChannels, int nBitsPerSample);
NSData *EncodePCMToRawSpeex(char *PCMdata, int maxLen,int nChannels, int nBitsPerSample);

// 根据帧头计算当前帧大小
float CalculatePlayTime(NSData *speexData, int frame_size);

void SpeexSetSampleRate(int sampleRate);
void SpeexSetQuality(int quality);

@end
