#include <jni.h>
#include "com_tencent_msdk_api_WGADObserverForSO.h"
#include "CommonFiles/WGPlatform.h"
#include "CommonFiles/WGCommon.h"

#include <android/log.h>

/*
 * Class:     com_tencent_msdk_api_WGADObserverForSO
 * Method:    OnADNotify
 * Signature: (Lcom/tencent/msdk/api/ADRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGADObserverForSO_OnADNotify
	(JNIEnv *env, jclass, jobject jADRet) {
	 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADNotify start%s", "");
		 jclass jADRetClz = env->GetObjectClass(jADRet);
		 ADRet cADRet;

		 JniGetAndSetStringField(viewTag, "viewTag", jADRetClz, jADRet,
				cADRet);
		 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADNotify viewTag:%s", cADRet.viewTag.c_str());

		 jfieldID jSceneFieldId = env->GetFieldID(jADRetClz, "scene", "Lcom/tencent/msdk/api/eADType;");
		 jobject jSceneObject = env->GetObjectField(jADRet, jSceneFieldId);

		 jclass jEnumSceneClass = env->GetObjectClass(jSceneObject);
		 jmethodID mEnumSceneID = env->GetMethodID(jEnumSceneClass, "val", "()I");
		 jint jscene = env->CallIntMethod(jSceneObject, mEnumSceneID);

		 int scene = (int) jscene;
		 cADRet.scene = (eADType)scene;
		 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADNotify scene:%d", scene);

		 if (WGPlatform::GetInstance()->GetADObserver() != NULL) {
			 WGPlatform::GetInstance()->GetADObserver()->OnADNotify(cADRet);
		 }
		 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADNotify end%s", "");
}

/*
 * Class:     com_tencent_msdk_api_WGADObserverForSO
 * Method:    OnADBackPressedNotify
 * Signature: (Lcom/tencent/msdk/api/ADRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGADObserverForSO_OnADBackPressedNotify
  (JNIEnv *env, jclass, jobject jADRet){
	 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADBackPressedNotify start%s", "");
	 jclass jADRetClz = env->GetObjectClass(jADRet);
	 ADRet cADRet;

	 JniGetAndSetStringField(viewTag, "viewTag", jADRetClz, jADRet,
			cADRet);
	 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADBackPressedNotify viewTag:%s", cADRet.viewTag.c_str());

	 jfieldID jSceneFieldId = env->GetFieldID(jADRetClz, "scene", "Lcom/tencent/msdk/api/eADType;");
	 jobject jSceneObject = env->GetObjectField(jADRet, jSceneFieldId);

	 jclass jEnumSceneClass = env->GetObjectClass(jSceneObject);
	 jmethodID mEnumSceneID = env->GetMethodID(jEnumSceneClass, "val", "()I");
	 jint jscene = env->CallIntMethod(jSceneObject, mEnumSceneID);

	 int scene = (int) jscene;
	 cADRet.scene = (eADType)scene;
	 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADBackPressedNotify scene:%d", scene);

#ifdef ANDROID
	 if (WGPlatform::GetInstance()->GetADObserver() != NULL) {
		 WGPlatform::GetInstance()->GetADObserver()->OnADBackPressedNotify(cADRet);
	 }
#endif
	 LOGD("Java_com_tencent_msdk_api_WGADObserverForSO_OnADBackPressedNotify end%s", "");
}
