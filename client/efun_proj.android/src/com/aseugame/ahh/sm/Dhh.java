/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.aseugame.ahh.sm;

import org.cocos2dx.lib.Cocos2dxActivity;

import com.dhh.xfyun.QSpeechPlayer;
import com.dhh.xfyun.XfyunRecognizer;
import com.efun.sdk.entrance.EfunSDK;
import com.qtz.dhh.PlayVedio;
import com.qtz.dhh.QCrashHandler;
import com.qtz.dhh.VedioActivity;
import com.qtz.dhh.smsdk.Login;

import android.content.Intent;

import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;

public class Dhh extends Cocos2dxActivity {

	public static Dhh instance;
	public static Intent intent;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		instance = this;
		intent = new Intent(Dhh.this, VedioActivity.class);
		
		PlayVedio.context = instance;
		PlayVedio.intent = intent;
		
		Login.context = instance;
		
		
		QSpeechPlayer.context = instance;
		QSpeechPlayer.getInstance();

		XfyunRecognizer.context = instance;
		XfyunRecognizer.getInstance();
		
		
		Thread.setDefaultUncaughtExceptionHandler(new QCrashHandler(this));
		
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		
		// 调用广告
		EfunSDK.getInstance().efunAds(this);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		
		Log.i("Dhh", "=====onNewIntent======");
		super.onNewIntent(intent);
		
		Login.smLoginCanceled();
	}
	
	@Override
	protected void onDestroy() {

		QSpeechPlayer.getInstance().destroy();
		super.onDestroy();
		EfunSDK.getInstance().onDestroy(Dhh.this);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		EfunSDK.getInstance().onResume(Dhh.this);
	}

	@Override
	protected void onPause() {
		super.onPause();
		EfunSDK.getInstance().onPause(Dhh.this);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		EfunSDK.getInstance().onActivityResult(Dhh.this, requestCode, resultCode, data);
	}

	
	public static void playVideo(String videoFileName){
		intent.addFlags( Intent.FLAG_ACTIVITY_NO_ANIMATION );
		intent.putExtra("videoFileName", videoFileName);
		instance.startActivity(intent);
		
	}
	
    static {
    	System.loadLibrary("game");
    	//playVideo("res/movie/movie.mp4");
    }
}
