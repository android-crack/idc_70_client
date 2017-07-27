package com.qtz.utils.share;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.Activity;
import android.os.Environment;
import android.util.Log;

public class QTZShareSDK {
	public static final int KSHAREPLATFORM_NONE = 0;
	public static final int KSHAREPLATFORM_QQ 	= 2;
	public static final int KSHAREPLATRORM_WX 	= 3;
	
	public static final String TAG = "QTZ_SHARE_SDK";
	
	private static Activity pActivity 				= null;
	private static QTZShareSDK pShareSDK			= null;
	private static QTZShareSDKInterface pInterface 	= null;

	private static String mImageFile = null;
	
	private static void initPlatform(int platform)
	{
		Log.i(TAG, "init platform[" + platform +"]..." );
		switch (platform) {
		
		case KSHAREPLATFORM_QQ:
			pInterface = new QQShareSDK();
			break;
		case KSHAREPLATRORM_WX:
			pInterface = new WXShareSDK();
			break;
		default:
			pInterface = null;
			break;
		}
	}
	
	public static void init(Activity activity)
	{
		pActivity = activity;
	}
	
	public static QTZShareSDK getInstance()
	{
		if(pShareSDK == null)
		{ 
			pShareSDK = new QTZShareSDK();
			
		}
		return pShareSDK;
	}
	
	public static Activity getActivity()
	{
		return pActivity;
	}
	
	public static String getRealImageURL(String imgURL) throws IOException
	{
		Log.i(TAG, "imgURL: " + imgURL);
		String storage = Environment.getExternalStorageDirectory().getPath();
		if (!imgURL.startsWith("http"))
		{
			InputStream input = null;
			File file = new File(imgURL);
			if (file.exists()) {
				input = new FileInputStream(file);
			} else {
				Log.i(TAG, "use assets resource");
				input = pActivity.getAssets().open(imgURL);
			}
			String filePath = storage + "/dhh_share_" + String.valueOf(System.currentTimeMillis()) + ".png";
			OutputStream output = new FileOutputStream(filePath);
			
			byte[] buffer = new byte[1024];
			int len = input.read(buffer);
			while(len > 0)
			{
				output.write(buffer);
				len = input.read(buffer);
			}
			
			output.flush();
			output.close();
			input.close();
			mImageFile = filePath;
			return filePath;
		}
		return imgURL;
	}

	public static void deleteImage() {
		Log.d(TAG, "deleteImage");
		if (mImageFile != null) {
			File file = new File(mImageFile);  
	        if (file.isFile()) {
	        	Log.d(TAG, "delete file");
	            file.delete();
	        }
			mImageFile = null;
		}
	}
	
	public static void share(int platform, final String title, final String desc, final String url, final String imgURL, final String extInfo)
	{
		Log.i(TAG, "start to share...");
		initPlatform(platform);
		if (pInterface != null)
		{
			pActivity.runOnUiThread(new Runnable(){

				@Override
				public void run() {
					pInterface.share(title, desc, url, imgURL, extInfo);
				}
			});
			
		}
		else
		{
			Log.w(TAG, "platform [ "+ platform + " ] doesn't support share");
		}
	}
	
	public static void shareToFriend(int platform, final String uid, final String title, final String desc, final String url, final String imgURL, final String extInfo)
	{	
		Log.i(TAG, "start to shareToFriend");
		initPlatform(platform);
		if(pInterface != null)
		{
			pActivity.runOnUiThread(new Runnable(){

				@Override
				public void run() {
					pInterface.shareToFriend(uid, title, desc, url, imgURL, extInfo);
				}
				
			});
			
		}
		else
		{
			Log.w(TAG, "platform [ "+ platform + " ] doesn't support share");
		}
	}
	
	public static void shareWithPhoto(int platform, final String imgURL, final String extInfo)
	{	
		Log.i(TAG, "start to shareWithPhoto");
		initPlatform(platform);
		if (pInterface != null) 
		{
			pActivity.runOnUiThread(new Runnable(){

				@Override
				public void run() {
					pInterface.shareWithPhoto(imgURL, extInfo);
				}
				
			});
		}
		else
		{
			Log.w(TAG, "platform [ "+ platform + " ] doesn't support share");
		}
	}

	public static void shareWithUrl(int platform, final String title, final String desc, final String url, final String imgURL, final String extInfo)
	{
		Log.i(TAG, "shart to shareWithUrl");
		if (platform != KSHAREPLATRORM_WX) {
			Log.w(TAG, "platform [ "+ platform + " ] doesn't support shareWithUrl");
			return;
		}
		initPlatform(platform);
		if (pInterface != null)
		{
			pActivity.runOnUiThread(new Runnable(){

				@Override
				public void run() {
					pInterface.shareWithUrl(title, desc, url, imgURL, extInfo);
				}
			});
		}
		else
		{
			Log.w(TAG, "platform [ "+ platform + " ] doesn't support shareWithUrl");
		}
	}

	public static void onShareNotify(final int code, final String msg)
	{
		Cocos2dxActivity activity = (Cocos2dxActivity) pActivity;
		if (activity != null) {
			Log.d(TAG, "activity is not null on onShareNotify");
			activity.runOnGLThread(new Runnable(){
				@Override
				public void run() {
					QTZShareSDK.getInstance().onShareNotifyNative(code, msg);
				}
			});
		} else {
			Log.d(TAG, "activity is null on onShareNotify");
		}

	}
	
	public static interface QTZShareSDKInterface
	{
		public void shareWithPhoto(String imgURL, String extInfo);
		public void share(String title, String desc, String url, String imgURL, String extInfo);
		public void shareToFriend(String uid, String title, String desc, String url, String imgURL, String extInfo);
		public void shareWithUrl(String title, String desc, String url, String imgURL, String extInfo);
	}

	private native void onShareNotifyNative(int code, String msg);
}
