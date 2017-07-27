--登录验证对象，所有的跟游戏有关sdk接口都包含在这里
local ClsGameSdk = {}

local authChannelObjFactory
authChannelObjFactory = function(chn, name)
	local cls = require(name)
	local obj = cls.new(chn)
	return obj
end

local loginAuthInfo = {
	moni = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		moni = authChannelObjFactory("guestmoni", "module/login/clsAuthDefault"),
	},
	tencent = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		qq = authChannelObjFactory("qq", "module/login/clsAuthTencentQQ"),
		wechat = authChannelObjFactory("wechat", "module/login/clsAuthTencentWechat"),
	},
	tencent_ios = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		qtz_guest = authChannelObjFactory("tencent_guest", "module/login/clsAuthTencentIosGuest"),
		qq = authChannelObjFactory("qq_ios", "module/login/clsAuthTencentIosQQ"),
		wechat = authChannelObjFactory("wechat_ios", "module/login/clsAuthTencentIosWechat"),
	},
	online = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		online = authChannelObjFactory("online", "module/login/clsAuthDefault"),
	},
	alicloud = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		alicloud = authChannelObjFactory("alicloud", "module/login/clsAuthDefault"),
	},
	qtz = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		qtz = authChannelObjFactory("qtz", "module/login/clsAuthDefault"),
	},
	efun = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		efun = authChannelObjFactory("efun", "module/login/clsAuthDefault"),
	},
	ce_test = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		ce_test = authChannelObjFactory("ce_test", "module/login/clsAuthDefault"),
	},
	debug = {
		guest = authChannelObjFactory("guest", "module/login/clsAuthGuest"),
		debug = authChannelObjFactory("debug", "module/login/clsAuthDefault"),
	},
}

LAST_SELECT_ROLE_ID = "last_select_role_id"
LAST_SELECT_PLATFORM = "last_select_platform"
LAST_SELECT_AUTH_CHN = "last_select_auth_chn"
local login_auth_obj = nil

---------------------登陆验证渠道的调用接口---------------------------------
ClsGameSdk.getWakeupInfo = function()
	local getWarkupInfoBack
	getWarkupInfoBack = function( content )
		wakeupNotifyBack( content )
	end

	if GTab.CHANNEL_ID == CHANNEL_TENCENT then
		local args = {getWarkupInfoBack}
		-- 调用 Java 方法
		luaj.callStaticMethod("com/qtz/dhh/msdk/DhhMsdk", "getWakeupInfo", args)
	elseif GTab.CHANNEL_ID == CHANNEL_TENCENT_IOS then
		QSDK:sharedQSDK():getWakeupInfo(function(event)
			wakeupNotifyBack(event.msg)
		end)
	end
end

wakeupNotifyBack = function( content )
	print("=============wakeup_info====================content", content)
	local ClsUpdateAlert = require("update/updateAlert")
	ClsUpdateAlert:showStopSvrNoticeInfo(function( ... )
		local login_layer = getUIManager():get("LoginLayer")
		if not content or string.len(content) < 1 then
			ClsGameSdk.autoLogin()
			return
		end
	
		-- table.print(wakeup_info)
		local wakeup_info = json.decode(content)	
		if wakeup_info.flag then	
			local flag = tonumber(wakeup_info.flag)
			local platform = tonumber(wakeup_info.platform)
			local start_and_login_data = getGameData():getStartAndLoginData()
			if wakeup_info.vip == "yes" then
				start_and_login_data:setStartupVipState(platform)
			end
			print("==================flag", flag)
			if flag == 0 or flag == 3004 --3004外部帐号和已登录帐号相同，使用外部票据更新本地票据，需等待登录回调
				--0本地账号登录成功，可直接进入游戏，或也可调用自动登录接口WGLogin()，等待登录回调
				or flag == 3001 --没有有效的票据，登出游戏让用户重新登录
				or flag == 3002 then--MSDK会尝试去用拉起账号携带票据验证登录，结果在OnLoginNotify中回调，游戏此时等待onLoginNotify的回调
				ClsGameSdk.beginByWakeup(platform)
			elseif flag == 3003 then
				--需要弹出提示框让用户选择登录的账号，并根据用户的选择调用WGSwitchUser接口        
				local Alert = require("scripts/ui/tools/alert")
				local ui_word = require("game_config/ui_word")
				require("gameobj/tips/clsPostCardTips")
				closePostCard()
				Alert:showAttention(ui_word.SDK_WAKE_UP_ACCOUNT_TIPS, function()
						ClsGameSdk.beginByWakeup(tonumber(wakeup_info.old_platform))
					end, nil, function()
						ClsGameSdk.beginByWakeup(platform, LOGIN_TYPE_SELECT_ACCOUNT, true)
					end, {ok_text = ui_word.MAIN_CANCEL, cancel_text = ui_word.SDK_WAKE_UP_ACCOUNT_SELECT_NEW, hide_close_btn = true}, 
					{type = UI_TYPE.TOP, is_touch_close_forbin = true})
			else
				if tolua.isnull(login_layer) then
					local module_game_rpc = require("module/gameRpc")
					module_game_rpc.reStartGame()
				end
			end
		end
		if login_layer and not tolua.isnull(login_layer) then
			login_layer:setViewTouchEnabled(true)
		end
	end)
end

ClsGameSdk.autoLogin = function()
	if not _G.has_first_login_app then
		_G.has_first_login_app = true
		local user_default = CCUserDefault:sharedUserDefault()
		local last_select_chn = user_default:getStringForKey(LAST_SELECT_AUTH_CHN)
		if last_select_chn and string.len(last_select_chn) > 0 then
			local last_select_platform = user_default:getStringForKey(LAST_SELECT_PLATFORM)
			ClsGameSdk.beginLogin(last_select_platform)
		end
		local login_layer = getUIManager():get("LoginLayer")
		if login_layer and not tolua.isnull(login_layer) then
			login_layer:setViewTouchEnabled(true)
		end
	end
end

ClsGameSdk.clearAutoLoginInfo = function()
	local user_default = CCUserDefault:sharedUserDefault()
	user_default:setIntegerForKey(LAST_SELECT_ROLE_ID, 0)
	user_default:setStringForKey(LAST_SELECT_PLATFORM, "")
	user_default:setStringForKey(LAST_SELECT_AUTH_CHN, "")
	user_default:flush()
end

ClsGameSdk.beginByWakeup = function( platform, select_account_type, select_account_val)
	if not select_account_type or not select_account_val then
		local start_and_login_data = getGameData():getStartAndLoginData()
		if start_and_login_data:getStartGameState() then
			login_auth_obj:sendStartupVip()
			print("==========已经再游戏中了，不需要再进游戏")
			return
		end
	end

	local begin_login_fun
	begin_login_fun = function(platform, select_account_type, select_account_val)
		if platform == SDK_PLATFORM_WEIXIN then--sdk为微信
			ClsGameSdk.beginLogin("wechat", select_account_type, select_account_val)
		elseif platform == SDK_PLATFORM_QQ then --sdk为QQ
			ClsGameSdk.beginLogin("qq", select_account_type, select_account_val)
		elseif platform == SDK_PLATFORM_IOS_GUEST then --sdk为ios游客
			ClsGameSdk.beginLogin("qtz_guest", select_account_type, select_account_val)
		end
	end

	local login_layer = getUIManager():get("LoginLayer")
	if tolua.isnull(login_layer) then
		local module_game_rpc = require("module/gameRpc")
		module_game_rpc.reStartGame(function()
			print("=============设置了登陆后回调", platform)
			begin_login_fun(platform, select_account_type, select_account_val)
		end)
	else
		begin_login_fun(platform, select_account_type, select_account_val)
	end
end

ClsGameSdk.beginLogin = function(auth_chn, select_account_type, select_account_val)
	local module_start_game = require("module/login/startGame")
	local chn_id = module_start_game.getChannelId()
	auth_chn = auth_chn or chn_id
	if login_auth_obj then
		login_auth_obj:logout()
	end
	local open_udid = getOpenUDID()
	login_auth_obj = loginAuthInfo[chn_id][auth_chn]
	if login_auth_obj then
		login_auth_obj:beginLogin(open_udid, select_account_type, select_account_val)
	end

	local user_default = CCUserDefault:sharedUserDefault()
	user_default:setStringForKey(LAST_SELECT_PLATFORM, auth_chn)
end

ClsGameSdk.beginLoginCallBack = function( result, openid, token, extArgs, ... )
	login_auth_obj:sdkCallBack( 0, openid, token, extArgs, ... )
end

ClsGameSdk.tryRelink = function()
	if login_auth_obj and login_auth_obj:isRelinking() then
		login_auth_obj:relink()
		return true
	end
	return false
end

ClsGameSdk.relinkCallBack = function( errno )
	login_auth_obj:relinkCallBack(errno)
end

ClsGameSdk.delayExecuteAuthChn = function()
	login_auth_obj:delayExecuteAuthChn()
end

ClsGameSdk.tryExecuteAuthChn = function()
	if login_auth_obj and login_auth_obj:isDelayExecuteAuthChn() then
		login_auth_obj:executeAuthChn()
		return true
	end
	return false
end

ClsGameSdk.beginRelink = function()
	if login_auth_obj then
		login_auth_obj:beginRelink()
	end
end

ClsGameSdk.logout = function()
	if login_auth_obj then
		login_auth_obj:logout()
	end
end

--切换账号，返回登录界面，并登出sdk票据
ClsGameSdk.switchAccount = function()
	if login_auth_obj then
		login_auth_obj:switchAccount()
	end
end

--安卓拉起登录返回调用的
loginSuccess = function(dataString)
	updateVersonInfo(LOG_1024)
	print("----------------loginSuccess---",dataString)
	local login_layer = getUIManager():get("LoginLayer")
	if not tolua.isnull(login_layer) then
		login_layer:setViewTouchEnabled(false)
	end

	local login_info = json.decode(dataString)
	-- table.print(login_info)
	login_auth_obj:sdkCallBack( 0, login_info.openId, login_info.accessToken, {}, login_info )
end

--  提供接口给sdk接入失败后的调用
loginFailedCB = function(flag)
	updateVersonInfo(LOG_1025)
	print("loginFailedCB---------------------------flag", flag)
	login_auth_obj:showSDKFlagAlert(flag)
end

-- 安卓Midas支付返回
midasPayCallBack = function( content )
	print("midasPayCallBack---------------------------", content)
	login_auth_obj:payCallBack(content)
end

--查询个人或者同玩好友数据返回
getTencentInfoCallBack = function( content )
	login_auth_obj:setSDKInfoData(content)
end

--安全sdk返回参数，用来上行协议给服务端
safeSDKDataBack = function(content)
	login_auth_obj:tssSdkGetAntiData(content)
end

--服务器返回的数据，再返回给安全sdk
rpc_client_tss_sdk_get_anti_data = function(content)
	login_auth_obj:tssSdkGetAntiBack(content)
end

--附近的人或者清理定位返回的方法
nearbyPersonInfoBack = function(content)
	login_auth_obj:setNearByPersonInfo(content)
end

--个人定位数据返回
getLocationInfoBack = function(content)
	login_auth_obj:setLocationInfo(content)
end

--请求支付下单
ClsGameSdk.beginPay = function(productId, amount, info)
	login_auth_obj:beginPay(productId, amount, info)
end

--拉起sdk进行支付
ClsGameSdk.pay = function(code, info)
	if code == 0 then
		login_auth_obj:pay(info)
	end
end

ClsGameSdk.setRelinkToken = function( token )
	login_auth_obj:setRelinkToken( token )
end

ClsGameSdk.setRelinkUid = function( uid )
	login_auth_obj:setRelinkUid( uid )
end
--获取个人信息
ClsGameSdk.getUserInfo = function()
	return login_auth_obj:getUserInfo()
end
--获取同玩好友信息
ClsGameSdk.getFriendsInfo = function()
	return login_auth_obj:getFriendsInfo()
end

--附近的人
ClsGameSdk.getNearbyPersonInfo = function()
	print("========gameRpc.getNearbyPersonInfo()")
	login_auth_obj:getNearbyPersonInfo()
end
--清除位置信息
ClsGameSdk.cleanLocation = function()
	login_auth_obj:cleanLocation()
end
--获取玩家位置信息
ClsGameSdk.getLocationInfo = function()
	login_auth_obj:getLocationInfo()
end

ClsGameSdk.openURL = function(url)
	login_auth_obj:openURL(url)
end
-- 传入参数说明：
--img_url 地址为：res/ui/...
--scene：SHARE_SCENE_SESSION 会话，SHARE_SCENE_ZONE为圈子（朋友圈或者是QQzone）
--media_tag_name：SHARE_TAG_MSG_INVITE邀请，宏看gameBases
--message_ext:可不传 为""
ClsGameSdk.share = function(title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
	login_auth_obj:share(title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
end

-- 传入参数说明：
--img_url 地址为：res/ui/...
--scene：SHARE_SCENE_SESSION 会话，SHARE_SCENE_ZONE为圈子（朋友圈或者是QQzone）
--media_tag_name：SHARE_TAG_MSG_INVITE邀请
--message_ext:可不传 为""
ClsGameSdk.shareToFriend = function(fopen_id, title, desc, url, img_url, media_tag_name, message_ext, call_back)
	print(fopen_id, title, desc, url, img_url, media_tag_name, message_ext, call_back)
	login_auth_obj:shareToFriend(fopen_id, title, desc, url, img_url, media_tag_name, message_ext, call_back)
end

-- 传入参数说明：
--img_url 地址为：res/ui/...
--scene：SHARE_SCENE_SESSION 会话，SHARE_SCENE_ZONE为圈子（朋友圈或者是QQzone）
--media_tag_name：SHARE_TAG_MSG_INVITE邀请
--message_ext:可不传 为""
--msg_action: SHARE_ACTION_SNS_JUMP_APP打开APP
--screen_rect：为CCRect数据，传入代表要截屏操作
ClsGameSdk.shareWithPhoto = function(scene, img_url, media_tag_name, message_ext, msg_action, screen_rect, call_back)
	login_auth_obj:shareWithPhoto(scene, img_url, media_tag_name, message_ext, msg_action, screen_rect, call_back)
end

ClsGameSdk.shareWithUrl = function(title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
	login_auth_obj:shareWithUrl(title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
end

ClsGameSdk.askFriendRelation = function()
	login_auth_obj:askFriendRelation()
end

--开通QQ会员
ClsGameSdk.openQQVip = function(url)
	login_auth_obj:openQQVip(url)
end

--绑群
--group_key 绑群需要的游戏中的公会id，分区需要不同key值，改为服务器拼装给
--group_name 游戏中公会名称
--player_name玩家群名称
--signature 服务端给的md5
ClsGameSdk.bindGroup = function(group_key, group_name, signature, player_name)
	login_auth_obj:bindGroup(group_key, group_name, signature, player_name)
end

--加入群
--signature 服务端给的md5
--group_key 绑群需要的游戏中的公会id，分区需要不同key值，改为服务器拼装给
--player_name 游戏中玩家名字
ClsGameSdk.joinGroup = function(signature, group_key, player_name)
	login_auth_obj:joinGroup(signature, group_key, player_name)
end

--用户反馈
ClsGameSdk.feedback = function(str)
	login_auth_obj:feedback(str)
end

--打开微信的deeplink，跳转到游戏中心
ClsGameSdk.openWeiXinDeeplink = function(link_url)
	login_auth_obj:openWeiXinDeeplink(link_url)
end

ClsGameSdk.getPlatform = function()
	return login_auth_obj:getPlatform()
end

ClsGameSdk.getAuthChn = function()
	return login_auth_obj:getAuthChn()
end

ClsGameSdk.canOperate = function(call_back)
	login_auth_obj:canOperate(call_back)
end

rpc_client_qq_pay_req = function(response)
	if login_auth_obj then
		login_auth_obj:payResponse(response)
	end
end

--清除支付冷却时间
rpc_client_payment_clear = function()
	if login_auth_obj then
		login_auth_obj:cleanPayCdTime()
	end
end

--------------------------客服连接地址---------------------------------------------
ClsGameSdk.openLoginService = function()
	if GTab.CHANNEL_ID == CHANNEL_TENCENT then
		ClsGameSdk.openURL("https://kf.qq.com/touch/scene_faq.html?scene_id=kf3486")
	elseif GTab.CHANNEL_ID == CHANNEL_TENCENT_IOS then
		ClsGameSdk.openURL("https://kf.qq.com/touch/scene_faq.html?scene_id=kf3484")
	end
end

ClsGameSdk.openPayService = function()
	if GTab.CHANNEL_ID == CHANNEL_TENCENT then
		ClsGameSdk.openURL("https://kf.qq.com/touch/scene_faq.html?scene_id=kf3490")
	elseif GTab.CHANNEL_ID == CHANNEL_TENCENT_IOS then
		ClsGameSdk.openURL("https://kf.qq.com/touch/scene_faq.html?scene_id=kf3488")
	end
end

ClsGameSdk.openSystemSetService = function()
	ClsGameSdk.openURL("https://kf.qq.com/touch/scene_product.html?scene_id=kf3482")
end
--------------------------------------------------------------------------------------

return ClsGameSdk
