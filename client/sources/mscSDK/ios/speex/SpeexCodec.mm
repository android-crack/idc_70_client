//
//  SpeexCodec.m
//  TEST_Speex_001
//
//  Created by cai xuejun on 12-9-4.
//  Copyright (c) 2012年 caixuejun. All rights reserved.
//

#import "SpeexCodec.h"

typedef unsigned long long u64;
typedef long long s64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;

u16 readUInt16(char* bis) {
    u16 result = 0;
    result += ((u16)(bis[0])) << 8;
    result += (u8)(bis[1]);
    return result;
}

u32 readUint32(char* bis) {
    u32 result = 0;
    result += ((u32) readUInt16(bis)) << 16;
    bis+=2;
    result += readUInt16(bis);
    return result;
}

s64 readSint64(char* bis) {
    s64 result = 0;
    result += ((u64) readUint32(bis)) << 32;
    bis+=4;
    result += readUint32(bis);
    return result;
}

static int _sampleRate = 16000;
static int _quality = 2;

@implementation SpeexCodec

void WriteWAVEHeader(NSMutableData* fpwave, int nFrame)
{
	char tag[10] = "";
	
	// 1. 写RIFF头
	RIFFHEADER riff;
	strcpy(tag, "RIFF");
	memcpy(riff.chRiffID, tag, 4);
	riff.nRiffSize = 4                                     // WAVE
	+ sizeof(XCHUNKHEADER)               // fmt
	+ sizeof(WAVEFORMATX)           // WAVEFORMATX
	+ sizeof(XCHUNKHEADER)               // DATA
	+ nFrame*160*sizeof(short);    //
	strcpy(tag, "WAVE");
	memcpy(riff.chRiffFormat, tag, 4);
	//fwrite(&riff, 1, sizeof(RIFFHEADER), fpwave);
    [fpwave appendBytes:&riff length:sizeof(RIFFHEADER)];
	
	// 2. 写FMT块
	XCHUNKHEADER chunk;
	WAVEFORMATX wfx;
	strcpy(tag, "fmt ");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = sizeof(WAVEFORMATX);
	//fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
	memset(&wfx, 0, sizeof(WAVEFORMATX));
	wfx.nFormatTag = 1;
	wfx.nChannels = 1; // 单声道
	wfx.nSamplesPerSec = 8000; // 8khz
	wfx.nAvgBytesPerSec = 16000;
	wfx.nBlockAlign = 2;
	wfx.nBitsPerSample = 16; // 16位
    //fwrite(&wfx, 1, sizeof(WAVEFORMATX), fpwave);
    [fpwave appendBytes:&wfx length:sizeof(WAVEFORMATX)];
	
	// 3. 写data块头
	strcpy(tag, "data");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = nFrame*160*sizeof(short);
	//fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
}

#pragma mark Encode
// 从WAVE文件读一个完整的PCM音频帧
// 返回值: 0-错误 >0: 完整帧大小
int ReadPCMFrameData(short speech[], char* fpwave, int nChannels, int nBitsPerSample)
{
	int nRead = 0;
	int x = 0, y=0;
	unsigned short ush1=0, ush2=0, ush=0;
	
	// 原始PCM音频帧数据
	unsigned char  pcmFrame_8b1[FRAME_SIZE];
	unsigned char  pcmFrame_8b2[FRAME_SIZE<<1];
	unsigned short pcmFrame_16b1[FRAME_SIZE];
	unsigned short pcmFrame_16b2[FRAME_SIZE<<1];
	
    nRead = (nBitsPerSample/8) * FRAME_SIZE*nChannels;
	if (nBitsPerSample==8 && nChannels==1)
    {
		//nRead = fread(pcmFrame_8b1, (nBitsPerSample/8), FRAME_SIZE*nChannels, fpwave);
        memcpy(pcmFrame_8b1,fpwave,nRead);
		for(x=0; x<FRAME_SIZE; x++)
        {
			speech[x] =(short)((short)pcmFrame_8b1[x] << 7);
        }
    }
	else
		if (nBitsPerSample==8 && nChannels==2)
        {
			//nRead = fread(pcmFrame_8b2, (nBitsPerSample/8), FRAME_SIZE*nChannels, fpwave);
            memcpy(pcmFrame_8b2,fpwave,nRead);
            
			for( x=0, y=0; y<FRAME_SIZE; y++,x+=2 )
            {
				// 1 - 取两个声道之左声道
				//speech[y] =(short)((short)pcmFrame_8b2[x+0] << 7);
				// 2 - 取两个声道之右声道
				//speech[y] =(short)((short)pcmFrame_8b2[x+1] << 7);
				// 3 - 取两个声道的平均值
				ush1 = (short)pcmFrame_8b2[x+0];
				ush2 = (short)pcmFrame_8b2[x+1];
				ush = (ush1 + ush2) >> 1;
				speech[y] = (short)((short)ush << 7);
            }
        }
		else
			if (nBitsPerSample==16 && nChannels==1)
            {
				//nRead = fread(pcmFrame_16b1, (nBitsPerSample/8), FRAME_SIZE*nChannels, fpwave);
                memcpy(pcmFrame_16b1,fpwave,nRead);
                
				for(x=0; x<FRAME_SIZE; x++)
                {
					speech[x] = (short)pcmFrame_16b1[x+0];
                }
            }
			else
				if (nBitsPerSample==16 && nChannels==2)
                {
					//nRead = fread(pcmFrame_16b2, (nBitsPerSample/8), FRAME_SIZE*nChannels, fpwave);
                    memcpy(pcmFrame_16b2,fpwave,nRead);
                    
					for( x=0, y=0; y<FRAME_SIZE; y++,x+=2 )
                    {
						//speech[y] = (short)pcmFrame_16b2[x+0];
						speech[y] = (short)((int)((int)pcmFrame_16b2[x+0] + (int)pcmFrame_16b2[x+1])) >> 1;
                    }
                }
	
	// 如果读到的数据不是一个完整的PCM帧, 就返回0
	return nRead;
}

struct CAFFileHeader {
    UInt32  mFileType;
    UInt16  mFileVersion;
    UInt16  mFileFlags;
};

struct CAFChunkHeader {
    UInt32  mChunkType;
    SInt64  mChunkSize;
};

//跳过CAF文件头
int SkipCaffHead(char* buf){
    
    if (!buf) {
        return 0;
    }
    char* oldBuf = buf;
    u32 mFileType = readUint32(buf);
    if (0x63616666 != mFileType) {
        return 0;
    }
    buf += 4;
    
    /*u16 mFileVersion = */readUInt16(buf);
    buf += 2;
    /*u16 mFileFlags = */readUInt16(buf);
    buf += 2;
    //    NSLog(@"fileVersion:%d,fileFlags:%d.",mFileVersion, mFileFlags);
    
    //desc free data
    u32 magics[3] = {0x64657363,0x66726565,0x64617461};
    for (int i=0; i<3; ++i) {
        u32 mChunkType = readUint32(buf);buf+=4;
        if (magics[i]!=mChunkType) {
            return 0;
        }
        
        u32 mChunkSize = readSint64(buf);buf+=8;
        if (mChunkSize<=0) {
            return 0;
        }
        if (i==2) {
            return buf-oldBuf;
        }
        buf += mChunkSize;
        
    }
    
    return 1;
}


NSData *EncodePCMToRawSpeex(char *PCMdata, int maxLen,int nChannels, int nBitsPerSample)
{
    char *oldBuf = PCMdata;
    short speech[FRAME_SIZE];
    int byte_counter, frames = 0, bytes = 0;
    
    float input[FRAME_SIZE];
    char speexFrame[MAX_NB_BYTES];

    int tmp = _quality;// bps?
    void *encode_state = speex_encoder_init(&speex_nb_mode);
    speex_encoder_ctl(encode_state, SPEEX_SET_QUALITY, &tmp);
    
    SpeexPreprocessState *preprocess_state = speex_preprocess_state_init(FRAME_SIZE, _sampleRate);
    
    int denoise = 1;
    int noiseSuppress = -25;
    speex_preprocess_ctl(preprocess_state, SPEEX_PREPROCESS_SET_DENOISE, &denoise);// 降噪
    speex_preprocess_ctl(preprocess_state, SPEEX_PREPROCESS_SET_NOISE_SUPPRESS, &noiseSuppress);// 噪音分贝数
    
    int agc = 1;
    float level = 32768;
    //actually default is 8000(0,32768),here make it louder for voice is not loudy enough by default.
    speex_preprocess_ctl(preprocess_state, SPEEX_PREPROCESS_SET_AGC, &agc);// 增益
    speex_preprocess_ctl(preprocess_state, SPEEX_PREPROCESS_SET_AGC_LEVEL, &level);// 增益后的值
    
    SpeexBits bits;
    speex_bits_init(&bits);
    NSMutableData *speexRawData = [[[NSMutableData alloc] init] autorelease];
    for (; ; ) {
        if ((PCMdata - oldBuf + sizeof(short)*FRAME_SIZE) > maxLen) {
            break;
        }
        
        int nRead = ReadPCMFrameData(speech, PCMdata, nChannels, nBitsPerSample);
        
        speex_preprocess_run(preprocess_state, speech); //对原始录入声音进行处理(降噪、增益等)
        
        for (int i = 0; i < FRAME_SIZE; i++) {
            input[i] = speech[i];
        }
        
        PCMdata += nRead;
        
		frames++;
        
        speex_bits_reset(&bits);
        speex_encode(encode_state, input, &bits);
        
        byte_counter = speex_bits_write(&bits, speexFrame, MAX_NB_BYTES);
        bytes += byte_counter;
        
        [speexRawData appendBytes:speexFrame length:byte_counter];
    }
    
    NSMutableData *speexData = [[[NSMutableData alloc] init] autorelease];
    SpeexHeader speexHeader;
    speex_init_header(&speexHeader, _sampleRate, 1, &speex_nb_mode);
    speexHeader.reserved1 = speex_bits_nbytes(&bits);
    [speexData appendBytes:&speexHeader length:speexHeader.header_size];
    [speexData appendData:speexRawData];
    
    speex_bits_destroy(&bits);
    speex_encoder_destroy(encode_state);
    speex_preprocess_state_destroy(preprocess_state);
    
    return speexData;
}

NSData *EncodeWAVEToSpeex(NSData *data, int nChannels, int nBitsPerSample)
{
    if (data == nil){
        NSLog(@"data is nil...");
        return nil;
    }
    
    int nPos  = 0;
    char *buf = (char *)[data bytes];
    int maxLen = [data length];
    
    
    nPos += SkipCaffHead(buf);
    if (nPos >= maxLen) {
        return nil;
    }
    
    //这时取出来的是纯pcm数据
    buf += nPos;
    
    NSData *speexData = EncodePCMToRawSpeex(buf, maxLen-nPos, nChannels, nBitsPerSample);
    return speexData;
}

NSData *DecodeSpeexToWAVE(NSData *data)
{
    if (data == nil){
        NSLog(@"data is nil...");
        return nil;
    }
    
    int nPos  = 0;
    char *buf = (char *)[data bytes];
    int maxLen = [data length];
    
    SpeexHeader *speexHeader = (SpeexHeader *)buf;
    int nbBytes = speexHeader->reserved1;
    
    nPos += sizeof(SpeexHeader);
    if (nPos >= maxLen) {
        return nil;
    }

    //这时取出来的是纯speex数据
    buf += nPos;
    //--------------------------------------
    
    char *oldBuf = (char *)[data bytes];
    int frames = 0;
    
    short pcmFrame[FRAME_SIZE];
    float output[FRAME_SIZE];
    
    int tmp = 1;
    void *dec_state = speex_decoder_init(&speex_nb_mode);
    speex_decoder_ctl(dec_state, SPEEX_SET_ENH,&tmp);
    
    NSMutableData *PCMRawData = [[[NSMutableData alloc] init] autorelease];
    
    SpeexBits bits;
    speex_bits_init(&bits);
    for (; ; ) {
        if ((buf - oldBuf + nbBytes) > maxLen) {
            break;
        }
        
        speex_bits_read_from(&bits, buf, nbBytes);
        speex_decode(dec_state, &bits, output);
        
        for (int i = 0; i < FRAME_SIZE; i++) {
            pcmFrame[i] = output[i];
        }
        
        [PCMRawData appendBytes:pcmFrame length:sizeof(short)*FRAME_SIZE];
    
        buf += nbBytes;
        frames++;
    }
    
    speex_bits_destroy(&bits);
    speex_decoder_destroy(dec_state);
    
    //不需要加上wave头
    //NSMutableData *outData = [[[NSMutableData alloc]init] autorelease];
	//WriteWAVEHeader(outData, frames);
    //[outData appendData:PCMRawData];
    
    return PCMRawData;
}

float CalculatePlayTime(NSData *speexData, int nbBytes)
{
    float play_time = 0.0;
    unsigned int speexHeaderLength = sizeof(SpeexHeader);
    unsigned int rawSpeexDataLength = [speexData length] - speexHeaderLength;
    play_time = (float)rawSpeexDataLength/(nbBytes*50); //每秒是50帧
    
    return play_time;
}

void SpeexSetSampleRate(int sampleRate)
{
    _sampleRate = sampleRate;
}

void SpeexSetQuality(int quality)
{
    _quality = quality;
}

@end
