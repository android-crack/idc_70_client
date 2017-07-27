package com.dhh.xfyun;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import java.util.Timer;
import java.util.TimerTask;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;



import android.R.string;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Environment;
import android.util.Base64;
import android.util.Log;

/**
 * 语音播放器
 */
public class QSpeechPlayer {
	private static String tag = "QSpeechPlayer";
	private static QSpeechPlayer instance = null;
	public static Cocos2dxActivity context = null;

	private static AudioTrack audioPlayer;
	
	private static int playFinishHandler;
	private static Timer playFinishTimer;
	private static TimerTask playFinishTimerTask;

	public QSpeechPlayer() {
		super();
		// TODO Auto-generated constructor stub
	}

	public static QSpeechPlayer getInstance() {
		if (instance == null) {
			instance = new QSpeechPlayer();
		}
		return instance;
	}

	private static void playFinish(String result) {
		callFinishHandler(result);
    }
	
	private static void stopAudioPlayer() {
		if (audioPlayer != null){
			audioPlayer.stop();
			audioPlayer.release();
			audioPlayer = null;
		}
	}
	
	private static void stopPlayFinishTimer() {
		if (playFinishTimer != null){
			playFinishTimer.cancel();
			playFinishTimer = null;
		}
	}
	
	private static void stopPlayFinishTimerTask() {
		if (playFinishTimerTask != null){
			playFinishTimerTask.cancel();
			playFinishTimerTask = null;
		}
	}
	
	public void destroy() {
		stopAudioPlayer();
		stopPlayFinishTimerTask();
		stopPlayFinishTimer();
	}

	private static void callFinishHandler(final String result) {
		if (playFinishHandler != 0) {
			context.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(playFinishHandler, result);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(playFinishHandler);
					playFinishHandler = 0;
				}
			});
		}
	}
	
	//播放音频   for lua
	public static void play(final String audioDataBase64, final int mFinishHandler) {
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				playFinishHandler = mFinishHandler;
				nativePlay(audioDataBase64);
				
			}
		});
	}
	
	//播发接口
	public static void nativePlay(String audioDataBase64) {
		stopAudioPlayer();
		stopPlayFinishTimerTask();
		stopPlayFinishTimer();

		try {
			//base64 解码
			byte[] audioData = Base64.decode(audioDataBase64, Base64.DEFAULT);
			
	        byte[] bytes = new byte[audioData.length * 25];
	        short[] rate = new short[1];
	        
	        //speex 解压
	        int decSize = Speex.decode(audioData, bytes, audioData.length, rate);
	        
	        audioPlayer = new AudioTrack(AudioManager.STREAM_MUSIC, rate[0], 
	                AudioFormat.CHANNEL_OUT_MONO, 
	                AudioFormat.ENCODING_PCM_16BIT, 
	                decSize, 
	                AudioTrack.MODE_STATIC);		
	        audioPlayer.write(bytes, 0, decSize);
	        audioPlayer.play();
	        
	        //计算大概播放时间
	        short playTime = (short) (decSize / (rate[0] * 1.6) * 1000);
	        if (playTime <= 1000) {
	        	playTime = 1000;
			}
	        Log.d("playTime", "playTime" + playTime);
	        if (playTime > 0) {
	        	playFinishTimer = new Timer();
	        	playFinishTimerTask = new TimerTask() {  
	                @Override  
	                public void run() {
	                	playFinish("result_success");
	                	stopPlayFinishTimerTask();
	    				stopPlayFinishTimer();
	                }
	            };
	            playFinishTimer.schedule(playFinishTimerTask, playTime);
	        }
			
		} catch (Exception e) {
			// TODO: handle exception
		}
	}
	
	//停止音频   for lua
	public static void stop() {
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				stopAudioPlayer();
			}
		});
	}
	
	//获取路径
		public static String getSDPath(){ 
			File sdDir = null; 
		    boolean sdCardExist = Environment.getExternalStorageState()   
		                           .equals(Environment.MEDIA_MOUNTED);   //ÅÐ¶Ïsd¿¨ÊÇ·ñ´æÔÚ 
		    if (sdCardExist)   
		    {                               
		    	sdDir = Environment.getExternalStorageDirectory();//»ñÈ¡¸úÄ¿Â¼ 
		    }   
		    return sdDir.toString(); 
		       
		}
	
	public static void playLocal(final String path, final int mFinishHandler){
		context.runOnGLThread(new Runnable() {		
			@Override
			public void run() {
				playFinishHandler = mFinishHandler;
				Log.d("1111", path);
		        try {
		        	String pathString = getSDPath() + "/dhh/" + path;
		        	File file = new File(pathString);
		    		InputStream in = new FileInputStream(file);   
		            byte b[]=new byte[(int)file.length()];     //创建合适文件大小的数组   
					in.read(b);
					in.close();   
			        nativePlay(new String(b));
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}    //读取文件中的内容到b[]数组   
				
			}
		});
        
	}
}
