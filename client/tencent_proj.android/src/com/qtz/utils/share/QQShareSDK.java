package com.qtz.utils.share;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.json.JSONException;
import org.json.JSONObject;

import com.qtz.utils.share.QTZShareSDK.QTZShareSDKInterface;
import com.tencent.msdk.api.WGPlatform;
import com.tencent.msdk.api.eQQScene;

import android.os.Environment;
import android.util.Log;

public class QQShareSDK implements QTZShareSDKInterface {
	public static final String TAG = "QQ_SHARE_SDK";
	
	@Override
	public void shareWithPhoto(String imgURL, String extInfo) {
		Log.i(TAG, String.format("start to shareWithPhoto.., imgURL is: %s, extInfo is: %s", imgURL, extInfo));
		eQQScene scene = eQQScene.QQScene_QZone;
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			scene = eQQScene.getEnum(jsonObject.getInt("scene"));
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		
		Log.i(TAG, "the share scene is: " + scene);
		
		try {
			String realImgURL = QTZShareSDK.getRealImageURL(imgURL);
			Log.d(TAG, "scene: " + scene + "; realImgURL: " + realImgURL);
			WGPlatform.WGSendToQQWithPhoto(scene, realImgURL);
		} catch (IOException e) {
			Log.i(TAG, "copy file to external storage failed");
		}
	}

	@Override
	public void share(String title, String desc, String url, String imgURL, String extInfo) {
		Log.i(TAG, "start to share...");
		eQQScene scene = eQQScene.QQScene_QZone;
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			scene = eQQScene.getEnum(jsonObject.getInt("scene"));
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		Log.d(TAG, "scene: " + scene + "; title: " + title + "; desc: " + desc + "; url: " + url + 
			"; imgURL: " + imgURL + "; imgURL.length(): " + imgURL.length());
		try {
			String realImgURL = QTZShareSDK.getRealImageURL(imgURL);

			Log.d(TAG, "scene: " + scene + "; title: " + title + "; desc: " + desc + "; url: " + url + 
			"; realImgURL: " + realImgURL + "; realImgURL.length(): " + realImgURL.length());

			WGPlatform.WGSendToQQ(scene, title, desc, url, realImgURL, realImgURL.length());
		} catch (IOException e) {
			Log.i(TAG, "copy file to external storage failed");
		}
	}

	@Override
	public void shareToFriend(String uid, String title, String desc, String url, String imgURL, String extInfo) {
		Log.i(TAG, "start to shareToFriend" + extInfo.toString());
		int act	= 1; 							// 	1: open app, 0:open url
		String gameTag 	= "MSG_INVITE";			//	
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			act = jsonObject.getInt("act");
			gameTag = jsonObject.getString("mediaTagName");
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		Log.d(TAG, "act: " + act + "; uid: " + uid + "; title: " + title + "; desc: " + desc + "; url: " + url + 
			"; imgURL: " + imgURL + "; previewText: " + desc + "; gameTag: " + gameTag);
		
		WGPlatform.WGSendToQQGameFriend(act, uid, title, desc, url, imgURL, desc, gameTag);
	}

	@Override
	public void shareWithUrl(String title, String desc, String url, String imgURL, String extInfo) {
		// TODO Auto-generated method stub
	}

}
