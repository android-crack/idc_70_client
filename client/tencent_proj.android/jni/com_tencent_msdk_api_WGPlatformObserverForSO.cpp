#include "com_tencent_msdk_api_WGPlatformObserverForSO.h"
#include "CommonFiles/WGPlatform.h"
#include "CommonFiles/WGPlatformObserver.h"
#include "CommonFiles/WGCommon.h"

#include <android/log.h>

JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnLoginNotify(JNIEnv * env, jclass jc,
        jobject jLoginRet) {
    LOGD("OnLoginNotify start%s", "");
    LoginRet lr;
    jclass jLoginRetClass = env->GetObjectClass(jLoginRet);
    jboolean isCopy;
    JniGetAndSetIntField(flag, "flag", jLoginRetClass, jLoginRet, lr);
    JniGetAndSetStringField(desc, "desc", jLoginRetClass, jLoginRet, lr);
    JniGetAndSetIntField(platform, "platform", jLoginRetClass, jLoginRet, lr);
    JniGetAndSetStringField(open_id, "open_id", jLoginRetClass, jLoginRet, lr);

    jfieldID vctId = env->GetFieldID(jLoginRetClass, "token", "Ljava/util/Vector;");
    jobject tokenList = env->GetObjectField(jLoginRet, vctId);
    jclass tokenRetVectorClass = env->GetObjectClass(tokenList);

    jmethodID vectorSizeM = env->GetMethodID(tokenRetVectorClass, "size", "()I");
    jmethodID vectorGetM = env->GetMethodID(tokenRetVectorClass, "get", "(I)Ljava/lang/Object;");
    jint len = env->CallIntMethod(tokenList, vectorSizeM);

    LOGD( "Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnLoginNotify: tokenListSize: %d", len);
    for (int i = 0; i < len; i++) {
        TokenRet cToken;
        jobject jTokenRetObject = env->CallObjectMethod(tokenList, vectorGetM, i);
        jclass jTokenRetClass = env->GetObjectClass(jTokenRetObject);

        JniGetAndSetIntField(type, "type", jTokenRetClass, jTokenRetObject, cToken);
        JniGetAndSetStringField(value, "value", jTokenRetClass, jTokenRetObject, cToken);
        JniGetAndSetLongField(expiration, "expiration", jTokenRetClass, jTokenRetObject, cToken);

        LOGD( "WGPlatformObserverForSO_OnLoginNotify: type: %d", cToken.type);
        LOGD( "WGPlatformObserverForSO_OnLoginNotify: value: %s", cToken.value.c_str());
        LOGD( "WGPlatformObserverForSO_OnLoginNotify: expiration: %lld", cToken.expiration);

        lr.token.push_back(cToken);

        env->DeleteLocalRef(jTokenRetObject);
        env->DeleteLocalRef(jTokenRetClass);
    }

    JniGetAndSetStringField(user_id, "user_id", jLoginRetClass, jLoginRet, lr);
    JniGetAndSetStringField(pf, "pf", jLoginRetClass, jLoginRet, lr);
    JniGetAndSetStringField(pf_key, "pf_key", jLoginRetClass, jLoginRet, lr);

    if (WGPlatform::GetInstance()->GetObserver() != NULL) {
		LOGD("OnLoginNotify GetObserver()->OnLoginNotify start%s", "");
        WGPlatform::GetInstance()->GetObserver()->OnLoginNotify(lr);
        LOGD("OnLoginNotify GetObserver()->OnLoginNotify end%s", "");
    } else {
        WGPlatform::GetInstance()->setLoginRet(lr);
    }

    env->DeleteLocalRef(jLoginRetClass);
    env->DeleteLocalRef(jLoginRet);
    LOGD("OnLoginNotify end%s", "");
}

JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnShareNotify(JNIEnv *env, jclass jc,
        jobject jShareRetObject) {
    LOGD("OnShareNotify start%s", "");
    jclass jShareRetClass = env->GetObjectClass(jShareRetObject);
    ShareRet sr;
    jboolean isCopy;
    JniGetAndSetIntField(platform, "platform", jShareRetClass, jShareRetObject, sr);
    JniGetAndSetIntField(flag, "flag", jShareRetClass, jShareRetObject, sr);
    JniGetAndSetStringField(desc, "desc", jShareRetClass, jShareRetObject, sr);
    JniGetAndSetStringField(extInfo, "extInfo", jShareRetClass, jShareRetObject, sr);

    if (WGPlatform::GetInstance()->GetObserver()) {
        WGPlatform::GetInstance()->GetObserver()->OnShareNotify(sr);
    }

    env->DeleteLocalRef(jShareRetObject);
    env->DeleteLocalRef(jShareRetClass);
    LOGD("OnShareNotify end%s", "");
}

JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnWakeupNotify(JNIEnv *env, jclass jc,
        jobject jWakeupRetObject) {
    LOGD("OnWakeupNotify start%s", "");
    jclass jWakeupRetClass = env->GetObjectClass(jWakeupRetObject);
    WakeupRet wr;
    jboolean isCopy;
    JniGetAndSetIntField(flag, "flag", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetIntField(platform, "platform", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(open_id, "open_id", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(media_tag_name, "media_tag_name", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(desc, "desc", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(lang, "lang", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(country, "country", jWakeupRetClass, jWakeupRetObject, wr);
    JniGetAndSetStringField(messageExt, "messageExt", jWakeupRetClass, jWakeupRetObject, wr);

    jfieldID jVectorMethodId = env->GetFieldID(jWakeupRetClass, "extInfo", "Ljava/util/Vector;");
    jobject extInfoVector = env->GetObjectField(jWakeupRetObject, jVectorMethodId);
    jclass extInfoVectorClass = env->GetObjectClass(extInfoVector);

    jmethodID vectorSizeM = env->GetMethodID(extInfoVectorClass, "size", "()I");
    jmethodID vectorGetM = env->GetMethodID(extInfoVectorClass, "get", "(I)Ljava/lang/Object;");
    jint len = env->CallIntMethod(extInfoVector, vectorSizeM);


    LOGD( "Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnWakeupNotify: extInfoSize: %s", "");
	for (int i = 0; i < len; i++) {
		KVPair cKVPair;
		jobject jKVPair = env->CallObjectMethod(extInfoVector, vectorGetM, i);
		jclass jKVPairClass = env->GetObjectClass(jKVPair);

		JniGetAndSetStringField(key, "key", jKVPairClass, jKVPair, cKVPair);
		JniGetAndSetStringField(value, "value", jKVPairClass, jKVPair, cKVPair);

		LOGD( "Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnWakeupNotify: key: %s", cKVPair.key.c_str());
		LOGD( "Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnWakeupNotify: value: %s", cKVPair.value.c_str());

		wr.extInfo.push_back(cKVPair);

		env->DeleteLocalRef(jKVPair);
		env->DeleteLocalRef(jKVPairClass);
	}
	env->DeleteLocalRef(extInfoVector);
	env->DeleteLocalRef(extInfoVectorClass);


    if (WGPlatform::GetInstance()->GetObserver()) {
        WGPlatform::GetInstance()->GetObserver()->OnWakeupNotify(wr);
    } else {
        WGPlatform::GetInstance()->setWakeup(wr);
    }
    env->DeleteLocalRef(jWakeupRetObject);
    env->DeleteLocalRef(jWakeupRetClass);

    LOGD("OnWakeupNotify end%s", "");
}

/*
 * Class:     com_tencent_msdk_api_WGPlatformObserverForSO
 * Method:    OnRelationCallBack
 * Signature: (Lcom/tencent/msdk/remote/api/RelationRet;)V
 */JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnRelationNotify(JNIEnv * env, jclass,
		jobject jRelationRet) {
	jclass jRelationRetClz = env->GetObjectClass(jRelationRet);
	RelationRet cRelactionRet;
	jboolean iscopy;

	JniGetAndSetIntField(flag,"flag", jRelationRetClz, jRelationRet, cRelactionRet);
	JniGetAndSetStringField(desc, "desc", jRelationRetClz, jRelationRet, cRelactionRet);
	//
	jfieldID jPersonsField = env->GetFieldID(jRelationRetClz, "persons", "Ljava/util/Vector;");
	jobject jPersonList = env->GetObjectField(jRelationRet, jPersonsField);
	jclass jArrayListClz = env->GetObjectClass(jPersonList);

	jmethodID jArrayListSizeMethod = env->GetMethodID(jArrayListClz, "size", "()I");
	jmethodID jArrayListGetMethod = env->GetMethodID(jArrayListClz, "get", "(I)Ljava/lang/Object;");
	jint jLength = env->CallIntMethod(jPersonList, jArrayListSizeMethod);

	LOGD("Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnRelationCallBack: tokenListSize: %d", jLength);
	for (int i = 0; i < (int) jLength; i++) {
		PersonInfo person;
		jobject jPerson = env->CallObjectMethod(jPersonList, jArrayListGetMethod, i);
		jclass jPersonInfoClass = env->GetObjectClass(jPerson);
		LOGD("push_back: tokenListSize: %d", jLength);
		JniGetAndSetStringField(nickName, "nickName", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(openId, "openId", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(gender, "gender", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureSmall, "pictureSmall", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureMiddle, "pictureMiddle", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureLarge, "pictureLarge", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(provice, "province", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(city, "city", jPersonInfoClass, jPerson, person);
		JniGetAndSetBooleanField(isFriend, "isFriend", jPersonInfoClass, jPerson, person);
		JniGetAndSetFloatField(distance, "distance", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(lang, "lang", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(country, "country", jPersonInfoClass, jPerson, person);
		cRelactionRet.persons.push_back(person);
        env->DeleteLocalRef(jPerson);
        env->DeleteLocalRef(jPersonInfoClass);
    }

    if (WGPlatform::GetInstance()->GetObserver() != NULL) {
        WGPlatform::GetInstance()->GetObserver()->OnRelationNotify(cRelactionRet);
    }

    env->DeleteLocalRef(jRelationRetClz);
    env->DeleteLocalRef(jPersonList);
    env->DeleteLocalRef(jArrayListClz);
}

 /*
  * Class:     com_tencent_msdk_api_WGPlatformObserverForSO
  * Method:    OnLocationNotify
  * Signature: (Lcom/tencent/msdk/remote/api/RelationRet;)V
  */
 JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnLocationNotify
   (JNIEnv * env, jclass, jobject jRelationRet) {
	jclass jRelationRetClz = env->GetObjectClass(jRelationRet);
	RelationRet cRelactionRet;
	jboolean iscopy;

	JniGetAndSetIntField(flag, "flag", jRelationRetClz, jRelationRet,
			cRelactionRet);
	JniGetAndSetStringField(desc, "desc", jRelationRetClz, jRelationRet,
			cRelactionRet);
	//
	jfieldID jPersonsField = env->GetFieldID(jRelationRetClz, "persons",
			"Ljava/util/Vector;");
	jobject jPersonList = env->GetObjectField(jRelationRet, jPersonsField);
	jclass jArrayListClz = env->GetObjectClass(jPersonList);

	jmethodID jArrayListSizeMethod = env->GetMethodID(jArrayListClz, "size",
			"()I");
	jmethodID jArrayListGetMethod = env->GetMethodID(jArrayListClz, "get",
			"(I)Ljava/lang/Object;");
	jint jLength = env->CallIntMethod(jPersonList, jArrayListSizeMethod);

	LOGD(
			"Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnRelationCallBack: tokenListSize: %d",
			jLength);
	for (int i = 0; i < (int) jLength; i++) {
		PersonInfo person;
		jobject jPerson = env->CallObjectMethod(jPersonList,
				jArrayListGetMethod, i);
		jclass jPersonInfoClass = env->GetObjectClass(jPerson);
		LOGD("push_back: tokenListSize: %d", jLength);
		JniGetAndSetStringField(nickName, "nickName", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(openId, "openId", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(gender, "gender", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureSmall, "pictureSmall", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureMiddle, "pictureMiddle", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(pictureLarge, "pictureLarge", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(provice, "province", jPersonInfoClass, jPerson, person);
		JniGetAndSetStringField(city, "city", jPersonInfoClass, jPerson, person);
		JniGetAndSetFloatField(distance, "distance", jPersonInfoClass, jPerson, person);
		JniGetAndSetBooleanField(isFriend, "isFriend", jPersonInfoClass, jPerson, person);
		cRelactionRet.persons.push_back(person);
	}

    if (WGPlatform::GetInstance()->GetObserver() != NULL) {
        WGPlatform::GetInstance()->GetObserver()->OnLocationNotify(cRelactionRet);
    }
}

 /*
  * Class:     com_tencent_msdk_api_WGPlatformObserverForSO
  * Method:    OnFeedbackNotify
  * Signature: (ILjava/lang/String;)V
  */
 JNIEXPORT void JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnFeedbackNotify
   (JNIEnv * env, jclass, jint jFlag, jstring jDesc) {
	 LOGD("Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnFeedbackNotify start%s", "");
	 std::string cDesc;
	 if (jDesc == NULL) {
		 cDesc = "";
	 } else {
		 cDesc = env->GetStringUTFChars(jDesc, NULL);
	 }

	 if (WGPlatform::GetInstance()->GetObserver() != NULL) {
		 WGPlatform::GetInstance()->GetObserver()->OnFeedbackNotify((int)jFlag, cDesc);
	 }
	 LOGD("Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnFeedbackNotify end%s", "");
 }

 /*
  * Class:     com_tencent_msdk_api_WGPlatformObserverForSO
  * Method:    OnCrashExtMessageNotify
  * Signature: ()Ljava/lang/String
  */
 JNIEXPORT jstring JNICALL Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnCrashExtMessageNotify
   (JNIEnv * env, jclass) {
	 LOGD("Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnCrashExtMessageNotify start%s", "");
	 std::string cMsg;

	 if (WGPlatform::GetInstance()->GetObserver() != NULL) {
		 cMsg = WGPlatform::GetInstance()->GetObserver()->OnCrashExtMessageNotify();
	 }

	 const char* c_s = cMsg.c_str();
	 LOGD("Java_com_tencent_msdk_api_WGPlatformObserverForSO_OnCrashExtMessageNotify end%s", "");
	 return env->NewStringUTF(c_s);
 }


