package com.qtz.dhh.notification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class ClearReceiver extends BroadcastReceiver {

    /**
     * Called when the notification was cleared from the notification center.
     *
     * @param context
     *      Application context
     * @param intent
     *      Received intent with content data
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        SharedPreferences.Editor editor = context.getSharedPreferences("LocalNotificationSet", Context.MODE_PRIVATE).edit();
        editor.clear();
        editor.commit();
    }
}
