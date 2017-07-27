package com.qtz.dhh.msdk;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;
import com.tencent.msdk.myapp.autoupdate.WGSaveUpdateObserver;

import android.content.Context;

public class SaveUpdateCallBack extends WGSaveUpdateObserver {

	private Context context;
	public SaveUpdateCallBack(Context context) {
		this.context = context;
	}

	@Override
	public void OnCheckNeedUpdateInfo(long newApkSize, String newFeature, long patchSize, int status,
            String updateDownloadUrl, int updateMethod) {
		// 检查结果status 如下：
		// TMSelfUpdateUpdateInfo.STATUS_OK : 成功		 --0
		// TMSelfUpdateUpdateInfo.STATUS_CHECKUPDATE_FAILURE : 失败 		--1
		// TMSelfUpdateUpdateInfo.STATUS_CHECKUPDATE_RESPONSE_IS_NULL : --2
		// 更新方式updateMethod 如下：
		// TMSelfUpdateUpdateInfo.UpdateMethod_NoUpdate : 无更新包 		--0
		// TMSelfUpdateUpdateInfo.UpdateMethod_Normal : 全量更新包 		--1
		// TMSelfUpdateUpdateInfo.UpdateMethod_ByPatch : 增量更新包		--2
		JSONObject msg = new JSONObject();
		try {
    		msg.put("newApkSize", newApkSize);
    		msg.put("newFeature", newFeature);
    		msg.put("patchSize", patchSize);
    		msg.put("status", status);
    		msg.put("updateDownloadUrl", updateDownloadUrl);
    		msg.put("updateMethod", updateMethod);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		final String str = msg.toString();
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("checkNeedUpdateInfoBack", str);
			}
		});
	}

	@Override
	public void OnDownloadAppProgressChanged(long receiveDataLen, long totalDataLen) {
		// TODO Auto-generated method stub
		final long progress = receiveDataLen * 100 / totalDataLen;
        // 游戏TODO 下载中，已完成 " + progress + "%";
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("downloadAppProgressBack", progress+"");
			}
		});
	}

	@Override
	public void OnDownloadAppStateChanged(final int state, final int errorCode, final String errorMsg) {
		// 状态state 如下：
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_WAITING = 1; 
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_DOWNLOADING = 2; 
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_PAUSED = 3; 
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_SUCCEED = 4; 
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_FAILED = 5; 
		// TMAssistantDownloadTaskState.DownloadSDKTaskState_DELETE = 6;
		JSONObject msg = new JSONObject();
		try {
    		msg.put("state", state);
    		msg.put("errorCode", errorCode);
    		msg.put("errorMsg", errorMsg);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		final String str = msg.toString();
		((Cocos2dxActivity) context).runOnGLThread(new Runnable() {
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("downloadAppStateBack", str);
			}
		});
	}

	@Override
	public void OnDownloadYYBProgressChanged(String url, long receiveDataLen, long totalDataLen) {
		// TODO Auto-generated method stub
		// 应用宝的下载进度，暂不处理
	}

	@Override
	public void OnDownloadYYBStateChanged(String url, int state, int errorCode, String errorMsg) {
		// TODO Auto-generated method stub
		// 应用宝的下载状态，暂不处理
	}

}
