package com.qtz.dhh.safesdk;

import com.tencent.tp.TssSdk;
import com.tencent.tp.TssSdkGameStatusInfo;
import com.tencent.tp.TssSdkInitInfo;
import com.tencent.tp.TssSdkUserInfoEx;

import android.app.Activity;
import android.util.Base64;

public class TssSdkWrapper {
	private static boolean mTtsSdkOpen = false;
	private static Activity context = null;

	private static SendDataToSvrImp m_sendDataToSvrImp = null;
	private static String qqAppId = null;	// 大航海的qq appid为"1104681464"
	private static String weixinAppId = null;	// 大航海的微信appid为"wxa228fbbb06c2cb79"

	/**
	 * 初始化安全SDK
	 * @param tssSdkOpen 是否打开安全sdk
	 * @param ctx 游戏的activity
	 * @param gameId 游戏的game_id
	 * @param qqappid qq的appid
	 * @param weixinappid 微信的appid
	 */
	public static void init(boolean tssSdkOpen, Activity ctx, int gameId, String qqappid, String weixinappid) {
		mTtsSdkOpen = tssSdkOpen;
		if (mTtsSdkOpen) {
			qqAppId = qqappid;
			weixinAppId = weixinappid;
			context = ctx;
			TssSdkInitInfo info = new TssSdkInitInfo();
			// 全民大航海：game_id = 2611
			info.game_id = gameId;
			TssSdk.init(info);
		}
	}

	/**
	 * 在游戏activity的onPause中调用
	 */
	public static void onPause() {
		if (mTtsSdkOpen) {
			 TssSdkGameStatusInfo info = new TssSdkGameStatusInfo();
		     info.game_status = TssSdkGameStatusInfo.GAME_STATUS_BACKEND;
		     TssSdk.setgamestatus(info);
		}
	}

	/**
	 * 在游戏activity的onResume中调用
	 */
	public static void onResume() {
		if (mTtsSdkOpen) {
			TssSdkGameStatusInfo info = new TssSdkGameStatusInfo();
	        info.game_status = TssSdkGameStatusInfo.GAME_STATUS_FRONTEND;
	        TssSdk.setgamestatus(info);
		}
	}

	/**
	 * 在QQ登录后调用该函数
	 * @param openId qq登录返回的openId
	 * @param worldId 大区号，如果没有区号概念，填0
	 * @param roleId 角色ID，如果没有角色ID概念，填""或null。如果是角色ID是整形，请格式化成字符串。如 "" + 10023;
	 */
	public static void onQQLogin(String openId, int worldId, String roleId) {
		if (mTtsSdkOpen) {
			TssSdkUserInfoEx info = new TssSdkUserInfoEx();
			info.app_id_type = TssSdkUserInfoEx.APP_ID_TYPE_STR;
			// QQ appid
			info.app_id_str = qqAppId;
			info.entry_id = TssSdkUserInfoEx.ENTRY_ID_QZONE;
			info.uin_type = TssSdkUserInfoEx.UIN_TYPE_STR;
			info.uin_str = openId;
			info.world_id = worldId;
			info.role_id = roleId;
			TssSdk.setuserinfoex(info);
		}
	}

	/**
	 * 在微信登录后回调的函数
	 * @param openId 微信登录的openid
	 * @param worldId 大区号，如果没有区号概念，填0
	 * @param roleId 角色ID，如果没有角色ID概念，填""或null。如果是角色ID是整形，请格式化成字符串。如 "" + 10023
	 */
	public static void onWeixinLogin(String openId, int worldId, String roleId) {
		if (mTtsSdkOpen) {
			TssSdkUserInfoEx info = new TssSdkUserInfoEx();
			info.app_id_type = TssSdkUserInfoEx.APP_ID_TYPE_STR;
			// 微信appid
			info.app_id_str = weixinAppId;
			info.entry_id = TssSdkUserInfoEx.ENTRY_ID_MM;
			info.uin_type = TssSdkUserInfoEx.UIN_TYPE_STR;
			info.uin_str = openId;
			info.world_id = worldId;
			info.role_id = roleId;
			TssSdk.setuserinfoex(info);
		}
	}

	/**
	 * 游客登录后回调的函数(函数体为空)
	 * @param tmpOpenId 微信登录的openid
	 * @param worldId 大区号，如果没有区号概念，填0
	 * @param roleId 角色ID，如果没有角色ID概念，填""或null。如果是角色ID是整形，请格式化成字符串。如 "" + 10023
	 */
	public static void onAnonymousLogin(String tmpOpenId, int worldId, String roleId) {
		if (mTtsSdkOpen) {
			
		}
	}

	/**
	 * 游戏端收到服务端的数据之后，需要调用此接口将数据发给SDK
	 * @param data 二进制数据
	 * @param size data的长度
	 */
	public static void onRecvDataWhichNeedSendToClientSdk(String str) {
		if (mTtsSdkOpen) {
			byte[] data = Base64.decode(str, Base64.NO_WRAP);
			TssSdk.senddatatosdk(data, data.length);
		}
	}

	/**
	 * 设置将数据发给游戏服的回调函数
	 */
	public static void setSendDataToSvrCallback(String luaCallbackFunction) {
		if (mTtsSdkOpen) {
			m_sendDataToSvrImp = new SendDataToSvrImp(context, luaCallbackFunction);
			TssSdk.setsenddatatosvrcb(m_sendDataToSvrImp);
		}
	}
}
