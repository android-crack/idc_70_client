package com.qtz.dhh.msdk;

import android.app.ProgressDialog;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import java.util.HashMap;
import java.util.Vector;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import com.tencent.msdk.WeGame;
import com.tencent.msdk.api.CallbackRet;
import com.tencent.msdk.api.LoginRet;
import com.tencent.msdk.api.MsdkBaseInfo;
import com.tencent.msdk.api.WGPlatform;
import com.tencent.msdk.api.WGQZonePermissions;
import com.tencent.msdk.consts.CallbackFlag;
import com.tencent.msdk.consts.EPlatform;
import com.tencent.msdk.notice.NoticeInfo;
import com.tencent.msdk.stat.eBuglyLogLevel;
import com.tencent.msdk.tools.Logger;
import com.tencent.tmgp.qmdhh.Dhh;


public class DhhMsdk {
	private static final String TAG = "DhhMsdk";
	public static Dhh context = null;
	private static ProgressDialog mAutoLoginWaitingDlg;
	public static int platform = EPlatform.ePlatform_None.val();
	
	private enum SDKPlatform  
    {  
		PLATFORM_NONE,
		PLATFORM_GUEST,
		PLATFORM_QQ,
		PLATFORM_WEIXIN
    };
	
    public static void toastCallbackInfo(int plat, String what, int flag, String desc) {
        String platStr = "";
        if (plat == EPlatform.ePlatform_QQ.val()) {
            platStr = "QQ游戏中心";
        } else if (plat == EPlatform.ePlatform_Weixin.val()) {
            platStr = "微信";
        } else if (plat == EPlatform.ePlatform_QQHall.val()) {
            platStr = "游戏大厅";
        }
        String msg = "收到" + platStr + what + "回调 ";
        msg += "\nflag :" + flag;
        msg += "\ndesc :" + desc;
        Toast.makeText(context, msg, Toast.LENGTH_LONG).show();
    }
    
    public static void logCallbackRet(CallbackRet cr) {
        Logger.d(cr.toString() + ":flag:" + cr.flag);
        Logger.d(cr.toString() + "desc:" + cr.desc);
        Logger.d(cr.toString() + "platform:" + cr.platform);
    }
	
    public static void startWaiting() {
        Logger.d("startWaiting");
        stopWaiting();
        mAutoLoginWaitingDlg = new ProgressDialog(context);
        mAutoLoginWaitingDlg.setTitle("自动登录中...");
        mAutoLoginWaitingDlg.show();
    }

    public static void stopWaiting() {
        Logger.d("stopWaiting");
        if (mAutoLoginWaitingDlg != null && mAutoLoginWaitingDlg.isShowing()) {
            mAutoLoginWaitingDlg.dismiss();
        }
    }

    /**
	 * MSDK登录接口
	 * @param platform 平台：0-无 1-游客 2-QQ 3-微信
	 */
	public static void login(final int platform) {
		if ((platform != SDKPlatform.PLATFORM_QQ.ordinal()) && (platform != SDKPlatform.PLATFORM_WEIXIN.ordinal())) {
			Log.d(TAG, "the platform value is wrong");
			return;
		}

		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				LoginRet ret = new LoginRet();
				WGPlatform.WGGetLoginRecord(ret);
				if (platform == SDKPlatform.PLATFORM_QQ.ordinal()) {
					boolean isQQInstalled = WGPlatform.WGIsPlatformInstalled(EPlatform.ePlatform_QQ);
					if (!isQQInstalled) {
						WGPlatform.WGLogout();
						WGPlatform.WGLogin(EPlatform.ePlatform_QQ);
					} else {
						if (ret.platform == WeGame.QQPLATID && ret.flag == CallbackFlag.eFlag_Succ) {
							startWaiting();
				        	WGPlatform.WGLogin(EPlatform.ePlatform_None);
						} else {
							WGPlatform.WGLogout();
							WGPlatform.WGLogin(EPlatform.ePlatform_QQ);
						}
					}
				} else if(platform == SDKPlatform.PLATFORM_WEIXIN.ordinal()) {
					Log.d(TAG, "ret flag: " + ret.flag);
					if (ret.platform == WeGame.WXPLATID && (ret.flag == CallbackFlag.eFlag_Succ || ret.flag == CallbackFlag.eFlag_WX_AccessTokenExpired)) {
						startWaiting();
			        	WGPlatform.WGLogin(EPlatform.ePlatform_None);
			        	Log.d(TAG, "weixin login with local info");
					} else {
						WGPlatform.WGLogout();
						WGPlatform.WGLogin(EPlatform.ePlatform_Weixin);
						Log.d(TAG, "weixin login by pulling auth page");
					}
				}
			}
		});
	}
	
	public static void reLogin() {
		LoginRet ret = new LoginRet();
		WGPlatform.WGGetLoginRecord(ret);
		if (ret.platform == WeGame.WXPLATID) {
        	WGPlatform.WGLogin(EPlatform.ePlatform_Weixin);
		} else if (ret.platform == WeGame.QQPLATID) {
			WGPlatform.WGLogin(EPlatform.ePlatform_QQ);
		}
	}

	/**
	 * 打开url
	 * @param url url地址
	 */
	public static void  openUrl(final String url) {
		Log.d(TAG, "openUrl url_str:" + url);
		context.runOnUiThread(new Runnable() {
			public void run() {
				WGPlatform.WGOpenUrl(url);
			}
		});
	}

	/**
	 * 获取加密的url
	 * @param url_str 未加密的url
	 * @param callback 对应的回调函数
	 */
	public static void getEncodeUrl(final String url_str, final int callback) {
		final String url_encode = WGPlatform.WGGetEncodeUrl(url_str);
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, url_encode);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
	}

	public static void loginBase() {
		if (WGPlatform.IsDifferentActivity(context)) {
            Logger.d("Warning!Reduplicate game activity was detected.Activity will finish immediately.");
            WGPlatform.handleCallback(context.getIntent());
            context.finish();
            return;
        }
        /***********************************************************
         *  TODO GAME 接入必须要看， baseInfo值因游戏而异，填写请注意以下说明：  *
         *  baseInfo值游戏填写错误将导致 QQ、微信的分享，登录失败 ，切记 ！！！        *
         * 	只接单一平台的游戏请勿随意填写其余平台的信息，否则会导致部分公告获取失败  *
         ***********************************************************/
        MsdkBaseInfo baseInfo = new MsdkBaseInfo();

        baseInfo.qqAppId = "1104681464";
        baseInfo.qqAppKey = "wD6ZoLLy1bkPR0E5";
        //游戏必须使用自己的微信AppId联调
        baseInfo.wxAppId = "wxa228fbbb06c2cb79"; 
        baseInfo.offerId = "1104681464";
        baseInfo.msdkKey = "4f88b91226cad529eb2d8c914303127c";                              
		WGPlatform.Initialized(context, baseInfo);
		WGPlatform.WGSetPermission(WGQZonePermissions.eOPEN_ALL);
		//WGPlatform.WGEnableCrashReport(true, true);
		WGPlatform.WGSetObserver(new MsdkCallBack(context));
		//QQ 加群加好友回调
		WGPlatform.WGSetGroupObserver(new MsdkGroupCallback(context));
		//添加省流量的回调
		WGPlatform.WGSetSaveUpdateObserver(new SaveUpdateCallBack(context));

		if (WGPlatform.wakeUpFromHall(context.getIntent())) {
        	// 拉起平台为大厅 
        	Logger.d("LoginPlatform is Hall");
            Logger.d(context.getIntent());
        } else {  
        	// 拉起平台不是大厅
            Logger.d("LoginPlatform is not Hall");
            Logger.d(context.getIntent());
            WGPlatform.handleCallback(context.getIntent());
        }
	}

	public static void onResume() {
		//WGPlatform.onResume();
        
	}
	
	public static void onPause() {
        WGPlatform.onPause();
	}
	
	public static void onDestroy() {
		WGPlatform.onDestory(context);
	}
	
	public static void onNewIntent(Intent intent) {
        if (WGPlatform.wakeUpFromHall(intent)) {
            Logger.d("LoginPlatform is Hall");
            Logger.d(intent);
        } else {
            Logger.d("LoginPlatform is not Hall");
            Logger.d(intent);
            WGPlatform.handleCallback(intent);
        }
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	      WGPlatform.onActivityResult(requestCode, resultCode, data);
	  }
	
	
	
	public static void logout() {
		Log.i(TAG, "logout");
		
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGLogout();
			}
		});
	}

	/**
	 * 上传灯塔数据接口
	 * @param name 事件名称
	 * @param body 事件内容
	 * @param isRealTime 是否实时上报
	 */
	public static void WGReportEvent(final String name, final String body, final boolean isRealTime) {
		Log.d(TAG, "WGReportEvent name:"+ name + " body: " + body + " isRealTime: " + isRealTime);
		context.runOnUiThread(new Runnable() {
			public void run() {
				WGPlatform.WGReportEvent(name, body, isRealTime);
				
			}
		});
	}

	/**
	 * 上传灯塔数据接口
	 * @param eventName 事件名称
	 * @param params key-value格式的自定义事件
	 * @param isRealTime 是否实时上报
	 */
	public static void WGReportEventByMap(final String eventName, final HashMap<String, String> params, final boolean isRealTime) {
		Log.d(TAG, "WGReportEventByMap");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGReportEvent(eventName, params, isRealTime);
			}
		});
	}

	/**
	 * 获取用户个人信息
	 * @param callbackName 获取用户个人信息回调的lua函数名字
	 */
	public static void getUserInfo() {
		Log.d(TAG, "getUserInfo");
		LoginRet ret = new LoginRet();
        WGPlatform.WGGetLoginRecord(ret);
        if (ret.flag != CallbackFlag.eFlag_Succ) {
            Logger.d("UserLogin error!!!");
            return;
        }
        // 判断是哪一个平台登录
        if (ret.platform == WeGame.QQPLATID) {
        	context.runOnUiThread(new Runnable() {
    			@Override
    			public void run() {
    				WGPlatform.WGQueryQQMyInfo();
    			}
    		});
        } else if (ret.platform == WeGame.WXPLATID) {
        	context.runOnUiThread(new Runnable() {
    			@Override
    			public void run() {
    				WGPlatform.WGQueryWXMyInfo();
    			}
    		});
        }
	}

	/**
	 * 获取同玩好友信息
	 * @param callbackName 获取同玩好友信息的回调lua函数名字
	 */
	public static void getFriendsInfo() {
		Log.d(TAG, "getFriendsInfo");
		LoginRet ret = new LoginRet();
        WGPlatform.WGGetLoginRecord(ret);
        if (ret.flag != CallbackFlag.eFlag_Succ) {
            Logger.d("UserLogin error!!!");
            return;
        }
        // 判断是哪一个平台登录
        if (ret.platform == WeGame.QQPLATID) {
        	context.runOnUiThread(new Runnable() {
    			@Override
    			public void run() {
    				WGPlatform.WGQueryQQGameFriendsInfo();
    			}
    		});
        } else if (ret.platform == WeGame.WXPLATID) {
        	context.runOnUiThread(new Runnable() {
    			@Override
    			public void run() {
    				WGPlatform.WGQueryWXGameFriendsInfo();
    			}
    		});
        }
	}

	/**
	 * 展示对应类型指定公告栏下的公告
	 * @param scene 公告栏ID，不能为空, 这个参数和公告管理端的“公告栏”设置对应
	 */
	public static void showNotice(final String scene) {
		Log.d(TAG, "showNotice");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGShowNotice(scene);
			}
		});
	}

	/**
	 * 隐藏正在展示的滚动公告
	 */
	public static void hideScrollNotice() {
		Log.d(TAG, "hideScrollNotice");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGHideScrollNotice();
			}
		});
	}

	/**
	 * 获取公告的数据
	 * @param scene 对应的公告栏id
	 * @param callback 对应的回调函数
	 */
	public static void getNoticeData(final String scene, final int callback) {
		Log.d(TAG, "getNoticeData");
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Vector<NoticeInfo> noticeInfos = WGPlatform.WGGetNoticeData(scene);
				JSONObject json = new JSONObject();
				for(int i = 0; i < noticeInfos.size(); i++) {
					JSONObject notice = new JSONObject();
					NoticeInfo info = noticeInfos.get(i);
					try {
						notice.put("startTime", info.mNoticeStartTime);
						notice.put("endTime", info.mNoticeEndTime);
						notice.put("content", info.mNoticeContent);
						notice.put("openId", info.mOpenId);
						notice.put("title", info.mNoticeTitle);
						notice.put("scene", info.mNoticeScene);
						notice.put("noticeId", info.mNoticeId);
						notice.put("NoticeContentWebUrl", info.mNoticeContentWebUrl);
						int key = i+1;
						json.put(""+key, notice);
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}
				Log.d(TAG, "notice data: " + json.toString());
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, json.toString());
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
	}

	/**
	 * 上报自定义日志到bugly
	 * @param level 日志级别
	 * eBuglyLogLevel_S(0),eBuglyLogLevel_E(1),eBuglyLogLevel_W(2),eBuglyLogLevel_I(3),eBuglyLogLevel_D(4),eBuglyLogLevel_V(5)
	 * @param log 日志内容
	 */
	public static void WGBuglyLog(final int level, final String log) {
		Log.d(TAG, "WGBuglyLog");
		final eBuglyLogLevel logLevel = eBuglyLogLevel.getEnum(level);
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGBuglyLog(logLevel, log);
			}
		});
	}

	/**
	 * 
	 * @param platform 平台：0-无 1-游客 2-QQ 3-微信
	 * @param callback 回调的lua函数，将是否安装的结果返回，0-有安装，1-没有安装
	 */
	public static void isPlatformInstalled(final int platform, final int callback) {
		Log.d(TAG, "isPlatformInstalled:platform:"+platform);
		boolean result = true;
		if (SDKPlatform.PLATFORM_QQ.ordinal() == platform) {
			Log.d(TAG, "QQ install?");
			result = WGPlatform.WGIsPlatformInstalled(EPlatform.ePlatform_QQ);
		} else if (SDKPlatform.PLATFORM_WEIXIN.ordinal() == platform) {
			Log.d(TAG, "weixin install?");
			result = WGPlatform.WGIsPlatformInstalled(EPlatform.ePlatform_Weixin);
		}
		// 0-有安装，1-QQ没有安装 2-微信没安装
		String isInstall = "1";

		if (!result) {
			isInstall = "1";
		} else {
			isInstall = "0";
		}

		Log.d("DhhMsdk", "platform: " + platform + "; isInstall: " + isInstall);
		final String str = isInstall;
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, str);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
	}

	/**
	 * 获取附近的好友接口
	 */
	public static void getNearbyPersonInfo() {
		Log.d(TAG, "getNearbyPersonInfo");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGGetNearbyPersonInfo();
			}
		});
	}

	/**
	 * 清除个人位置信息
	 */
	public static void cleanLocation() {
		Log.d(TAG, "cleanLocation");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGCleanLocation();
			}
		});
	}

	/**
	 * 获取当前玩家位置信息,返回给游戏的同时上报到MSDK后台
	 */
	public static void getLocationInfo() {
		Log.d(TAG, "getLocationInfo");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGGetLocationInfo();
			}
		});
	}

	/**
	 * 扫码登录(MSDK目前只支持微信扫码登录)
	 * @param platform 平台：0-无 1-游客 2-QQ 3-微信
	 */
	public static void qrCodeLogin(final int platform) {
		if (SDKPlatform.PLATFORM_QQ.ordinal() == platform) {
			Log.d(TAG, "QQ qrCodeLogin");
			WGPlatform.WGQrCodeLogin(EPlatform.ePlatform_QQ);
		} else if (SDKPlatform.PLATFORM_WEIXIN.ordinal() == platform) {
			Log.d(TAG, "weixin qrCodeLogin");
			WGPlatform.WGQrCodeLogin(EPlatform.ePlatform_Weixin);
		} else {
			Log.d(TAG, "the platform is not support qrCode login");
		}
	}

	public static void feedback(final String str) {
		Log.d(TAG, "feedback");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGFeedback(str);
			}
		});
	}

	/**
	 * 游戏内创建公会微信群
	 * @param unionid 工会ID
	 * @param chatRoomName 聊天群名称
	 * @param chatRoomNickName 用户在聊天群的自定义昵称
	 */
	public static void createWXGroup(final String unionid, final String chatRoomName, final String chatRoomNickName) {
		Log.d(TAG, "createWXGroup");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGCreateWXGroup(unionid, chatRoomName, chatRoomNickName);
			}
		});
	}

	/**
	 * 游戏内加入公会微信群
	 * @param unionid 工会ID
	 * @param chatRoomNickName 用户在聊天群的自定义昵称
	 */
	public static void joinWXGroup(final String unionid, final String chatRoomNickName) {
		Log.d(TAG, "joinWXGroup");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGJoinWXGroup(unionid, chatRoomNickName);
			}
		});
	}

	/**
	 * 游戏内查询公会微信群信息
	 * @param unionid 工会ID
	 * @param openIdList 待检查是否在群里的用户
	 */
	public static void queryWXGroupInfo(final String unionid, final String openIdList) {
		Log.d(TAG, "queryWXGroupInfo");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGQueryWXGroupInfo(unionid, openIdList);
			}
		});
	}

	/**
	 * 绑定QQ群
	 * @param unionid 公会ID，opensdk限制只能填数字，字符可能会导致绑定失败
	 * @param unionName 公会名称
	 * @param zoneid 大区ID，opensdk限制只能填数字，字符可能会导致绑定失败
	 * @param signature 游戏盟主身份验证签名，生成算法为"玩家openid_游戏appid_游戏appkey_公会id_区id"做md5
	 */
	public static void bindQQGroup(final String unionid, final String unionName,
	        final String zoneid, final String signature) {
		Log.d(TAG, "WGBindQQGroup");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGBindQQGroup(unionid, unionName, zoneid, signature);
			}
		});
	}

	/**
	 * 查询QQ群绑定信息
	 * @param unionid 公会ID
	 * @param zoneid 大区ID
	 */
	public static void queryQQGroupInfo(final String unionid, final String zoneid) {
		Log.d(TAG, "WGQueryQQGroupInfo");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGQueryQQGroupInfo(unionid, zoneid);
			}
		});
	}

	/**
	 * 查询公会绑定群加群时的GroupKey的信息
	 * @param groupOpenid 群openID
	 */
	public static void queryQQGroupKey(final String groupOpenid) {
		Log.d(TAG, "queryQQGroupKey");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGQueryQQGroupKey(groupOpenid);
			}
		});
	}

	/**
	 * 加入QQ群(该接口没有回调给游戏)
	 * @param qqGroupKey 需要添加的QQ群对应的key
	 */
	public static void joinQQGroup(final String qqGroupKey) {
		Log.d(TAG, "joinQQGroup");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGJoinQQGroup(qqGroupKey);
			}
		});
	}

	/**
	 * 解绑公会当前绑定的QQ群
	 * @param groupOpenid 公会绑定的群的群openid
	 * @param unionid 公会ID
	 */
	public static void unbindQQGroup(final String groupOpenid, final String unionid) {
		Log.d(TAG, "unbindQQGroup");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGUnbindQQGroup(groupOpenid, unionid);
			}
		});
	}

	/**
	 * 开通QQ会员
	 * @param zoneId 游戏内分区ID
	 * @param roleId 游戏内的角色ID
	 * @param url url地址
	 */
	public static void openQQVIP(final String zoneId, final String roleId, final String url) {
		String pfKey = WGPlatform.WGGetPfKey();
		final String getParas = url + "?" + "sRoleId=" + roleId + "&sPartition=" + zoneId + "&sPfkey=" + pfKey;
		Log.d(TAG, "qqPrivilege: " + getParas);
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGOpenUrl(getParas);
			}
		});
	}

	/**
	 * 切换账号
	 * @param flag true : 切换到外部帐号; false : 继续使用原帐号
	 * 返回给lua: 0-表明此账号有票据。MSDK会去验证此票据的有效性，并在 WGPlatformObserver 中返回验证结果。
	 *          1-表明此账号无票据或票据不合法。可直接登录，让用户重新授权登录。
	 */
	public static void switchUser(final boolean flag, final int callback) {
		Log.d(TAG, "switchUser flag: " + flag);
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				// true : 表明此账号有票据。MSDK会去验证此票据的有效性，并在 WGPlatformObserver 中返回验证结果。
				// false : 表明此账号无票据或票据不合法。可直接登录，让用户重新授权登录。
				boolean returnValue = WGPlatform.WGSwitchUser(flag);
				if (!returnValue) {
					WGPlatform.WGLogout();
				}
				String returnString = returnValue ? "0" : "1";
				Log.d(TAG, "switchUser return: " + returnValue);
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, returnString);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
	}

	/**
	 * 玩家可以在游戏中直接加其他游戏玩家为QQ好友
	 * @param fopenid 要添加好友的openid
	 * @param desc 要添加好友的备注信息
	 * @param message 添加好友时发送的验证信息
	 */
	public static void addGameFriendToQQ(final String fopenid, final String desc, final String message) {
		Log.d(TAG, "addGameFriendToQQ fopenid: " + fopenid + "; desc: " + desc + ";message: " + message);
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGAddGameFriendToQQ(fopenid, desc, message);
			}
		});
	}

	/**
	 * Deeplink链接跳转
	 * @param link  INDEX：跳转微信游戏中心首页
	 *  			DETAIL：跳转微信游戏中心详情页
	 *				LIBRARY：跳转微信游戏中心游戏库
	 *				具体跳转的url （需要在微信游戏中心先配置好此url）
	 */
	public static void openWeiXinDeeplink(final String link) {
		Log.d(TAG, "oepnWeiXinDeeplink link: " + link);
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGOpenWeiXinDeeplink(link);
			}
		});
	}

	/**
	 * 获取onWakeupNotify的拉起信息
	 * @param callback 对应的回调函数
	 */
	public static void getWakeupInfo(final int callback) {
		Log.d(TAG, "getWakeupInfo");
		final String str = (MsdkCallBack.wakeupJson) != null ? MsdkCallBack.wakeupJson.toString() : "";
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, str);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
		MsdkCallBack.wakeupJson = null;
		MsdkCallBack.isInGame = true;
	}

	/**
	 * 检查是否有更新
	 */
	public static void checkNeedUpdate() {
		Log.d(TAG, "checkNeedUpdate");
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGCheckNeedUpdate();
			}
		});
	}

	/**
	 * 开始省流量更新
	 * @param isUseYYB 是否拉起应用宝更新游戏，如果选否，会直接在游戏内完成更新
	 */
	public static void startSaveUpdate(final boolean isUseYYB) {
		Log.d(TAG, "startSaveUpdate isUseYYB: " + isUseYYB);
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				WGPlatform.WGStartSaveUpdate(isUseYYB);
			}
		});
	}

	/**
	 * 是否安装了应用宝
	 * @param callback 回调的Lua接口
	 * 0：表示应用宝已安装
	 * 1：表示应用宝未安装
	 * 其他值表示安装了低版本的应用宝
	 */
	public static void checkYYBInstalled(final int callback) {
		Log.d(TAG, "checkYYBInstalled");
		int returnValue = WGPlatform.WGCheckYYBInstalled();
		final String str = returnValue + "";
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if (callback != 0) {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, str);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
				}
			}
		});
	}
}
