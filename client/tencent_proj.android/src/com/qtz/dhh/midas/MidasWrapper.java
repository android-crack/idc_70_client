package com.qtz.dhh.midas;

import org.json.JSONException;
import org.json.JSONObject;

import com.tencent.midas.api.APMidasPayAPI;
import com.tencent.midas.api.request.APMidasGameRequest;
import com.tencent.midas.api.request.APMidasMonthRequest;
import com.tencent.midas.api.request.APMidasSubscribeRequest;
import com.tencent.msdk.WeGame;
import com.tencent.msdk.api.LoginRet;
import com.tencent.msdk.api.TokenRet;
import com.tencent.msdk.api.WGPlatform;
import com.tencent.msdk.consts.CallbackFlag;
import com.tencent.msdk.consts.TokenType;
import com.tencent.msdk.tools.Logger;
import com.tencent.tmgp.qmdhh.R;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

public class MidasWrapper {

    public static String offerId = "";
    public static String userId = "";
    public static String openKey = "";
    public static String payToken = "";
    public static String accessToken = "";
    public static String sessionId = "";
    public static String sessionType = "";
    public static String pf = "";
    public static String pfKey = "";
    // public static String zoneId = "";
    public static String saveNum = "";
    public static String env = APMidasPayAPI.ENV_TEST;
    // public static String env = APMidasPayAPI.ENV_RELEASE;
    static String[] assignChannels = {"指定渠道", APMidasPayAPI.PAY_CHANNEL_WECHAT, APMidasPayAPI.PAY_CHANNEL_QQWALLET, APMidasPayAPI.PAY_CHANNEL_BANK};
    public static String assignChannel = assignChannels[0];   //默认
    
    public static Context context = null;

    private static boolean isInited = false;
    private static DhhMidasPayCallBack callback = null;

    // 初始化参数
	public static void init(final String environment) {
        Log.d("midas", "init environment: " + environment);
		LoginRet ret = new LoginRet();
		WGPlatform.WGGetLoginRecord(ret);
		if (ret.flag != CallbackFlag.eFlag_Succ) {
			Logger.d("UserLogin error!!!");
			return;
		}
		// 对于openkey，qq是paytoken，微信是accesstoken
		if (ret.platform == WeGame.QQPLATID) {
			String qqAccessToken = "";
			String qqPayToken = "";

			for (TokenRet tr : ret.token) {
				switch (tr.type) {
					case TokenType.eToken_QQ_Access:
						qqAccessToken = tr.value;
						break;
					case TokenType.eToken_QQ_Pay:
						qqPayToken = tr.value;
						break;
					default:
						break;
				}
			}
	
			userId = ret.open_id;
			openKey = qqPayToken;
			payToken = qqPayToken;
			accessToken = qqAccessToken;
			sessionId = "openid";
			sessionType = "kp_actoken";
			pf = ret.pf;
			pfKey = ret.pf_key;

		} else if (ret.platform == WeGame.WXPLATID) {
			String wxAccessToken = "";
			for (TokenRet tr : ret.token) {
				switch (tr.type) {
					case TokenType.eToken_WX_Access:
						wxAccessToken = tr.value;
						break;
					case TokenType.eToken_WX_Refresh:
						// wxRefreshToken = tr.value;
						break;
					default:
						break;
				}
			}

			userId = ret.open_id;
			openKey = wxAccessToken;
			payToken = wxAccessToken;
			accessToken = wxAccessToken;
			sessionId = "hy_gameid";
			sessionType = "wc_actoken";
			pf = ret.pf;
			pfKey = ret.pf_key;
		}

		offerId = "1450008714";
		isInited = false;
		env = environment;
        callback = null;
 	}

	private static void initMidas() {
		Log.d("midas", "initMidas");
        final Activity activity = (Activity)context;
        activity.runOnUiThread(new Runnable(){
            @Override
            public void run() {
        		APMidasGameRequest request = new APMidasGameRequest();
                request.offerId = offerId;
                request.openId = userId;
                request.openKey = openKey;
                request.sessionId = sessionId;
                request.sessionType = sessionType;
                request.pf = pf;
                request.pfKey = pfKey;
                APMidasPayAPI.setEnv(env);
                APMidasPayAPI.setLogEnable(true);
                //初始化新接口
                APMidasPayAPI.init(context, request);
            }
        });

        isInited = true;
	}


	public static void pay(int uid, String order, String productId, String productName, String amount, String paydes) {
		Log.d("midas", "pay uid:" + uid + "; order: " + order + "; productId: " + 
        		productId + "; productName: " + productName + "; amount: " + amount + "; paydes: " + paydes);
		String type = null;
		String serviceCode = null;
        String zoneId = null;
		try {
			JSONObject extInfo = new JSONObject(paydes);
			type = extInfo.getString("type");
			serviceCode = extInfo.getString("serviceCode");
            zoneId = extInfo.getString("zoneId");
		} catch (JSONException e) {
			e.printStackTrace();
		}
        Log.d("midas", "type: " + type + "; serviceCode: " + serviceCode  + "; zoneId: " + zoneId);

		if ("0".equals(type)) {
			payGame(uid, order, productId, productName, amount, zoneId);
		} else if ("1".equals(type)) {
			paySubscribe(uid, order, productId, productName, serviceCode, zoneId);
		} else {
			
		}

	}


	// 
	public static void payGame(int uid, String order, String productId, String productName, String amount, String zoneId) {
		Log.d("midas", "payGame uid:" + uid + "; order: " + order + "; productId: " + 
        		productId + "; productName: " + productName + "; amount: " + amount);
		if (!isInited) {
			initMidas();
		}
		if (callback == null) {
			callback = new DhhMidasPayCallBack();
            callback.context = context;
            callback.userId = userId;
            callback.payToken = payToken;
            callback.accessToken = accessToken;
            callback.pf =  pf;
            callback.pfKey = pfKey;
		}

		final APMidasGameRequest request = new APMidasGameRequest();
        request.offerId = offerId;
        request.openId = userId;
        request.openKey = openKey;
        request.sessionId = sessionId;
        request.sessionType = sessionType;
        request.zoneId = zoneId;
        request.pf = pf;
        request.pfKey = pfKey;
        request.saveValue = amount;
        request.reserv = "";
        request.extendInfo.unit = "个";

//        request.extendInfo.unit = "specialUnit=1:文|100:两|10000:锭";


        request.isCanChange = false;

        // request.acctType = "common";
        request.resId = R.drawable.icon; //显示的游戏币示意图，例如R.drawable.yuanbao;
        request.gameLogo = R.drawable.icon; // 游戏的logo，例如R.drawable.midas_store_custom_skin_cartoon;

        // request.mpInfo.payChannel = APMidasPayAPI.PAY_CHANNEL_WECHAT; //APMidasPayAPI.PAY_CHANNEL_WECHAT, APMidasPayAPI.PAY_CHANNEL_QQWALLET, APMidasPayAPI.PAY_CHANNEL_BANK//assignChannel;
        request.mpInfo.payChannel = assignChannel;
        // request.mpInfo.payChannel = "指定渠道";

        request.extendInfo.isShowNum = true; // 显示数量
        request.extendInfo.isShowListOtherNum = true; //显示其他数额

        Log.d("midasrequest=============", "offerId: " + request.offerId);
        Log.d("midasrequest=============", "openId: " + request.openId);
        Log.d("midasrequest=============", "openKey: " + request.openKey);
        Log.d("midasrequest=============", "sessionId: " + request.sessionId);
        Log.d("midasrequest=============", "sessionType: " + request.sessionType);
        Log.d("midasrequest=============", "zoneId: " + request.zoneId);
        Log.d("midasrequest=============", "pf: " + request.pf);
        Log.d("midasrequest=============", "pfKey: " + request.pfKey);
        Log.d("midasrequest=============", "saveValue: " + request.saveValue);
        Log.d("midasrequest=============", "reserv: " + request.reserv);
        Log.d("midasrequest=============", "extendInfo.unit: " + request.extendInfo.unit);
        Log.d("midasrequest=============", "isCanChange: " + request.isCanChange);
        Log.d("midasrequest=============", "resId: " + request.resId);
        Log.d("midasrequest=============", "gameLogo: " + request.gameLogo);
        Log.d("midasrequest=============", "mpInfo.payChannel: " + request.mpInfo.payChannel);
        Log.d("midasrequest=============", "extendInfo.isShowNum: " + request.extendInfo.isShowNum);
        Log.d("midasrequest=============", "extendInfo.isShowListOtherNum: " + request.extendInfo.isShowListOtherNum);

        final Activity activity = (Activity)context;
        activity.runOnUiThread(new Runnable(){
            @Override
            public void run() {
                APMidasPayAPI.launchPay(activity, request, callback);
            }
        });
	}

    public static void paySubscribe(int uid, String order, String productId, String serviceName, String serviceCode, String zoneId) {
        Log.d("midas", "paySubscribe uid:" + uid + "; order: " + order + "; productId: " + 
        		productId + "; serviceName: " + serviceName + "; serviceCode: " + serviceCode);
        if (!isInited) {
            initMidas();
        }
        if (callback == null) {
            callback = new DhhMidasPayCallBack();
            callback.context = context;
            callback.userId = userId;
            callback.payToken = payToken;
            callback.accessToken = accessToken;
            callback.pf =  pf;
            callback.pfKey = pfKey;
        }

        final APMidasSubscribeRequest request = new APMidasSubscribeRequest();
        request.offerId = offerId;
        request.openId = userId;
        request.openKey = openKey;
        request.sessionId = sessionId;
        request.sessionType = sessionType;
        request.zoneId = zoneId;
        request.pf = pf;
        request.pfKey = pfKey;
        request.saveValue = "1";
        request.reserv = "";
        // request.extendInfo.unit = "个";

        request.autoPay = false;
        request.acctType = "common";
        request.serviceCode = serviceCode; 	// 需要开通业务的业务代码
        request.serviceName = serviceName; 	//需要开通业务的业务名称
        request.productId = productId;
        request.remark = null;
        // request.serviceType = APMidasMonthRequest.SERVICETYPE_NORMAL;	// 1表示正常开通,3表示升级,4表示赠送
        
//        request.extendInfo.unit = "specialUnit=1:文|100:两|10000:锭";


        request.isCanChange = false;		// 开通月数是否可改，默认为true

        // request.acctType = "common";
        request.resId = R.drawable.icon; //显示的游戏币示意图，例如R.drawable.yuanbao;
        request.gameLogo = R.drawable.icon; // 游戏的logo，例如R.drawable.midas_store_custom_skin_cartoon;

        // request.mpInfo.payChannel = APMidasPayAPI.PAY_CHANNEL_WECHAT; //APMidasPayAPI.PAY_CHANNEL_WECHAT, APMidasPayAPI.PAY_CHANNEL_QQWALLET, APMidasPayAPI.PAY_CHANNEL_BANK//assignChannel;
        request.mpInfo.payChannel = assignChannel;
        // request.mpInfo.payChannel = "指定渠道";

        request.extendInfo.isShowNum = true; // 显示数量
        request.extendInfo.isShowListOtherNum = true; //显示其他数额

        Log.d("midasrequest=============", "offerId: " + request.offerId);
        Log.d("midasrequest=============", "openId: " + request.openId);
        Log.d("midasrequest=============", "openKey: " + request.openKey);
        Log.d("midasrequest=============", "sessionId: " + request.sessionId);
        Log.d("midasrequest=============", "sessionType: " + request.sessionType);
        Log.d("midasrequest=============", "zoneId: " + request.zoneId);
        Log.d("midasrequest=============", "pf: " + request.pf);
        Log.d("midasrequest=============", "pfKey: " + request.pfKey);
        Log.d("midasrequest=============", "saveValue: " + request.saveValue);
        Log.d("midasrequest=============", "reserv: " + request.reserv);
        Log.d("midasrequest=============", "acctType: " + request.acctType);
        Log.d("midasrequest=============", "serviceCode: " + request.serviceCode);
        Log.d("midasrequest=============", "serviceName: " + request.serviceName);
        Log.d("midasrequest=============", "productId: " + request.productId);
        Log.d("midasrequest=============", "remark: " + request.remark);
        Log.d("midasrequest=============", "acctType: " + request.acctType);
        Log.d("midasrequest=============", "serviceType: " + request.serviceType);
        Log.d("midasrequest=============", "isCanChange: " + request.isCanChange);

        final Activity activity = (Activity)context;
        activity.runOnUiThread(new Runnable(){
            @Override
            public void run() {
                APMidasPayAPI.launchPay(activity, request, callback);
            }
        });
    }
}
