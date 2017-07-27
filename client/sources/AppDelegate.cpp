
#include "cocos2d.h"
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "support/CCNotificationCenter.h"
#include "CCLuaEngine.h"
#include <string>

// lua extensions
#include "lua_extensions.h"
// cocos2dx_extra luabinding
#include "luabinding/cocos2dx_extra_luabinding.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "luabinding/cocos2dx_extra_ios_iap_luabinding.h"
#endif
// thrid_party
#include "third_party_luabinding.h"

#include "ToLuaSocket.h"
//#include "luaHttp.h"
#include "QTZUtil.h"
#include "toluaAstar.h"
#include "toluaRegx.h"
#include "CCPlatform3D.h"

#include "Q2Common.h"
#include "LuaQ2Common.h"
//#include "vld.h"

extern "C"{
#include "lua.h"
#include "lauxlib.h"
#include "curl/curl.h"
}
#include "CCLuaEngine.h"
#include "CCLuaStack.h"

void bind_lua_playVideo(lua_State* L);
void bind_lua_dumpMemory(lua_State* L);
void bind_lua_dumpGaf(lua_State* L);

void bind_check_string_has_invisible_char(lua_State* L);

using namespace std;
using namespace cocos2d;

AppDelegate::AppDelegate()
{
    // fixed me
    //_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
}

AppDelegate::~AppDelegate()
{
    // end simple audio engine here, or it may crashed on win32
    //SimpleAudioEngine::sharedEngine()->end();
}


bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();

	// register lua engine
	CCLuaEngine *pEngine = CCLuaEngine::defaultEngine();
	CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

	CCLuaStack *pStack = pEngine->getLuaStack();
	pStack->setXXTEAKeyAndSign("dhh", strlen("dhh"), "XXTEA", strlen("XXTEA"));

	lua_State* L = pStack->getLuaState();

	CCPlatform3D::initialize();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

    pDirector->setProjection(kCCDirectorProjection2D);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 35);
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    pDirector->setAnimationInterval(1.0 / 30);
#endif

    // load lua extensions
    luaopen_lua_extensions(L);
    // load cocos2dx_extra luabinding
    luaopen_cocos2dx_extra_luabinding(L);

	// for ToLuaSocket
	luaopen_luasocket(L);

    tolua_Q2Common_open(L);

	// for luaHttp
	//luaopen_luaHttp(L);

	// for astar
	luaopen_astar(L);

	
	// for regx
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	luaopen_regx(L);
//#endif

	// for qtz util
	luaopen_QTZUtil(L);

    bind_lua_playVideo( pEngine->getLuaStack()->getLuaState() );
	bind_lua_dumpMemory(pEngine->getLuaStack()->getLuaState() );
	bind_lua_dumpGaf(pEngine->getLuaStack()->getLuaState());
	bind_check_string_has_invisible_char(pEngine->getLuaStack()->getLuaState());
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    luaopen_cocos2dx_extra_ios_iap_luabinding(L);
#endif


	int pos;
	string updateDirName = "dhh.game.qtz.com";
	string updatePath = CCFileUtils::sharedFileUtils()->getWritablePath().append(  updateDirName );
	while ((pos = updatePath.find_first_of("\\")) != std::string::npos)
	{
		updatePath.replace(pos, 1, "/");
	}
	pStack->addSearchPath( updatePath.c_str() );
	
	updatePath = updatePath.append( "/scripts" );
	pStack->addSearchPath( updatePath.c_str() );


	updatePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	while ((pos = updatePath.find_first_of("\\")) != std::string::npos)
	{
		updatePath.replace(pos, 1, "/");
	}
	pStack->addSearchPath( updatePath.c_str() );

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("scripts/main.lua");
#else
    string path = CCFileUtils::sharedFileUtils()->fullPathForFilename(m_projectConfig.getScriptFileRealPath().c_str());
#endif

    while ((pos = path.find_first_of("\\")) != std::string::npos)
    {
        path.replace(pos, 1, "/");
    }
    size_t p = path.find_last_of("/\\");
    if (p != path.npos)
    {
        const string dir = path.substr(0, p);
        pStack->addSearchPath(dir.c_str());

        p = dir.find_last_of("/\\");
		string pdir = dir.substr(0, p);
        if (p != dir.npos)
        {
            pStack->addSearchPath(pdir.c_str());
        }

		p = pdir.find_last_of("/\\");
        if (p != pdir.npos)
        {
            pStack->addSearchPath(pdir.substr(0, p).c_str());
        }
    }

    //string env = "__LUA_STARTUP_FILE__=\"";
    //env.append(path);
    //env.append("\"");
    //pEngine->executeString(env.c_str());

#ifdef ENCRYPT_SCRIPT_PATH
	if (!CCFileUtils::sharedFileUtils()->isFileExist(path.c_str()))
	{
		CCConfiguration::sharedConfiguration()->setEncryptScriptPath(true);
	}
#endif // ENCRYPT_SCRIPT_PATH

    CCLOG("------------------------------------------------");
    CCLOG("LOAD LUA FILE: %s", path.c_str());
    CCLOG("------------------------------------------------");
    pEngine->executeScriptFile(path.c_str());

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
    CCDirector::sharedDirector()->pause();
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    SimpleAudioEngine::sharedEngine()->pauseAllEffects();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_BACKGROUND");
	CCPlatform3D::pause();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();
    CCDirector::sharedDirector()->resume();
    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
    SimpleAudioEngine::sharedEngine()->resumeAllEffects();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_FOREGROUND");
	CCPlatform3D::resume();
}

void AppDelegate::setProjectConfig(const ProjectConfig& config)
{
    m_projectConfig = config;
}

void AppDelegate::restartScript()
{
    
}

int dumpMemory(lua_State* L)
{
	//dumpMemoryAllocations();

	return 0;
}

void bind_lua_dumpMemory(lua_State* L)
{
	lua_register(L, "dumpMemory", dumpMemory);
}

extern void gaf_dump_textures();

int dumpGaf(lua_State* L)
{
	//gaf_dump_textures();

	//CCTexture2D::dumpTextureInfo();
	//CCTexturePVR::dumpTextureInfo();

	return 0;
}

int check_string_has_invisible_char(lua_State* L)
{
	const char* str = lua_tostring(L, 1);
	//printf("input string %s", str);
	bool has = checkUnicodeStringHasInvisibleChar(str);
	lua_pushboolean(L, has);
	return 1;
}

void bind_check_string_has_invisible_char(lua_State* L)
{
	lua_register(L, "check_string_has_invisible_char", check_string_has_invisible_char);
}

void bind_lua_dumpGaf(lua_State* L)
{
	lua_register(L, "dumpGaf", dumpGaf);
}
