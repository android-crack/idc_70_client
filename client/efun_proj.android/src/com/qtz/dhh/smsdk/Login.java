package com.qtz.dhh.smsdk;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.util.Log;
import android.widget.Toast;

import com.aseugame.ahh.sm.Dhh;
import com.efun.ads.appsflyer.EfunAF;
import com.efun.os.uicallback.EfunUICallBack.EfunUiLogoutCallBack;
import com.efun.platform.login.comm.bean.LoginParameters;
import com.efun.platform.login.comm.callback.OnEfunLoginListener;
import com.efun.platform.login.comm.utils.EfunLoginHelper.ReturnCode;
import com.efun.sdk.entrance.EfunSDK;
import com.efun.sdk.entrance.entity.EfunLoginEntity;
import com.efun.sdk.entrance.entity.EfunLogoutEntity;
import com.efun.sdk.entrance.entity.EfunPlatformEntity;
import com.efun.sdk.entrance.entity.EfunTrackingEventEntity;

public class Login {
	private static final String TAG = "efun";
	public static EfunLoginEntity efunLoginEntity = new EfunLoginEntity();
	public static EfunPlatformEntity efunPlatform = null;
	public static Dhh context = null;
	static long uid = 0l;
	static long timestamp = 0l;
	static String sign = "";
	
	/**
	 * efun 登录成功。进入游戏
	 * @param openId - 
	 * @param token - 
	 */
	private static void smLoginSuccess() {
		Log.i("efun", "=====smLoginSuccess=====");
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				try {
					String str = "uid:" + uid + "-timestamp:" + timestamp + "-sign:" + sign;
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("efunLoginSuccess", str);
				}catch(Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
	public static void smLoginCanceled() {
		context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				try {
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("smLoginCanceled", "");
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
	public static void login() {
		context.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				
				efunLoginEntity.setEfunCallBack(new OnEfunLoginListener() {
					
					@Override
					public void onFinishLoginProcess(LoginParameters params) {
						final LoginParameters lParams = params;
						
						Log.i("efun", "=====sdk login result" + params.getCode());
						// 登陆成功
						if (ReturnCode.RETURN_SUCCESS.equals(params.getCode()) || ReturnCode.ALREADY_EXIST.equals(params.getCode())) {
							//Toast.makeText(context, "userid:" + params.getUserId(), Toast.LENGTH_LONG).show();
							Log.i("efun", params.getUserId() + "");
							// 重写返回事件
							uid = params.getUserId();
							timestamp = params.getTimestamp();
							sign = params.getSign();
							
							smLoginSuccess();
							
						} else if (ReturnCode.LOGIN_BACK.equals(params.getCode())) {
							 smLoginCanceled();
						}
						
					}
					
				});
				EfunSDK.getInstance().efunLogin(context, efunLoginEntity);
			}
			
		});
	}
	
	public static void logout() {
		
		context.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				
					EfunLogoutEntity entity = new EfunLogoutEntity();
					entity.setEfunCallBack(new EfunUiLogoutCallBack() {
						
						@Override
						public void callback() {
							// TODO Auto-generated method stub
							efunPlatform = new EfunPlatformEntity();
							efunPlatform.setPlatformStatu(efunPlatform.ExitGameApp);
							EfunSDK.getInstance().efunPlatformByStatu(context,
									efunPlatform);
							
							Log.i("efun", "logout success=======");
							Toast.makeText(context, "帐号注销成功，请重新登录...", Toast.LENGTH_LONG).show();
							//** //
						}
					});
					
					EfunSDK.getInstance().efunLogout(context, entity);
			}
			
		});
	}
	
	//新手事件统计接口
	public static void trackingEvent() {
		Log.i("efun", "trackingEvent=======");
		context.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				
				EfunTrackingEventEntity trackingEventEntity = new EfunTrackingEventEntity();
				trackingEventEntity.setEvent(EfunAF.EVENT_FINISH_GUIDE);
				EfunSDK.getInstance().efunTrackingEvent(context, trackingEventEntity);
			}
			
		});
	}
}
