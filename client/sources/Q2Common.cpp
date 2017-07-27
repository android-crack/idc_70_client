
#include "cocos2d.h"
#include "CCLuaEngine.h"

unsigned char* GetFileDataQ3(const char* pszFileName, const char* pszMode, unsigned long * pSize)
{
	return cocos2d::CCFileUtils::sharedFileUtils()->getFileData(pszFileName, pszMode, pSize);
}


int cocos2dxLoadScript(const char* path)
{
	return cocos2d::CCLuaEngine::defaultEngine()->getLuaStack()->executeScriptFile(path);
}