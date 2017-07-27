package com.qtz.utils.sdk;

import com.qtz.utils.sdk.QTZJavaSDK.JavaSDKInterface;

public class QQSDK implements JavaSDKInterface {

	@Override
	public void login() 
	{
		QTZJavaSDK.onNotifyDirect(QTZJavaSDK.SDK_EVENTS.SDK_EVENT_LOGIN, 0, "login succ");
	}

	@Override
	public void logout() {
		// TODO Auto-generated method stub

	}

	@Override
	public String getAccessToken() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getPayToken() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getPf() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getPfKey() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getOpenId() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getUid() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getUdid() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getExtraInfo() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void getUserInfo() {
		// TODO Auto-generated method stub

	}

	@Override
	public void getFriendsInfo() {
		// TODO Auto-generated method stub

	}

	@Override
	public void pay(int uid, String order, String productId, String productName, float amount, String paydes) {
		// TODO Auto-generated method stub

	}

	@Override
	public void reportEvent(String name, String body, boolean isRealTime) {
		// TODO Auto-generated method stub

	}

}
