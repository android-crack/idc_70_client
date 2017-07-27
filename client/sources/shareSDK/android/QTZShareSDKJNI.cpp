#include "QTZShareSDKJNI.h"
#include "QShareSDK.h"

JNIEXPORT void JNICALL Java_com_qtz_utils_share_QTZShareSDK_onShareNotifyNative
  (JNIEnv *env, jobject jc, jint code, jstring msg)
{
	const char *locstr;
    locstr = env->GetStringUTFChars(msg, 0);
    std::string strMsg = locstr;
    env->ReleaseStringUTFChars(msg, locstr);
    QShareSDK::getInstance()->shareCallback(int(code),strMsg.c_str());
    return;
}
