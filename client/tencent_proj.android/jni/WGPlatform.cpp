#include "CommonFiles/WGPlatform.h"
#include "CommonFiles/WGPlatformObserver.h"
#include <string>
#include <android/log.h>

static jclass s_WGPlatformClass;
static jclass s_LoginRetClass;

WGPlatform::WGPlatform() :
		m_pObserver(NULL),
		mSaveUpdateObserver(NULL),
		needDelayLoginNotify(false),
		needDelayWakeupNotify(false),
		m_nPermissions(0){
		m_pVM = NULL;
}
WGPlatform::~WGPlatform() {
}
//-----------------------------------------------------------------------------
void WGPlatform::init(JavaVM* pVM) {
	m_pVM = pVM;
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jclass cls = env->FindClass("com/tencent/msdk/api/WGPlatform");
	s_WGPlatformClass = (jclass) env->NewGlobalRef(cls);
	env->DeleteLocalRef(cls);
	cls = env->FindClass("com/tencent/msdk/api/LoginRet");
	s_LoginRetClass = (jclass) env->NewGlobalRef(cls);
	env->DeleteLocalRef(cls);
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
	m_pVM->AttachCurrentThread(&env, NULL);

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
}

bool WGPlatform::WGSwitchUser(bool switchToLaunchUser) {
	LOGD("WGPlatform::WGLogin platform:%d", switchToLaunchUser);
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
				"WGSwitchUser", "(Z)Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, method, switchToLaunchUser);
}

//-----------------------------------------------------------------------------
bool WGPlatform::WGLogout() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID WGLogout = env->GetStaticMethodID(s_WGPlatformClass, "WGLogout",
			"()Z");
	return env->CallStaticBooleanMethod(s_WGPlatformClass, WGLogout);
}

int WGPlatform::WGGetLoginRecord(LoginRet& lr) {
	JNIEnv* env;
	m_pVM->AttachCurrentThread(&env, NULL);

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
	return lr.platform;
}

WGPlatformObserver* WGPlatform::GetObserver() const {
	return m_pObserver;
}

WGSaveUpdateObserver* WGPlatform::GetSaveUpdateObserver() const {
	return mSaveUpdateObserver;
}

void WGPlatform::WGSetPermission(int permissions) {
	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

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
		unsigned char*messageExt
	) {
	LOGD("WGPlatform::WGSendToWeixin no scene title:%s", title);
	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID WGSendToWeixin = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixin",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BILjava/lang/String;)V");

	jstring jTitle = env->NewStringUTF((const char*) title);
	jstring jDesc = env->NewStringUTF((const char*) desc);
	jbyteArray jImgData = env->NewByteArray(thumbImgDataLen);
	jstring jMediaTagName = env->NewStringUTF((const char*) mediaTagName);
	jstring jMessageExt = env->NewStringUTF((const char*) messageExt);
	env->SetByteArrayRegion(jImgData, 0, thumbImgDataLen,
			(jbyte *) thumbImgData);

	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToWeixin, jTitle, jDesc,
			jMediaTagName, jImgData, thumbImgDataLen, jMessageExt);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jImgData);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jMessageExt);
}

void WGPlatform::WGSendToWeixinWithPhoto(const eWechatScene& cScene,
		unsigned char* mediaTagName, unsigned char* imgData,
		const int& imgDataLen) {
	LOGD("WGPlatform::WGSendToWeixinWithPhoto imgDataLen=%d", imgDataLen);

	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithPhoto", "(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;[BI)V");
	jbyteArray jImageData = env->NewByteArray(imgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageData, 0, imgDataLen, (jbyte *) imgData);
	jstring jMediaTagName = env->NewStringUTF((char const*) mediaTagName);

	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);

	env->CallStaticVoidMethod(s_WGPlatformClass, method, jScene, jMediaTagName,
			jImageData, imgDataLen);

	env->DeleteLocalRef(jImageData);
	env->DeleteLocalRef(jMediaTagName);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);
}
void WGPlatform::WGSendToWeixinWithPhoto(const eWechatScene& cScene,
		unsigned char* mediaTagName, unsigned char* imgData,
		const int& imgDataLen, unsigned char* messageExt,
		unsigned char* messageAction) {
	LOGD("WGPlatform::WGSendToWeixinWithPhoto imgDataLen=%d", imgDataLen);

	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithPhoto",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;[BILjava/lang/String;Ljava/lang/String;)V");

	jbyteArray jImageData = env->NewByteArray(imgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageData, 0, imgDataLen, (jbyte *) imgData);
	jstring jMediaTagName = env->NewStringUTF((char const*) mediaTagName);
	jstring jMessageExt = env->NewStringUTF((char const*) messageExt);
	jstring jMessageAction = env->NewStringUTF((char const*) messageAction);

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
}

void WGPlatform::WGSendToWeixinWithMusic(const eWechatScene& cScene, unsigned char* cTitle,
        unsigned char* cDesc, unsigned char* cMusicUrl, unsigned char* cMusicDataUrl,
        unsigned char *cMediaTagName, unsigned char *cImgData, const int &cImgDataLen,
        unsigned char *cMessageExt, unsigned char *cMessageAction){
	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID jWGSendToWeixinWithMusicMethod = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToWeixinWithMusic",
			"(Lcom/tencent/msdk/api/eWechatScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BILjava/lang/String;Ljava/lang/String;)V");

	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eWechatScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eWechatScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	jstring jTitle = env->NewStringUTF((char const *) cTitle);
	jstring jDesc = env->NewStringUTF((char const *) cDesc);
	jstring jMusicUrl = env->NewStringUTF((char const *) cMusicUrl);
	jstring jMusicDataUrl = env->NewStringUTF((char const *) cMusicDataUrl);
	jstring jMediaTagName = env->NewStringUTF((char const*) cMediaTagName);
	jbyteArray jImageDataArray = env->NewByteArray(cImgDataLen);
	// 把char*中的数据转到jByteArray中
	env->SetByteArrayRegion(jImageDataArray, 0, cImgDataLen, (jbyte *) cImgData);
	jint jImgDataLen = (jint) cImgDataLen;
	jstring jMessageExt = env->NewStringUTF((char const*) cMessageExt);
	jstring jMessageAction = env->NewStringUTF((char const*) cMessageAction);
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
}

void WGPlatform::WGSendToQQWithMusic(const eQQScene& cScene, unsigned char* cTitle,unsigned char* cDesc,
		unsigned char* cMusicUrl,unsigned char* cMusicDataUrl,unsigned char* cImgUrl){
	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);
	LOGD("WGPlatform::WGSendToQQWithMusic cScene=%d", (int)cScene);

	jmethodID jWGSendToQQMethod =
				env->GetStaticMethodID(s_WGPlatformClass,
						"WGSendToQQWithMusic",
						"(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	jstring jTitle = env->NewStringUTF((char const *) cTitle);
	jstring jDesc = env->NewStringUTF((char const *) cDesc);
	jstring jMusicUrl = env->NewStringUTF((char const *) cMusicUrl);
	jstring jMusicDataUrl = env->NewStringUTF((char const *) cMusicDataUrl);
	jstring jImgUrl = env->NewStringUTF((char const *) cImgUrl);
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
}

void WGPlatform::WGSendToQQ(const eQQScene& cScene, unsigned char* cTitle,
		unsigned char* cDesc, unsigned char* cUrl, unsigned char* cImgUrl,
		const int& imgUrlLen) {
	LOGD("WGPlatform::WGSendToQQ title:%s", cTitle);

	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID WGSendToQQ =
			env->GetStaticMethodID(s_WGPlatformClass, "WGSendToQQ",
					"(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jScene = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);
	jstring jTitle = env->NewStringUTF((char const *) cTitle);
	jstring jDesc = env->NewStringUTF((char const *) cDesc);
	jstring jUrl = env->NewStringUTF((char const *) cUrl);
	jstring jImgUrl = env->NewStringUTF((char const *) cImgUrl);
	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToQQ, jScene, jTitle,
			jDesc, jUrl, jImgUrl, imgUrlLen);

	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jScene);
	env->DeleteLocalRef(jTitle);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jUrl);
	env->DeleteLocalRef(jImgUrl);

}

void WGPlatform::WGSendToQQWithPhoto(const eQQScene& cScene, unsigned char* cImgFilePath) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID WGSendToQQWithPhoto = env->GetStaticMethodID(s_WGPlatformClass,
			"WGSendToQQWithPhoto", "(Lcom/tencent/msdk/api/eQQScene;Ljava/lang/String;)V");
	jclass jSceneClass = env->FindClass("com/tencent/msdk/api/eQQScene");
	jmethodID jGetEnumMethod = env->GetStaticMethodID(jSceneClass, "getEnum", "(I)Lcom/tencent/msdk/api/eQQScene;");
	jobject jSceneObj = env->CallStaticObjectMethod(jSceneClass, jGetEnumMethod, (int)cScene);

	jstring jImgFilePath = env->NewStringUTF((char const *) cImgFilePath);
	env->CallStaticVoidMethod(s_WGPlatformClass, WGSendToQQWithPhoto, jSceneObj,
			jImgFilePath);
	env->DeleteLocalRef(jSceneClass);
	env->DeleteLocalRef(jImgFilePath);
	env->DeleteLocalRef(jSceneObj);
}
int WGPlatform::WGFeedback(unsigned char* cGame, unsigned char* cTxt) {
	LOGD("WGPlatform::WGFeedBack txt:%s", cTxt);
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass, "WGFeedback",
			"(Ljava/lang/String;Ljava/lang/String;)Z");

	jstring jGame = env->NewStringUTF((char const *) cGame);
	jstring jTxt = env->NewStringUTF((char const *) cTxt);
	int rtn = env->CallStaticBooleanMethod(s_WGPlatformClass, method, jGame,
			jTxt);
	env->DeleteLocalRef(jGame);
	env->DeleteLocalRef(jTxt);
	return rtn;
}

void WGPlatform::WGFeedback(unsigned char* cBody) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jstring jTxt = env->NewStringUTF((char const *) cBody);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGFeedback",
			"(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jTxt);
	env->DeleteLocalRef(jTxt);
}


const std::string WGPlatform::WGGetVersion() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
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
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGEnableCrashReport", "(ZZ)V");

	env->CallStaticVoidMethod(s_WGPlatformClass, method, isRdmEnable,
			isMtaEnable);
}

void WGPlatform::WGTestSpeed(std::vector<std::string> &addrList) {
	JNIEnv * env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jclass jArrayListClass = env->FindClass("java/util/ArrayList");
	jmethodID jInitMethod = env->GetMethodID(jArrayListClass, "<init>", "()V");
	jmethodID jSizeMethod = env->GetMethodID(jArrayListClass, "size", "()I");
	jmethodID jAddMethod = env->GetMethodID(jArrayListClass, "add",
			"(Ljava/lang/Object;)Z");

	jobject jAddrList = env->NewObject(jArrayListClass, jInitMethod);

	for (int i = 0; i < addrList.size(); i++) {
		jstring jAddr = env->NewStringUTF(
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
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGReportEvent", "(Ljava/lang/String;Ljava/lang/String;Z)V");

	jstring jName = env->NewStringUTF((char const *) cName);
	jstring jBody = env->NewStringUTF((char const *) cBody);
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jName, jBody,
			isRealTime);
	env->DeleteLocalRef(jName);
	env->DeleteLocalRef(jBody);
}

void WGPlatform::WGReportEvent(unsigned char* cName, std::vector<KVPair>& cEventList,
		bool isRealTime) {
	LOGD("WGPlatform::WGEnableReport Vector %s", "");

	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGReportEvent", "(Ljava/lang/String;Ljava/util/HashMap;Z)V");
	jstring jName = env->NewStringUTF((char const *) cName);
	jclass jHashMapClass = env->FindClass("java/util/HashMap");
	jmethodID jInitMethod = env->GetMethodID(jHashMapClass, "<init>", "()V");
	jmethodID jPutMethod = env->GetMethodID(jHashMapClass, "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
	//	HashMap<String, String> extraMap = new HashMap<String, String>();
	jobject jparams = env->NewObject(jHashMapClass, jInitMethod);

	for (int i = 0; i < cEventList.size(); i++) {
		jstring jKey = env->NewStringUTF(
				(const char *) cEventList.at(i).key.c_str());
		jstring jValue = env->NewStringUTF(
						(const char *) cEventList.at(i).value.c_str());
		env->CallObjectMethod(jparams, jPutMethod, jKey,jValue);
		env->DeleteLocalRef(jKey);
		env->DeleteLocalRef(jValue);
	}
	env->CallStaticVoidMethod(s_WGPlatformClass, method, jName, jparams,isRealTime);
	env->DeleteLocalRef(jHashMapClass);
	env->DeleteLocalRef(jName);
	env->DeleteLocalRef(jparams);
}

const std::string WGPlatform::WGGetChannelId() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetChannelId", "()Ljava/lang/String;");

	jstring jChannelId = (jstring) env->CallStaticObjectMethod(
			s_WGPlatformClass, method);

	jboolean isCopy;
	const char* cChannel = env->GetStringUTFChars(jChannelId, &isCopy);
	std::string cChannelStr = cChannel;
	env->ReleaseStringUTFChars(jChannelId, cChannel);
	env->DeleteLocalRef(jChannelId);

	return cChannelStr;
}

bool WGPlatform::WGIsPlatformInstalled(ePlatform platform) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

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
	return result;
}

bool WGPlatform::WGIsPlatformSupportApi(ePlatform platform) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
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

const std::string WGPlatform::WGGetRegisterChannelId(){
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetRegisterChannelId", "()Ljava/lang/String;");

	jstring jRegChannelId = (jstring) env->CallStaticObjectMethod(
			s_WGPlatformClass, method);

	jboolean isCopy;
	const char* cRegChannel = env->GetStringUTFChars(jRegChannelId, &isCopy);
	std::string cRegChannelStr = cRegChannel;
	env->ReleaseStringUTFChars(jRegChannelId, cRegChannel);
	env->DeleteLocalRef(jRegChannelId);
	return cRegChannelStr;
}

const std::string WGPlatform::WGGetPlatformAPPVersion(ePlatform platform) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jclass jEPlatformCls = env->FindClass("com/tencent/msdk/consts/EPlatform");
	jmethodID getEnum = env->GetStaticMethodID(jEPlatformCls, "getEnum",
			"(I)Lcom/tencent/msdk/consts/EPlatform;");
	jobject enumObj = env->CallStaticObjectMethod(jEPlatformCls, getEnum,
			(int) platform);

	jmethodID WGGetPlatAPPVersion = env->GetStaticMethodID(s_WGPlatformClass,
			"WGGetPlatformAPPVersion", "(Lcom/tencent/msdk/consts/EPlatform;)Ljava/lang/String;");
	jstring jAPPVersion = (jstring) env->CallStaticObjectMethod(s_WGPlatformClass, WGGetPlatAPPVersion,
			enumObj);
	jboolean isCopy;
	const char* cResult = env->GetStringUTFChars(jAPPVersion, &isCopy);
	std::string cResultStr = cResult;
	env->DeleteLocalRef(jEPlatformCls);
	env->DeleteLocalRef(enumObj);
	env->ReleaseStringUTFChars(jAPPVersion, cResult);
	env->DeleteLocalRef(jAPPVersion);
	return cResultStr;
}

void WGPlatform::WGRefreshWXToken() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method;
	method = env->GetStaticMethodID(s_WGPlatformClass, "WGRefreshWXToken",
			"()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

const std::string WGPlatform::WGGetPf(unsigned char * cGameCustomInfo) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method= env->GetStaticMethodID(s_WGPlatformClass, "WGGetPf",
			"(Ljava/lang/String;)Ljava/lang/String;");
	jstring jGameCustomInfo = env->NewStringUTF((char const*)cGameCustomInfo);
	jstring jPf = (jstring) env->CallStaticObjectMethod(s_WGPlatformClass,
			method, jGameCustomInfo);

	jboolean isCopy;
	const char* cPf = env->GetStringUTFChars(jPf, &isCopy);
	std::string cPfStr = cPf;
	env->DeleteLocalRef(jGameCustomInfo);
	env->ReleaseStringUTFChars(jPf, cPf);
	env->DeleteLocalRef(jPf);
	return cPfStr;
}

const std::string WGPlatform::WGGetPfKey() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
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
	m_pVM->AttachCurrentThread(&env, NULL);

	jint jAct = (jint) cAct;
	jstring jFriendOpenid = env->NewStringUTF((char const*) cFriendOpenid);
	jstring jTitle = env->NewStringUTF((char const*) cTitle);
	jstring jSummary = env->NewStringUTF((char const*) cSummary);
	jstring jTargetUrl = env->NewStringUTF((char const*) cTargetUrl);
	jstring jImgUrl = env->NewStringUTF((char const*) cImgUrl);
	jstring jPreviewText = env->NewStringUTF((char const*) cPreviewText);
	jstring jGameTag = env->NewStringUTF((char const*) cGameTag);
	jstring jExtMsdkInfo = env->NewStringUTF((char const*) cExtMsdkinfo);

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
	m_pVM->AttachCurrentThread(&env, NULL);
	LOGD("WGSendToWXGameFriend cFriendOpenId : %s ", cFriendOpenId);
	LOGD("WGSendToWXGameFriend cTitle : %s ", cTitle);
	LOGD("WGSendToWXGameFriend cMediaId : %s ", cMediaId);
	LOGD("WGSendToWXGameFriend cMessageExt : %s ", cMessageExt);
	LOGD("WGSendToWXGameFriend cMediaTagName : %s ", cMediaTagName);
	LOGD("WGSendToWXGameFriend cDescription : %s ", cDescription);
	LOGD("WGSendToWXGameFriend cExtMsdkInfo : %s ", cExtMsdkInfo);

	jstring jFriendOpenid = env->NewStringUTF((char const*) cFriendOpenId);
	jstring jTitle = env->NewStringUTF((char const*) cTitle);
	jstring jDescription = env->NewStringUTF((char const*) cDescription);
	jstring jMediaId = env->NewStringUTF((char const*) cMediaId);
	jstring jMessageExt = env->NewStringUTF((char const*) cMessageExt);
	jstring jMediaTagName = env->NewStringUTF((char const*) cMediaTagName);
	jstring jExtMsdkInfo = env->NewStringUTF((char const*) cExtMsdkInfo);

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

	return ret;
}

bool WGPlatform::WGQueryQQMyInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID WGQueryQQMyInfo = env->GetStaticMethodID(s_WGPlatformClass,
			"WGQueryQQMyInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryQQMyInfo);
	return ret;
}
bool WGPlatform::WGQueryQQGameFriendsInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID WGQueryQQGameFriendsInfo = env->GetStaticMethodID(
			s_WGPlatformClass, "WGQueryQQGameFriendsInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryQQGameFriendsInfo);
	return ret;
}

void WGPlatform::WGJoinQQGroup(unsigned char* cQQGroupKey) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jstring jQQGroupKey = env->NewStringUTF((char const*) cQQGroupKey);

	jmethodID WGJoinQQGroup = env->GetStaticMethodID(s_WGPlatformClass,
			"WGJoinQQGroup", "(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGJoinQQGroup,jQQGroupKey);
	env->DeleteLocalRef(jQQGroupKey);
	return;
}

void WGPlatform::WGBindQQGroup(unsigned char* cUnionid,
		unsigned char* cUnion_name, unsigned char* cZoneid,
		unsigned char* cSignature) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jstring jUnionid = env->NewStringUTF((char const*) cUnionid);
	jstring jUnion_name = env->NewStringUTF((char const*) cUnion_name);
	jstring jZoneid = env->NewStringUTF((char const*) cZoneid);
	jstring jSignature = env->NewStringUTF((char const*) cSignature);
	jmethodID WGBindQQGroup =
			env->GetStaticMethodID(s_WGPlatformClass, "WGBindQQGroup",
					"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGBindQQGroup, jUnionid,
			jUnion_name, jZoneid, jSignature);

	env->DeleteLocalRef(jUnionid);
	env->DeleteLocalRef(jUnion_name);
	env->DeleteLocalRef(jZoneid);
	env->DeleteLocalRef(jSignature);
	return;
}

void WGPlatform::WGAddGameFriendToQQ(unsigned char* cFopenid,
		unsigned char* cDesc, unsigned char* cMessage) {

	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jstring jFopenid = env->NewStringUTF((char const*) cFopenid);
	jstring jDesc = env->NewStringUTF((char const*) cDesc);
	jstring jMessage = env->NewStringUTF((char const*) cMessage);

	jmethodID WGAddGameFriendToQQ = env->GetStaticMethodID(s_WGPlatformClass,
			"WGAddGameFriendToQQ",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass, WGAddGameFriendToQQ, jFopenid,
			jDesc, jMessage);

	env->DeleteLocalRef(jFopenid);
	env->DeleteLocalRef(jDesc);
	env->DeleteLocalRef(jMessage);
	return;
}

bool WGPlatform::WGQueryWXMyInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID WGQueryWXMyInfo = env->GetStaticMethodID(s_WGPlatformClass,
			"WGQueryWXMyInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryWXMyInfo);

	return ret;
}
bool WGPlatform::WGQueryWXGameFriendsInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID WGQueryWXGameFriendsInfo = env->GetStaticMethodID(
			s_WGPlatformClass, "WGQueryWXGameFriendsInfo", "()Z");
	bool ret = env->CallStaticBooleanMethod(s_WGPlatformClass,
			WGQueryWXGameFriendsInfo);
	return ret;
}
bool WGPlatform::WGCheckApiSupport(eApiName apiName) {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
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
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass,
			"WGLogPlatformSDKVersion", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

/*
 * @param type   公告类型
 * 	  eMSG_NOTICETYPE_ALERT: 弹出公告
 * 	  eMSG_NOTICETYPE_SCROLL: 滚动公告
 * @param scene 公告场景ID
 */
std::vector<NoticeInfo> WGPlatform::WGGetNoticeData(eMSG_NOTICETYPE cType, unsigned char* cScene){
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	LOGD("WGPlatform::WGGetNoticeData %s", "");
	//转化参数为jni格式
	jstring jScene = env->NewStringUTF((char const*) cScene);
	jclass jMsgTypeClass = env->FindClass("com/tencent/msdk/notice/eMSG_NOTICETYPE");
	jmethodID jGetMsgTypeEnumMethod = env->GetStaticMethodID(jMsgTypeClass, "getEnum",
			"(I)Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;");
	jmethodID jGetMsgTypeValueMethod = env->GetMethodID(jMsgTypeClass, "val","()I");
	jobject jMsgTypeEnumObj = env->CallStaticObjectMethod(jMsgTypeClass, jGetMsgTypeEnumMethod, (int) cType);

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
	jobject jNoticeVectorObj = env->NewObject(jVectorClass, jVectorInitMethod);
	jmethodID jWGGetNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass,"WGGetNoticeData",
					"(Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;Ljava/lang/String;)Ljava/util/Vector;");
	jNoticeVectorObj = env->CallStaticObjectMethod(s_WGPlatformClass,jWGGetNoticeMethod,jMsgTypeEnumObj,jScene);
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
		jobject jNoticeInfoObj = env->NewObject(jNoticeInfoClass, jNoticeInfoInitMethod);
		jNoticeInfoObj = env->CallObjectMethod(jNoticeVectorObj,jVectorGetMethod,i);
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
		//jobject jNoticePicObj = env->NewObject(jVectorClass, jVectorInitMethod);
		jfieldID jNoticePicVecFiled = env->GetFieldID(jNoticeInfoClass, "mNoticePics", "Ljava/util/Vector;");
		jobject jNoticePicVecObj = env->GetObjectField(jNoticeInfoObj, jNoticePicVecFiled);
		jint jNoticePicVectorLength = env->CallIntMethod(jNoticePicVecObj,jVectorSizeMethod);
		std::vector<PicInfo> picInfoVector;
		for(int j=0; j < jNoticePicVectorLength; j++){
			jobject jNoticePicObj = env->NewObject(jNoticePicClass, jNoticePicInitMethod);
			jNoticePicObj = env->CallObjectMethod(jNoticePicVecObj,jVectorGetMethod,j);
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
	env->DeleteLocalRef(jMsgTypeEnumObj);
	env->DeleteLocalRef(jNoticeVectorObj);
	return noticeVector;
}

void WGPlatform::WGShowNotice(eMSG_NOTICETYPE cType,unsigned char* cScene){
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jstring jScene = env->NewStringUTF((char const*) cScene);
    jclass jMsgTypeClass = env->FindClass("com/tencent/msdk/notice/eMSG_NOTICETYPE");
    jmethodID jGetEnumMethod = env->GetStaticMethodID(jMsgTypeClass, "getEnum",
            "(I)Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;");
    jobject jEnumObj = env->CallStaticObjectMethod(jMsgTypeClass, jGetEnumMethod, (int) cType);
    jmethodID jWGShowNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGShowNotice", "(Lcom/tencent/msdk/notice/eMSG_NOTICETYPE;Ljava/lang/String;)V");

    env->CallStaticVoidMethod(s_WGPlatformClass, jWGShowNoticeMethod, jEnumObj,jScene);
    env->DeleteLocalRef(jMsgTypeClass);
    env->DeleteLocalRef(jScene);
    env->DeleteLocalRef(jEnumObj);
}

void WGPlatform::WGHideScrollNotice(){
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID jWGHideScrollNoticeMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGHideScrollNotice", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, jWGHideScrollNoticeMethod);
}

void WGPlatform::WGOpenUrl(unsigned char * openUrl){
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	LOGD("WGOpenUrl openUrl %s : ", openUrl);
	jstring jOpenUrl = env->NewStringUTF((char const*) openUrl);

	jmethodID WGOpenUrl =
			env->GetStaticMethodID(s_WGPlatformClass, "WGOpenUrl","(Ljava/lang/String;)V");
	env->CallStaticVoidMethod(s_WGPlatformClass,WGOpenUrl, jOpenUrl);
	env->DeleteLocalRef(jOpenUrl);
}

bool WGPlatform::WGOpenAmsCenter(unsigned char * cParams) {
	LOGD("%s", "WGOpenAmsCenter called!");
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID jWGOpenAmsCenterMethod = env->GetStaticMethodID(s_WGPlatformClass, "WGOpenAmsCenter","(Ljava/lang/String;)Z");
	jstring jParams = env->NewStringUTF((const char *)cParams);
	jboolean rtn = env->CallStaticBooleanMethod(s_WGPlatformClass, jWGOpenAmsCenterMethod, jParams);
	env->DeleteLocalRef(jParams);
	return rtn;
}

void WGPlatform::WGLoginWithLocalInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGLoginWithLocalInfo", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

void WGPlatform::WGGetNearbyPersonInfo() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGGetNearbyPersonInfo", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

bool WGPlatform::WGCleanLocation() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCleanLocation", "()Z");
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
	m_pVM->AttachCurrentThread(&env, NULL);

	jmethodID method =
			env->GetStaticMethodID(s_WGPlatformClass,
					"WGSendMessageToWechatGameCenter",
					"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/tencent/msdk/weixin/MsgBase;Lcom/tencent/msdk/weixin/BtnBase;Ljava/lang/String;)Z");
	jstring jFriendOpenId = env->NewStringUTF((char const*) friendOpenId);
	jstring jTitle = env->NewStringUTF((char const*) title);
	jstring jContent = env->NewStringUTF((char const*) content);
	jstring jExtMsdkInfo = env->NewStringUTF((char const*) msdkExtInfo);

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

void WGPlatform::WGStartCommonUpdate() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGStartCommonUpdate", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

void WGPlatform::WGStartSaveUpdate() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGStartSaveUpdate", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
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
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCheckNeedUpdate", "()V");
	env->CallStaticVoidMethod(s_WGPlatformClass, method);
}

int WGPlatform::WGCheckYYBInstalled() {
	JNIEnv *env;
	m_pVM->AttachCurrentThread(&env, NULL);
	jmethodID method = env->GetStaticMethodID(s_WGPlatformClass, "WGCheckYYBInstalled", "()I");
	return env->CallStaticIntMethod(s_WGPlatformClass, method);
}
