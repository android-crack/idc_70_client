LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := game_shared

LOCAL_MODULE_FILENAME := libgame

LOCAL_SRC_FILES := hellocpp/main.cpp \
	../../sources/QVideoPlayer.cpp \
	../../sources/sdk/QSDKCommon.cpp \
	../../sources/sdk/android/QTZJavaSDKJNI.cpp			\
	../../sources/sdk/android/QSDKAndroid.cpp			\
	../../sources/sdk/android/QSDKAndroidBridge.cpp		\
	../../sources/shareSDK/QShareSDK.cpp				\
	../../sources/shareSDK/android/QShareSDKAndroid.cpp	\
	../../sources/shareSDK/android/QTZShareSDKJNI.cpp	\
	../../sources/tssSDK/QTssSDK.cpp	\
	../../sources/tssSDK/android/QTssSDKAndroid.cpp	\
	../../sources/mscSDK/QMSCSDK.cpp	\
	hellocpp/AndroidPlayVideo.cpp \
    ../../sources/AppDelegate.cpp \
    ../../sources/LuaQ2Common.cpp \
	../../sources/Q2Common.cpp \
    ../../sources/SimulatorConfig.cpp	\
    ../../../gameplay3d/lib/qtz_component/gameplay/CCPlatform3D.cpp \
	../../../gameplay3d/lib/qtz_component/gameplay/CCLayer3D.cpp \
    ../../../gameplay3d/lib/qtz_component/gameplay/LuaGame.cpp \
    ../../../gameplay3d/lib/qtz_component/gameplay/lua_extra.cpp \
	../../../gameplay3d/lib/qtz_component/gameplay/CCRenderTarget3D.cpp \
    ../../../gameplay3d/lib/qtz_component/gameplay/CCPlistFrame.cpp \
	../../../gameplay3d/lib/qtz_component/gameplay/CCGameThread.cpp	\
	../../../gameplay3d/lib/qtz_component/qtz_util/src/QTZUtil.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../sources					\
	$(LOCAL_PATH)/../../sources/sdk								\
	$(LOCAL_PATH)/../../sources/sdk/android								\
	$(LOCAL_PATH)/../../sources/shareSDK						\
	$(LOCAL_PATH)/../../sources/tssSDK						\
	$(LOCAL_PATH)/../../sources/mscSDK						\
	$(LOCAL_PATH)/hellocpp										\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/castar/include		\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/luasocket_encrypt/include	\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/speex/include    \
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/luaHttp/include	\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/qtz_util/include	\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/regx/include		\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/gameplay	\
	$(QUICK_COCOS2DX_ROOT)/lib/qtz_component/gameplay/src	\
	$(QUICK_COCOS2DX_ROOT)/lib/GamePlay-master/gameplay/src 	\
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/bullet/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/png/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/oggvorbis/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/zlib/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/openal/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/glew/include \
	$(QUICK_COCOS2DX_ROOT)/lib/gameplay-external-deps/fmod/include \
	$(QUICK_COCOS2DX_ROOT)/lib/cocos2d-x/scripting/lua/lua/src 	\
	$(QUICK_COCOS2DX_ROOT)/lib/cocos2d-x 

#LOCAL_CFLAGS += -Wno-psabi -DCC_LUA_ENGINE_ENABLED=1 -DDEBUG=0 -DCOCOS2D_DEBUG=0 -O3
LOCAL_CFLAGS += -Wno-psabi
#需要移到gameplay.mk中去。
LOCAL_LDLIBS    := -llog -landroid -lEGL -lGLESv2 -lOpenSLES


LOCAL_WHOLE_STATIC_LIBRARIES := quickcocos2dx
LOCAL_WHOLE_STATIC_LIBRARIES += libpng
LOCAL_WHOLE_STATIC_LIBRARIES += libevent2
LOCAL_WHOLE_STATIC_LIBRARIES += luasocket_encrypt
LOCAL_WHOLE_STATIC_LIBRARIES += luaAstar
LOCAL_WHOLE_STATIC_LIBRARIES += libbullet
LOCAL_WHOLE_STATIC_LIBRARIES += libOpenAL
LOCAL_WHOLE_STATIC_LIBRARIES += libgameplay
LOCAL_WHOLE_STATIC_LIBRARIES += luaRegx
LOCAL_WHOLE_STATIC_LIBRARIES += libspeex
LOCAL_WHOLE_STATIC_LIBRARIES += libfmod

#LOCAL_LDFLAGS := -Wl,-rpath, $(QUICK_COCOS2DX_ROOT)/lib/

include $(BUILD_SHARED_LIBRARY)

$(call import-module,lib/proj.android) \
$(call import-module,lib/gameplay-external-deps/png/lib/android/arm)	\
$(call import-module,libevent/android/jni)			\
$(call import-module,luasocket_encrypt/android/jni)			\
$(call import-module,castar/android/jni)			\
$(call import-module,lib/gameplay-external-deps/bullet/lib/android/arm)	\
$(call import-module,lib/gameplay-external-deps/openal/lib/android/arm)	\
$(call import-module,lib/GamePlay-master/gameplay/android)	\
$(call import-module,lib/gameplay-external-deps/zlib/lib/android/arm)	\
$(call import-module,lib/gameplay-external-deps/oggvorbis/lib/android/arm)	\
$(call import-module,lib/gameplay-external-deps/fmod/lib/android) \
$(call import-module,luaHttp/android/jni)			\
$(call import-module,qtz_util/android/jni)          \
$(call import-module,regx/android)\
$(call import-module,speex/android/jni)\


