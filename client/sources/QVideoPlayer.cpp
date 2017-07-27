//
//  Platform.cpp
//  VedioTest
//
//  Created by Himi on 12-10-9.
//
//

#include "QVideoPlayer.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    #include <jni.h>
    #include "platform/android/jni/JniHelper.h"
    #include <android/log.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    #include "IOSPlayVedio.h"
#endif

extern "C"{
#include "lua.h"
#include "lauxlib.h"
#include "curl/curl.h"
}
#include "CCLuaEngine.h"
#include "CCLuaStack.h"

static QVideoPlayer* m_sharedQVideoPlayer = NULL;
static lua_State* mainLuaState = NULL;

QVideoPlayer::QVideoPlayer():
m_iHandler( 0 )
{
}

QVideoPlayer* QVideoPlayer::sharedQVideoPlayer()
{
    if (m_sharedQVideoPlayer == NULL) {
        m_sharedQVideoPlayer = new QVideoPlayer();
    }
    return m_sharedQVideoPlayer;
}

void QVideoPlayer::pureQVideoPlayer()
{
    if (m_sharedQVideoPlayer != NULL) {
        delete m_sharedQVideoPlayer;
        m_sharedQVideoPlayer = NULL;
    }
}

void QVideoPlayer::registerHandler( int nHandler )
{
	m_iHandler = nHandler;
}

void QVideoPlayer::onCompletion()
{
	if ( m_iHandler ){
		//CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent( m_iHandler, "kVideoPlayFinish" );
        lua_getglobal(mainLuaState, "__G__TRACKBACK__");
        lua_getref(mainLuaState, m_iHandler);

        lua_pcall(mainLuaState, 0, 1, -2);
        lua_unref(mainLuaState, m_iHandler);
	}
}

void QVideoPlayer::playVideo(const char *videoFileName)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    //Android视频播放代码
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo,"com/qtz/dhh/PlayVedio","playVideo", "(Ljava/lang/String;)V");
    if (isHave) {
		jstring arg = minfo.env->NewStringUTF( videoFileName );
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, arg);
    }
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    //iOS视频播放代码
    IOSPlayVedio::playVedio4iOS(videoFileName);
#endif
}


int playVideo( lua_State* L )
{
    const char* str_vedio_path = lua_tostring(L,1);
    int f_finish_callback = lua_ref(L,1);

    QVideoPlayer * player = QVideoPlayer::sharedQVideoPlayer();
    player->registerHandler(f_finish_callback);
    player->playVideo(str_vedio_path);

    return 0;
}

void bind_lua_playVideo(lua_State* L)
{
    mainLuaState = L;
    lua_register(L, "playVideo", playVideo);
}