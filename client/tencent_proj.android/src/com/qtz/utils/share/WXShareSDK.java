package com.qtz.utils.share;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import com.qtz.utils.share.QTZShareSDK;
import com.tencent.msdk.api.WGPlatform;
import com.tencent.msdk.api.eWechatScene;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

public class WXShareSDK implements QTZShareSDK.QTZShareSDKInterface {
	
	public static final String TAG = "WX_SHARE_SDK";
	
	@Override
	public void shareWithPhoto(String imgURL, String extInfo) {
		Log.i(TAG, String.format("start to shareWithPhoto... imgURL is: %s, extInfo is: %s", imgURL, extInfo));
		Log.i(TAG, "Timeline scene num is: " + eWechatScene.WechatScene_Timeline.val());
		Log.i(TAG, "Session scene num is: " + eWechatScene.WechatScene_Session.val());
		eWechatScene scene = eWechatScene.WechatScene_Timeline; //one of them below
		/* 
		 * eWechatScene.WechatScene_Timeline : 1
		 * eWechatScene.WechatScene_Session : 0
		 */
		
		String mediaTagName = "MSG_INVITE"; // one of them below
		/*
		"MSG_INVITE";
		"MSG_SHARE_MOMENT_HIGH_SCORE";
		"MSG_SHARE_MOMENT_BEST_SCORE";
		"MSG_SHARE_MOMENT_CROWN";
		"MSG_SHARE_FRIEND_HIGH_SCORE";
		"MSG_SHARE_FRIEND_BEST_SCORE";
		"MSG_SHARE_FRIEND_CROWN";
		"MSG_friend_exceed";
		"MSG_heart_send"; 
		*/
		
		/*
		 * WeChat will give it back to you through OnWakeUpNotify(WakeupRet ret)(the messageExt is in
		 * ret.messageExt) when other open our game via click this massage
		 */
		String messageExt = "";
		
        String mediaAction = null;  // one of then below
        /*
         * WECHAT_SNS_JUMP_SHOWRANK
         * WECHAT_SNS_JUMP_URL
         * WECHAT_SNS_JUMP_APP
         */

		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			scene = eWechatScene.getEnum(jsonObject.getInt("scene"));
			mediaTagName = jsonObject.getString("mediaTagName");
			messageExt = jsonObject.getString("messageExt");
			mediaAction = jsonObject.getString("mediaAction");
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		
        String realImgURL = imgURL;
        try {
        	realImgURL = QTZShareSDK.getRealImageURL(imgURL);
        } catch (IOException e1) {
        	Log.i(TAG, "copy failed");
        }
        
        Bitmap imgBit = null;
        try {
            imgBit = BitmapFactory.decodeFile(realImgURL);
        } catch (OutOfMemoryError e) {
            Log.e(TAG, "the png file is too large");
            try {
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inSampleSize = 2;
                imgBit = BitmapFactory.decodeFile(realImgURL, options);
            } catch(Exception e1) {
                Log.e("TAG", "decodefile with options is failed");
                e1.printStackTrace();
            }
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        if (null == imgBit) {
            Log.e(TAG, "imgBit is null");
            return;
        }
        imgBit.compress(Bitmap.CompressFormat.PNG, 100, baos);
        byte[] imgData = baos.toByteArray();
        try {
        	baos.close();
        } catch (IOException e) {
        	Log.e(TAG, "close failed in shareWithPhote function");
        }

        Log.d(TAG, "scene: " + scene + "; mediaTagName: " + mediaTagName + "; imgData.length: " + imgData.length + 
        	"; messageExt: " + messageExt + "; mediaAction: " + mediaAction);

        if(scene == eWechatScene.WechatScene_Timeline && mediaAction != null)
        {
        	Log.d(TAG, "WGSendToWeixinWithPhoto with WechatScene_Timeline");
        	WGPlatform.WGSendToWeixinWithPhoto(scene, mediaTagName, imgData, imgData.length, messageExt, mediaAction);
        }
        else
        {
        	Log.d(TAG, "WGSendToWeixinWithPhoto with WechatScene_Session");
        	WGPlatform.WGSendToWeixinWithPhoto(scene, mediaTagName, imgData,imgData.length);
        }
	}

	@Override
	public void share(String title, String desc, String url, String imgURL, String extInfo) {
		Log.i(TAG, "start to share ...");
		
		String mediaTagName = "MSG_INVITE";	// one of them below
		/*
		"MSG_INVITE";
		"MSG_SHARE_MOMENT_HIGH_SCORE";
		"MSG_SHARE_MOMENT_BEST_SCORE";
		"MSG_SHARE_MOMENT_CROWN";
		"MSG_SHARE_FRIEND_HIGH_SCORE";
		"MSG_SHARE_FRIEND_BEST_SCORE";
		"MSG_SHARE_FRIEND_CROWN";
		"MSG_friend_exceed";
		"MSG_heart_send"; 
		*/
		
		/*
		 * WeChat will give it back to you through OnWakeUpNotify(WakeupRet ret)(the messageExt is in
		 * ret.messageExt) when other open our game via click this massage
		 */
		String messageExt = "";
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			mediaTagName = jsonObject.getString("mediaTagName");
			messageExt = jsonObject.getString("messageExt");
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		
		String realImgURL = imgURL;	
		try {
			realImgURL = QTZShareSDK.getRealImageURL(imgURL);
		} catch (IOException e1) {
			Log.i(TAG, "copy to sd failed");
		}
		Bitmap imgBit = BitmapFactory.decodeFile(realImgURL);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		imgBit.compress(Bitmap.CompressFormat.PNG, 100, baos);
		byte[] thumbData = baos.toByteArray();
		try {
			baos.close();
		} catch (IOException e) {
        	Log.e(TAG, "close failed in share function");
        }
        Log.d(TAG, "title: " + title + "; desc: " + desc + "; mediaTagName: " + mediaTagName +
        	"; thumbData.length: " + thumbData.length + "; messageExt: " + messageExt);

		WGPlatform.WGSendToWeixin(title, desc, mediaTagName, thumbData, thumbData.length, messageExt);
	}

	@Override
	public void shareToFriend(String uid, String title, String desc, String url, String imgURL, String extInfo) {
		Log.i(TAG, "start to shareToFriend...");

		String mediaTagName = "MSG_INVITE";	// one of them below
		/*
		"MSG_INVITE";
		"MSG_SHARE_MOMENT_HIGH_SCORE";
		"MSG_SHARE_MOMENT_BEST_SCORE";
		"MSG_SHARE_MOMENT_CROWN";
		"MSG_SHARE_FRIEND_HIGH_SCORE";
		"MSG_SHARE_FRIEND_BEST_SCORE";
		"MSG_SHARE_FRIEND_CROWN";
		"MSG_friend_exceed";
		"MSG_heart_send"; 
		*/
		
		/*
		 * WeChat will give it back to you through OnWakeUpNotify(WakeupRet ret)(the messageExt is in
		 * ret.messageExt) when other open our game via click this massage
		 */
		String messageExt 	= "";
		
		String thumbMediaId = ""; //I don't know what is this?
		
		/*
		 * WeChat will give it back to you through OnShareNotify(ShareRet& shareRet) when sharing finished.
		 */
		String msdkExtInfo 	= "";
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			mediaTagName = jsonObject.getString("mediaTagName");
			messageExt = jsonObject.optString("messageExt", "messageExt");
			thumbMediaId = jsonObject.optString("thumbMediaId", "");
			msdkExtInfo = jsonObject.getString("msdkExtInfo");
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}

		Log.d(TAG, "mediaTagName: " + mediaTagName + "; messageExt: " + messageExt + "; thumbMediaId: " + thumbMediaId + "; msdkExtInfo: " + msdkExtInfo);
		
		WGPlatform.WGSendToWXGameFriend(uid, title, desc, messageExt, mediaTagName, thumbMediaId, msdkExtInfo);
	}

	@Override
	public void shareWithUrl(String title, String desc, String url, String imgURL, String extInfo) {
		Log.i(TAG, "start to shareWithUrl ...");

		eWechatScene scene = eWechatScene.WechatScene_Timeline; //one of them below
		/* 
		 * eWechatScene.WechatScene_Timeline : 1
		 * eWechatScene.WechatScene_Session : 0
		 */
		String mediaTagName = "MSG_INVITE";	// one of them below
		/*
		"MSG_INVITE" : 邀请
		"MSG_SHARE_MOMENT_HIGH_SCORE" : 分享本周最高到朋友圈
		"MSG_SHARE_MOMENT_BEST_SCORE" : 分享历史最高到朋友圈
		"MSG_SHARE_MOMENT_CROWN" : 分享金冠到朋友圈
		"MSG_SHARE_FRIEND_HIGH_SCORE" : 分享本周最高给好友
		"MSG_SHARE_FRIEND_BEST_SCORE" : 分享历史最高给好友
		"MSG_SHARE_FRIEND_CROWN" : 分享金冠给好友
		"MSG_friend_exceed" : 超越炫耀
		"MSG_heart_send" : 送心
		*/
		
		/*
		 * WeChat will give it back to you through OnWakeUpNotify(WakeupRet ret)(the messageExt is in
		 * ret.messageExt) when other open our game via click this massage
		 */
		String messageExt = "";
		
		try {
			JSONObject jsonObject = new JSONObject(extInfo);
			scene = eWechatScene.getEnum(jsonObject.getInt("scene"));
			mediaTagName = jsonObject.getString("mediaTagName");
			messageExt = jsonObject.getString("messageExt");
		} catch (JSONException e1) {
			Log.i(TAG, "cann't parse extInfo, please check your extInfo");
		}
		
		String realImgURL = imgURL;	
		try {
			realImgURL = QTZShareSDK.getRealImageURL(imgURL);
		} catch (IOException e1) {
			Log.i(TAG, "copy to sd failed");
		}
		Bitmap imgBit = BitmapFactory.decodeFile(realImgURL);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		imgBit.compress(Bitmap.CompressFormat.PNG, 100, baos);
		byte[] thumbData = baos.toByteArray();
		try {
			baos.close();
		} catch (IOException e) {
        	Log.e(TAG, "close failed in share function");
        }
        Log.d(TAG, "scene: " + scene + "; title: " + title + "; desc: " + desc + "; url: " + url + "; mediaTagName: " + mediaTagName +
        	"; thumbData.length: " + thumbData.length + "; messageExt: " + messageExt);

		WGPlatform.WGSendToWeixinWithUrl(scene, title, desc, url, mediaTagName, thumbData, thumbData.length, messageExt);
	}

}
