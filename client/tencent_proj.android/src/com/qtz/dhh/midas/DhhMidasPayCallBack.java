package com.qtz.dhh.midas;

import com.tencent.midas.api.APMidasResponse;
import com.tencent.midas.api.IAPMidasPayCallBack;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxActivity;

import android.util.Log;
import android.widget.Toast;

import android.content.Context;
import org.json.JSONException;
import org.json.JSONObject;

public class DhhMidasPayCallBack implements IAPMidasPayCallBack {
    public static Context context = null;

    public static String userId = "";
    // public static String userKey = "";
    public static String pf = "";
    public static String pfKey = "";
    public static String payToken = "";
    public static String accessToken = "";

	@Override
	public void MidasPayCallBack(APMidasResponse apMidasResponse) {
		// TODO Auto-generated method stub
		//Log.d("midas", "MidasPayCallback");
		Log.d("midaspaycallback", "resultcode: " + apMidasResponse.resultCode);
		//Log.d("midaspaycallback=============", "resultMsg: " + apMidasResponse.resultMsg);
		//Log.d("midaspaycallback=============", "realSaveNum: " + apMidasResponse.realSaveNum);
		//Log.d("midaspaycallback=============", "payChannel: " + apMidasResponse.payChannel);

		JSONObject json = new JSONObject();
		JSONObject object = new JSONObject();
		
		switch (apMidasResponse.resultCode){
			case -1:
				//支付流程失败     PAYRESULT_ERROR        = -1;
				Toast.makeText(context, "支付流程失败", Toast.LENGTH_LONG).show();
				break;
			case 0:	//支付流程成功     PAYRESULT_SUCC         =  0;
				Toast.makeText(context, "支付流程成功", Toast.LENGTH_LONG).show();
				break;
			case 2:	//用户取消         PAYRESULT_CANCEL       =  2;
				Toast.makeText(context, "支付流程取消", Toast.LENGTH_LONG).show();
				break;
			case 3:
				//参数错误         PAYRESULT_PARAMERROR   =  3;
				Toast.makeText(context, "参数错误", Toast.LENGTH_LONG).show();
				break;
			default:
				break;
		}

		try {
			object.put("openId", userId);
			object.put("tradeNo", "");
			object.put("pf", pf);
			object.put("pfKey", pfKey);
			object.put("payToken", payToken);  //qq平台使用paytoken,与登录的accesstoken不一样
			object.put("accessToken", accessToken);	//微信平台使用的是accesstoken与登录一样
			Log.d("midaspaycallback", "pf: " + pf);
			Log.d("midaspaycallback", "pfkey: " + pfKey);
			Log.d("midaspaycallback", "payToken: " + payToken);
			Log.d("midaspaycallback", "accessToken: " + accessToken);
			json.put("info", object.toString());
			json.put("flag", apMidasResponse.resultCode);
		} catch (JSONException e) {
			Log.d("midaspaycallback error:mk object json exception", "");
			e.printStackTrace();
		}
		final String result = json.toString();
		final Cocos2dxActivity activity = (Cocos2dxActivity)context;
        activity.runOnGLThread(new Runnable(){
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("midasPayCallBack", result);
            }
        });
	}

	@Override
	public void MidasPayNeedLogin() {
		// 登录态失败的回调，就是传递登录态的userkey过期或者无效，支付sdk就会回调这个接口
		Log.d("midas", "MidasPayNeedLogin");
		JSONObject json = new JSONObject();
		try {
			json.put("flag", 10000);
		} catch (JSONException e) {
			Log.d("midaspaycallback error:mk object json exception", "");
			e.printStackTrace();
		}
		final String result = json.toString();
		final Cocos2dxActivity activity = (Cocos2dxActivity)context;
        activity.runOnGLThread(new Runnable(){
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("midasPayCallBack", result);
            }
        });
		// Toast.makeText(context, "userkey过期或者无效, 请重新登录", Toast.LENGTH_LONG).show();
	}

}
