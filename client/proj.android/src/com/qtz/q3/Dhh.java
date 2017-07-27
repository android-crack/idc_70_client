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
package com.qtz.q3;

import org.cocos2dx.lib.Cocos2dxActivity;

//import com.baidu.qtzspeech.QSpeechPlayer;
//import com.baidu.qtzspeech.QSpeechRecognizer;
//import com.baidu.qtzspeech.QSpeechSynthesizer;
//import com.dhh.speech.QSpeechPlayer;
//import com.dhh.speech.XfyunRecognizer;
import com.dhh.xfyun.QSpeechPlayer;
import com.dhh.xfyun.XfyunRecognizer;
import com.qtz.dhh.Notification;
import com.qtz.dhh.PlayVedio;
import com.qtz.dhh.VedioActivity;

import android.content.Intent;

import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;

public class Dhh extends Cocos2dxActivity {
	public static Dhh instance;
	public static Intent intent;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		hideSystemUI();
		instance = this;
		intent = new Intent(Dhh.this, VedioActivity.class);
		
		PlayVedio.context = instance;
		PlayVedio.intent = intent;
		//instance.playVideo("res/movie/movie.mp4");
		
		QSpeechPlayer.context = instance;
		QSpeechPlayer.getInstance();

		XfyunRecognizer.context = instance;
		XfyunRecognizer.getInstance();
		
		//อฦหอ
		org.fmod.FMOD.init(this);
        Notification.init(this);
		
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		QSpeechPlayer.getInstance().destroy();
		super.onDestroy();
//		QSpeechSynthesizer.getInstance().destroy();
	//	QSpeechPlayer.getInstance().destroy();
//		QSpeechRecognizer.getInstance().destroy();
	}

	@Override
	public void onWindowFocusChanged(boolean hasWindowFocus) {
		// TODO Auto-generated method stub
		super.onWindowFocusChanged(hasWindowFocus);
		if (hasWindowFocus) {
			hideSystemUI();
		}
	}

    private void hideSystemUI() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
    }
	
	
	public static void playVideo(String videoFileName){
		intent.addFlags( Intent.FLAG_ACTIVITY_NO_ANIMATION );
		intent.putExtra("videoFileName", videoFileName);
		instance.startActivity(intent);
		
	}
	
    static {
    	System.loadLibrary("fmod");
    	System.loadLibrary("game");
    	//playVideo("res/movie/movie.mp4");
    }
}
