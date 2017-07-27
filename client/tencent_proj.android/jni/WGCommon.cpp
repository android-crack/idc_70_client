#include "CommonFiles/WGCommon.h"
#include "CommonFiles/WGPlatform.h"
#include <android/log.h>

WXMessageButton::WXMessageButton(std::string aName) {
	name = aName;
}
WXMessageButton::~WXMessageButton() {
}
//*********************************************************************************************************
ButtonApp::ButtonApp(std::string aName, std::string aMessageExt) :
		WXMessageButton(aName), messageExt(aMessageExt) {
	LOGD("%s", "ButtonApp");
	messageExt = aMessageExt;

}
jobject ButtonApp::getJavaObject() {
	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jBtnAppClass = env->FindClass("com/tencent/msdk/weixin/BtnApp");
	jmethodID jConstractorMethod = env->GetMethodID(jBtnAppClass, "<init>",
			"()V");
	jobject jBtnAppObject = env->NewObject(jBtnAppClass, jConstractorMethod);

	jmethodID jSetmNameMethod = env->GetMethodID(jBtnAppClass, "setmName",
			"(Ljava/lang/String;)V");
	jstring jName = env->NewStringUTF(this->name.c_str());
	env->CallVoidMethod(jBtnAppObject, jSetmNameMethod, jName);
	env->DeleteLocalRef(jName);

	jmethodID jSetmMessageExt = env->GetMethodID(jBtnAppClass, "setmMessageExt",
			"(Ljava/lang/String;)V");
	jstring jMessageExt = env->NewStringUTF(this->messageExt.c_str());
	env->CallVoidMethod(jBtnAppObject, jSetmMessageExt, jMessageExt);
	env->DeleteLocalRef(jMessageExt);

	return jBtnAppObject;
}
ButtonApp::~ButtonApp() {
	LOGD("%s", "~~ButtonApp");
}
//*********************************************************************************************************
ButtonWebview::ButtonWebview(std::string aName, std::string aWebViewUrl) :
		WXMessageButton(aName), webViewUrl(aWebViewUrl) {
	LOGD("%s", "ButtonWebview");
}
jobject ButtonWebview::getJavaObject() {
	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jBtnWebClass = env->FindClass("com/tencent/msdk/weixin/BtnWeb");
	jmethodID jConstractorMethod = env->GetMethodID(jBtnWebClass, "<init>", "()V");
	jobject jBtnWebObject = env->NewObject(jBtnWebClass, jConstractorMethod);

	jmethodID jSetmNameMethod = env->GetMethodID(jBtnWebClass, "setmName",
			"(Ljava/lang/String;)V");
	jstring jName = env->NewStringUTF(this->name.c_str());
	env->CallVoidMethod(jBtnWebObject, jSetmNameMethod, jName);
	env->DeleteLocalRef(jName);

	jmethodID jSetmUrlMethod = env->GetMethodID(jBtnWebClass, "setmUrl",
			"(Ljava/lang/String;)V");
	jstring jUrl = env->NewStringUTF(this->webViewUrl.c_str());
	env->CallVoidMethod(jBtnWebObject, jSetmUrlMethod, jUrl);
	env->DeleteLocalRef(jUrl);

	return jBtnWebObject;
}
ButtonWebview::~ButtonWebview() {
	LOGD("%s", "~ButtonWebview");
}
//*********************************************************************************************************
ButtonRankView::ButtonRankView(std::string aName, std::string aTitle,
		std::string aRankeViewButtonName, std::string aMessageExt) :
		WXMessageButton(aName), title(aTitle), rankViewButtonName(aRankeViewButtonName), messageExt(
				aMessageExt) {
	LOGD("%s", "ButtonRankView");
}
jobject ButtonRankView::getJavaObject() {
	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jBtnRankClass = env->FindClass("com/tencent/msdk/weixin/BtnRank");
	jmethodID jConstractorMethod = env->GetMethodID(jBtnRankClass, "<init>", "()V");
	jobject jBtnRankObject = env->NewObject(jBtnRankClass, jConstractorMethod);

	jmethodID jSetmNameMethod = env->GetMethodID(jBtnRankClass, "setmName",
			"(Ljava/lang/String;)V");
	jstring jName = env->NewStringUTF(this->name.c_str());
	env->CallVoidMethod(jBtnRankObject, jSetmNameMethod, jName);
	env->DeleteLocalRef(jName);

	jmethodID jSetmTitleMethod = env->GetMethodID(jBtnRankClass, "setmTitle",
			"(Ljava/lang/String;)V");
	jstring jTitle = env->NewStringUTF(this->title.c_str());
	env->CallVoidMethod(jBtnRankObject, jSetmTitleMethod, jTitle);
	env->DeleteLocalRef(jTitle);

	jmethodID jSetmRankViewButtonNameMethod = env->GetMethodID(jBtnRankClass, "setmRankViewButtonName",
			"(Ljava/lang/String;)V");
	jstring jRankViewButtonName = env->NewStringUTF(this->rankViewButtonName.c_str());
	env->CallVoidMethod(jBtnRankObject, jSetmRankViewButtonNameMethod, jRankViewButtonName);
	env->DeleteLocalRef(jRankViewButtonName);

	jmethodID jSetmMessageExtMethod = env->GetMethodID(jBtnRankClass, "setmMessageExt",
			"(Ljava/lang/String;)V");
	jstring jMessageExt = env->NewStringUTF(this->messageExt.c_str());
	env->CallVoidMethod(jBtnRankObject, jSetmMessageExtMethod, jMessageExt);
	env->DeleteLocalRef(jMessageExt);

	return jBtnRankObject;
}
ButtonRankView::~ButtonRankView() {
	LOGD("%s", "~ButtonRankView");
}
//*********************************************************************************************************
WXMessageTypeInfo::WXMessageTypeInfo(std::string aPictureUrl) {
	LOGD("%s", "WXMessageTypeInfo");
	pictureUrl = aPictureUrl;
}
WXMessageTypeInfo::~WXMessageTypeInfo() {
	LOGD("%s", "~WXMessageTypeInfo");
}
//*********************************************************************************************************
TypeInfoImage::~TypeInfoImage() {
	LOGD("%s", "~TypeInfoImage");
}
TypeInfoImage::TypeInfoImage(std::string aPictureUrl, int aHeight, int aWidth) :
		WXMessageTypeInfo(aPictureUrl), height(aHeight), width(aWidth) {
	LOGD("%s", "TypeInfoImage");
}
jobject TypeInfoImage::getJavaObject() {
	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jMsgImageClass = env->FindClass("com/tencent/msdk/weixin/MsgImage");
	jmethodID jConstractorMethod = env->GetMethodID(jMsgImageClass, "<init>", "()V");
	jobject jMsgImageObject = env->NewObject(jMsgImageClass, jConstractorMethod);

	jmethodID jSetmPicUrlMethod = env->GetMethodID(jMsgImageClass, "setmPicUrl",
			"(Ljava/lang/String;)V");
	jstring jPicUrl = env->NewStringUTF(this->pictureUrl.c_str());
	env->CallVoidMethod(jMsgImageObject, jSetmPicUrlMethod, jPicUrl);
	env->DeleteLocalRef(jPicUrl);

	jmethodID jsetmHeightMethod = env->GetMethodID(jMsgImageClass, "setmHeight","(I)V");
	jint jHeight = this->height;
	env->CallVoidMethod(jMsgImageObject, jsetmHeightMethod, jHeight);


	jmethodID jSetmWidthMethod = env->GetMethodID(jMsgImageClass, "setmWidth","(I)V");
	jint jWidth = this->width;
	env->CallVoidMethod(jMsgImageObject, jSetmWidthMethod, jWidth);
	return jMsgImageObject;
}
//*********************************************************************************************************
TypeInfoVideo::TypeInfoVideo(std::string aPictureUrl, int aHeight, int aWidth,
		std::string aMediaUrl) :
		TypeInfoImage(aPictureUrl, aHeight, aWidth), mediaUrl(aMediaUrl) {
	LOGD("%s", "TypeInfoVideo");
}
TypeInfoVideo::~TypeInfoVideo() {
	LOGD("%s", "~TypeInfoVideo");
}
jobject TypeInfoVideo::getJavaObject() {
	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

 	jclass jMsgVideoClass = env->FindClass("com/tencent/msdk/weixin/MsgVideo");
 	jmethodID jConstractorMethod = env->GetMethodID(jMsgVideoClass, "<init>", "()V");
 	jobject jMsgVideoObject = env->NewObject(jMsgVideoClass, jConstractorMethod);

	jmethodID jSetmPicUrlMethod = env->GetMethodID(jMsgVideoClass, "setmPicUrl",
			"(Ljava/lang/String;)V");
	jstring jPicUrl = env->NewStringUTF(this->pictureUrl.c_str());
	env->CallVoidMethod(jMsgVideoObject, jSetmPicUrlMethod, jPicUrl);
	env->DeleteLocalRef(jPicUrl);

	jmethodID jSetmMediaUrlMethod = env->GetMethodID(jMsgVideoClass, "setmMediaUrl",
			"(Ljava/lang/String;)V");
	jstring jMediaUrl = env->NewStringUTF(this->mediaUrl.c_str());
	env->CallVoidMethod(jMsgVideoObject, jSetmMediaUrlMethod, jMediaUrl);
	env->DeleteLocalRef(jMediaUrl);

	jmethodID jsetmHeightMethod = env->GetMethodID(jMsgVideoClass, "setmHeight","(I)V");
	jint jHeight = this->height;
	env->CallVoidMethod(jMsgVideoObject, jsetmHeightMethod, jHeight);


	jmethodID jSetmWidthMethod = env->GetMethodID(jMsgVideoClass, "setmWidth","(I)V");
	jint jWidth = this->width;
	env->CallVoidMethod(jMsgVideoObject, jSetmWidthMethod, jWidth);
	return jMsgVideoObject;
}
//*********************************************************************************************************
TypeInfoLink::TypeInfoLink(std::string aPictureUrl, std::string aTargetUrl) :
		WXMessageTypeInfo(aPictureUrl), targetUrl(aTargetUrl) {
	LOGD("%s", "TypeInfoLink");
}
jobject TypeInfoLink::getJavaObject() {

	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jMsgLinkClass = env->FindClass("com/tencent/msdk/weixin/MsgLink");
	jmethodID jConstractorMethod = env->GetMethodID(jMsgLinkClass, "<init>",
			"()V");
	jobject jMsgLinkObject = env->NewObject(jMsgLinkClass, jConstractorMethod);

	jmethodID jSetmIconUrlMethod = env->GetMethodID(jMsgLinkClass,
			"setmIconUrl", "(Ljava/lang/String;)V");
	jstring jIconUrl = env->NewStringUTF(this->pictureUrl.c_str());
	env->CallVoidMethod(jMsgLinkObject, jSetmIconUrlMethod, jIconUrl);
	env->DeleteLocalRef(jIconUrl);

	jmethodID jSetmUrlMethod = env->GetMethodID(jMsgLinkClass, "setmUrl",
			"(Ljava/lang/String;)V");
	jstring jTargetUrl = env->NewStringUTF(this->targetUrl.c_str());
	env->CallVoidMethod(jMsgLinkObject, jSetmUrlMethod, jTargetUrl);
	env->DeleteLocalRef(jTargetUrl);

	return jMsgLinkObject;
}

//*********************************************************************************************************
TypeInfoText::TypeInfoText() :
		WXMessageTypeInfo(""){
	LOGD("%s", "TypeInfoText");
}
jobject TypeInfoText::getJavaObject() {

	JavaVM * vm = WGPlatform::GetInstance()->getVm();
	JNIEnv *env;
	vm->AttachCurrentThread(&env, NULL);

	jclass jMsgTextClass = env->FindClass("com/tencent/msdk/weixin/MsgText");
	jmethodID jConstractorMethod = env->GetMethodID(jMsgTextClass, "<init>",
			"()V");
	jobject jMsgTextObject = env->NewObject(jMsgTextClass, jConstractorMethod);
	env->DeleteLocalRef(jMsgTextClass);
	return jMsgTextObject;
}
