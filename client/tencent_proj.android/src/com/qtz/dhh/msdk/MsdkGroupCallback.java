package com.qtz.dhh.msdk;

import com.tencent.msdk.api.GroupRet;
import com.tencent.msdk.api.WGGroupObserver;
import com.tencent.msdk.consts.CallbackFlag;
import com.tencent.msdk.consts.EPlatform;
import com.tencent.msdk.tools.Logger;

import android.content.Context;

public class MsdkGroupCallback implements WGGroupObserver {
	
	private Context context;
	public MsdkGroupCallback(Context context) {
		this.context = context;
	}

	@Override
	public void OnBindGroupNotify(GroupRet groupRet) {
		//TODO GAME 增加绑定QQ群的回调
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if(CallbackFlag.eFlag_Succ == groupRet.flag){
			//游戏可以去查询绑定的公会的相关信息。
			//由于目前手QSDK尚不支持，因此无论绑定是否成功，MSDK都会给游戏一个成功的回调，游戏收到回调以后需要调用查询接口确认绑定是否成功
			Logger.d("绑定成功。");
		}else{
			//游戏可以引导用户重试
			Logger.d("绑定失败，系统错误，请重试！");
		}
	}

	@Override
	public void OnCreateWXGroupNotify(GroupRet groupRet) {
		// TODO 增加创建微信群信息的回调
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if (CallbackFlag.eFlag_Succ == groupRet.flag) {
			Logger.d("建群成功");
		} else {
			handleWXGroupNotifyErrorCode(groupRet);
		}
	}

	@Override
	public void OnJoinWXGroupNotify(GroupRet groupRet) {
		// TODO Auto-generated method stub
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if(CallbackFlag.eFlag_Succ == groupRet.flag){
			Logger.d("加群成功。");
		}else{
			handleWXGroupNotifyErrorCode(groupRet);
		}
	}

	@Override
	public void OnQueryGroupInfoNotify(GroupRet groupRet) {
		// TODO 增加查询群信息的回调
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if (EPlatform.ePlatform_Weixin.val() == groupRet.platform) {
			//TODO GAME 查询微信群信息的回调
			if (CallbackFlag.eFlag_Succ == groupRet.flag) {
				Logger.d("查询成功，提交列表中的以下成员已经在群:"+groupRet.getWXGroupInfo().openIdList);
			} else {
				handleWXGroupNotifyErrorCode(groupRet);
			}
		} else if (EPlatform.ePlatform_QQ.val() == groupRet.platform) {
			//TODO GAME 查询QQ群信息的回调
			if (CallbackFlag.eFlag_Succ == groupRet.flag) {
				//游戏可以在会长公会界面显解绑按钮，非工会会长显示进入QQ群按钮
				Logger.d("查询成功。\n群昵称为："+groupRet.getQQGroupInfo().groupName 
						+"\n群openID:"+groupRet.getQQGroupInfo().groupOpenid 
						+"\n加群Key为："+groupRet.getQQGroupInfo().groupKey);
			} else {
				if (2002 == groupRet.errorCode) {
					//游戏可以在会长公会界面显示绑群按钮，非会长显示尚未绑定
					Logger.d("查询失败，当前公会没有绑定记录！");
				} else if (2003 == groupRet.errorCode) {
					//游戏可以在用户公会界面显示加群按钮
					Logger.d("查询失败，当前用户尚未加入QQ群，请先加入QQ群！");
				} else if (2007 == groupRet.errorCode) {
					//游戏可以在用户公会界面显示加群按钮
					Logger.d("查询失败，QQ群已经解散或者不存在！");
				} else {
					//游戏可以引导用户重试
					Logger.d("查询失败，系统错误，请重试！");
				}
			}
		} else {
			Logger.d("查询失败，平台错误，请重试！");
		}
	}

	@Override
	public void OnQueryQQGroupKeyNotify(GroupRet groupRet) {
		//TODO GAME 增加查询QQ群信息的回调
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if (CallbackFlag.eFlag_Succ == groupRet.flag) {
			//成功获取到加群用的key，可以进一步使用key加入QQ群
			Logger.d("查询成功。\n加群Key为："+groupRet.getQQGroupInfo().groupKey);
		} else {
			//游戏可以引导用户重试
			Logger.d("查询失败，请重试！");
		}
	}

	@Override
	public void OnUnbindGroupNotify(GroupRet groupRet) {
		//TODO GAME 增加解绑QQ群的回调
		Logger.d("flag:"+ groupRet.flag + ";errorCode："+ groupRet.errorCode + ";desc:" + groupRet.desc);
		if(CallbackFlag.eFlag_Succ == groupRet.flag){
			//解绑成功，游戏可以提示用户解绑成功，并在工会会长界面显示绑群按钮，非会长界面显示尚未绑定按钮
			Logger.d("解绑成功。");
		}else{
			if(2001 == groupRet.errorCode){
				//解绑用的群openID没有群绑定记录，游戏重新调用查询接口查询绑定情况
				Logger.d("解绑失败，当前QQ群没有绑定记录！");
			}else if(2003 == groupRet.errorCode){
				//用户登录态过期，重新登陆
				Logger.d("解绑失败，用户登录态过期，请重新登陆！");
			}else if(2004 == groupRet.errorCode){
				//操作太过频繁，让用户稍后尝试
				Logger.d("解绑失败，操作太过频繁，让用户稍后尝试！");
			}else if(2005 == groupRet.errorCode){
				//解绑参数错误，游戏重新调用查询接口查询绑定情况
				Logger.d("解绑失败，操解绑参数错误！");
			}else{
				//游戏可以引导用户重试
				Logger.d("解绑失败，系统错误，请重试！");
			}
		}
	}

	public void handleWXGroupNotifyErrorCode(GroupRet groupRet) {
		if(CallbackFlag.eFlag_Succ != groupRet.flag) {
			switch (groupRet.errorCode) {
			case -10001:
				// 该游戏没有建群权限
				Logger.d("系统错误，游戏没有建群权限，请重试");
				break;
			case -10002:
				//参数检查错误
				Logger.d("系统错误，参数检查错误，请检查参数后重试");
				break;
			case -10005:
				//群ID已存在
				Logger.d("系统错误，微信群已存在，请检查后重试");
				break;
			case -10006:
				//建群数量超过上限
				Logger.d("系统错误，建群数量超过上限，请检查后重试");
				break;
			case -10007:
				//群ID不存在
				Logger.d("系统错误，群ID不存在，请检查后重试");
				break;
			default:
				Logger.d("系统错误，("+groupRet.errorCode+")，请重试");
				break;
			}
		}
	}

}
