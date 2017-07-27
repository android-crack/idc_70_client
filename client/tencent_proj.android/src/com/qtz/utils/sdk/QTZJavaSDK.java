package com.qtz.utils.sdk;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.Activity;
import android.util.Log;

public class QTZJavaSDK {
	public static final String TAG = "QTZJavaSDK";
	
	public static final int SDK_PLATFORM_NONE 	= 0;
	public static final int SDK_PLATFORM_GUEST 	= 1;
	public static final int SDK_PLATFORM_QQ		= 2;
	public static final int SDK_PLATFORM_WEIXIN	= 3;
	
	public static enum SDK_EVENTS
	{
		SDK_EVENT_INIT,
		SDK_EVENT_LOGIN,
		SDK_EVENT_LOGOUT,
		SDK_EVENT_PAY,
		SDK_EVENT_USER_INFO,
		SDK_EVENT_FRIEND_INFO
	};
	
	public static Activity pActivity 		= null;
	public static JavaSDKInterface pJavaSDK = null;
	public static QTZJavaSDK pQTZJavaSDK 	= null;
	
	
	public static int mPlatform 	= -1;
	
	public static QTZJavaSDK getInstance()
	{
		if (pQTZJavaSDK == null) {
			pQTZJavaSDK = new QTZJavaSDK();
		}
		return pQTZJavaSDK;
	}
	
	
	public static void init(Activity activity)
	{
		pActivity = activity;
	}
	
	
	public static Activity getActivity()
	{
		return pActivity;
	}
	
	
	public static void init(int platform)
	{
		if (mPlatform == platform) {
			return;
		}
		switch (platform)
		{
		case SDK_PLATFORM_QQ:
			pJavaSDK = new QQSDK();
			break;
		case SDK_PLATFORM_WEIXIN:
			break;
		default:
			pJavaSDK = null;
		
		}
		mPlatform = platform;
	}
	
	public static void login(int platform)
	{
		init(platform);
		if (pJavaSDK != null) {
			pJavaSDK.login();
		}
		else
		{
			Log.i(TAG, "call login failed... platform is: " + mPlatform);
		}
	}
	
	
	public static void logout()
	{
		if (pJavaSDK != null) {
			pJavaSDK.logout();
		}
		else
		{
			Log.i(TAG, "call logout failed... platform is: " + mPlatform);
		}
	}
	
	
	public static String getAccessToken()
	{
		String ret = "";
		if (pJavaSDK != null) 
		{
			ret = pJavaSDK.getAccessToken();
		}
		else
		{
			Log.i(TAG, "call getAccessToken failed... platform is: " + mPlatform);
		}
		return ret;
	}
	
	
	public static String getPayToken()
	{
		String ret = "";
		if (pJavaSDK != null)
		{
			ret = pJavaSDK.getPayToken();
		}
		else
		{
			Log.i(TAG, "call getPayToken failed... platform is: " + mPlatform);
		}
		return ret;
	}
	
	
	public static String getPf()
	{
		String ret = "";
		if (pJavaSDK != null) {
			ret = pJavaSDK.getPf();
		}
		else
		{
			Log.i(TAG, "call getPf failed... platform is: " + mPlatform);
		}
		return ret;
	}
	
	
	public static String getPfKey()
	{
		String ret = "";
		if (pJavaSDK != null) {
			ret = pJavaSDK.getPfKey();
		}
		else
		{
			Log.i(TAG, "call getPfKey failed... platform is: " + mPlatform);
		}
		return ret;
	}
	
	
	public static void onNotifyDirect(SDK_EVENTS event, final int code, final String msg)
	{
		Log.i(TAG, "Event type is: " + event + " code is: " + code + " msg is: " + msg);
		QTZJavaSDK.getInstance().onNotifyNative(event.ordinal(), code, msg);
	}
	
	
	public static void onNotify(SDK_EVENTS event, final int code, final String msg)
	{
		Log.i(TAG, "Event type is: " + event + " code is: " + code + " msg is: " + msg);
		
		final int iEvent = event.ordinal();
		Cocos2dxActivity activity = (Cocos2dxActivity)pActivity;
		activity.runOnGLThread(new Runnable(){

			@Override
			public void run() {
				QTZJavaSDK.getInstance().onNotifyNative(iEvent, code, msg);
			}
			
		});
	}
	
	private native void onNotifyNative(int eEventType, int code, String msg);
	
	public static interface JavaSDKInterface
	{
		public void login();
		public void logout();
		public String getAccessToken();
		public String getPayToken();
		public String getPf();
		public String getPfKey();
		public String getOpenId();
		public String getUid();
		public String getUdid();
		public String getExtraInfo();
		
		public void getUserInfo();
		public void getFriendsInfo();
		public void pay(int uid, String order, String productId, String productName, float amount, String paydes);
		public void reportEvent(String name, String body, boolean isRealTime);
	}
}
