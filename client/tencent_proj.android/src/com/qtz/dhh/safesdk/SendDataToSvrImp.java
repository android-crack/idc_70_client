package com.qtz.dhh.safesdk;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import com.tencent.tp.TssSdk;
import android.app.Activity;
import android.util.Base64;
import android.util.Log;

public class SendDataToSvrImp implements TssSdk.ISendDataToSvr{
	private static final String TAG = "SendDataToSvrImp";
	private Activity context = null;
	private String luaCallback = null;

	public SendDataToSvrImp(Activity context, String luaCallback) {
		this.context = context;
		this.luaCallback = luaCallback;
	}

	@Override
	public int sendDataToSvr(byte[] data, int size) {
		Log.d(TAG, "sendDataToSvr: size=" + size);
		final String ret = Base64.encodeToString(data, Base64.NO_WRAP);

		Log.d(TAG, "ret is: " + ret + " , len is: " + ret.length());

		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				if (luaCallback != null && !luaCallback.equals("")) {
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(luaCallback, ret);
				}
			}
		});
		
		return 1;
	}

}
