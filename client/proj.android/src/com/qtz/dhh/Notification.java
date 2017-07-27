package com.qtz.dhh;

import java.util.Calendar;

import org.cocos2dx.lib.Cocos2dxHelper;

import org.json.JSONObject;
import org.json.JSONException;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.support.v4.content.LocalBroadcastManager;
import android.content.SharedPreferences;

import com.qtz.dhh.notification.Manager;

/*
import com.tencent.android.tpush.XGLocalMessage;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.android.tpush.XGPushManager;
import com.tencent.android.tpush.service.XGPushService;
*/

public class Notification {
    public static final String SENT_TOKEN_TO_SERVER = "sentTokenToServer";
    public static final String REGISTRATION_COMPLETE = "registrationComplete";
	
	private static Context pContext;
    private static int counter;
	
	public static void init(Context context){
		pContext = context;
	}
	
	public static void pushMessage(String msg, int delay, int repeats ){
        try {
            JSONObject dict = new JSONObject();
            dict.put("id", counter++);
            dict.put("text", msg);
            dict.put("at", System.currentTimeMillis() / 1000 + delay);
            if (repeats == 1) {
                dict.put("every", "day");
            } else if (repeats == 2) {
                dict.put("every", "hour");
            } else if (repeats == 3) {
                dict.put("every", "minute");
            } else if (repeats == 4) {
                dict.put("every", "second");
            }
            Manager.getInstance(pContext).schedule(dict);
        } catch (JSONException e) {
            e.printStackTrace();
        }
	}
	
	public static void registerNotification( String uid ){
	}
	
	public static void removeNotification() {
        counter = 0;
        Manager.getInstance(pContext).cancelAll();
        SharedPreferences.Editor editor = pContext.getSharedPreferences("LocalNotificationSet", Context.MODE_PRIVATE).edit();
        editor.clear();
        editor.commit();
	}

}
