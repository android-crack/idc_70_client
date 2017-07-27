#include "CommonFiles/WGPlatform.h"
#include "CommonFiles/WGPlatformObserver.h"
#include <string>
#include <android/log.h>

static jclass s_WGPlatformClass;
static jclass s_LoginRetClass;

WGPlatform::WGPlatform() :
		m_pObserver(NULL),
		mSaveUpdateObserver(NULL),
		mADObserver(NULL),
		mRealNameAuthObserver(NULL),
		mGroupObserver(NULL),
		needDelayLoginNotify(false),
		needDelayWakeupNotify(false),
		m_nPermissions(0){
		m_pVM = NULL;
}
WGPlatform::~WGPlatform() {
}
//-----------------------------------------------------------------------------
void WGPlatform::init(JavaVM* pVM) {
	if(pVM == NULL){
		LOGD("WGPlatform::init pvm is null %s","");
	}
	m_pVM = pVM;
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass cls = env->FindClass("com/tencent/msdk/api/WGPlatform");
	s_WGPlatformClass = (jclass) env->NewGlobalRef(cls);
	env->DeleteLocalRef(cls);
	cls = env->FindClass("com/tencent/msdk/api/LoginRet");
	s_LoginRetClass = (jclass) env->NewGlobalRef(cls);
	env->DeleteLocalRef(cls);
	ON_FUNC_OUT(__func__);
}
void WGPlatform::setVM(JavaVM* pVM) {
}

JavaVM* WGPlatform::getVm() {
	return m_pVM;
}

void WGPlatform::WGSetObserver(WGPlatformObserver* pNotify) {
	LOGD("WGPlatform::WGSetObserver needDelayWakeupNotify %d",
			needDelayWakeupNotify);
	LOGD("WGPlatform::WGSetObserver needDelayLoginNotify %d",
			needDelayLoginNotify);

	if (pNotify == NULL) {
		LOGI("pNotify is NULL%s", "");
		return;
	}
	m_pObserver = pNotify;

	//上次没有回调到的m_lastWakeup延迟回调一下
	if (needDelayWakeupNotify) {
		LOGD("WGPlatform::WGSetObserver wakeup delay notify openid:%s",
				m_lastWakeup.open_id.c_str());
		m_pObserver->OnWakeupNotify(m_lastWakeup);
		needDelayWakeupNotify = false;
	} else if (needDelayLoginNotify) {
		for (int i = 0; i < m_lastLoginRet.token.size(); i++) {
			LOGD(
					"WGPlatform::WGSetObserver login delay notify type:%d; value:%s",
					m_lastLoginRet.token.at(i).type, m_lastLoginRet.token.at(i).value.c_str());
		}
		m_pObserver->OnLoginNotify(m_lastLoginRet);
		needDelayLoginNotify = false;
	}
}

void WGPlatform::WGSetADObserver(WGADObserver* pADNotify) {
	LOGD("WGPlatform::WGSetADObserver%s", "");

	if (pADNotify == NULL) {
		LOGI("pADNotify is NULL%s", "");
		return;
	}
	mADObserver = pADNotify;
}

void WGPlatform::WGSetRealNameAuthObserver(WGRealNameAuthObserver* pRealNameAuthObserver){
		LOGD("WGPlatform::WGSetRealNameAuthObserver%s", "");

		if (pRealNameAuthObserver == NULL) {
			LOGI("pRealNameAuthObserver is NULL%s", "");
			return;
		}
		mRealNameAuthObserver = pRealNameAuthObserver;

}


void WGPlatform::WGSetGroupObserver(WGGroupObserver* pGroupNotify) {
	LOGD("WGPlatform::WGSetGroupObserver%s", "");

	if (pGroupNotify == NULL) {
		LOGI("pGroupNotify is NULL%s", "");
		return;
	}
	mGroupObserver = pGroupNotify;
}


WGPlatform * WGPlatform::m_pInst;
WGPlatform* WGPlatform::GetInstance() {
	if (m_pInst == NULL) {
		m_pInst = new WGPlatform();
	}
	return m_pInst;
}

void WGPlatform::WGLogin(ePlatform platform) {
	LOGD("WGPlatform::WGLogin platform:%d", (int)platform);

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGLogin AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass jCommonClass = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject jEnumObj = env->CallStaticObjectMethod(jCommonClass, jGetEnumMethod,
			(int) platform);

	jmethodID WGLogin = env->GetStaticMethodID(s_WGPlatformClass, "WGLogin",
			"(Lcom/tencent/msdk/consts/EPlatform;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGLogin, jEnumObj);

	env->DeleteLocalRef(jCommonClass);
	env->DeleteLocalRef(jEnumObj);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGQrCodeLogin(ePlatform platform) {
	LOGD("WGPlatform::WGQrCodeLogin platform:%d", (int)platform);

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQrCodeLogin AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass jCommonClass = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject jEnumObj = env->CallStaticObjectMethod(jCommonClass, jGetEnumMethod,
			(int) platform);

	jmethodID WGQrCodeLogin = env->GetStaticMethodID(s_WGPlatformClass, "WGQrCodeLogin",
			"(Lcom/tencent/msdk/consts/EPlatform;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGQrCodeLogin, jEnumObj);

	env->DeleteLocalRef(jCommonClass);
	env->DeleteLocalRef(jEnumObj);

	ON_FUNC_OUT(__func__);
}

bool WGPlatform::WGSwitchUser(bool switchToLaunchUser) {
	LOGD("WGPlatform::WGLogin platform:%d", switchToLaunchUser);
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSwitchUser AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
				"WGSwitchUser", "(Z)Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, method, switchToLaunchUser);
}

void WGPlatform::WGShowAD(const _eADType& cScene) {
	LOGD("WGPlatform::WGShowAD scene:%d", (int)cScene);
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGShowAD AttachCurrentThread env is null %s","");
	}

	ON_FUNC_INTER(__func__);
	jclass jCommonClass = env->FindClass("com/tencent/msdk/api/eADType");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/api/eADType;");
	jobject jEnumObj = env->CallStaticObjectMethod(jCommonClass, jGetEnumMethod,
			(int) cScene);

	jmethodID WGShowAD = env->GetStaticMethodID(s_WGPlatformClass, "WGShowAD",
			"(Lcom/tencent/msdk/api/eADType;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGShowAD, jEnumObj);

	env->DeleteLocalRef(jCommonClass);
	env->DeleteLocalRef(jEnumObj);
	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGCloseAD(const _eADType& cScene) {
	LOGD("WGPlatform::WGCloseAD scene:%d", (int)cScene);
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCloseAD AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass jCommonClass = env->FindClass("com/tencent/msdk/api/eADType");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/api/eADType;");
	jobject jEnumObj = env->CallStaticObjectMethod(jCommonClass, jGetEnumMethod,
			(int) cScene);

	jmethodID WGCloseAD = env->GetStaticMethodID(s_WGPlatformClass, "WGCloseAD",
			"(Lcom/tencent/msdk/api/eADType;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGCloseAD, jEnumObj);

	env->DeleteLocalRef(jCommonClass);
	env->DeleteLocalRef(jEnumObj);
	ON_FUNC_OUT(__func__);
}

//-----------------------------------------------------------------------------
bool WGPlatform::WGLogout() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGLogout AttachCurrentThread env is null %s","");
	}
	jmethodID WGLogout = env->GetStaticMethodID(s_WGPlatformClass, "WGLogout",
			"()Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, WGLogout);
}

int WGPlatform::WGGetLoginRecord(LoginRet& lr) {
	JNIEnv* env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetLoginRecord AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jboolean isCopy;
	jmethodID WGGetLoginRecord = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetLoginRecord", "(Lcom/tencent/msdk/api/LoginRet;)I");
	jmethodID lrConstruct = env->GetMethodID(s_LoginRetClass, "<init>", "()V");
	jobject jLoginRet = env->NewObject(s_LoginRetClass, lrConstruct);
	env->CallStaticIntMethod(s_WGPlatformClass, WGGetLoginRecord, jLoginRet);

	JniGetAndSetStringField(pf, "pf", s_LoginRetClass, jLoginRet, lr);
	JniGetAndSetStringField(pf_key, "pf_key", s_LoginRetClass, jLoginRet, lr);
	JniGetAndSetIntField(flag, "flag", s_LoginRetClass, jLoginRet, lr);
	JniGetAndSetStringField(desc, "desc", s_LoginRetClass, jLoginRet, lr);
	JniGetAndSetIntField(platform, "platform", s_LoginRetClass, jLoginRet, lr);
	JniGetAndSetStringField(open_id, "open_id", s_LoginRetClass, jLoginRet, lr);

	// Vector
	jfieldID jVectorFieldId = env->GetFieldID(s_LoginRetClass, "token",
			"Ljava/util/Vector;");
	jobject jTokenVectorObject = env->GetObjectField(jLoginRet, jVectorFieldId);
	jclass jVectorClass = env->GetObjectClass(jTokenVectorObject);

	jmethodID jVectorSizeMethod = env->GetMethodID(jVectorClass, "size", "()I");
	jmethodID jVectorGetMethod = env->GetMethodID(jVectorClass, "get",
			"(I)Ljava/lang/Object;");
	jint jLength = env->CallIntMethod(jTokenVectorObject, jVectorSizeMethod);

	for (int i = 0; i < jLength; i++) {
		TokenRet cTokenRet;
		jobject jTokenRetObject = env->CallObjectMethod(jTokenVectorObject,
				jVectorGetMethod, i);
		jclass jTokenRetClass = env->GetObjectClass(jTokenRetObject);

		JniGetAndSetIntField(type, "type", jTokenRetClass, jTokenRetObject,
				cTokenRet);
		JniGetAndSetStringField(value, "value", jTokenRetClass, jTokenRetObject,
				cTokenRet);
		JniGetAndSetLongField(expiration, "expiration", jTokenRetClass,
				jTokenRetObject, cTokenRet)

		lr.token.push_back(cTokenRet);

		env->DeleteLocalRef(jTokenRetObject);
		env->DeleteLocalRef(jTokenRetClass);
	}
	JniGetAndSetStringField(user_id, "user_id", s_LoginRetClass, jLoginRet, lr);

	env->DeleteLocalRef(jLoginRet);
	env->DeleteLocalRef(jTokenVectorObject);
	env->DeleteLocalRef(jVectorClass);

	ON_FUNC_OUT(__func__);

	return lr.platform;
}

int WGPlatform::WGGetPaytokenValidTime() {
    JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetPaytokenValidTime AttachCurrentThread env is null %s","");
	}
    ON_FUNC_INTER(__func__);
    jmethodID methodJ = env->GetStaticMethodID(s_WGPlatformClass,
                                                       "WGGetPaytokenValidTime", "()I");
    int validTime = env->CallStaticIntMethod(s_WGPlatformClass, methodJ);

	ON_FUNC_OUT(__func__);

    return validTime;
}

WGPlatformObserver* WGPlatform::GetObserver() const {
	return m_pObserver;
}

WGSaveUpdateObserver* WGPlatform::GetSaveUpdateObserver() const {
	return mSaveUpdateObserver;
}

WGADObserver* WGPlatform::GetADObserver() const {
	return mADObserver;
}

WGRealNameAuthObserver* WGPlatform::GetRealNameAuthObserver() const {
	return mRealNameAuthObserver;
}


WGGroupObserver* WGPlatform::GetGroupObserver() const {
	return mGroupObserver;
}

void WGPlatform::WGSetPermission(int permissions) {
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSetPermission AttachCurrentThread env is null %s","");
	}

	jmethodID WGSetPermission = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSetPermission", "(I)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGSetPermission, permissions);
}

void WGPlatform::WGSendToWeixin(
		unsigned char* title,
		unsigned char* desc,
		unsigned char* mediaTagName,
		unsigned char* thumbImgData,
		const int& thumbImgDataLen,
		unsigned char *messageExt
	) {
	LOGD("WGPlatform::WGSendToWeixin no scene title:%s", title);
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixin AttachCurrentThread env is null %s","");
	}

	if(title == NULL){
		LOGD("WGSendToWeixin parameter title is null %s","");
		return;
	}else if(desc == NULL){
		LOGD("WGSendToWeixin parameter desc is null %s","");
		return;
	}else if(mediaTagName == NULL){
		LOGD("WGSendToWeixin parameter mediaTagName is null %s","");
		return;
	}else if(thumbImgData == NULL){
		LOGD("WGSendToWeixin parameter thumbImgData is null %s","");
		return;
	}

	ON_FUNC_INTER(__func__);
	jmethodID WGSendToWeixin = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixin",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BILjava/lang/String;)V");

	//jstring jTitle = env->NewStringUTF((const char*) title);
	jstring jTitle = StringFromStdString(env,(const char*) title);
	//jstring jDesc = env->NewStringUTF((const char*) desc);
	jstring jDesc = StringFromStdString(env,(const char*) desc);
	jbyteArray jImgData = env->NewByteArray(thumbImgDataLen);
	//jstring jMediaTagName = env->NewStringUTF((const char*) mediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) mediaTagName);
	//jstring jMessageExt = env->NewStringUTF((const char*) messageExt);
	jstring jMessageExt = StringFromStdString(env, messageExt == NULL  ? "" : (const char*) messageExt);
	env->SetByteArrayRegion(jImgData, 0, thumbImgDataLen,
			(jbyte *) thumbImgData);

	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToWeixin, jTitle, jDesc,
			jMediaTagName, jImgData, thumbImgDataLen, jMessageExt);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jImgData);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jMessageExt);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToWeixinWithUrl(
		const eWechatScene& scene,
		unsigned char* title,
		unsigned char* desc,
		unsigned char* url,
		unsigned char* mediaTagName,
		unsigned char* thumbImgData,
		const int& thumbImgDataLen,
		unsigned char* messageExt){
	LOGD("WGPlatform::WGSendToWeixinWithUrl no scene title:%s", title);
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixinWithUrl AttachCurrentThread env is null %s","");
	}

	if(title == NULL){
		LOGD("WGSendToWeixinWithUrl parameter title is null %s","");
		return;
	}else if(desc == NULL){
		LOGD("WGSendToWeixinWithUrl parameter desc is null %s","");
		return;
	}else if(url == NULL){
		LOGD("WGSendToWeixinWithUrl parameter url is null %s","");
		return;
	}else if(mediaTagName == NULL){
		LOGD("WGSendToWeixinWithUrl parameter mediaTagName is null %s","");
		return;
	}else if(thumbImgData == NULL){
		LOGD("WGSendToWeixinWithUrl parameter thumbImgData is null %s","");
		return;
	}

	ON_FUNC_INTER(__func__);
	jmethodID WGSendToWeixinWithUrl = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithUrl",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BILjava/lang/String;)V");

	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)scene);
	//jstring jTitle = env->NewStringUTF((const char*) title);
	jstring jTitle = StringFromStdString(env,(const char*) title);
	//jstring jDesc = env->NewStringUTF((const char*) desc);
	jstring jDesc = StringFromStdString(env,(const char*) desc);
	//jstring jUrl = env->NewStringUTF((const char*) url);
	jstring jUrl = StringFromStdString(env,(const char*) url);
	//jstring jMediaTagName = env->NewStringUTF((const char*) mediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) mediaTagName);
	jbyteArray jImgData = env->NewByteArray(thumbImgDataLen);
	//jstring jMessageExt = env->NewStringUTF((const char*) messageExt);
	jstring jMessageExt = StringFromStdString(env,messageExt == NULL  ? "" : (const char*) messageExt);
	env->SetByteArrayRegion(jImgData, 0, thumbImgDataLen,
			(jbyte *) thumbImgData);

	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToWeixinWithUrl, jScene, jTitle, jDesc, jUrl,
			jMediaTagName, jImgData, thumbImgDataLen, jMessageExt);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jUrl);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jImgData);
	env->DeleteLocalRef(jMessageExt);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToWeixinWithPhoto(const eWechatScene& cScene,
		unsigned char* mediaTagName, unsigned char* imgData,
		const int& imgDataLen) {
	LOGD("WGPlatform::WGSendToWeixinWithPhoto imgDataLen=%d", imgDataLen);

	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixinWithPhoto AttachCurrentThread env is null %s","");
	}

	if(mediaTagName == NULL){
		LOGD("WGSendToWeixinWithPhoto parameter mediaTagName is null %s","");
		return;
	}else if(imgData == NULL){
		LOGD("WGSendToWeixinWithPhoto parameter imgData is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithPhoto", "(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;[BI)V");
	jbyteArray jImageData = env->NewByteArray(imgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageData, 0, imgDataLen, (jbyte *) imgData);
	//jstring jMediaTagName = env->NewStringUTF((char const*) mediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) mediaTagName);
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);

	env->CallStaticVoidMethod(s_WGPlatformClass, method, jScene, jMediaTagName,
			jImageData, imgDataLen);

	env->DeleteLocalRef(jImageData);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);

	ON_FUNC_OUT(__func__);
}
void WGPlatform::WGSendToWeixinWithPhoto(const eWechatScene& cScene,
		unsigned char* mediaTagName, unsigned char* imgData,
		const int& imgDataLen, unsigned char* messageExt,
		unsigned char* messageAction) {
	LOGD("WGPlatform::WGSendToWeixinWithPhoto imgDataLen=%d", imgDataLen);

	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixinWithPhoto AttachCurrentThread env is null %s","");
	}

	if(mediaTagName == NULL){
		LOGD("WGSendToWeixinWithPhoto parameter mediaTagName is null %s","");
		return;
	}else if(imgData == NULL){
		LOGD("WGSendToWeixinWithPhoto parameter imgData is null %s","");
		return;
	}else if(messageAction == NULL){
		LOGD("WGSendToWeixinWithPhoto parameter messageAction is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithPhoto",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;[BILjava/lang/String;Ljava/lang/String;)V");

	jbyteArray jImageData = env->NewByteArray(imgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageData, 0, imgDataLen, (jbyte *) imgData);
	//jstring jMediaTagName = env->NewStringUTF((char const*) mediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) mediaTagName);
	//jstring jMessageExt = env->NewStringUTF((char const*) messageExt);
	jstring jMessageExt = StringFromStdString(env,messageExt == NULL  ? "" : (const char*) messageExt);
	//jstring jMessageAction = env->NewStringUTF((char const*) messageAction);
	jstring jMessageAction = StringFromStdString(env,(const char*) messageAction);
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);

	env->CallStaticVoidMethod(s_WGPlatformClass, method, jScene, jMediaTagName,
			jImageData, imgDataLen, jMessageExt, jMessageAction);

	env->DeleteLocalRef(jImageData);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jMessageExt);
	env->DeleteLocalRef(jMessageAction);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToWeixinWithPhotoPath(const eWechatScene &scene,
		unsigned char *mediaTagName, unsigned char *imgPath,
		unsigned char *messageExt, unsigned char *messageAction) {
	LOGD("WGPlatform::WGSendToWeixinWithPhotoPath imgPath=%s", imgPath);

	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixinWithPhotoPath AttachCurrentThread env is null %s","");
	}

	if(mediaTagName == NULL){
		LOGD("WGSendToWeixinWithPhotoPath parameter mediaTagName is null %s","");
		return;
	}else if(imgPath == NULL){
		LOGD("WGSendToWeixinWithPhotoPath parameter imgPath is null %s","");
		return;
	}else if(messageAction == NULL){
		LOGD("WGSendToWeixinWithPhotoPath parameter messageAction is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithPhotoPath",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");

	//jstring jMediaTagName = env->NewStringUTF((char const*) mediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) mediaTagName);
	//jstring jImgPath = env->NewStringUTF((char const*) imgPath);
	jstring jImgPath = StringFromStdString(env,(const char*) imgPath);
	//jstring jMessageExt = env->NewStringUTF((char const*) messageExt);
	jstring jMessageExt = StringFromStdString(env,messageExt == NULL  ? "" : (const char*) messageExt);
	//jstring jMessageAction = env->NewStringUTF((char const*) messageAction);
	jstring jMessageAction = StringFromStdString(env,(const char*) messageAction);

	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)scene);

	env->CallStaticVoidMethod(s_WGPlatformClass, method, jScene, jMediaTagName,
			jImgPath, jMessageExt, jMessageAction);

	env->DeleteLocalRef(jImgPath);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jMessageExt);
	env->DeleteLocalRef(jMessageAction);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToWeixinWithMusic(const eWechatScene& cScene, unsigned char* cTitle,
        unsigned char* cDesc, unsigned char* cMusicUrl, unsigned char* cMusicDataUrl,
        unsigned char *cMediaTagName, unsigned char *cImgData, const int &cImgDataLen,
        unsigned char *cMessageExt, unsigned char *cMessageAction){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWeixinWithMusic AttachCurrentThread env is null %s","");
	}

	if(cTitle == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cTitle is null %s","");
		return;
	}else if(cDesc == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cDesc is null %s","");
		return;
	}else if(cMusicUrl == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cMusicUrl is null %s","");
		return;
	}else if(cMusicDataUrl == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cMusicDataUrl is null %s","");
		return;
	}else if(cMediaTagName == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cMediaTagName is null %s","");
		return;
	}else if(cImgData == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cImgData is null %s","");
		return;
	}else if(cMessageAction == NULL){
		LOGD("WGSendToWeixinWithMusic parameter cMessageAction is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID jWGSendToWeixinWithMusicMethod = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithMusic",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BILjava/lang/String;Ljava/lang/String;)V");

	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	//jstring jTitle = env->NewStringUTF((char const *) cTitle);
	jstring jTitle = StringFromStdString(env,(const char*) cTitle);
	//jstring jDesc = env->NewStringUTF((char const *) cDesc);
	jstring jDesc = StringFromStdString(env,(const char*) cDesc);
	//jstring jMusicUrl = env->NewStringUTF((char const *) cMusicUrl);
	jstring jMusicUrl = StringFromStdString(env,(const char*) cMusicUrl);
	//jstring jMusicDataUrl = env->NewStringUTF((char const *) cMusicDataUrl);
	jstring jMusicDataUrl = StringFromStdString(env,(const char*) cMusicDataUrl);
	//jstring jMediaTagName = env->NewStringUTF((char const*) cMediaTagName);
	jstring jMediaTagName = StringFromStdString(env,(const char*) cMediaTagName);
	jbyteArray jImageDataArray = env->NewByteArray(cImgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageDataArray, 0, cImgDataLen, (jbyte *) cImgData);
	jint jImgDataLen = (jint) cImgDataLen;
	//jstring jMessageExt = env->NewStringUTF((char const*) cMessageExt);
	jstring jMessageExt = StringFromStdString(env,cMessageExt == NULL  ? "" : (const char*) cMessageExt);
	//jstring jMessageAction = env->NewStringUTF((char const*) cMessageAction);
	jstring jMessageAction = StringFromStdString(env,(const char*) cMessageAction);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGSendToWeixinWithMusicMethod,
			jScene, jTitle,jDesc,jMusicUrl,jMusicDataUrl,jMediaTagName,jImageDataArray,
			jImgDataLen, jMessageExt, jMessageAction);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jMusicUrl);
	env->DeleteLocalRef(jMusicDataUrl);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jImageDataArray);
	env->DeleteLocalRef(jMessageExt);
	env->DeleteLocalRef(jMessageAction);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToQQWithMusic(const eQQScene& cScene, unsigned char* cTitle,unsigned char* cDesc,
		unsigned char* cMusicUrl,unsigned char* cMusicDataUrl,unsigned char* cImgUrl){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQWithMusic AttachCurrentThread env is null %s","");
	}

	if(cTitle == NULL){
		LOGD("WGSendToQQWithMusic parameter cTitle is null %s","");
		return;
	}else if(cDesc == NULL){
		LOGD("WGSendToQQWithMusic parameter cDesc is null %s","");
		return;
	}else if(cMusicUrl == NULL){
		LOGD("WGSendToQQWithMusic parameter cMusicUrl is null %s","");
		return;
	}else if(cMusicDataUrl == NULL){
		LOGD("WGSendToQQWithMusic parameter cMusicDataUrl is null %s","");
		return;
	}else if(cImgUrl == NULL){
		LOGD("WGSendToQQWithMusic parameter cImgUrl is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGSendToQQWithMusic cScene=%d", (int)cScene);

	jmethodID jWGSendToQQMethod =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGSendToQQWithMusic",
						"(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	//jstring jTitle = env->NewStringUTF((char const *) cTitle);
	jstring jTitle = StringFromStdString(env,(const char*) cTitle);
	//jstring jDesc = env->NewStringUTF((char const *) cDesc);
	jstring jDesc = StringFromStdString(env,(const char*) cDesc);
	//jstring jMusicUrl = env->NewStringUTF((char const *) cMusicUrl);
	jstring jMusicUrl = StringFromStdString(env,(const char*) cMusicUrl);
	//jstring jMusicDataUrl = env->NewStringUTF((char const *) cMusicDataUrl);
	jstring jMusicDataUrl = StringFromStdString(env,(const char*) cMusicDataUrl);
	//jstring jImgUrl = env->NewStringUTF((char const *) cImgUrl);
	jstring jImgUrl = StringFromStdString(env,(const char*) cImgUrl);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGSendToQQMethod, jScene, jTitle,
			jDesc, jMusicUrl, jMusicDataUrl, jImgUrl);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jMusicUrl);
	env->DeleteLocalRef(jMusicDataUrl);
	env->DeleteLocalRef(jImgUrl);
	LOGD("WGPlatform::WGSendToQQWithMusic end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToQQWithRichPhoto(unsigned char* summary, std::vector<std::string> &imgFilePaths) {
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQWithRichPhoto AttachCurrentThread env is null %s","");
	}

	if(summary == NULL){
		LOGD("WGSendToQQWithRichPhoto parameter summary is null %s","");
		return;
	}
	LOGD("WGPlatform::WGSendToQQWithRichPhoto%s", "");
	ON_FUNC_INTER(__func__);
	//jstring jSummary = env->NewStringUTF((char const *) summary);
	jstring jSummary = StringFromStdString(env,(const char*) summary);

	jclass jArrayListClass = env->FindClass("java/util/ArrayList");
	jmethodID jInitMethod = env->GetMethodID(jArrayListClass, "<init>", "()V");
	jmethodID jSizeMethod = env->GetMethodID(jArrayListClass, "size", "()I");
	jmethodID jAddMethod = env->GetMethodID(jArrayListClass, "add",
			"(Ljava/lang/Object;)Z");

	jobject jAddrList = env->NewObject(jArrayListClass, jInitMethod);

	for (int i = 0; i < imgFilePaths.size(); i++) {
		//jstring jAddr = env->NewStringUTF((const char *) imgFilePaths.at(i).c_str());
		jstring jAddr = StringFromStdString(env,(const char*) imgFilePaths.at(i).c_str());
		env->CallBooleanMethod(jAddrList, jAddMethod, jAddr);
		env->DeleteLocalRef(jAddr);
	}

	jmethodID jShareMethod = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToQQWithRichPhoto", "(Ljava/lang/String;Ljava/util/ArrayList;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jShareMethod, jSummary, jAddrList);
	env->DeleteLocalRef(jSummary);
	env->DeleteLocalRef(jArrayListClass);
	env->DeleteLocalRef(jAddrList);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToQQWithVideo(unsigned char* summary, unsigned char* videoPath) {
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQWithVideo AttachCurrentThread env is null %s","");
	}

	if(summary == NULL){
		LOGD("WGSendToQQWithVideo parameter summary is null %s","");
		return;
	}else if(videoPath == NULL){
		LOGD("WGSendToQQWithVideo parameter videoPath is null %s","");
		return;
	}
	LOGD("WGPlatform::WGSendToQQWithVideo%s", "");
	ON_FUNC_INTER(__func__);
	jmethodID jShareMethod =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGSendToQQWithVideo",
						"(Ljava/lang/String;Ljava/lang/String;)V");
	//jstring jSummary = env->NewStringUTF((char const *) summary);
	jstring jSummary = StringFromStdString(env,(const char*) summary);
	//jstring jVideoPath = env->NewStringUTF((char const *) videoPath);
	jstring jVideoPath = StringFromStdString(env,(const char*) videoPath);
	env->CallStaticVoidMethod(s_WGPlatformClass, jShareMethod, jSummary, jVideoPath);
	env->DeleteLocalRef(jSummary);
	env->DeleteLocalRef(jVideoPath);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGBindQQGroup(unsigned char* cUnionid,unsigned char* cUnion_name,unsigned char* cZoneid,unsigned char* cSignature){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGBindQQGroup AttachCurrentThread env is null %s","");
	}

	if(cUnionid == NULL){
		LOGD("WGBindQQGroup parameter cUnionid is null %s","");
		return;
	}else if(cUnion_name == NULL){
		LOGD("WGBindQQGroup parameter cUnion_name is null %s","");
		return;
	}else if(cZoneid == NULL){
		LOGD("WGBindQQGroup parameter cZoneid is null %s","");
		return;
	}else if(cSignature == NULL){
		LOGD("WGBindQQGroup parameter cSignature is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGBindQQGroup start%s", "");
	jmethodID jWGBindQQGroup =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGBindQQGroup",
						"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	//jstring jUnionid = env->NewStringUTF((char const *) cUnionid);
	jstring jUnionid = StringFromStdString(env,(const char*) cUnionid);
	//jstring jUnion_name = env->NewStringUTF((char const *) cUnion_name);
	jstring jUnion_name = StringFromStdString(env,(const char*) cUnion_name);
	//jstring jZoneid = env->NewStringUTF((char const *) cZoneid);
	jstring jZoneid = StringFromStdString(env,(const char*) cZoneid);
	//jstring jSignature = env->NewStringUTF((char const *) cSignature);
	jstring jSignature = StringFromStdString(env,(const char*) cSignature);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGBindQQGroup, jUnionid, jUnion_name,
			jZoneid, jSignature);
	env->DeleteLocalRef(jUnionid);
	env->DeleteLocalRef(jUnion_name);
	env->DeleteLocalRef(jZoneid);
	env->DeleteLocalRef(jSignature);
	LOGD("WGPlatform::WGBindQQGroup end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGAddGameFriendToQQ(unsigned char* cFopenid,unsigned char* cDesc,unsigned char* cMessage){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGAddGameFriendToQQ AttachCurrentThread env is null %s","");
	}

	if(cFopenid == NULL){
		LOGD("WGAddGameFriendToQQ parameter cFopenid is null %s","");
		return;
	}else if(cDesc == NULL){
		LOGD("WGAddGameFriendToQQ parameter cDesc is null %s","");
		return;
	}else if(cMessage == NULL){
		LOGD("WGAddGameFriendToQQ parameter cMessage is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGAddGameFriendToQQ start%s", "");
	jmethodID jWGAddGameFriendToQQ =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGAddGameFriendToQQ",
						"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	jstring jFopenid = StringFromStdString(env,(char const *) cFopenid);
	jstring jDesc = StringFromStdString(env,(char const *) cDesc);
	jstring jMessage = StringFromStdString(env,(char const *) cMessage);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGAddGameFriendToQQ, jFopenid, jDesc,jMessage);
	env->DeleteLocalRef(jFopenid);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jMessage);
	LOGD("WGPlatform::WGAddGameFriendToQQ end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGJoinQQGroup(unsigned char* cQqGroupKey){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGJoinQQGroup AttachCurrentThread env is null %s","");
	}

	if(cQqGroupKey == NULL){
		LOGD("WGJoinQQGroup parameter cQqGroupKey is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGJoinQQGroup start%s", "");
	jmethodID jWGJoinQQGroup =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGJoinQQGroup","(Ljava/lang/String;)V");
	jstring jQqGroupKey = StringFromStdString(env,(char const *) cQqGroupKey);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGJoinQQGroup, jQqGroupKey);
	env->DeleteLocalRef(jQqGroupKey);
	LOGD("WGPlatform::WGJoinQQGroup end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGQueryQQGroupInfo(unsigned char* cUnionid,unsigned char* cZoneid){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryQQGroupInfo AttachCurrentThread env is null %s","");
	}

	if(cUnionid == NULL){
		LOGD("WGQueryQQGroupInfo parameter cUnionid is null %s","");
		return;
	}else if(cZoneid == NULL){
		LOGD("WGQueryQQGroupInfo parameter cZoneid is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGQueryQQGroupInfo start%s", "");
	jmethodID jWGQueryQQGroupInfo =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGQueryQQGroupInfo",
						"(Ljava/lang/String;Ljava/lang/String;)V");
	jstring jUnionid = StringFromStdString(env,(char const *) cUnionid);
	jstring jZoneid = StringFromStdString(env,(char const *) cZoneid);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGQueryQQGroupInfo, jUnionid,jZoneid);
	env->DeleteLocalRef(jUnionid);
	env->DeleteLocalRef(jZoneid);
	LOGD("WGPlatform::WGQueryQQGroupInfo end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGUnbindQQGroup(unsigned char* cGroupOpenid,unsigned char* cUnionid){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGUnbindQQGroup AttachCurrentThread env is null %s","");
	}

	if(cGroupOpenid == NULL){
		LOGD("WGUnbindQQGroup parameter cGroupOpenid is null %s","");
		return;
	}else if(cUnionid == NULL){
		LOGD("WGUnbindQQGroup parameter cUnionid is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGUnbindQQGroup start%s", "");
	jmethodID jWGUnbindQQGroup =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGUnbindQQGroup",
						"(Ljava/lang/String;Ljava/lang/String;)V");
	jstring jUnionid = StringFromStdString(env,(char const *) cUnionid);
	jstring jGroupOpenid = StringFromStdString(env,(char const *) cGroupOpenid);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGUnbindQQGroup, jGroupOpenid,jUnionid);
	env->DeleteLocalRef(jUnionid);
	env->DeleteLocalRef(jGroupOpenid);
	LOGD("WGPlatform::WGUnbindQQGroup end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGQueryQQGroupKey(unsigned char* cGroupOpenid){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryQQGroupKey AttachCurrentThread env is null %s","");
	}

	if(cGroupOpenid == NULL){
		LOGD("WGQueryQQGroupKey parameter cGroupOpenid is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGQueryQQGroupKey start%s", "");
	jmethodID jWGQueryQQGroupKey =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGQueryQQGroupKey",
						"(Ljava/lang/String;)V");
	jstring jGroupOpenid = StringFromStdString(env,(char const *) cGroupOpenid);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGQueryQQGroupKey, jGroupOpenid);
	env->DeleteLocalRef(jGroupOpenid);
	LOGD("WGPlatform::WGQueryQQGroupKey end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGAddCardToWXCardPackage(unsigned char* cardId,unsigned char* timestamp,unsigned char* sign){
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGAddCardToWXCardPackage AttachCurrentThread env is null %s","");
	}

	if(cardId == NULL){
		LOGD("WGAddCardToWXCardPackage parameter cardId is null %s","");
		return;
	}else if(timestamp == NULL){
		LOGD("WGAddCardToWXCardPackage parameter timestamp is null %s","");
		return;
	}else if(sign == NULL){
		LOGD("WGAddCardToWXCardPackage parameter sign is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGPlatform::WGAddCardToWXCardPackage start%s", "");
	jmethodID jWGAddCardToWXCardPackage =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGAddCardToWXCardPackage",
						"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	jstring jCardId = StringFromStdString(env,(char const *) cardId);
	jstring jTimestamp = StringFromStdString(env,(char const *) timestamp);
	jstring jSign = StringFromStdString(env,(char const *) sign);
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGAddCardToWXCardPackage, jCardId,jTimestamp,jSign);
	env->DeleteLocalRef(jCardId);
	env->DeleteLocalRef(jTimestamp);
	env->DeleteLocalRef(jSign);
	LOGD("WGPlatform::WGAddCardToWXCardPackage end%s", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGSendToQQ(const eQQScene& cScene, unsigned char* cTitle,
		unsigned char* cDesc, unsigned char* cUrl, unsigned char* cImgUrl,
		const int& imgUrlLen) {
	LOGD("WGPlatform::WGSendToQQ title:%s", cTitle);

	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQ AttachCurrentThread env is null %s","");
	}

	if(cTitle == NULL){
		LOGD("WGSendToQQ parameter cTitle is null %s","");
		return;
	}else if(cDesc == NULL){
		LOGD("WGSendToQQ parameter cDesc is null %s","");
		return;
	}else if(cUrl == NULL){
		LOGD("WGSendToQQ parameter cUrl is null %s","");
		return;
	}else if(cImgUrl == NULL){
		LOGD("WGSendToQQ parameter cImgUrl is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGSendToQQ =
			env->GetStaticMethodID(s_WGPlatformClass, "WGSendToQQ",
					"(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	jstring jTitle = StringFromStdString(env,(char const *) cTitle);
	jstring jDesc = StringFromStdString(env,(char const *) cDesc);
	jstring jUrl = StringFromStdString(env,(char const *) cUrl);
	jstring jImgUrl = StringFromStdString(env,(char const *) cImgUrl);
	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToQQ, jScene, jTitle,
			jDesc, jUrl, jImgUrl, imgUrlLen);

	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jUrl);
	env->DeleteLocalRef(jImgUrl);

	ON_FUNC_OUT(__func__);

}

void WGPlatform::WGSendToQQWithPhoto(const eQQScene& cScene, unsigned char* cImgFilePath) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQWithPhoto AttachCurrentThread env is null %s","");
	}

	if(cImgFilePath == NULL){
		LOGD("WGSendToQQWithPhoto parameter cImgFilePath is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGSendToQQWithPhoto = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToQQWithPhoto", "(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jSceneObj = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);

	jstring jImgFilePath = StringFromStdString(env,(char const *) cImgFilePath);
	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToQQWithPhoto, jSceneObj,
			jImgFilePath);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jImgFilePath);
	env->DeleteLocalRef(jSceneObj);

	ON_FUNC_OUT(__func__);
}
int WGPlatform::WGFeedback(unsigned char* cGame, unsigned char* cTxt) {
	LOGD("WGPlatform::WGFeedBack txt:%s", cTxt);
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGFeedback AttachCurrentThread env is null %s","");
	}

	if(cGame == NULL){
		LOGD("WGFeedback parameter cGame is null %s","");
		return 0;
	}else if(cTxt == NULL){
		LOGD("WGFeedback parameter cTxt is null %s","");
		return 0;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass, "WGFeedback",
			"(Ljava/lang/String;Ljava/lang/String;)Z");

	jstring jGame = StringFromStdString(env,(char const *) cGame);
	jstring jTxt = StringFromStdString(env,(char const *) cTxt);
	int rtn = env->CallStaticBooleanMethod(s_WGPlatformClass, method, jGame,
			jTxt);
	env->DeleteLocalRef(jGame);
	env->DeleteLocalRef(jTxt);
	ON_FUNC_OUT(__func__);
	return rtn;
}

void WGPlatform::WGFeedback(unsigned char* cBody) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGFeedback AttachCurrentThread env is null %s","");
	}

	if(cBody == NULL){
		LOGD("WGFeedback parameter cGame is null %s","");
		return ;
	}
	jstring jTxt = StringFromStdString(env,(char const *) cBody);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGFeedback",
			"(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jTxt);
	env->DeleteLocalRef(jTxt);
}


const std::string WGPlatform::WGGetVersion() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetVersion AttachCurrentThread env is null %s","");
	}
	jmethodID jWGGetVersionMethod = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetVersion", "()Ljava/lang/String;");
	jstring jVersion = (jstring) env->CallStaticObjectMethod(s_WGPlatformClass,
			jWGGetVersionMethod);

	jboolean isCopy;
	const char* cVersion = env->GetStringUTFChars(jVersion, &isCopy);
	std::string cVersionStr = cVersion;
	env->ReleaseStringUTFChars(jVersion, cVersion);
	env->DeleteLocalRef(jVersion);
	return cVersionStr;
}

void WGPlatform::setWakeup(WakeupRet& wakeup) {

	this->m_lastWakeup = wakeup;

	needDelayWakeupNotify = true;
	LOGD("WGPlatform::setWakeup %d", needDelayWakeupNotify);
}

void WGPlatform::setLoginRet(LoginRet& lr) {
	this->m_lastLoginRet = lr;
	needDelayLoginNotify = true;
	LOGD("WGPlatform::setLoginRet %d", needDelayLoginNotify);
}

LoginRet& WGPlatform::getLoginRet() {
	return this->m_lastLoginRet;
}

WakeupRet& WGPlatform::getWakeup() {
	return m_lastWakeup;
}

void WGPlatform::WGEnableCrashReport(bool isRdmEnable, bool isMtaEnable) {
	LOGD("WGPlatform::WGEnableCrashReport bEnable rdm: %d; mta: %d;",
			isRdmEnable, isMtaEnable);

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGEnableCrashReport AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGEnableCrashReport", "(ZZ)V");

	env->CallStaticVoidMethod(s_WGPlatformClass, method, isRdmEnable,
			isMtaEnable);
}

void WGPlatform::WGTestSpeed(std::vector<std::string> &addrList) {
	JNIEnv * env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGTestSpeed AttachCurrentThread env is null %s","");
	}

	jclass jArrayListClass = env->FindClass("java/util/ArrayList");
	jmethodID jInitMethod = env->GetMethodID(jArrayListClass, "<init>", "()V");
	jmethodID jSizeMethod = env->GetMethodID(jArrayListClass, "size", "()I");
	jmethodID jAddMethod = env->GetMethodID(jArrayListClass, "add",
			"(Ljava/lang/Object;)Z");

	jobject jAddrList = env->NewObject(jArrayListClass, jInitMethod);

	for (int i = 0; i < addrList.size(); i++) {
		jstring jAddr = StringFromStdString(env,
				(const char *) addrList.at(i).c_str());
		env->CallBooleanMethod(jAddrList, jAddMethod, jAddr);
		env->DeleteLocalRef(jAddr);
	}
	jmethodID jmTestSpeed = env->GetStaticMethodID(s_WGPlatformClass,
			"WGTestSpeed", "(Ljava/util/ArrayList;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jmTestSpeed, jAddrList);
	env->DeleteLocalRef(jArrayListClass);
	env->DeleteLocalRef(jAddrList);
}
void WGPlatform::WGReportEvent(unsigned char* cName, unsigned char * cBody,
		bool isRealTime) {
	LOGD("WGPlatform::WGEnableReport bEnable %s", "");

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGReportEvent AttachCurrentThread env is null %s","");
	}

	if(cName == NULL){
		LOGD("WGReportEvent parameter cName is null %s","");
		return;
	}else if(cBody == NULL){
		LOGD("WGReportEvent parameter cBody is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGReportEvent", "(Ljava/lang/String;Ljava/lang/String;Z)V");

	jstring jName = StringFromStdString(env,(char const *) cName);
	jstring jBody = StringFromStdString(env,(char const *) cBody);
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jName, jBody,
			isRealTime);
	env->DeleteLocalRef(jName);
	env->DeleteLocalRef(jBody);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGReportEvent(unsigned char* cName, std::vector<KVPair>& cEventList,
		bool isRealTime) {
	LOGD("WGPlatform::WGReportEvent Vector %s", "");

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGReportEvent AttachCurrentThread env is null %s","");
	}

	if(cName == NULL){
		LOGD("WGReportEvent parameter cName is null %s","");
		return;
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGReportEvent", "(Ljava/lang/String;Ljava/util/HashMap;Z)V");
	jstring jName = StringFromStdString(env,(char const *) cName);
	jclass jHashMapClass = env->FindClass("java/util/HashMap");
	jmethodID jInitMethod = env->GetMethodID(jHashMapClass, "<init>", "()V");
	jmethodID jPutMethod = env->GetMethodID(jHashMapClass, "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
	//	HashMap<String, String> extraMap = new HashMap<String, String>();
	jobject jparams = env->NewObject(jHashMapClass, jInitMethod);

	for (int i = 0; i < cEventList.size(); i++) {
		jstring jKey = StringFromStdString(env,
				(const char *) cEventList.at(i).key.c_str());
		jstring jValue = StringFromStdString(env,
						(const char *) cEventList.at(i).value.c_str());
		jobject map = env->CallObjectMethod(jparams, jPutMethod, jKey,jValue);
		env->DeleteLocalRef(map);
		env->DeleteLocalRef(jKey);
		env->DeleteLocalRef(jValue);
	}
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jName, jparams,isRealTime);
	env->DeleteLocalRef(jHashMapClass);
	env->DeleteLocalRef(jName);
	env->DeleteLocalRef(jparams);

	ON_FUNC_OUT(__func__);
}

const std::string WGPlatform::WGGetChannelId() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetChannelId AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetChannelId", "()Ljava/lang/String;");

	jstring jChannelId = (jstring) env->CallStaticObjectMethod(
			s_WGPlatformClass, method);

	jboolean isCopy;
	const char* cChannel = env->GetStringUTFChars(jChannelId, &isCopy);
	std::string cChannelStr = cChannel;
	env->ReleaseStringUTFChars(jChannelId, cChannel);
	env->DeleteLocalRef(jChannelId);

	ON_FUNC_OUT(__func__);

	return cChannelStr;
}

const std::string WGPlatform::WGGetPlatformAPPVersion(ePlatform platform) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetPlatformAPPVersion AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass WGCommonClass = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID getEnum = env->GetStaticMethodID(WGCommonClass, "getEnum",
					"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject enumObj = env->CallStaticObjectMethod(WGCommonClass, getEnum,
					(int) platform);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetPlatformAPPVersion", "(Lcom/tencent/msdk/consts/EPlatform;)Ljava/lang/String;");

	jstring jAPPVersion = (jstring) env->CallStaticObjectMethod(
			s_WGPlatformClass, method,enumObj);

	jboolean isCopy;
	const char* cAPPVersion = env->GetStringUTFChars(jAPPVersion, &isCopy);
	std::string cAPPVersionStr = cAPPVersion;
	env->ReleaseStringUTFChars(jAPPVersion, cAPPVersion);
	env->DeleteLocalRef(jAPPVersion);
	env->DeleteLocalRef(WGCommonClass);
	env->DeleteLocalRef(enumObj);
	ON_FUNC_OUT(__func__);
	return cAPPVersionStr;
}

bool WGPlatform::WGIsPlatformInstalled(ePlatform platform) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGIsPlatformInstalled AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass WGCommonClass = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID getEnum = env->GetStaticMethodID(WGCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject enumObj = env->CallStaticObjectMethod(WGCommonClass, getEnum,
			(int) platform);

	jboolean result;
	jmethodID isInstalled;
	isInstalled = env->GetStaticMethodID(s_WGPlatformClass,
			"WGIsPlatformInstalled", "(Lcom/tencent/msdk/consts/EPlatform;)Z");

	result = env->CallStaticBooleanMethod(s_WGPlatformClass, isInstalled,
			enumObj);
	env->DeleteLocalRef(WGCommonClass);
	env->DeleteLocalRef(enumObj);
	ON_FUNC_OUT(__func__);
	return result;
}

bool WGPlatform::WGIsPlatformSupportApi(ePlatform platform) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGIsPlatformSupportApi AttachCurrentThread env is null %s","");
	}
	jclass WGCommonClass = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID getEnum = env->GetStaticMethodID(WGCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject enumObj = env->CallStaticObjectMethod(WGCommonClass, getEnum,
			(int) platform);

	jboolean result;
	jmethodID isSupportApi;
	isSupportApi = env->GetStaticMethodID(s_WGPlatformClass,
			"WGIsPlatformSupportApi", "(Lcom/tencent/msdk/consts/EPlatform;)Z");
	result = env->CallStaticBooleanMethod(s_WGPlatformClass, isSupportApi,
			enumObj);
	env->DeleteLocalRef(WGCommonClass);
	env->DeleteLocalRef(enumObj);
	return (bool) result;
}

const std::string WGPlatform::WGGetRegisterChannelId() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetRegisterChannelId AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetRegisterChannelId", "()Ljava/lang/String;");

	jstring jRegChannelId = (jstring) env->CallStaticObjectMethod(
			s_WGPlatformClass, method);

	jboolean isCopy;
	const char* cRegChannel = env->GetStringUTFChars(jRegChannelId, &isCopy);
	std::string cRegChannelStr = cRegChannel;
	env->ReleaseStringUTFChars(jRegChannelId, cRegChannel);
	env->DeleteLocalRef(jRegChannelId);

	ON_FUNC_OUT(__func__);

	return cRegChannelStr;
}

void WGPlatform::WGRefreshWXToken() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGRefreshWXToken AttachCurrentThread env is null %s","");
	}
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass, "WGRefreshWXToken",
			"()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

const std::string WGPlatform::WGGetPf(unsigned char * cGameCustomInfo) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetPf AttachCurrentThread env is null %s","");
	}

	if(cGameCustomInfo == NULL){
			LOGD("WGGetPf parameter cGameCustomInfo is null %s","");
			return "";
	}
	ON_FUNC_INTER(__func__);
	jmethodID method= env->GetStaticMethodID(s_WGPlatformClass, "WGGetPf",
			"(Ljava/lang/String;)Ljava/lang/String;");
	jstring jGameCustomInfo = StringFromStdString(env,(char const*)cGameCustomInfo);
	jstring jPf = (jstring) env->CallStaticObjectMethod(s_WGPlatformClass,
			method, jGameCustomInfo);

	jboolean isCopy;
	const char* cPf = env->GetStringUTFChars(jPf, &isCopy);
	std::string cPfStr = cPf;
	env->DeleteLocalRef(jGameCustomInfo);
	env->ReleaseStringUTFChars(jPf, cPf);
	env->DeleteLocalRef(jPf);

	ON_FUNC_OUT(__func__);

	return cPfStr;
}

const std::string WGPlatform::WGGetPfKey() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetPfKey AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass, "WGGetPfKey",
			"()Ljava/lang/String;");

	jstring jPfKey = (jstring) env->CallStaticObjectMethod(s_WGPlatformClass,
			method);

	jboolean isCopy;
	const char* cPfKey = env->GetStringUTFChars(jPfKey, &isCopy);
	std::string cPfKeyStr = cPfKey;
	env->ReleaseStringUTFChars(jPfKey, cPfKey);
	env->DeleteLocalRef(jPfKey);

	ON_FUNC_OUT(__func__);

	return cPfKeyStr;
}

/*
 fopenids 里面只放一个openid，分享两个测试失败
 previewText 非必需 不超过45字节
 game_tag 取下面几种 非必须
 MSG_INVITE                //邀请
 MSG_FRIEND_EXCEED       //超越炫耀
 MSG_HEART_SEND          //送心
 MSG_SHARE_FRIEND_PVP    //PVP对战
 */
bool WGPlatform::WGSendToQQGameFriend(
		int cAct,
		unsigned char* cFriendOpenid,
		unsigned char *cTitle,
		unsigned char *cSummary,
		unsigned char *cTargetUrl,
		unsigned char *cImgUrl,
		unsigned char* cPreviewText,
		unsigned char* cGameTag) {
	std::string extInfo = "";
	return WGSendToQQGameFriend(cAct, cFriendOpenid, cTitle, cSummary, cTargetUrl, cImgUrl, cPreviewText, cGameTag, (unsigned char *)extInfo.c_str());
}

bool WGPlatform::WGSendToQQGameFriend(
		int cAct,
		unsigned char *cFriendOpenid,
		unsigned char *cTitle,
		unsigned char *cSummary,
		unsigned char *cTargetUrl,
		unsigned char *cImgUrl,
		unsigned char *cPreviewText,
		unsigned char *cGameTag,
		unsigned char *cExtMsdkinfo){

	JNIEnv *env;
	LOGD("WGSendToQQGameFriend cAct %d : ", cAct);
	LOGD("WGSendToQQGameFriend cFriendOpenid : %s ", cFriendOpenid);
	LOGD("WGSendToQQGameFriend cTitle : %s ", cTitle);
	LOGD("WGSendToQQGameFriend cSummary : %s ", cSummary);
	LOGD("WGSendToQQGameFriend cTargetUrl : %s ", cTargetUrl);
	LOGD("WGSendToQQGameFriend cImgUrl : %s ", cImgUrl);
	LOGD("WGSendToQQGameFriend cPreviewText : %s ", cPreviewText);
	LOGD("WGSendToQQGameFriend cGameTag : %s ", cGameTag);
	LOGD("WGSendToQQGameFriend cExtMsdkinfo : %s ", cExtMsdkinfo);

	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToQQGameFriend AttachCurrentThread env is null %s","");
	}

	if(cFriendOpenid == NULL){
			LOGD("WGSendToQQGameFriend parameter cFriendOpenid is null %s","");
			return false;
	}else if(cTitle == NULL){
		LOGD("WGSendToQQGameFriend parameter cTitle is null %s","");
		return false;
	}else if(cSummary == NULL){
		LOGD("WGSendToQQGameFriend parameter cSummary is null %s","");
		return false;
	}else if(cTargetUrl == NULL){
		LOGD("WGSendToQQGameFriend parameter cTargetUrl is null %s","");
		return false;
	}else if(cImgUrl == NULL){
		LOGD("WGSendToQQGameFriend parameter cImgUrl is null %s","");
		return false;
	}else if(cPreviewText == NULL){
		LOGD("WGSendToQQGameFriend parameter cPreviewText is null %s","");
		return false;
	}else if(cGameTag == NULL){
		LOGD("WGSendToQQGameFriend parameter cGameTag is null %s","");
		return false;
	}
	ON_FUNC_INTER(__func__);
	jint jAct = (jint) cAct;
	jstring jFriendOpenid = StringFromStdString(env,(char const*) cFriendOpenid);
	jstring jTitle = StringFromStdString(env,(char const*) cTitle);
	jstring jSummary = StringFromStdString(env,(char const*) cSummary);
	jstring jTargetUrl = StringFromStdString(env,(char const*) cTargetUrl);
	jstring jImgUrl = StringFromStdString(env,(char const*) cImgUrl);
	jstring jPreviewText = StringFromStdString(env,(char const*) cPreviewText);
	jstring jGameTag = StringFromStdString(env,(char const*) cGameTag);
	jstring jExtMsdkInfo = StringFromStdString(env,cExtMsdkinfo == NULL  ? "" : (const char*) cExtMsdkinfo);

	jmethodID WGSendToQQGameFriend =
			env->GetStaticMethodID(s_WGPlatformClass, "WGSendToQQGameFriend",
					"(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z");
	LOGD("WGSendToQQGameFriend befor java %d", cAct);
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGSendToQQGameFriend, jAct, jFriendOpenid, jTitle, jSummary,
			jTargetUrl, jImgUrl, jPreviewText, jGameTag, jExtMsdkInfo);

	env->DeleteLocalRef(jFriendOpenid);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jSummary);
	env->DeleteLocalRef(jTargetUrl);
	env->DeleteLocalRef(jImgUrl);
	env->DeleteLocalRef(jPreviewText);
	env->DeleteLocalRef(jGameTag);
	env->DeleteLocalRef(jExtMsdkInfo);
	LOGD("WGSendToQQGameFriend end ret = %d : ", ret);

	ON_FUNC_OUT(__func__);

	return ret;
}
bool WGPlatform::WGSendToWXGameFriend(
		unsigned char *cFriendOpenId,
		unsigned char *cTitle,
		unsigned char *cDescription,
		unsigned char *cMediaId,
		unsigned char* cMessageExt,
		unsigned char *cMediaTagName
		) {
	std::string msdkExtInfo = "";
	return WGSendToWXGameFriend(
			cFriendOpenId,
			cTitle,
			cDescription,
			cMediaId,
			cMessageExt,
			cMediaTagName,
			(unsigned char *)msdkExtInfo.c_str()
			);
}

/**
 *  重载WGSendToWXGameFriend接口，增加extInfo字段。
 *  extInfo由游戏传入，分享结果通过OnShareNotify回调给游戏的时候会在shareRet.extInfo中返回给游戏
 *  游戏可以用extInfo区分request
 */
bool WGPlatform::WGSendToWXGameFriend(
    unsigned char* cFriendOpenId,
    unsigned char* cTitle,
    unsigned char* cDescription,
    unsigned char* cMediaId,
    unsigned char* cMessageExt,
    unsigned char* cMediaTagName,
    unsigned char* cExtMsdkInfo
) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWXGameFriend AttachCurrentThread env is null %s","");
	}

	if(cFriendOpenId == NULL){
		LOGD("WGSendToWXGameFriend parameter cFriendOpenId is null %s","");
		return false;
	}else if(cTitle == NULL){
		LOGD("WGSendToWXGameFriend parameter cTitle is null %s","");
		return false;
	}else if(cMediaId == NULL){
		LOGD("WGSendToWXGameFriend parameter cMediaId is null %s","");
		return false;
	}else if(cDescription == NULL){
		LOGD("WGSendToWXGameFriend parameter cDescription is null %s","");
		return false;
	}else if(cMediaTagName == NULL){
		LOGD("WGSendToWXGameFriend parameter cMediaTagName is null %s","");
		return false;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGSendToWXGameFriend cFriendOpenId : %s ", cFriendOpenId);
	LOGD("WGSendToWXGameFriend cTitle : %s ", cTitle);
	LOGD("WGSendToWXGameFriend cMediaId : %s ", cMediaId);
	LOGD("WGSendToWXGameFriend cMessageExt : %s ", cMessageExt);
	LOGD("WGSendToWXGameFriend cMediaTagName : %s ", cMediaTagName);
	LOGD("WGSendToWXGameFriend cDescription : %s ", cDescription);
	LOGD("WGSendToWXGameFriend cExtMsdkInfo : %s ", cExtMsdkInfo);

	jstring jFriendOpenid = StringFromStdString(env,(char const*) cFriendOpenId);
	jstring jTitle = StringFromStdString(env,(char const*) cTitle);
	jstring jDescription = StringFromStdString(env,(char const*) cDescription);
	jstring jMediaId = StringFromStdString(env,(char const*) cMediaId);
	jstring jMessageExt = StringFromStdString(env,cMessageExt == NULL  ? "" : (const char*) cMessageExt);
	jstring jMediaTagName = StringFromStdString(env,(char const*) cMediaTagName);
	jstring jExtMsdkInfo = StringFromStdString(env,cExtMsdkInfo == NULL  ? "" : (const char*) cExtMsdkInfo);

	jmethodID WGSendToWXGameFriend =
			env->GetStaticMethodID(s_WGPlatformClass, "WGSendToWXGameFriend",
					"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z");
	/************************************************************************
	 * 这里C++层和Java的参数顺序不一致, 保持接口不变, 通过此处来适配Java和C++接口
	 ************************************************************************/
	bool ret = env->CallStaticBooleanMethod(
			s_WGPlatformClass,
			WGSendToWXGameFriend,
			jFriendOpenid,
			jTitle,
			jDescription,
			jMessageExt,
			jMediaTagName,
			jMediaId,
			jExtMsdkInfo);

	env->DeleteLocalRef(jFriendOpenid);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDescription);
	env->DeleteLocalRef(jMediaId);
	env->DeleteLocalRef(jMessageExt);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jExtMsdkInfo);
	LOGD("WGSendToWXGameFriend end ret = %d : ", ret);

	ON_FUNC_OUT(__func__);

	return ret;
}

bool WGPlatform::WGQueryQQMyInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryQQMyInfo AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGQueryQQMyInfo = env->GetStaticMethodID(s_WGPlatformClass,
			"WGQueryQQMyInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryQQMyInfo);

	ON_FUNC_OUT(__func__);

	return ret;
}
bool WGPlatform::WGQueryQQGameFriendsInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryQQGameFriendsInfo AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGQueryQQGameFriendsInfo = env->GetStaticMethodID(
			s_WGPlatformClass, "WGQueryQQGameFriendsInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryQQGameFriendsInfo);

	ON_FUNC_OUT(__func__);

	return ret;
}
bool WGPlatform::WGQueryWXMyInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryWXMyInfo AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGQueryWXMyInfo = env->GetStaticMethodID(s_WGPlatformClass,
			"WGQueryWXMyInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryWXMyInfo);

	ON_FUNC_OUT(__func__);

	return ret;
}
bool WGPlatform::WGQueryWXGameFriendsInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryWXGameFriendsInfo AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID WGQueryWXGameFriendsInfo = env->GetStaticMethodID(
			s_WGPlatformClass, "WGQueryWXGameFriendsInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryWXGameFriendsInfo);

	ON_FUNC_OUT(__func__);

	return ret;
}
bool WGPlatform::WGCheckApiSupport(eApiName apiName) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCheckApiSupport AttachCurrentThread env is null %s","");
	}
	jmethodID WGCheckApiSupport = env->GetStaticMethodID(s_WGPlatformClass,
			"WGCheckApiSupport", "(Lcom/tencent/msdk/qq/ApiName;)Z");

	jclass jApiNameClz = env->FindClass("com/tencent/msdk/qq/ApiName");
	jmethodID jApiNameGetEnumMethod = env->GetStaticMethodID(jApiNameClz,
			"getEnum", "(I)Lcom/tencent/msdk/qq/ApiName;");
	jobject jApiName = env->CallStaticObjectMethod(jApiNameClz,
			jApiNameGetEnumMethod, (int) apiName);
	bool rtn = (bool) env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGCheckApiSupport, jApiName);

	env->DeleteLocalRef(jApiNameClz);
	env->DeleteLocalRef(jApiName);
	return rtn;
}
void WGPlatform::WGLogPlatformSDKVersion() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGLogPlatformSDKVersion AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGLogPlatformSDKVersion", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}


void WGPlatform::WGRealNameAuth(RealNameAuthInfo &info){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGRealNameAuth AttachCurrentThread env is null %s","");
	}
	jclass jAuthInfoClass = env->FindClass("com/tencent/msdk/api/RealNameAuthInfo");
	jmethodID jstruct = env->GetMethodID(jAuthInfoClass, "<init>", "()V");
	jobject jRealNameAuthInfoObject= env->NewObject(jAuthInfoClass, jstruct);


	jclass jeIDTypeClass = env->FindClass("com/tencent/msdk/api/eIDType");
	jmethodID jjeIDTypeEnumMethod = env->GetStaticMethodID(jeIDTypeClass, "getEnum",
				"(I)Lcom/tencent/msdk/api/eIDType;");
	jobject jEnumObj = env->CallStaticObjectMethod(jeIDTypeClass, jjeIDTypeEnumMethod,
				(int) info.identityType);
	env->DeleteLocalRef(jeIDTypeClass);

	jfieldID jidentityID = env->GetFieldID(jAuthInfoClass,"identityType","Lcom/tencent/msdk/api/eIDType;");
	env->SetObjectField(jRealNameAuthInfoObject,jidentityID,jEnumObj);
	env->DeleteLocalRef(jEnumObj);

	jfieldID jprovinceIDID = env->GetFieldID(jAuthInfoClass,"provinceID","I");
	env->SetIntField(jRealNameAuthInfoObject,jprovinceIDID,(int)info.provinceID);

	jfieldID jidentityNumID = env->GetFieldID(jAuthInfoClass,"identityNum","Ljava/lang/String;");
	jstring jidentityNum = StringFromStdString(env,info.identityNum.c_str());
	env->SetObjectField(jRealNameAuthInfoObject,jidentityNumID,jidentityNum);
	env->DeleteLocalRef(jidentityNum);

	jfieldID jnameID = env->GetFieldID(jAuthInfoClass,"name","Ljava/lang/String;");
	jstring jname = StringFromStdString(env,info.name.c_str());
	env->SetObjectField(jRealNameAuthInfoObject,jnameID,jname);
	env->DeleteLocalRef(jname);

	jfieldID jcityID = env->GetFieldID(jAuthInfoClass,"city","Ljava/lang/String;");
	jstring jcity = StringFromStdString(env,info.city.c_str());
	env->SetObjectField(jRealNameAuthInfoObject,jcityID,jcity);
	env->DeleteLocalRef(jcity);

	//LOGD("OnLoginNotify:Need_Realname_Auth %d",6);
	jmethodID jWGRealNameAuth = env->GetStaticMethodID(s_WGPlatformClass, "WGRealNameAuth","(Lcom/tencent/msdk/api/RealNameAuthInfo;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGRealNameAuth, jRealNameAuthInfoObject);
	//LOGD("OnLoginNotify:Need_Realname_Auth %d",7);
	env->DeleteLocalRef(jAuthInfoClass);
	env->DeleteLocalRef(jRealNameAuthInfoObject);

}

/*
 * @param type   公告类型
 * 	  eMSG_NOTICETYPE_ALERT: 弹出公告
 * 	  eMSG_NOTICETYPE_SCROLL: 滚动公告
 * @param scene 公告场景ID
 */
std::vector<NoticeInfo> WGPlatform::WGGetNoticeData(char* cScene){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetNoticeData AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	//转化参数为jni格式
	jstring jScene = StringFromStdString(env,(char const*) cScene);
	jclass jMsgTypeClass = env->FindClass("com/tencent/msdk/notice/eMSG_NOTICETYPE");
	jmethodID jGetMsgTypeValueMethod = env->GetMethodID(jMsgTypeClass, "val","()I");

	jclass jContentTypeClass = env->FindClass("com/tencent/msdk/notice/eMSG_CONTENTTYPE");
	jmethodID jGetContentTypeEnumMethod = env->GetStaticMethodID(jContentTypeClass, "getEnum",
			"(I)Lcom/tencent/msdk/notice/eMSG_CONTENTTYPE;");
	jmethodID jGetContentTypeValueMethod = env->GetMethodID(jContentTypeClass, "val","()I");

	jclass jPicScreenDirClass = env->FindClass("com/tencent/msdk/notice/eMSDK_SCREENDIR");
	jmethodID jGetPicScreenDirEnumMethod = env->GetStaticMethodID(jPicScreenDirClass, "getEnum",
			"(I)Lcom/tencent/msdk/notice/eMSDK_SCREENDIR;");
	jmethodID jGetPicScreenDirValueMethod = env->GetMethodID(jPicScreenDirClass, "val","()I");
	jclass jVectorClass = env->FindClass("java/util/Vector");
	jmethodID jVectorInitMethod = env->GetMethodID(jVectorClass, "<init>", "()V");
	jmethodID jVectorSizeMethod = env->GetMethodID(jVectorClass, "size", "()I");
	jmethodID jVectorGetMethod = env->GetMethodID(jVectorClass, "get", "(I)Ljava/lang/Object;");
	//LOGD("WGPlatform::WGGetNoticeData1 %s", "");
	//jobject jNoticeVectorObj = env->NewObject(jVectorClass, jVectorInitMethod);
	jmethodID jWGGetNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass,"WGGetNoticeData",
					"(Ljava/lang/String;)Ljava/util/Vector;");
	jobject jNoticeVectorObj = env->CallStaticObjectMethod(s_WGPlatformClass,jWGGetNoticeMethod,jScene);
	//noticeinfo 对象
	jclass jNoticeInfoClass = env->FindClass("com/tencent/msdk/notice/NoticeInfo");
	jmethodID jNoticeInfoInitMethod = env->GetMethodID(jNoticeInfoClass, "<init>", "()V");
	jfieldID jmsg_type = env->GetFieldID(jNoticeInfoClass,"mNoticeType","Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;");
	jclass jNoticePicClass = env->FindClass("com/tencent/msdk/notice/NoticePic");
	jmethodID jNoticePicInitMethod = env->GetMethodID(jNoticePicClass, "<init>", "()V");
	std::vector<NoticeInfo> noticeVector;
	jint jnoticeVectorLength = env->CallIntMethod(jNoticeVectorObj,jVectorSizeMethod);
	LOGD("PlatformTest_WGGetNotice jnoticeVectorLength:%d", jnoticeVectorLength);
	for(int i=0; i < jnoticeVectorLength; i++){
		//jobject jNoticeInfoObj = env->NewObject(jNoticeInfoClass, jNoticeInfoInitMethod);
		jobject jNoticeInfoObj = env->CallObjectMethod(jNoticeVectorObj,jVectorGetMethod,i);
		NoticeInfo tempNoticeInfo;
//		jfieldID jmsgIdFiled = env->GetFieldID(jNoticeInfoClass, "mNoticeId", "I");
//		jint tempMsgId = env->GetIntField(jNoticeInfoObj, jmsgIdFiled);
		JniGetAndSetStringField(msg_id,"mNoticeId",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(open_id,"mOpenId",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(msg_url,"mNoticeUrl",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		jmsg_type = env->GetFieldID(jNoticeInfoClass,"mNoticeType","Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;");
		jobject jTempMsgTypeEnumObj = env->GetObjectField(jNoticeInfoObj,jmsg_type);
		int temp_msg_type =(int) env->CallIntMethod(jTempMsgTypeEnumObj,jGetMsgTypeValueMethod);
		tempNoticeInfo.msg_type = (eMSG_NOTICETYPE) temp_msg_type;
		JniGetAndSetStringField(msg_scene,"mNoticeScene",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(start_time,"mNoticeStartTime",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(end_time,"mNoticeEndTime",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		jfieldID jcontent_type = env->GetFieldID(jNoticeInfoClass,"mNoticeContentType","Lcom/tencent/msdk/notice/eMSG_CONTENTTYPE;");
		jobject jTempContentTypeEnumObj = env->GetObjectField(jNoticeInfoObj,jcontent_type);
		int temp_content_type =(int) env->CallIntMethod(jTempContentTypeEnumObj,jGetContentTypeValueMethod);
		tempNoticeInfo.content_type = (_eMSG_CONTENTTYPE) temp_content_type;
		JniGetAndSetStringField(msg_title,"mNoticeTitle",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(msg_content,"mNoticeContent",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		JniGetAndSetStringField(msg_order,"mNoticeOrder",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		//jobject jNoticePicObj = env->NewObject(jVectorClass, jVectorInitMethod);
		jfieldID jNoticePicVecFiled = env->GetFieldID(jNoticeInfoClass, "mNoticePics", "Ljava/util/Vector;");
		jobject jNoticePicVecObj = env->GetObjectField(jNoticeInfoObj, jNoticePicVecFiled);
		jint jNoticePicVectorLength = env->CallIntMethod(jNoticePicVecObj,jVectorSizeMethod);
		std::vector<PicInfo> picInfoVector;
		for(int j=0; j < jNoticePicVectorLength; j++){
			//jobject jNoticePicObj = env->NewObject(jNoticePicClass, jNoticePicInitMethod);
			jobject jNoticePicObj = env->CallObjectMethod(jNoticePicVecObj,jVectorGetMethod,j);
			PicInfo tempPicInfo;
			jfieldID jPicScreenDirFiled = env->GetFieldID(jNoticePicClass,"mScreenDir","Lcom/tencent/msdk/notice/eMSDK_SCREENDIR;");
			jobject jTempPicScreenDirEnumObj = env->GetObjectField(jNoticePicObj,jPicScreenDirFiled);
			int temp_screenDir = (int) env->CallIntMethod(jTempPicScreenDirEnumObj,jGetPicScreenDirValueMethod);
			tempPicInfo.screenDir = (eMSDK_SCREENDIR) temp_screenDir;
			JniGetAndSetStringField(picPath,"mPicUrl",jNoticePicClass, jNoticePicObj,tempPicInfo);
			JniGetAndSetStringField(hashValue,"mPicHash",jNoticePicClass, jNoticePicObj,tempPicInfo);
			picInfoVector.push_back(tempPicInfo);
			env->DeleteLocalRef(jNoticePicObj);
			env->DeleteLocalRef(jTempPicScreenDirEnumObj);
		}
		JniGetAndSetStringField(content_url,"mNoticeContentWebUrl",jNoticeInfoClass, jNoticeInfoObj,tempNoticeInfo);
		tempNoticeInfo.picArray = picInfoVector;
		noticeVector.push_back(tempNoticeInfo);
		env->DeleteLocalRef(jTempMsgTypeEnumObj);
		env->DeleteLocalRef(jTempContentTypeEnumObj);
		env->DeleteLocalRef(jNoticeInfoObj);
		env->DeleteLocalRef(jNoticePicVecObj);
	}
	env->DeleteLocalRef(jMsgTypeClass);
	env->DeleteLocalRef(jContentTypeClass);
	env->DeleteLocalRef(jPicScreenDirClass);
	env->DeleteLocalRef(jVectorClass);
	env->DeleteLocalRef(jNoticeInfoClass);
	env->DeleteLocalRef(jNoticePicClass);
	env->DeleteLocalRef(jScene);
	env->DeleteLocalRef(jNoticeVectorObj);

	ON_FUNC_OUT(__func__);

	return noticeVector;
}

void WGPlatform::WGShowNotice(unsigned char* cScene){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGShowNotice AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jstring jScene = StringFromStdString(env,(char const*) cScene);
    jmethodID jWGShowNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGShowNotice", "(Ljava/lang/String;)V");

    env->CallStaticVoidMethod(s_WGPlatformClass, jWGShowNoticeMethod, jScene);
    env->DeleteLocalRef(jScene);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGHideScrollNotice(){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGHideScrollNotice AttachCurrentThread env is null %s","");
	}
	jmethodID jWGHideScrollNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGHideScrollNotice", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGHideScrollNoticeMethod);
}

void WGPlatform::WGOpenUrl(unsigned char * openUrl){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGOpenUrl AttachCurrentThread env is null %s","");
	}

	if(openUrl == NULL){
		LOGD("WGOpenUrl parameter openUrl is null %s","");
		return;
	}
	LOGD("WGOpenUrl openUrl %s : ", openUrl);
	jstring jOpenUrl = StringFromStdString(env,(char const*) openUrl);

	jmethodID WGOpenUrl =
			env->GetStaticMethodID(s_WGPlatformClass, "WGOpenUrl","(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass,WGOpenUrl, jOpenUrl);
	env->DeleteLocalRef(jOpenUrl);
}

void WGPlatform::WGOpenUrl(unsigned char * openUrl, const eMSDK_SCREENDIR &screendir){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGOpenUrl AttachCurrentThread env is null %s","");
	}

	if(openUrl == NULL){
		LOGD("WGOpenUrl parameter openUrl is null %s","");
		return;
	}
	LOGD("WGOpenUrl openUrl: %s ", openUrl);
	jstring jOpenUrl = StringFromStdString(env,(char const*) openUrl);

	jmethodID WGOpenUrl =
				env->GetStaticMethodID(s_WGPlatformClass, "WGOpenUrl","(Ljava/lang/String;Lcom/tencent/msdk/notice/eMSDK_SCREENDIR;)V");
	jclass jScreenClass = env->FindClass("com/tencent/msdk/notice/eMSDK_SCREENDIR");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jScreenClass, "getEnum", "(I)Lcom/tencent/msdk/notice/eMSDK_SCREENDIR;");
	jobject jscreendir = env->CallStaticObjectMethod(jScreenClass, jGetEnumMethod, (int)screendir);
	env->CallStaticVoidMethod(s_WGPlatformClass,WGOpenUrl, jOpenUrl,jscreendir);
	env->DeleteLocalRef(jOpenUrl);
	env->DeleteLocalRef(jScreenClass);
	env->DeleteLocalRef(jscreendir);
}

const std::string WGPlatform::WGGetEncodeUrl(unsigned char * openUrl) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetEncodeUrl AttachCurrentThread env is null %s","");
	}

	if(openUrl == NULL){
		LOGD("WGGetEncodeUrl parameter openUrl is null %s","");
		return "";
	}
	LOGD("WGGetEncodeUrl openUrl : %s", openUrl);
	jstring jOpenUrl = StringFromStdString(env,(char const*) openUrl);
	jmethodID WGGetEncodeUrl = env->GetStaticMethodID(s_WGPlatformClass, "WGGetEncodeUrl", "(Ljava/lang/String;)Ljava/lang/String;");
	jstring jEncodeUrl = (jstring)env->CallStaticObjectMethod(s_WGPlatformClass, WGGetEncodeUrl, jOpenUrl);

	jboolean isCopy;
	const char * cEncodeUrl = env->GetStringUTFChars(jEncodeUrl, &isCopy);
	std::string sEncodeUrl = cEncodeUrl;
	env->ReleaseStringUTFChars(jEncodeUrl, cEncodeUrl);
	env->DeleteLocalRef(jOpenUrl);
	return sEncodeUrl;
}


bool WGPlatform::WGOpenAmsCenter(unsigned char * cParams) {
	LOGD("%s", "WGOpenAmsCenter called!");
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGOpenAmsCenter AttachCurrentThread env is null %s","");
	}

	if(cParams == NULL){
		LOGD("WGOpenAmsCenter parameter cParams is null %s","");
		return false;
	}
	jmethodID jWGOpenAmsCenterMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGOpenAmsCenter","(Ljava/lang/String;)Z");
	jstring jParams = StringFromStdString(env,(const char *)cParams);
	jboolean rtn = env->CallStaticBooleanMethod(s_WGPlatformClass, jWGOpenAmsCenterMethod, jParams);
	env->DeleteLocalRef(jParams);
	return rtn;
}

void WGPlatform::WGLoginWithLocalInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGLoginWithLocalInfo AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGLoginWithLocalInfo", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGGetNearbyPersonInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetNearbyPersonInfo AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGGetNearbyPersonInfo", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

bool WGPlatform::WGCleanLocation() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCleanLocation AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCleanLocation", "()Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, method);
}

bool WGPlatform::WGGetLocationInfo() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGGetLocationInfo AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGGetLocationInfo", "()Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, method);
}

bool WGPlatform::WGSendMessageToWechatGameCenter(unsigned char* friendOpenId,
		unsigned char* title, unsigned char* content, WXMessageTypeInfo *pInfo,
		WXMessageButton *pButton, unsigned char * msdkExtInfo) {
	LOGD("WGSendMessageToWechatGameCenter friendOpenId: %s", friendOpenId);
	LOGD("WGSendMessageToWechatGameCenter title: %s", title);
	LOGD("WGSendMessageToWechatGameCenter content: %s", content);
	LOGD("WGSendMessageToWechatGameCenter msdkExtInfo: %s", msdkExtInfo);

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendMessageToWechatGameCenter AttachCurrentThread env is null %s","");
	}

	if(friendOpenId == NULL){
		LOGD("WGSendMessageToWechatGameCenter parameter friendOpenId is null %s","");
		return false;
	}else if(title == NULL){
		LOGD("WGSendMessageToWechatGameCenter parameter title is null %s","");
		return false;
	}else if(content == NULL){
		LOGD("WGSendMessageToWechatGameCenter parameter content is null %s","");
		return false;
	}else if(pInfo == NULL){
		LOGD("WGSendMessageToWechatGameCenter parameter pInfo is null %s","");
		return false;
	}else if(pButton == NULL){
		LOGD("WGSendMessageToWechatGameCenter parameter pButton is null %s","");
		return false;
	}
	jmethodID method =
			env->GetStaticMethodID(s_WGPlatformClass,
					"WGSendMessageToWechatGameCenter",
					"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/tencent/msdk/weixin/MsgBase;Lcom/tencent/msdk/weixin/BtnBase;Ljava/lang/String;)Z");
	jstring jFriendOpenId = StringFromStdString(env,(char const*) friendOpenId);
	jstring jTitle = StringFromStdString(env,(char const*) title);
	jstring jContent = StringFromStdString(env,(char const*) content);
	jstring jExtMsdkInfo = StringFromStdString(env,msdkExtInfo == NULL ? "" : (char const*) msdkExtInfo);

	jobject jMsg = pInfo->getJavaObject();
	jobject jBtn = pButton->getJavaObject();

	bool rtn = env->CallStaticBooleanMethod(s_WGPlatformClass, method, jFriendOpenId, jTitle, jContent, jMsg, jBtn, jExtMsdkInfo);

	env->DeleteLocalRef(jFriendOpenId);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jContent);
	env->DeleteLocalRef(jMsg);
	env->DeleteLocalRef(jBtn);
	env->DeleteLocalRef(jExtMsdkInfo);
	return rtn;
}

void WGPlatform::WGStartSaveUpdate(bool isUseYYB) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGStartSaveUpdate AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGStartSaveUpdate", "(Z)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method, isUseYYB);
}

void WGPlatform::WGSetSaveUpdateObserver(WGSaveUpdateObserver * saveUpdateObserver) {
	if (saveUpdateObserver == NULL) {
		LOGI("pNotify is NULL%s", "");
		return;
	}
	mSaveUpdateObserver = saveUpdateObserver;
}

void WGPlatform::WGCheckNeedUpdate() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCheckNeedUpdate AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCheckNeedUpdate", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

int WGPlatform::WGCheckYYBInstalled() {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCheckYYBInstalled AttachCurrentThread env is null %s","");
	}
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCheckYYBInstalled", "()I");
	return env->CallStaticIntMethod(s_WGPlatformClass, method);
}

void WGPlatform::WGOpenWeiXinDeeplink(unsigned char * link) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGOpenWeiXinDeeplink AttachCurrentThread env is null %s","");
	}
	if(link == NULL){
		LOGD("WGOpenWeiXinDeeplink parameter link is null %s","");
		return ;
	}

	LOGD("WGOpenWeiXinDeeplink %s : ", link);
	jstring jLink = StringFromStdString(env,(char const*) link);

	jmethodID WGOpenWeiXinDeeplink =
			env->GetStaticMethodID(s_WGPlatformClass, "WGOpenWeiXinDeeplink","(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGOpenWeiXinDeeplink, jLink);
	env->DeleteLocalRef(jLink);
}

void WGPlatform::WGStartGameStatus(unsigned char* cGameStatus){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGStartGameStatus AttachCurrentThread env is null %s","");
	}
	if(cGameStatus == NULL){
		LOGD("WGStartGameStatus parameter cGameStatus is null %s","");
		return ;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGOpenWeiXinDeeplink %s : ", cGameStatus);
	jstring jGameStatus = StringFromStdString(env,(char const*) cGameStatus);

	jmethodID jWGStartGameStatus =
			env->GetStaticMethodID(s_WGPlatformClass, "WGStartGameStatus","(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGStartGameStatus, jGameStatus);
	env->DeleteLocalRef(jGameStatus);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGEndGameStatus(unsigned char* cGameStatus, int succ, int errorCode){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGEndGameStatus AttachCurrentThread env is null %s","");
	}
	if(cGameStatus == NULL){
		LOGD("WGEndGameStatus parameter cGameStatus is null %s","");
		return ;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGOpenWeiXinDeeplink %s : ", cGameStatus);
	jstring jGameStatus = StringFromStdString(env,(char const*) cGameStatus);
	jint jSucc = (jint) succ;
	jint jErrorCode = (jint) errorCode;

	jmethodID jWGEndGameStatus =
			env->GetStaticMethodID(s_WGPlatformClass, "WGEndGameStatus","(Ljava/lang/String;II)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGEndGameStatus, jGameStatus,jSucc,jErrorCode);
	env->DeleteLocalRef(jGameStatus);

	ON_FUNC_OUT(__func__);
}
void WGPlatform::WGCreateWXGroup(unsigned char* unionid, unsigned char* chatRoomName,
		unsigned char* chatRoomNickName) {
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGCreateWXGroup AttachCurrentThread env is null %s","");
	}
	if(unionid == NULL){
		LOGD("WGCreateWXGroup parameter unionid is null %s","");
		return ;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGCreateWXGroup %s : ", "");
	jstring junionid = StringFromStdString(env,(char const*) unionid);
	jstring jchatRoomName = StringFromStdString(env,(char const*) chatRoomName);
	jstring jchatRoomNickName = StringFromStdString(env,(char const*) chatRoomNickName);

	jmethodID jWGCreateWXGroup =
			env->GetStaticMethodID(s_WGPlatformClass, "WGCreateWXGroup","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGCreateWXGroup, junionid,jchatRoomName,jchatRoomNickName);
	env->DeleteLocalRef(junionid);
	env->DeleteLocalRef(jchatRoomName);
	env->DeleteLocalRef(jchatRoomNickName);

	ON_FUNC_OUT(__func__);

}

void WGPlatform::WGJoinWXGroup(unsigned char* unionid, unsigned char* chatRoomNickName){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGJoinWXGroup AttachCurrentThread env is null %s","");
	}
	if(unionid == NULL){
		LOGD("WGJoinWXGroup parameter unionid is null %s","");
		return ;
	}else if(chatRoomNickName == NULL){
		LOGD("WGJoinWXGroup parameter chatRoomNickName is null %s","");
		return ;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGJoinWXGroup %s : ", "");
	jstring junionid = StringFromStdString(env,(char const*) unionid);
	jstring jchatRoomNickName = StringFromStdString(env,(char const*) chatRoomNickName);

	jmethodID jWGCreateWXGroup =
			env->GetStaticMethodID(s_WGPlatformClass, "WGJoinWXGroup","(Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGCreateWXGroup, junionid,jchatRoomNickName);
	env->DeleteLocalRef(junionid);
	env->DeleteLocalRef(jchatRoomNickName);

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGQueryWXGroupInfo(unsigned char* unionid, unsigned char* openIdList){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGQueryWXGroupInfo AttachCurrentThread env is null %s","");
	}
	if(unionid == NULL){
		LOGD("WGQueryWXGroupInfo parameter unionid is null %s","");
		return ;
	}else if(openIdList == NULL){
		LOGD("WGQueryWXGroupInfo parameter openIdList is null %s","");
		return ;
	}
	ON_FUNC_INTER(__func__);
	LOGD("WGQueryWXGroupInfo %s : ", "");
	jstring junionid = StringFromStdString(env,(char const*) unionid);
	jstring jopenIdList = StringFromStdString(env,(char const*) openIdList);

	jmethodID jWGCreateWXGroup =
			env->GetStaticMethodID(s_WGPlatformClass, "WGQueryWXGroupInfo","(Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGCreateWXGroup, junionid,jopenIdList);
	env->DeleteLocalRef(junionid);
	env->DeleteLocalRef(jopenIdList);

	ON_FUNC_OUT(__func__);
}

long WGPlatform::WGAddLocalNotification(LocalMessage &msg){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGAddLocalNotification AttachCurrentThread env is null %s","");
	}
	ON_FUNC_INTER(__func__);
	jclass jScreenClass = env->FindClass("com/tencent/msdk/api/LocalMessage");
	jmethodID jstruct = env->GetMethodID(jScreenClass, "<init>", "()V");
	jobject jLocalMessageObject= env->NewObject(jScreenClass, jstruct);

	if(msg.action_type != -1){
		jmethodID jsetAction_typeMethod = env->GetMethodID(jScreenClass, "setAction_type", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetAction_typeMethod, (int)msg.action_type);
	}

	if(msg.icon_type != -1){
		jmethodID jsetIcon_typeMethod = env->GetMethodID(jScreenClass, "setIcon_type", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetIcon_typeMethod, (int)msg.icon_type);
	}

	if(msg.lights != -1){
		jmethodID jsetLightsMethod = env->GetMethodID(jScreenClass, "setLights", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetLightsMethod, (int)msg.lights);
	}
	if(msg.ring != -1){
		jmethodID jsetRingMethod = env->GetMethodID(jScreenClass, "setRing", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetRingMethod, (int)msg.ring);
	}
	if(msg.vibrate != -1){
		jmethodID jsetVibrateMethod = env->GetMethodID(jScreenClass, "setVibrate", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetVibrateMethod, (int)msg.vibrate);
	}
	if(msg.style_id != -1){
		jmethodID jsetStyle_idMethod = env->GetMethodID(jScreenClass, "setStyle_id", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetStyle_idMethod, (int)msg.style_id);
	}
	if(msg.builderId != -1){
		jmethodID jsetBuilderIdMethod = env->GetMethodID(jScreenClass, "setBuilderId", "(J)V");
		env->CallVoidMethod(jLocalMessageObject, jsetBuilderIdMethod, (long)msg.builderId);
	}
	if(msg.type != -1){
		jmethodID jsetTypeMethod = env->GetMethodID(jScreenClass, "setType", "(I)V");
		env->CallVoidMethod(jLocalMessageObject, jsetTypeMethod, (int)msg.type);
	}


	jmethodID jsetActivityMethod = env->GetMethodID(jScreenClass, "setActivity", "(Ljava/lang/String;)V");
	//jstring setstring = env->NewStringUTF(msg.activity.c_str());
	jstring setstring = StringFromStdString(env,msg.activity.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetActivityMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetPackageDownloadUrlMethod = env->GetMethodID(jScreenClass, "setPackageDownloadUrl", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.packageDownloadUrl.c_str());
	setstring = StringFromStdString(env,msg.packageDownloadUrl.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetPackageDownloadUrlMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetPackageNameMethod = env->GetMethodID(jScreenClass, "setPackageName", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.packageName.c_str());
	setstring = StringFromStdString(env,msg.packageName.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetPackageNameMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetIcon_resMethod = env->GetMethodID(jScreenClass, "setIcon_res", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.icon_res.c_str());
	setstring = StringFromStdString(env,msg.icon_res.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetIcon_resMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetRing_rawMethod = env->GetMethodID(jScreenClass, "setRing_raw", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.ring_raw.c_str());
	setstring = StringFromStdString(env,msg.ring_raw.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetRing_rawMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetSmall_iconMethod = env->GetMethodID(jScreenClass, "setSmall_icon", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.small_icon.c_str());
	setstring = StringFromStdString(env,msg.small_icon.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetSmall_iconMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetContentMethod = env->GetMethodID(jScreenClass, "setContent", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.content.c_str());
	setstring = StringFromStdString(env,msg.content.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetContentMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetCustom_contentMethod = env->GetMethodID(jScreenClass, "setCustom_content", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.custom_content.c_str());
	setstring = StringFromStdString(env,msg.custom_content.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetCustom_contentMethod, setstring);
	env->DeleteLocalRef(setstring);


	jmethodID jsetDateMethod = env->GetMethodID(jScreenClass, "setDate", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.date.c_str());
	setstring = StringFromStdString(env,msg.date.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetDateMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetHourMethod = env->GetMethodID(jScreenClass, "setHour", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.hour.c_str());
	setstring = StringFromStdString(env,msg.hour.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetHourMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetIntentMethod = env->GetMethodID(jScreenClass, "setIntent", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.intent.c_str());
	setstring = StringFromStdString(env,msg.intent.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetIntentMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetMinMethod = env->GetMethodID(jScreenClass, "setMin", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.min.c_str());
	setstring = StringFromStdString(env,msg.min.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetMinMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetTitleMethod = env->GetMethodID(jScreenClass, "setTitle", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.title.c_str());
	setstring = StringFromStdString(env,msg.title.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetTitleMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jsetUrlMethod = env->GetMethodID(jScreenClass, "setUrl", "(Ljava/lang/String;)V");
	//setstring = env->NewStringUTF(msg.url.c_str());
	setstring = StringFromStdString(env,msg.url.c_str());
	env->CallVoidMethod(jLocalMessageObject, jsetUrlMethod, setstring);
	env->DeleteLocalRef(setstring);

	jmethodID jWGAddLocalNotification =
				env->GetStaticMethodID(s_WGPlatformClass, "WGAddLocalNotification","(Lcom/tencent/msdk/api/LocalMessage;)J");
	jlong id = env->CallStaticLongMethod(s_WGPlatformClass, jWGAddLocalNotification, jLocalMessageObject);
	env->DeleteLocalRef(jScreenClass);
	env->DeleteLocalRef(jLocalMessageObject);

	ON_FUNC_OUT(__func__);

	return (long)id;
}


void WGPlatform::WGClearLocalNotifications(){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGClearLocalNotifications AttachCurrentThread env is null %s","");
	}

	jmethodID jClearLocalNotifications =
			env->GetStaticMethodID(s_WGPlatformClass, "WGClearLocalNotifications","()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jClearLocalNotifications);
}


void WGPlatform::WGSetPushTag(std::string tag){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSetPushTag AttachCurrentThread env is null %s","");
	}
	jmethodID jSetPushTag =
		env->GetStaticMethodID(s_WGPlatformClass, "WGSetPushTag","(Ljava/lang/String;)V");
	jstring jtag = StringFromStdString(env,tag.c_str());
	env->CallStaticVoidMethod(s_WGPlatformClass, jSetPushTag,jtag);
	env->DeleteLocalRef(jtag);
}

void WGPlatform::WGDeletePushTag(std::string tag){
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGDeletePushTag AttachCurrentThread env is null %s","");
	}
	jmethodID jDeletePushTag =
		env->GetStaticMethodID(s_WGPlatformClass, "WGDeletePushTag","(Ljava/lang/String;)V");
	jstring jtag = StringFromStdString(env,tag.c_str());
	env->CallStaticVoidMethod(s_WGPlatformClass, jDeletePushTag,jtag);
	env->DeleteLocalRef(jtag);
}

void WGPlatform::WGSendToWXGroup(
		int msgType,
		int subType,
		unsigned char* unionid,
		unsigned char* title,
		unsigned char* description,
		unsigned char* messageExt,
		unsigned char* mediaTagName,
		unsigned char* imgUrl,
		unsigned char* msdkExtInfo) {
	LOGD("WGSendToWXGroup start  %s : ", "");
	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGSendToWXGroup AttachCurrentThread env is null %s","");
	}

	if(unionid == NULL){
		LOGD("WGSendToWXGroup parameter unionid is null %s","");
		return ;
	}else if(title == NULL){
		LOGD("WGSendToWXGroup parameter title is null %s","");
		return ;
	}else if(description == NULL){
		LOGD("WGSendToWXGroup parameter description is null %s","");
		return ;
	}else if(mediaTagName == NULL){
		LOGD("WGSendToWXGroup parameter mediaTagName is null %s","");
		return ;
	}else if(imgUrl == NULL){
		LOGD("WGSendToWXGroup parameter imgUrl is null %s","");
		return ;
	}

	ON_FUNC_INTER(__func__);
	jint jmsgType = (jint) msgType;
	jint jsubType = (jint) subType;
	jstring junionid = StringFromStdString(env,(char const*) unionid);
	jstring jtitle = StringFromStdString(env,(char const*) title);
	jstring jdescription = StringFromStdString(env,(char const*) description);
	jstring jmessageExt = StringFromStdString(env,messageExt == NULL  ? "" : (const char*) messageExt);
	jstring jmediaTagName = StringFromStdString(env,(char const*) mediaTagName);
	jstring jimgUrl = StringFromStdString(env,(char const*) imgUrl);
	jstring jmsdkExtInfo = StringFromStdString(env, msdkExtInfo == NULL ? "" : (char const*) msdkExtInfo);

	jmethodID jWGSendToWXGroup =
			env->GetStaticMethodID(s_WGPlatformClass, "WGSendToWXGroup",
					"(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass,jWGSendToWXGroup,
			jmsgType,
			jsubType,
			junionid,
			jtitle,
			jdescription,
			jmessageExt,
			jmediaTagName,
			jimgUrl,
			jmsdkExtInfo);

	env->DeleteLocalRef(junionid);
	env->DeleteLocalRef(jtitle);
	env->DeleteLocalRef(jdescription);
	env->DeleteLocalRef(jmessageExt);
	env->DeleteLocalRef(jmediaTagName);
	env->DeleteLocalRef(jimgUrl);
	env->DeleteLocalRef(jmsdkExtInfo);
	LOGD("WGSendToWXGroup end  %s : ", "");

	ON_FUNC_OUT(__func__);
}

void WGPlatform::WGBuglyLog (eBuglyLogLevel level, unsigned char* log) {
	LOGD("WGPlatform::WGBuglyLog %s", "");

	JNIEnv *env;
	int status = m_pVM->AttachCurrentThread(&env, NULL);
	if(status < 0){
		LOGD("WGBuglyLog AttachCurrentThread env is null %s","");
	}

	if(log == NULL){
		LOGD("WGBuglyLog parameter log is null %s","");
		return ;
	}

	jclass jCommonClass = env->FindClass("com/tencent/msdk/stat/eBuglyLogLevel");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jCommonClass, "getEnum",
			"(I)Lcom/tencent/msdk/stat/eBuglyLogLevel;");
	jobject jEnumObj = env->CallStaticObjectMethod(jCommonClass, jGetEnumMethod,
			(int) level);

	//jstring jLog = env->NewStringUTF((char const*) log);
	jstring jLog = StringFromStdString(env,(char const*) log);
	jmethodID WGBuglyLog = env->GetStaticMethodID(s_WGPlatformClass, "WGBuglyLog",
			"(Lcom/tencent/msdk/stat/eBuglyLogLevel;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGBuglyLog, jEnumObj, jLog);

	env->DeleteLocalRef(jLog);
	env->DeleteLocalRef(jCommonClass);
	env->DeleteLocalRef(jEnumObj);
}
