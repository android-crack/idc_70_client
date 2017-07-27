--登录基类
local ClsAuthBase = class("ClsAuthBase")

ClsAuthBase.ctor = function(self, chn)
	self.__init_flag = false
	self.auth_chn = chn
	self.pay_op_interval = 30

	self.SHARE_SCENE = {
		[PLATFORM_QQ] = {[SHARE_SCENE_SESSION] = 2, [SHARE_SCENE_ZONE] = 1},
		[PLATFORM_WEIXIN] = {[SHARE_SCENE_SESSION] = 0, [SHARE_SCENE_ZONE] = 1},
	}
end

-- 初始化函数
ClsAuthBase.__init__ = function(self, select_account_type, select_account_val)
	self.__init_flag = true
end


ClsAuthBase.checkInit = function(self, select_account_type, select_account_val)
	if self.__init_flag then return end
	self:__init__(select_account_type, select_account_val)
end

ClsAuthBase.hasInit = function(self)
	return self.__init_flag
end

-- 开始登录
ClsAuthBase.beginLogin = function(self, open_udid, select_account_type, select_account_val)
	self.begin_login = true
	self:checkInit(select_account_type, select_account_val)
	self.open_udid = open_udid
end

-- 执行验证渠道，拉起授权等
ClsAuthBase.executeAuthChn = function(self)
	updateVersonInfo(LOG_1040)
	self.delay_execute_auth_chn = false
	-- local start_and_login_data = getGameData():getStartAndLoginData()
	-- local ext_data = start_and_login_data:getAuthRoleInfo()
	self:loginCallBack(1, self.openId, self.token, "")
end

-- 需要延时执行验证登录
ClsAuthBase.delayExecuteAuthChn = function(self)
	self.delay_execute_auth_chn = true
end

-- 是否延时执行验证登录
ClsAuthBase.isDelayExecuteAuthChn = function(self)
	return self.delay_execute_auth_chn
end

ClsAuthBase.getClientChannel = function(self)
	local config = require("root/baseConfig")
	local dist_channel_id = config.dist_channel_id or ""
	return dist_channel_id
end

ClsAuthBase.switchAccount = function(self)
	self:reStartGame()
end

ClsAuthBase.reStartGame = function(self)
	local login_layer = getUIManager():get("LoginLayer")
	if not tolua.isnull(login_layer) then
		return
	end
	local module_game_rpc = require("module/gameRpc")
	module_game_rpc.reStartGame()
end

ClsAuthBase.showSDKFlagAlert = function(self, flag)
	local Alert = require("ui/tools/alert")
	local ui_word = require("game_config/ui_word")
	flag = tostring(flag)
	if flag == "0" then
		Alert:warning({msg = ui_word.LOGIN_SDK_SUCCESS, size = 26})
	elseif flag == "1001" or flag == "2002" then
		Alert:warning({msg = ui_word.LOGIN_SDK_CANCEL, size = 26})
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.clearAutoLoginInfo()
	else
		Alert:warning({msg = ui_word.SDK_LOGIN_FIELD, size = 26})
		self:reStartGame()
	end
end

-- 登录回调
ClsAuthBase.loginCallBack = function(self, result, openid, token, extArgs, ...)
	updateVersonInfo(LOG_1041)
	self.openId = openid
	self.token = token
	local ext_data = extArgs
	if type(extArgs) == "table" then
		ext_data = json.encode(extArgs)
	end
	GameUtil.callRpc("rpc_server_auth", {self:getClientChannel(), self.auth_chn, openid, token, ext_data}, "rpc_client_auth_return")
end

ClsAuthBase.sendStartupVip = function(self)
	local start_and_login_data = getGameData():getStartAndLoginData()
	local start_plat = start_and_login_data:getStartupVipPlat()
	if start_plat then
		print("===========start_plat", start_plat, self.platform)
		if (start_plat == SDK_PLATFORM_WEIXIN and self.platform == PLATFORM_WEIXIN) or
			(start_plat == SDK_PLATFORM_QQ and self.platform == PLATFORM_QQ) then
			GameUtil.callRpc("rpc_server_startup_buff", {start_plat})
		end
	end
end

ClsAuthBase.switchUserBack = function(self, is_success)
	if not is_success then
		self.begin_login = false
		self:beginLogin(self.open_udid)
	end
end

-- set 重联 token
ClsAuthBase.setRelinkToken = function(self, token)
	self.relink_token = token
end

-- set 重联 token
ClsAuthBase.setRelinkUid = function(self, uid)
	self.relink_uid = uid
	self:sendSafeInfoByLogin( uid )
	self:loginCheakPayment()
	self:sendStartupVip()
end

-- 重联
ClsAuthBase.beginRelink = function(self)
	if not self.relink_token or not self.relink_uid then
		return
	end
	self.is_relinking = true
end

-- 获取重连信息
ClsAuthBase.getRelinkInfo = function(self)
	return self.relink_token, self.relink_uid
end

ClsAuthBase.setRelinckInfo = function(self, relink_token, relink_uid)
	self.relink_token = relink_token
	self.relink_uid = relink_uid
	self:beginRelink()
end

ClsAuthBase.relink = function(self)
	print("======================  ClsAuthBase:relink()")
	GameUtil.callRpc("rpc_server_uid_relink", {self.relink_uid, self.relink_token}, "rpc_client_uid_relink_return")
end

ClsAuthBase.isRelinking = function(self)
	return self.is_relinking
end

ClsAuthBase.relinkCallBack = function(self, result)
	print("=========ClsAuthBase:relinkCallBack(result)", result)
	self.is_relinking = false
	if ( result == 0) then
		-- getUIManager():removeAllView() --断线重连返回成功应该清除所有的界面
		return
	end
	local error_info = require("game_config/error_info")
	local Alert = require("ui/tools/alert")
	Alert:warning({msg = error_info[result].message, size = 26})

	self:reStartGame()
end

-- 登出
ClsAuthBase.logout = function(self)
	self.begin_login = false
	self.is_relinking = false
	self.last_pay_time = 0
	self.hasRegisterPay = false
end

-- order, product_id, product_name, amount, pay_des
ClsAuthBase.pay = function(self, info)
end

ClsAuthBase.getPayConfig = function(self, info)
	local pay_info = json.decode(info)
	local mall_pay_info = require("game_config/shop/mall_pay_info")
	local pay_config = mall_pay_info[pay_info.product_id]
	return pay_info, pay_config
end

ClsAuthBase.beginPay = function(self, product_id, amount, info)
	local interval_time = tonumber(self.last_pay_time) + tonumber(self.pay_op_interval) - os.time()
	if interval_time > 0 then
		local ui_word = require("game_config/ui_word")
		local Alert = require("ui/tools/alert")
		Alert:warning({msg = string.format(ui_word.SDK_PAY_QUICK_TIPS, interval_time), size = 26})
		return
	end
	self.last_pay_time = os.time()
	amount = amount or 1
	info = info or {}
	GameUtil.callRpc("rpc_server_payment_create", {product_id, amount, json.encode(info)})
end

ClsAuthBase.payCallBack = function(self, success, msg)
	if success then
		print("ClsAuthBase:payCallBack:", msg)
		GameUtil.callRpc("rpc_server_qq_pay_req", {msg})
	else
	end
end

ClsAuthBase.showMidasLoginFail = function(self)
	local ui_word = require("game_config/ui_word")
	local Alert = require("ui/tools/alert")
	local back_login_fun
	back_login_fun = function()
		local module_game_rpc = require("module/gameRpc")
		module_game_rpc.reStartGame(function()
			self:beginLogin(self.open_udid)
		end)
	end
	Alert:showAttention(ui_word.SDK_PAY_LOGIN_FAIL_TIPS, back_login_fun, back_login_fun, nil, {hide_cancel_btn = true, ok_text = ui_word.BACK_LOGIN, hide_close_btn = true})
end

ClsAuthBase.payResponse = function(self, response)
	self:cleanPayCdTime()
end

ClsAuthBase.cleanPayCdTime = function(self)
	self.last_pay_time = 0
end

ClsAuthBase.loginCheakPayment = function(self, info)
	if info then
		GameUtil.callRpc("rpc_server_payment_login_check", {json.encode(info)})
	end
end

ClsAuthBase.beginGetUserInfo = function(self)
end

ClsAuthBase.beginGetFriendsInfo = function(self)
end

ClsAuthBase.openURL = function(self, url)
	CCNative:openURL(url)
end

ClsAuthBase.getUserInfo = function(self)
	return self.user_info
end

ClsAuthBase.getFriendsInfo = function(self)
	return self.friends_info
end

--附近的人
ClsAuthBase.getNearbyPersonInfo = function(self)
end

--清除位置信息
ClsAuthBase.cleanLocation = function(self)
end

--获取玩家位置信息
ClsAuthBase.getLocationInfo = function(self)
end

ClsAuthBase.askFriendRelation = function(self)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:askUserInfo(self.token)
end

ClsAuthBase.setNearByPersonInfo = function(self, info)
	local friend_data_handle = getGameData():getFriendDataHandler()
	friend_data_handle:setNeatFriends(info)
end

ClsAuthBase.setLocationInfo = function(self, info)
end

--name:事件名
--content：事件内容
--是否实时上报
ClsAuthBase.reportEvent = function(self, name, content, is_real_time)
	
end

ClsAuthBase.openQQVip = function(self)
end

--分享小图，不能超过32K
ClsAuthBase.share = function(self, title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
	self:canOperate(function()
		scene = self.SHARE_SCENE[self.platform][scene]
		message_ext = message_ext or ""
		
		local ext_info = {}
		ext_info.scene = scene
		ext_info.mediaTagName = media_tag_name
		ext_info.messageExt = message_ext
		img_url = self:getUpdatePath(img_url)

		QShareSDK:getInstance():share(self.platform, title, desc, url, img_url, json.encode(ext_info), function(code, msg)
			local share_result = tostring(code) == "0"
			if call_back then 
				call_back(share_result)
			end
			require("framework.scheduler").performWithDelayGlobal(function()
				print("=======share with photo back", code, msg)
				local Alert = require("ui/tools/alert")
				local ui_word = require("game_config/ui_word")
				if share_result then
					Alert:warning({msg = ui_word.STR_SHARE_OK, size = 26})
				else
					Alert:warning({msg = ui_word.STR_SHARE_CANCAL, size = 26})
				end
			end, 0.5)
		end)
	end)
end

--分享朋友，不带图
ClsAuthBase.shareToFriend = function(self, fopen_id, title, desc, url, img_url, media_tag_name, message_ext, call_back)
	local ext_info = {}
	-- -- act: 点击分享消息行为；1 拉起游戏，0 拉起targetUrl；此参数目前无效，统一为拉起游戏
	ext_info.act = 1
	img_url = self:getUpdatePath(img_url)
	ext_info.mediaTagName = media_tag_name
	ext_info.msdkExtInfo = ""
	QShareSDK:getInstance():shareToFriend(self.platform, fopen_id, title, desc, url, img_url, json.encode(ext_info), function(code, msg)
		local share_result = tostring(code) == "0"
		if call_back then 
			call_back(share_result)
		end
		require("framework.scheduler").performWithDelayGlobal(function()
			print("=======share with photo back", code, msg)
			local Alert = require("ui/tools/alert")
			local ui_word = require("game_config/ui_word")
			if share_result then
				Alert:warning({msg = ui_word.STR_SHARE_OK, size = 26})
			else
				Alert:warning({msg = ui_word.STR_SHARE_CANCAL, size = 26})
			end
		end, 0.5)
	end)
end

--10M以内的，大图分享
ClsAuthBase.shareWithPhoto = function(self, scene, img_url, media_tag_name, message_ext, msg_action, screen_rect, call_back)
	self:canOperate(function()
		if screen_rect then
			local share_img = "share_big_pic.jpg"
			QShareSDK:saveScreenToFile(share_img, screen_rect)
			img_url = CCFileUtils:sharedFileUtils():getWritablePath() .. share_img
		else
			img_url = self:getUpdatePath(img_url)
		end
		scene = self.SHARE_SCENE[self.platform][scene]
		message_ext = message_ext or ""
		-- android qq
		local ext_info = {}
		ext_info.scene = scene
		ext_info.mediaTagName = media_tag_name
		ext_info.messageExt = message_ext
		ext_info.mediaAction = msg_action
		QShareSDK:getInstance():shareWithPhoto(self.platform, img_url, json.encode(ext_info), function(code, msg)
			local share_result = tostring(code) == "0"
			if call_back then 
				call_back(share_result)
			end
			require("framework.scheduler").performWithDelayGlobal(function()
				print("=======share with photo back", code, msg)
				local Alert = require("ui/tools/alert")
				local ui_word = require("game_config/ui_word")
				if share_result then
					Alert:warning({msg = ui_word.STR_SHARE_OK, size = 26})
				else
					Alert:warning({msg = ui_word.STR_SHARE_CANCAL, size = 26})
				end
			end, 0.5)
		end)
	end)
end

--分享链接 只有微信有
ClsAuthBase.shareWithUrl = function(self, title, desc, url, img_url, scene, media_tag_name, message_ext, call_back)
	self:canOperate(function()
		scene = self.SHARE_SCENE[self.platform][scene]
		message_ext = message_ext or ""
		
		local ext_info = {}
		ext_info.scene = scene
		ext_info.mediaTagName = media_tag_name
		ext_info.messageExt = message_ext
		img_url = self:getUpdatePath(img_url)

		QShareSDK:getInstance():shareWithUrl(self.platform, title, desc, url, img_url, json.encode(ext_info), function(code, msg)
			if call_back then 
				call_back()
			end
			require("framework.scheduler").performWithDelayGlobal(function()
				print("=======share with url back", code, msg)
				local Alert = require("ui/tools/alert")
				local ui_word = require("game_config/ui_word")
				if tostring(code) == "0" then
					Alert:warning({msg = ui_word.STR_SHARE_OK, size = 26})
				else
					Alert:warning({msg = ui_word.STR_SHARE_CANCAL, size = 26})
				end
			end, 0.5)
		end)
	end)
end

ClsAuthBase.getUpdatePath = function(self, path)
	local res_path = string.format("%s/%s", GTab.UPDATE_RES_PATH, path) 
	if fileExist(res_path) then 
		return res_path
	end
	return path
end 

ClsAuthBase.sendSafeInfoByLogin = function(self, uid)
end

ClsAuthBase.setSDKInfoData = function(self, content)
end

ClsAuthBase.tssSdkGetAntiData = function(self, content)
	GameUtil.callRpc("rpc_server_tss_sdk_get_anti_data", {content})
end

ClsAuthBase.tssSdkGetAntiBack = function(self, content)
end

ClsAuthBase.getPlatform = function(self)
	return self.platform or -1
end

ClsAuthBase.getAuthChn = function(self)
	return self.auth_chn
end

ClsAuthBase.canOperate = function(self, call_back)
	local platform = self:getPlatform()
	if platform == PLATFORM_QQ or platform == PLATFORM_WEIXIN then
		self:isPlatformInstalled(platform, function(is_installed)
			if not is_installed then
				local Alert = require("ui/tools/alert")
				local ui_word = require("game_config/ui_word")
				local tips = ui_word.SDK_NOT_INSTALLED_WECHAT
				if platform == PLATFORM_QQ then
					tips = ui_word.SDK_NOT_INSTALLED_QQ
				end
				Alert:warning({msg = tips, size = 26})
			else
				call_back()
			end
		end)
	end
end

ClsAuthBase.isPlatformInstalled = function(self, platform, call_back)
	-- call_back(true)
end

ClsAuthBase.bindGroup = function(self, group_key, group_name, signature, player_name)
end

ClsAuthBase.joinGroup = function(self, signature, group_key, player_name)
end

ClsAuthBase.feedback = function(self, str)
end

ClsAuthBase.openWeiXinDeeplink = function(self, link_url)
	-- body
end

return ClsAuthBase
