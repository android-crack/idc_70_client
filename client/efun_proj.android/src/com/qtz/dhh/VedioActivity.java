/**
 * 
 */
package com.qtz.dhh;
 

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.Activity;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Bundle;
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
	
	@Override
	protected void onStop() {
		super.onStop();
		
		Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
			@Override
			public void run() {
			
				nativeOnCompletion();
			}
		});
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

	
	private native void nativeOnCompletion();

}
