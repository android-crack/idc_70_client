#include <jni.h>
#include "com_tencent_msdk_api_WGGroupObserverForSO.h"
#include "CommonFiles/WGPlatform.h"
#include "CommonFiles/WGCommon.h"

#include <android/log.h>

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnQueryGroupInfoNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnQueryGroupInfoNotify
  (JNIEnv *env, jclass, jobject jGroupRet){
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnQueryGroupInfoNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(platform, "platform", jGroupRetClz, jGroupRet, cGroupRet);
	 if(cGroupRet.platform == ePlatform_QQ){
		 //QQGroupInfo 对象
		 QQGroupInfo tempQQGroupInfo;
		 jclass jQQGroupInfoClass = env->FindClass("com/tencent/msdk/qq/group/QQGroupInfo");
		 jmethodID jQQGroupInfoInitMethod = env->GetMethodID(jQQGroupInfoClass, "<init>", "()V");
		 jmethodID jGetQQGroupInfoMethod = env->GetMethodID(jGroupRetClz, "getQQGroupInfo", "()Lcom/tencent/msdk/qq/group/QQGroupInfo;");
		 //jobject jQQGroupInfoObj = env->NewObject(jQQGroupInfoClass, jQQGroupInfoInitMethod);
		 jobject jQQGroupInfoObj = env->CallObjectMethod(jGroupRet,jGetQQGroupInfoMethod);
		 JniGetAndSetStringField(groupName,"groupName",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(fingerMemo,"fingerMemo",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(memberNum,"memberNum",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(maxNum,"maxNum",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(ownerOpenid,"ownerOpenid",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(unionid,"unionid",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(zoneid,"zoneid",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(adminOpenids,"adminOpenids",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(groupOpenid,"groupOpenid",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 JniGetAndSetStringField(groupKey,"groupKey",jQQGroupInfoClass, jQQGroupInfoObj,tempQQGroupInfo);
		 cGroupRet.mQQGroupInfo = tempQQGroupInfo;
		 env->DeleteLocalRef(jQQGroupInfoClass);
		 env->DeleteLocalRef(jQQGroupInfoObj);
	 }else{
		 //WXGroupInfo 对象
		 WXGroupInfo tempWXGroupInfo;
		 jclass jWXGroupInfoClass = env->FindClass("com/tencent/msdk/weixin/group/WXGroupInfo");
		 jmethodID jWXGroupInfoInitMethod = env->GetMethodID(jWXGroupInfoClass, "<init>", "()V");
		 jmethodID jGetWXGroupInfoMethod = env->GetMethodID(jGroupRetClz, "getWXGroupInfo", "()Lcom/tencent/msdk/weixin/group/WXGroupInfo;");
		 //jobject jWXGroupInfoObj = env->NewObject(jWXGroupInfoClass, jWXGroupInfoInitMethod);
		 jobject jWXGroupInfoObj = env->CallObjectMethod(jGroupRet,jGetWXGroupInfoMethod);
		 JniGetAndSetStringField(openIdList,"openIdList",jWXGroupInfoClass, jWXGroupInfoObj,tempWXGroupInfo);
		 JniGetAndSetStringField(memberNum,"memberNum",jWXGroupInfoClass, jWXGroupInfoObj,tempWXGroupInfo);
		 JniGetAndSetStringField(chatRoomURL,"chatRoomURL",jWXGroupInfoClass, jWXGroupInfoObj,tempWXGroupInfo);
		 cGroupRet.mWXGroupInfo = tempWXGroupInfo;
		 env->DeleteLocalRef(jWXGroupInfoClass);
		 env->DeleteLocalRef(jWXGroupInfoObj);
	 }

	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnQueryGroupInfoNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);


	 LOGD("Java_com_tencent_msdk_api_WGQQGroupObserverForSO_OnQueryGroupInfoNotify end%s", "");

		////ON_FUNC_OUT(__func__);
}

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnBindGroupNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnBindGroupNotify
(JNIEnv *env, jclass, jobject jGroupRet){

	LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnBindGroupNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);

	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnBindGroupNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnBindGroupNotify end%s", "");

		//ON_FUNC_OUT(__func__);
}

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnUnbindGroupNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnUnbindGroupNotify
(JNIEnv *env, jclass, jobject jGroupRet){
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnUnbindGroupNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);

	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnUnbindGroupNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnUnbindGroupNotify end%s", "");

		//ON_FUNC_OUT(__func__);
}

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnQueryQQGroupKeyNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnQueryQQGroupKeyNotify
(JNIEnv *env, jclass, jobject jGroupRet){
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnQueryQQGroupKeyNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);
	 //QQGroupInfo 对象
	 QQGroupInfo tempGroupInfo;
	 jclass jQQGroupInfoClass = env->FindClass("com/tencent/msdk/qq/group/QQGroupInfo");
	 jmethodID jQQGroupInfoInitMethod = env->GetMethodID(jQQGroupInfoClass, "<init>", "()V");
	 jmethodID jGetGroupInfoMethod = env->GetMethodID(jGroupRetClz, "getQQGroupInfo", "()Lcom/tencent/msdk/qq/group/QQGroupInfo;");
	 //jobject jQQGroupInfoObj = env->NewObject(jQQGroupInfoClass, jQQGroupInfoInitMethod);
	 jobject jQQGroupInfoObj = env->CallObjectMethod(jGroupRet,jGetGroupInfoMethod);
	 JniGetAndSetStringField(groupOpenid,"groupOpenid",jQQGroupInfoClass, jQQGroupInfoObj,tempGroupInfo);
	 JniGetAndSetStringField(groupKey,"groupKey",jQQGroupInfoClass, jQQGroupInfoObj,tempGroupInfo);
	 cGroupRet.mQQGroupInfo = tempGroupInfo;
	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnQueryGroupKeyNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);
	 env->DeleteLocalRef(jQQGroupInfoClass);
	 env->DeleteLocalRef(jQQGroupInfoObj);
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnQueryQQGroupKeyNotify end%s", "");

		//ON_FUNC_OUT(__func__);
}

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnJoinWXGroupNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnJoinWXGroupNotify
(JNIEnv *env, jclass, jobject jGroupRet){
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnJoinWXGroupNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);

	 //WXGroupInfo 对象
	 WXGroupInfo tempGroupInfo;
	 jclass jWXGroupInfoClass = env->FindClass("com/tencent/msdk/weixin/group/WXGroupInfo");
	 jmethodID jWXGroupInfoInitMethod = env->GetMethodID(jWXGroupInfoClass, "<init>", "()V");
	 jmethodID jGetGroupInfoMethod = env->GetMethodID(jGroupRetClz, "getWXGroupInfo", "()Lcom/tencent/msdk/weixin/group/WXGroupInfo;");
	 //jobject jWXGroupInfoObj = env->NewObject(jWXGroupInfoClass, jWXGroupInfoInitMethod);
	 jobject jWXGroupInfoObj = env->CallObjectMethod(jGroupRet,jGetGroupInfoMethod);
	 JniGetAndSetStringField(openIdList,"openIdList",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 JniGetAndSetStringField(memberNum,"memberNum",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 JniGetAndSetStringField(chatRoomURL,"chatRoomURL",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 cGroupRet.mWXGroupInfo = tempGroupInfo;
	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnJoinWXGroupNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);
	 env->DeleteLocalRef(jWXGroupInfoClass);
	 env->DeleteLocalRef(jWXGroupInfoObj);
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnJoinWXGroupNotify end%s", "");

		//ON_FUNC_OUT(__func__);
}

/*
 * Class:     com_tencent_msdk_api_WGGroupObserverForSO
 * Method:    OnCreateWXGroupNotify
 * Signature: (Lcom/tencent/msdk/api/GroupRet;)V
 */
JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGGroupObserverForSO_OnCreateWXGroupNotify
(JNIEnv *env, jclass, jobject jGroupRet){
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnCreateWXGroupNotify start%s", "");
	 jclass jGroupRetClz = env->GetObjectClass(jGroupRet);
	 GroupRet cGroupRet;

	 JniGetAndSetIntField(flag, "flag", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetIntField(errorCode, "errorCode", jGroupRetClz, jGroupRet, cGroupRet);
	 JniGetAndSetStringField(desc, "desc", jGroupRetClz, jGroupRet, cGroupRet);

	 //WXGroupInfo 对象
	 WXGroupInfo tempGroupInfo;
	 jclass jWXGroupInfoClass = env->FindClass("com/tencent/msdk/weixin/group/WXGroupInfo");
	 jmethodID jWXGroupInfoInitMethod = env->GetMethodID(jWXGroupInfoClass, "<init>", "()V");
	 jmethodID jGetGroupInfoMethod = env->GetMethodID(jGroupRetClz, "getWXGroupInfo", "()Lcom/tencent/msdk/weixin/group/WXGroupInfo;");
	 //jobject jWXGroupInfoObj = env->NewObject(jWXGroupInfoClass, jWXGroupInfoInitMethod);
	 jobject jWXGroupInfoObj = env->CallObjectMethod(jGroupRet,jGetGroupInfoMethod);
	 JniGetAndSetStringField(openIdList,"openIdList",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 JniGetAndSetStringField(memberNum,"memberNum",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 JniGetAndSetStringField(chatRoomURL,"chatRoomURL",jWXGroupInfoClass, jWXGroupInfoObj,tempGroupInfo);
	 cGroupRet.mWXGroupInfo = tempGroupInfo;
	 if (WGPlatform::GetInstance()->GetGroupObserver() != NULL) {
		 WGPlatform::GetInstance()->GetGroupObserver()->OnCreateWXGroupNotify(cGroupRet);
	 }
	 env->DeleteLocalRef(jGroupRetClz);
	 env->DeleteLocalRef(jWXGroupInfoClass);
	 env->DeleteLocalRef(jWXGroupInfoObj);
	 LOGD("Java_com_tencent_msdk_api_WGGroupObserverForSO_OnCreateWXGroupNotify end%s", "");

		//ON_FUNC_OUT(__func__);
}
