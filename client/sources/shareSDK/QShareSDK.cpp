#include "QShareSDK.h"

using namespace::cocos2d;

static QShareSDK* p_sharedQShareSDK =   NULL;

QShareSDK* QShareSDK::getInstance()
{
    if ( p_sharedQShareSDK == NULL ) {
        p_sharedQShareSDK = new QShareSDK();
    }
    return p_sharedQShareSDK;
}

QShareSDK::QShareSDK()
{
    m_iHandle = 0;
}

const char* QShareSDK::saveScreenToFile(const char *filename, const CCRect& rect)
{
    CCDirector *pDirector = CCDirector::sharedDirector();
    CCScene *pScene = pDirector->getRunningScene();
    pScene->visit();
    
    CCSize size = rect.size;
    int startX  = 0;
    int startY  = 0;
    int w = 0;
    int h = 0;
    if( size.height == 0 || size.width == 0 ){
        size = pDirector->getOpenGLView()->getFrameSize();
    }else{
        CCSize winSize = pDirector->getWinSize();
        CCSize frameSize = pDirector->getOpenGLView()->getFrameSize();
        float scale_factor = min( frameSize.width / winSize.width, frameSize.height / winSize.height );
        size.width = int( size.width * scale_factor );
        size.height = int( size.height * scale_factor );
        startX = int( rect.origin.x * scale_factor + (frameSize.width - (winSize.width * scale_factor)) * 0.5);
        startY = int( rect.origin.y * scale_factor + (frameSize.height - (winSize.height * scale_factor)) * 0.5);
        
    }
    
    w = size.width;
    h = size.height;
    
    int screenDataLength = w * h * 4;
    GLubyte *buffer = (GLubyte *)malloc(screenDataLength);
    glReadPixels(startX, startY, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    CCImage *image = new CCImage();
	GLubyte tmpStr;
    for(int y = 0; y < (h -1) / 2; y++) {
        for(int x = 0; x < w * 4; x++) {
			tmpStr	= buffer[ y * w * 4 + x ];
			buffer[ y * w * 4 + x ] = buffer[ (h - 2 - y) * w * 4 + x ];
			buffer[ (h - 2 - y) * w * 4 + x ] = tmpStr;
        }
    }
    image->initWithImageData(buffer, screenDataLength, CCImage::kFmtRawData, w, h);
    std::string pathOfCapture = CCFileUtils::sharedFileUtils()->getWritablePath().append(filename);
    image->saveToFile(pathOfCapture.c_str());
    free(buffer);
    image->release();
    return "";
}


void QShareSDK::shareWithPhoto(ShareSDKPlatform platform, const char *imgURL, const char *extInfo, int handler)
{
    m_iHandle = handler;
    shareWithPhoto(platform, imgURL, extInfo); 
}


void QShareSDK::share(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler)
{
    m_iHandle = handler;
    share(platform, title, desc, url, imgURL, extInfo);
}


void QShareSDK::shareToFriend(ShareSDKPlatform platform, const char *uid, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler)
{
    m_iHandle = handler;
    shareToFriend(platform, uid, title, desc, url, imgURL, extInfo);
}

void QShareSDK::shareWithUrl(ShareSDKPlatform platform, const char *title, const char *desc, const char *url, const char *imgURL, const char *extInfo, int handler)
{
    m_iHandle = handler;
    shareWithUrl(platform, title, desc, url, imgURL, extInfo);
}

void QShareSDK::shareCallback(int code, const char *msg)
{
    if(m_iHandle)
    {
        CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_iHandle, code, msg);
        CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(m_iHandle);
        m_iHandle = 0;

    }
}
