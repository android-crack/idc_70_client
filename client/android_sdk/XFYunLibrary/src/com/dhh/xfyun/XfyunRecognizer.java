package com.dhh.xfyun;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.HashMap;
import java.util.LinkedHashMap;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.os.Environment;
import android.util.Base64;
import android.util.Log;


import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechUtility;


public class XfyunRecognizer implements InitListener{
	
	// 语音听写对象
	private static SpeechRecognizer mIat;
	//语音结果
	private static HashMap<String, String> mIatResults = new LinkedHashMap<String, String>();
	// 引擎类型
	private static String mEngineType = SpeechConstant.TYPE_CLOUD;
	
	static XfyunRecognizer instance = null;
	public static Cocos2dxActivity context = null;
	//压缩率
	private static int compressLevel = 2;
	//缓存流
	private static ByteArrayOutputStream outputStream;
	
	
	//lua函数句柄
	private static int recognStartHandler;
	private static int recognVoiceFinishHandler;
	private static int recogntextFinishHandler;
	private static int recognFinishHandler;
	private static int recognErrorHandler;
	
	
	private XfyunRecognizer() {
		super();
		// TODO Auto-generated constructor stub
		SpeechUtility.createUtility(context, "appid=" + "5673b515");
		mIat = SpeechRecognizer.createRecognizer(context, this);
		setParam();
	}

	public static XfyunRecognizer getInstance() {
		if (instance == null) {
			instance = new XfyunRecognizer();
		}
		return instance;
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
	
	//保存语音数据
	public static void saveData(String data) {
		//为了测试
		byte[] encodeBytes = data.getBytes();
		String dir = getSDPath() +"/dhh";
		String path = getSDPath()+ "/dhh/out.speex";

		File dirmg = new File(dir);
		if (!dirmg.exists() ) {
			dirmg.mkdir();
		}
		File fmg = new File(path);
		fmg.delete();
		if (!fmg.exists()) {
			try {
				fmg.createNewFile();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		synchronized (fmg) {

			RandomAccessFile randomFile;
			try {
				randomFile = new RandomAccessFile(path, "rw");
				randomFile.seek(0);
				randomFile.write(encodeBytes);
	            randomFile.close(); 
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
	}
	
	public static void setParam() {
		// 清空参数
		mIat.setParameter(SpeechConstant.PARAMS, null);

		// 设置听写引擎
		mIat.setParameter(SpeechConstant.ENGINE_TYPE, mEngineType);
		// 设置返回结果格式
		mIat.setParameter(SpeechConstant.RESULT_TYPE, "json");
	
		// 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
		mIat.setParameter(SpeechConstant.VAD_EOS,"4000");

		// 设置音量  
        mIat.setParameter(SpeechConstant.VOLUME, "100");  
		
		// 设置语言
		mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
		
		// 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
		mIat.setParameter(SpeechConstant.ASR_PTT, "0");
		mIat.setParameter(SpeechConstant.SAMPLE_RATE, "16000");
		
		// 设置音频保存路径，保存音频格式支持pcm、wav，设置路径为sd卡请注意WRITE_EXTERNAL_STORAGE权限
		// 注：AUDIO_FORMAT参数语记需要更新版本才能生效
		mIat.setParameter(SpeechConstant.AUDIO_FORMAT,"pcm");
		mIat.setParameter(SpeechConstant.ASR_AUDIO_PATH, Environment.getExternalStorageDirectory()+"/dhh/out.pcm");
		
		// 设置听写结果是否结果动态修正，为“1”则在听写过程中动态递增地返回结果，否则只在听写结束之后返回最终结果
		// 注：该参数暂时只对在线听写有效
		mIat.setParameter(SpeechConstant.ASR_DWA, "1");
	}
	
	//语音结果解析
	private static void printResult(RecognizerResult results) {
		String text = JsonParser.parseIatResult(results.getResultString());
		callRecognTextFinishHandler(text);

	}
	
	//导出给lua用
	public static void start(
							final int mStartHandler, 
							final int mVoiceFinishHandler,
							final int mTextFinishHandler,
							final int mFinishHandler, 
							final int mErrorHandler
								) {
		context.runOnGLThread(new Runnable() {			
			@Override
			public void run() {
				closeOutputStream();
				outputStream = new ByteArrayOutputStream();
				//保存句柄
				recognStartHandler = mStartHandler;
				recognVoiceFinishHandler = mVoiceFinishHandler;
				recogntextFinishHandler = mTextFinishHandler;
				recognFinishHandler = mFinishHandler;
				recognErrorHandler = mErrorHandler;
				mIat.cancel();
				int ret = mIat.startListening(mRecognizerListener);
				Log.d("tag", "" + ret);
				
			}
		});
	}
	
	
	public static void stop() {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				mIat.stopListening();
				callRecognVoiceFinishHandler();
			}
		});
	}
	
	public static void cancel() {
		context.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				mIat.cancel();
			}
		});
	}
	
	private static void callRecognStartHandler(final String result) {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (recognStartHandler != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(recognStartHandler, result);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(recognStartHandler);
					recognStartHandler = 0;
				}
			}
		});
	}
	
	private static void callRecognVoiceFinishHandler() {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (recognVoiceFinishHandler != 0) {
					String audioDataBase64 = "";
					if (outputStream != null) {
						byte[] bytes = outputStream.toByteArray();
						
						if (bytes.length > 0) {
							byte[] encoded = new byte[bytes.length];

							//speex 压缩
					        int getSize = Speex.encode(bytes, encoded, bytes.length, compressLevel);
					        
					        ByteArrayOutputStream out = new ByteArrayOutputStream();
					        out.write(encoded, 0, getSize);
					        byte[] encodeBytes = out.toByteArray();
					        
					       
							audioDataBase64 = Base64.encodeToString(encodeBytes, Base64.DEFAULT);
							saveData(audioDataBase64);
		            		
		            		//end
							
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(recognVoiceFinishHandler, audioDataBase64);
						}
					}
					Cocos2dxLuaJavaBridge.releaseLuaFunction(recognVoiceFinishHandler);
					recognVoiceFinishHandler = 0;
				}
				closeOutputStream();
			}
		});
	}
	
	private static void closeOutputStream() {
		if (outputStream != null) {
			try {
				outputStream.close();
				outputStream = null;
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
	}
	private static void callRecognTextFinishHandler(final String audioText) {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (recogntextFinishHandler != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(recogntextFinishHandler, audioText);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(recogntextFinishHandler);
					recogntextFinishHandler = 0;
				}
			}
		});
	}
	
	private static void callRecognFinishHandler(final String result) {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (recognFinishHandler != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(recognFinishHandler, result);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(recognFinishHandler);
					recognFinishHandler = 0;
				}
			}
		});
	}
	
	private static void callRecognErrorHandle(final String error) {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (recognErrorHandler != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(recognErrorHandler, error);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(recognErrorHandler);
					recognErrorHandler = 0;
				}
			}
		});
	}
	

	//---------------------------------接口回调实现---------------------------------------------
	private static RecognizerListener mRecognizerListener = new RecognizerListener()
	{
		@Override
		public void onBeginOfSpeech() {
			// TODO Auto-generated method stub
			String result = "ok";
			callRecognStartHandler(result);
		}
	
		@Override
		public void onEndOfSpeech() {
			// TODO Auto-generated method stub
			Log.d("onEndOfSpeech", "onEndOfSpeech");
			//
		}
	
		@Override
		public void onError(SpeechError arg0) {
			// TODO Auto-generated method stub
			callRecognErrorHandle("" + arg0);
		}
	
		@Override
		public void onEvent(int arg0, int arg1, int arg2, Bundle arg3) {
			// TODO Auto-generated method stub
			Log.d("ddd", "onEvent");
			
		}
	
		@Override
		public void onResult(RecognizerResult result, boolean arg1) {
			// TODO Auto-generated method stub
			printResult(result);
			callRecognFinishHandler("end");
			
		}
	
		//每帧返回语音数据
		public void onVolumeChanged(int arg0, byte[] arg1) {
			if (outputStream != null && arg1 != null && arg1 instanceof byte[]) {
        		//处理数据 
        		try {
					outputStream.write((byte[])arg1);
				} catch (IOException e) {
					
				}
        	}
		}
	};
	@Override
	public void onInit(int arg0) {
		// TODO Auto-generated method stub
		
	}

}
