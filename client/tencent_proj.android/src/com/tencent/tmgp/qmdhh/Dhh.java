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
package com.tencent.tmgp.qmdhh;


import org.cocos2dx.lib.Cocos2dxActivity;

import com.dhh.xfyun.QSpeechPlayer;
import com.dhh.xfyun.XfyunRecognizer;
import com.qtz.dhh.PlayVedio;
import com.qtz.dhh.VedioActivity;
import com.qtz.dhh.midas.MidasWrapper;
import com.qtz.dhh.msdk.DhhMsdk;
import com.qtz.dhh.safesdk.TssSdkWrapper;
import com.qtz.utils.share.QTZShareSDK;
import com.qtz.dhh.Notification;
import com.tencent.msdk.tools.Logger;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;

public class Dhh extends Cocos2dxActivity {
	private static final String TAG = "Dhh";
	public static Dhh instance;
	public static Intent intent;
	//public View decorView = null;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		hideSystemUI();
		instance = this;
		intent = new Intent(Dhh.this, VedioActivity.class);
		
		PlayVedio.context = instance;
		PlayVedio.intent = intent;
		
		XfyunRecognizer.context = instance;
		XfyunRecognizer.getInstance();

		QSpeechPlayer.context = instance;
		QSpeechPlayer.getInstance();
		
		DhhMsdk.context = instance;
		
		// 米大师
		MidasWrapper.context = instance;
		
		DhhMsdk.loginBase();
		
		//share init
		QTZShareSDK.init(this);
		
        //推送
        Notification.init(this);

        //fmod音频初始化
        org.fmod.FMOD.init(this);
        
        // 安全SDK
        TssSdkWrapper.init(true, this, 2611, "1104681464", "wxa228fbbb06c2cb79");
        // 需要传入lua的回调函数，此处先设为空字符串
        TssSdkWrapper.setSendDataToSvrCallback("safeSDKDataBack");
		
		//禁止锁屏   
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
	}
	
	@Override
	protected void onStart() {
//		Pay.context = instance;
//		Pay.onStart();
		super.onStart();
	}
	
	@Override
	protected void onRestart() {
		super.onRestart();
//		Login.onRestart();
	}

    @Override
    protected void onResume() {
        super.onResume();
        DhhMsdk.onResume();
        TssSdkWrapper.onResume();
    }
	
    @Override
    protected void onPause() {
        super.onPause();
        DhhMsdk.onPause();
        TssSdkWrapper.onPause();
    }
    
    @Override
    protected void onStop() {
//    	Pay.onStop();
    	super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        DhhMsdk.onDestroy();
		org.fmod.FMOD.close();//关闭fmod功能
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Logger.d("onConfigurationChanged");
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        DhhMsdk.onActivityResult(requestCode, resultCode, data);
        Logger.d("onActivityResult");
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Logger.d("onSaveInstanceState");
    }

    @Override
    protected void onNewIntent(Intent intent) {
        Logger.d("onNewIntent");
        super.onNewIntent(intent);

        DhhMsdk.onNewIntent(intent);
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


	static {
    	//System.loadLibrary("Bugly"); // 游戏需要加载此动态库, 数据上报用
        System.loadLibrary("fmod");
    	System.loadLibrary("game");
    	//playVideo("res/movie/movie.mp4");
    }
}
