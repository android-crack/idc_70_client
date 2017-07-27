/**
 * 
 */
package com.qtz.dhh;
 

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.Activity;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

/**
 * @author Himi
 *
 */
public class VedioActivity extends Activity implements MediaPlayer.OnCompletionListener, MediaPlayer.OnErrorListener{
	
	private VideoView view = null;
	private boolean pauseState = false;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) { 
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
		hideSystemUI();
		
		view = new VideoView(this);
		setContentView(view);
		view.setOnCompletionListener(this);
		view.setOnErrorListener(this);
		
		try {
			view.setVideoURI( getIntent().getStringExtra("videoFileName") );
			view.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		if (pauseState) {
			finishActivity();
		}
	}

	
	@Override
	protected void onPause() {
		super.onPause();
		
		if (view.isPlaying() && !pauseState ) {
			view.stopPlayback();
			pauseState = true;
		}
	
	}
	
	private void finishActivity() {
		
		this.finish();
		overridePendingTransition(0, 0);
		
	}
	
	
	@Override
	protected void onDestroy() {
		if(view != null) {
			view.setOnCompletionListener(null);
			view.setOnErrorListener(null);
			view.stopPlayback();
			
			Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
				@Override
				public void run() {
					nativeOnCompletion();
				}
			});
		}
		super.onDestroy();
	}

	@Override
	public void onCompletion(MediaPlayer mp) {
		finishActivity();
	}

	@Override
	public boolean onError(MediaPlayer mp, int what, int extra) {
		
		finishActivity();
		return true;
	}

    

    @Override
	public void onWindowFocusChanged(boolean hasFocus) {
		// TODO Auto-generated method stub
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus) {
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
	
	private native void nativeOnCompletion();

}
