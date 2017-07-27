//
//  Platform.h
//  VedioTest
//
//  Created by Himi on 12-10-9.
//
//

#ifndef __Dhh__QVideoPlayer__
#define __Dhh__QVideoPlayer__

#include "cocos2d.h"
using namespace cocos2d;


class QVideoPlayer {
private:
	int m_iHandler;

public:
	QVideoPlayer();
    static QVideoPlayer* sharedQVideoPlayer();
    void pureQVideoPlayer();
	void onCompletion();
	void registerHandler( int nHandler );
    void playVideo( const char* videoFileName );
};

#endif
