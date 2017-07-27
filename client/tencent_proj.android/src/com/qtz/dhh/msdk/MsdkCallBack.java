package com.qtz.dhh.msdk;

import java.util.Vector;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import android.content.Context;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import com.qtz.dhh.midas.MidasWrapper;
import com.qtz.utils.share.QTZShareSDK;
import com.tencent.msdk.WeGame;
import com.tencent.msdk.api.CardRet;
import com.tencent.msdk.api.LocationRet;
import com.tencent.msdk.api.LoginRet;
import com.tencent.msdk.api.ShareRet;
import com.tencent.msdk.api.TokenRet;
import com.tencent.msdk.api.WGPlatform;
import com.tencent.msdk.api.WGPlatformObserver;
import com.tencent.msdk.api.WakeupRet;
import com.tencent.msdk.consts.CallbackFlag;
import com.tencent.msdk.consts.TokenType;
import com.tencent.msdk.remote.api.RelationRet;
import com.tencent.msdk.tools.Logger;

public class MsdkCallBack implements WGPlatformObserver {
	private static final String TAG = "MsdkCallBack";
    public static JSONObject wakeupJson = null;
    private static String result = "";
    // 判断是否已经进入游戏
    public static boolean isInGame = false;

    // 查询个人信息或者好友信息
    private static boolean queryMyInfo = false;
	
	private Context context;
	public MsdkCallBack(Context context) {
		this.context = context;
	}

	@Override
	public String OnCrashExtMessageNotify() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void OnFeedbackNotify(int flag, String desc) {
		// TODO Auto-generated method stub
		Log.d(TAG, "OnFeedbackNotify flag: " + flag + "; desc: " + desc);
	}

	@Override
	public void OnLocationNotify(RelationRet relationRet) {
		// TODO Auto-generated method stub
		Log.d(TAG, "OnLocationNotify: " + relationRet.flag);
		JSONObject json = new JSONObject();
		try {
			json.put("flag", relationRet.flag);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		switch (relationRet.flag) {
			case CallbackFlag.eFlag_Succ:
		    	JSONObject msg = new JSONObject();
		        // relationRet.persons里面放置的就是附近的同玩好友的信息
        		try {
	        		for (int i = 0; i < relationRet.persons.size(); i++) {
			            JSONObject person = new JSONObject();
						person.put("gender", relationRet.persons.elementAt(i).gender);
			            person.put("nickName", relationRet.persons.elementAt(i).nickName);
			            person.put("openId", relationRet.persons.elementAt(i).openId);
			            person.put("pictureLarge", relationRet.persons.elementAt(i).pictureLarge);
			            person.put("pictureMiddle", relationRet.persons.elementAt(i).pictureMiddle);
			            person.put("pictureSmall", relationRet.persons.elementAt(i).pictureSmall);
			            person.put("provice", relationRet.persons.elementAt(i).province);
			            person.put("city", relationRet.persons.elementAt(i).city);
			            person.put("country", relationRet.persons.elementAt(i).country);
			            person.put("distance", relationRet.persons.elementAt(i).distance);
			            person.put("gpsCity", relationRet.persons.elementAt(i).gpsCity);
			            person.put("isFriend", relationRet.persons.elementAt(i).isFriend);
			            person.put("lang", relationRet.persons.elementAt(i).lang);
			            int key = i + 1;
			            msg.put(key+"", person);
			    	}
	        		json.put("msg", msg);
        		} catch (JSONException e) {
					e.printStackTrace();
				}
				
				break;
			default:
				break;
		}

		Log.d(TAG, json.toString());
		final String str = json.toString();
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("nearbyPersonInfoBack", str);
			}
		});
	}

	/**
	 * msdk 拉起授权登录成功,进入游戏
	 * @param openId - 
	 * @param token - 
	 */
	private void msdkLoginSuccess(final String openId, final String token, final Boolean isWx) {
		Log.d(TAG, "msdkLoginSuccess");
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			@Override
			public void run() {
            	String result = null;
            	if (isWx) {
  					JSONObject json = new JSONObject();

					try {
						json.put("openId", openId);
						json.put("pf", LoginConfig.pf);
						json.put("payToken", token);
						json.put("accessToken", token);
						json.put("pfKey", LoginConfig.pfKey);
						result = json.toString();
					} catch(JSONException e) {
						e.printStackTrace();
					}
				} else {
                    JSONObject json = new JSONObject();
                    try {
						json.put("openId", openId);
						json.put("pf", LoginConfig.pf);
						json.put("payToken", LoginConfig.qqPayToken);
						json.put("accessToken", LoginConfig.qqAccessToken);
						json.put("pfKey", LoginConfig.pfKey);
						result = json.toString();
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}
            	Log.d(TAG, "login success return: " + result);
            	Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("loginSuccess", result);

            	// 米大师数据的初始化
            	// MidasWrapper.init("test");
			}
		});
	}
	
	/**
	 * msdk 拉起授权登录失败
	 */
	private void msdkLoginFailed(final int flag) {
		Log.d(TAG, "msdkLoginFailed");
		// 显示登陆界面
   	 	DhhMsdk.stopWaiting();
   	 
   	 	DhhMsdk.logout();
   	 
   	 	((Cocos2dxActivity) context).runOnGLThread(new Runnable(){
			public void run() {	
				
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("loginFailedCB", flag+"");
			}
		});
	}

	@Override
	public void OnLoginNotify(final LoginRet ret) {
		// game todo
        // Login.toastCallbackInfo(ret.platform, "登录", ret.flag, ret.desc);
        Logger.d("called");
        Logger.d("ret.flag" + ret.flag);
        
        switch (ret.flag) {
        	case CallbackFlag.eFlag_Need_Realname_Auth:
        		Log.d(TAG, "need real name auth.......");
        		break;
            case CallbackFlag.eFlag_Succ:
            	handleLoginCallBack(ret);
                break;
            case CallbackFlag.eFlag_WX_RefreshTokenSucc:
                Log.d(TAG, "wx_refresh token succ");
                break;
            case CallbackFlag.eFlag_WX_RefreshTokenFail:
                Log.d(TAG, "wx_refresh token fail");
                break;
      		// case CallbackFlag.eFlag_WX_UserCancel:
      		// case CallbackFlag.eFlag_WX_NotInstall:
      		// case CallbackFlag.eFlag_WX_NotSupportApi:
      		// case CallbackFlag.eFlag_WX_LoginFail:
      		// case CallbackFlag.eFlag_QQ_NoAcessToken:
    		// case CallbackFlag.eFlag_Login_NetworkErr:
            case CallbackFlag.eFlag_Local_Invalid:
            	msdkLoginFailed(ret.flag);
            	break;
            default:
            	msdkLoginFailed(ret.flag);
                break;
        }
	}

	private void handleLoginCallBack(LoginRet ret) {
		DhhMsdk.stopWaiting();
    	// 登陆成功, 读取各种票据
        String openId = ret.open_id;
        LoginConfig.openId = openId;
        LoginConfig.pf = ret.pf;
        LoginConfig.pfKey = ret.pf_key;
        Log.d(TAG, "open_id: " + openId);
        DhhMsdk.platform = ret.platform;
        String wxAccessToken = "";
        long wxAccessTokenExpire = 0;
        String wxRefreshToken = "";
        long wxRefreshTokenExpire = 0;
        for (final TokenRet tr : ret.token) {
        	Logger.d("tr.type" + tr.type);
            switch (tr.type) {
                case TokenType.eToken_WX_Access:
                    wxAccessToken = tr.value;
                    wxAccessTokenExpire = tr.expiration;
                    Logger.d("wxAccessToken: " + wxAccessToken + ", wxAccessTokenExpire: " + wxAccessTokenExpire);
                    break;
                case TokenType.eToken_WX_Refresh:
                    wxRefreshToken = tr.value;
                    wxRefreshTokenExpire = tr.expiration;
                    Logger.d("wxAccessToken1: " + wxAccessToken + ", wxAccessTokenExpire: " + wxAccessTokenExpire);
                    break;
                case TokenType.eToken_QQ_Access:
                	Logger.d("startActivity:" + tr.value);
                	LoginConfig.qqAccessToken = tr.value;
                	break;
                case TokenType.eToken_QQ_Pay:
                	LoginConfig.qqPayToken = tr.value;
                	break;
                case TokenType.eToken_WX_Code:
                	break;
                default:
                    break;
            }
        }
        if (ret.platform == WeGame.QQPLATID) {
        	msdkLoginSuccess(ret.open_id, LoginConfig.qqAccessToken, false);
        } else if (ret.platform == WeGame.WXPLATID) {
        	msdkLoginSuccess(ret.open_id, wxAccessToken, true);
        }
	}
	
	@Override
	public void OnRelationNotify(RelationRet relationRet) {
		Log.d(TAG, "OnRelationNotify: " + relationRet.flag);
		switch (relationRet.flag) {
			case CallbackFlag.eFlag_Succ:
				
				JSONObject json = new JSONObject();
		    	JSONObject msg = new JSONObject();
		    	
				LoginRet ret = new LoginRet();
		        WGPlatform.WGGetLoginRecord(ret);
		        
		        int start = 0;
		        int key = 1;
		        // 判断是哪一个平台登录
		        if (ret.platform == WeGame.QQPLATID) {
		        	if (relationRet.persons.size() == 1 && relationRet.persons.elementAt(0).openId.equals("")) {
		        		queryMyInfo = true;
		        	} else {
		        		queryMyInfo = false;
		        		start = 0;	// QQ好友信息从下标0开始
		        	}
		        } else if (ret.platform == WeGame.WXPLATID) {
		        	if (relationRet.persons.size() == 1) { // 如果返回的数据只有一行，则认为是获取个人信息
		        		queryMyInfo = true;
		        	} else {
		        		queryMyInfo = false;
		        		start = 1;	// 微信好友信息从下标1开始
		        	}
		        }		    	

		        if (queryMyInfo) {
	        		try {
						json.put("type", "0");
		        		msg.put("gender", relationRet.persons.elementAt(0).gender);
		        		msg.put("nickName", relationRet.persons.elementAt(0).nickName);
		        		msg.put("openId", relationRet.persons.elementAt(0).openId);
		        		msg.put("pictureLarge", relationRet.persons.elementAt(0).pictureLarge);
		        		msg.put("pictureMiddle", relationRet.persons.elementAt(0).pictureMiddle);
		        		msg.put("pictureSmall", relationRet.persons.elementAt(0).pictureSmall);
		        		msg.put("provice", relationRet.persons.elementAt(0).province);
		        		msg.put("city", relationRet.persons.elementAt(0).city);
		        		msg.put("country", relationRet.persons.elementAt(0).country);
		        		msg.put("distance", relationRet.persons.elementAt(0).distance);
		        		msg.put("gpsCity", relationRet.persons.elementAt(0).gpsCity);
		        		msg.put("isFriend", relationRet.persons.elementAt(0).isFriend);
		        		msg.put("lang", relationRet.persons.elementAt(0).lang);
		        		json.put("msg", msg);
					} catch (JSONException e) {
						e.printStackTrace();
					}
	        	} else {
	        		try {
		        		json.put("type", "1");
		        		for (int i = start; i < relationRet.persons.size(); i++) {
				            JSONObject person = new JSONObject();
							person.put("gender", relationRet.persons.elementAt(i).gender);
				            person.put("nickName", relationRet.persons.elementAt(i).nickName);
				            person.put("openId", relationRet.persons.elementAt(i).openId);
				            person.put("pictureLarge", relationRet.persons.elementAt(i).pictureLarge);
				            person.put("pictureMiddle", relationRet.persons.elementAt(i).pictureMiddle);
				            person.put("pictureSmall", relationRet.persons.elementAt(i).pictureSmall);
				            person.put("provice", relationRet.persons.elementAt(i).province);
				            person.put("city", relationRet.persons.elementAt(i).city);
				            person.put("country", relationRet.persons.elementAt(i).country);
				            person.put("distance", relationRet.persons.elementAt(i).distance);
				            person.put("gpsCity", relationRet.persons.elementAt(i).gpsCity);
				            person.put("isFriend", relationRet.persons.elementAt(i).isFriend);
				            person.put("lang", relationRet.persons.elementAt(i).lang);
				            msg.put(key+"", person);
				            key++;
				    	}
		        		json.put("msg", msg);
	        		} catch (JSONException e) {
						e.printStackTrace();
					}
	        	}
		        Log.d(TAG, "queryMyInfo: " + queryMyInfo);
				Log.d(TAG, json.toString());
				final String str = json.toString();
				((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("getTencentInfoCallBack", str);
					}
				});

				break;
			default:
				break;
		}
	}

	@Override
	public void OnShareNotify(ShareRet arg0) {
		Log.i(TAG, String.format("share notify... platform is [%d], and ret is [%d], and msg is: %s", arg0.platform, arg0.flag, arg0.desc));
		QTZShareSDK.onShareNotify(arg0.flag, arg0.desc);
		QTZShareSDK.deleteImage();
	}

	@Override
	public void OnWakeupNotify(WakeupRet ret) {
        // Login.toastCallbackInfo(ret.platform, "拉起", ret.flag, ret.desc);
		Log.d(TAG, "onWakeupNotify");
        DhhMsdk.logCallbackRet(ret);
        DhhMsdk.platform = ret.platform;

        LoginRet oldRet = new LoginRet();
        WGPlatform.WGGetLoginRecord(oldRet);
        int oldPlatform = oldRet.platform;
        
        // 是否拥有启动特权
		String vip = "no";
		if ((ret.platform == WeGame.WXPLATID) && ("WX_GameCenter".equals(ret.messageExt))) {
        	vip = "yes";
        } else if (ret.platform == WeGame.QQPLATID) {
        	for (int i = 0; i < ret.extInfo.size(); i++) {
        		if ("launchfrom".equals(ret.extInfo.elementAt(i).key)) {
        			if ("sq_gamecenter".equals(ret.extInfo.elementAt(i).value)) {
        				vip = "yes";
        			}
        			break;
        		}
    		}
        }

        wakeupJson = new JSONObject();
        try {
        	wakeupJson.put("old_platform", oldPlatform);
			wakeupJson.put("platform", ret.platform);	// platform: 1-wexin 2-qq
			wakeupJson.put("flag", ret.flag);
			wakeupJson.put("vip", vip);		// yes-有启动特权 no-没有启动特权
		} catch (JSONException e) {
			e.printStackTrace();
		}
        Log.d(TAG, "wakeupJson: " + wakeupJson.toString());
        
        if (isInGame) {
        	final String str = wakeupJson.toString();
        	((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("wakeupNotifyBack", str);
				}
			});
        	wakeupJson = null;
        }

        // 游戏对于平台拉起的处理，主要是处理异帐号相关的逻辑
        if (CallbackFlag.eFlag_Succ == ret.flag
                || CallbackFlag.eFlag_AccountRefresh == ret.flag) {
        	Log.d(TAG, "OnWakeupNotify: flag: " + ret.flag);
            //代表拉起以后通过本地帐号登录游戏，处理逻辑与onLoginNotify的一致
        	// DhhMsdk.switchUser(0);
        } else if (CallbackFlag.eFlag_UrlLogin == ret.flag) {
        	Log.d(TAG, "OnWakeupNotify: url login");
            // MSDK会尝试去用拉起账号携带票据验证登录，结果在OnLoginNotify中回调，游戏此时等待onLoginNotify的回调
        	// DhhMsdk.switchUser(1);
        } else if (ret.flag == CallbackFlag.eFlag_NeedSelectAccount) {
            // 当前游戏存在异账号，游戏需要弹出提示框让用户选择需要登录的账号
            Log.d(TAG, "OnWakeupNotify: need select accout");

        } else if (ret.flag == CallbackFlag.eFlag_NeedLogin) {
            // 没有有效的票据，无法登录游戏，此时游戏调用WGLogout登出游戏让用户重新登录
            Log.d(TAG, "OnWakeupNotify: need login");
        	DhhMsdk.logout();

        } else {
            //默认的处理逻辑建议游戏调用WGLogout登出游戏让用户重新登录
        	DhhMsdk.logout();
        }
	}



	@Override
	public void OnAddWXCardNotify(CardRet arg0) {
		// TODO Auto-generated method stub
		
	}



	@Override
	public byte[] OnCrashExtDataNotify() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void OnLocationGotNotify(LocationRet locationRet) {
		// TODO Auto-generated method stub
		Log.d(TAG, "OnLocationGotNotify:" + locationRet.flag);
		JSONObject json = new JSONObject();
		try {
			json.put("flag", locationRet.flag);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}

		switch (locationRet.flag) {
			case CallbackFlag.eFlag_Succ:
		    	JSONObject msg = new JSONObject();
		        // longitude 玩家位置经度，double类型
		        // latitude 玩家位置纬度，double类型
	    		try {
	        		msg.put("longitude", locationRet.longitude);
	        		msg.put("latitude", locationRet.latitude);
	        		json.put("msg", msg);
	    		} catch (JSONException e) {
					e.printStackTrace();
				}
				break;
			default:
				break;
		}
		Log.d(TAG, json.toString());
		final String str = json.toString();
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("getLocationInfoBack", str);
			}
		});
	}
}
