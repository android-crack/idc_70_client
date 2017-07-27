#include <jni.h>
#include <android/log.h>
#include "QVideoPlayer.h"

using namespace cocos2d;

extern "C" {
	JNIEXPORT void JNICALL Java_com_qtz_dhh_VedioActivity_nativeOnCompletion(JNIEnv* env, jobject thiz){
		QVideoPlayer::sharedQVideoPlayer()->onCompletion();		
	}
}
