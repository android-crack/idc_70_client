--登录验证界面
local ClsLoginLayerBase = require("gameobj/login/clsLoginLayerBase")
local ClsLoginAuthLayer = class("ClsLoginAuthLayer", ClsLoginLayerBase)

ClsLoginAuthLayer.onEnter = function(self)
	--关闭正在播放的聊天语音
	require("ui/tools/QSpeechMgr")            
	local speech = getSpeechInstance()
	speech:stopPlay()

	updateVersonInfo(LOG_1011)
	self.plist_tab = {
		["ui/login.plist"] = 1,
	}
	LoadPlist(self.plist_tab)
	ClsLoginAuthLayer.super.onEnter(self)
	hideVersionInfo(true)
end

ClsLoginAuthLayer.mkJsonUI = function(self)
	local channel_id = GTab.CHANNEL_ID
	if channel_id == "tencent" then
		self:mkTencentUI()
	elseif channel_id == "tencent_ios" then
		self:mkTencentIosUI()
	elseif channel_id == "efun" and device.platform == "android" then
		self:mkEfunLogin()
	else
		self:mkLoginKeyUI()
	end

	if GTab.IS_VERIFY then 
		return
	end 
	
	if STOP_SVR_ANNOUNCE then
		getUIManager():create("gameobj/login/clsLoginNoticeLayer")
	else
		local start_and_login_data = getGameData():getStartAndLoginData()
		local last_show_time = start_and_login_data:getLoginNoticeTime()
		local last_date = os.date("*t", last_show_time)
		local cur_date = os.date("*t")
		if not last_show_time or last_date.month ~= cur_date.month or last_date.day ~= cur_date.day then
			getUIManager():create("gameobj/login/clsLoginNoticeLayer")
			start_and_login_data:setLoginNoticeTime()
		end
	end
end

local createEditBox
createEditBox = function(key, word, input_flag)
	local userDefault = CCUserDefault:sharedUserDefault()
	local editbox_size = CCSize(260,40)
	local frame1 = display.newScale9Sprite("#login_input.png")
	local edit_box = CCEditBox:create(editbox_size, frame1)
	edit_box:setInputFlag(input_flag)

	edit_box:setPlaceholderFont("ui/font/microhei_bold.fnt", 20)
	edit_box:setFont("ui/font/microhei_bold.fnt", 18)

	local key_info = userDefault:getStringForKey(key)
	if key_info and #key_info>0 then
		edit_box:setText(key_info)
	else
		edit_box:setPlaceHolder(word)
	end
	edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
	edit_box:setFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))

	edit_box:setMaxLength(20)
	edit_box:registerScriptEditBoxHandler(function(eventType)
		userDefault:setStringForKey(key, edit_box:getText())
		userDefault:flush()
	end)
	return edit_box
end

local playVideoClick
playVideoClick = function()
	audioExt.pauseMusic()
	audioExt.pauseAllEffects()
	playVideo("res/movie/movie.mp4", function()
		audioExt.resumeMusic()
		audioExt.resumeAllEffects()
		print("end movie call back")
	end)
end

local createKeyJson
createKeyJson = function(self, login_back)
	local STR_NAME = "loginName"
	local STR_PASSWORLD = "passWord"

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/login_neifu.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.btn_login = getConvertChildByName(self.panel, "btn_login")
	self.btn_replay = getConvertChildByName(self.panel, "btn_replay")
	self.account_input = getConvertChildByName(self.panel, "account_input")
	self.password_input = getConvertChildByName(self.panel, "password_input")
	self.btn_notice = getConvertChildByName(self.panel, "btn_notice")

	local account_pos = self.account_input:getPosition()
	local pwd_pos = self.password_input:getPosition()

	local ui_word = require("game_config/ui_word")
	self.edit_box_key = createEditBox(STR_NAME, ui_word.SEP_ACCOUNT_HOLDER, kEditBoxInputFlagSensitive)
	self.edit_box_key:setPosition(account_pos.x + 10, account_pos.y)
	self:addChild(self.edit_box_key)
	self.account_input:setVisible(false)

	self.edit_box_pwd = createEditBox(STR_PASSWORLD, ui_word.SEP_PASSWORD_HOLDER, kEditBoxInputFlagPassword)
	self.edit_box_pwd:setPosition(account_pos.x + 10, pwd_pos.y)
	self:addChild(self.edit_box_pwd)
	self.password_input:setVisible(false)

	self.btn_replay:setPressedActionEnabled(true)
	self.btn_replay:addEventListener(function()
		playVideoClick()
	end,TOUCH_EVENT_ENDED)

	self.btn_notice:setPressedActionEnabled(true)
	self.btn_notice:addEventListener(function()
		getUIManager():create("gameobj/login/clsLoginNoticeLayer")
	end,TOUCH_EVENT_ENDED)

	self.btn_login:setPressedActionEnabled(true)
	self.btn_login:addEventListener(function()
		self:checkClickOperate(function()
			--加输入的判断====================
			local text_key = self.edit_box_key:getText()
			local text_pwd = self.edit_box_pwd:getText()
			local propertyHeadIndex_1, propertyTailIndex_1 = string.find(text_key, "%w+")
			local propertyHeadIndex_2, propertyTailIndex_2 = string.find(text_pwd, "%w+")

			if (propertyHeadIndex_1) and (propertyHeadIndex_2)  and 
				propertyHeadIndex_1 == 1 and propertyTailIndex_1 == #text_key and 
				propertyHeadIndex_1 == 1 and propertyTailIndex_2 == #text_pwd then
				self:getViewTouchEnabled(false)
				
				login_back(text_key, text_pwd)
			else
				local Alert = require("scripts/ui/tools/alert")
				Alert:warning({msg = ui_word.ACCOUNT_ERROR, color = ccc3(dexToColor3B(COLOR_RED))})
			end
		end)
	end,TOUCH_EVENT_ENDED)

	local module_game_rpc = require("module/gameRpc")
	module_game_rpc.callLoginFun()
end

local createTencentJson
createTencentJson = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/login_tencent.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.btn_visitor = getConvertChildByName(self.panel, "btn_visitor")
	self.btn_qq = getConvertChildByName(self.panel, "btn_qq")
	self.btn_wechat = getConvertChildByName(self.panel, "btn_wechat")
	self.btn_replay = getConvertChildByName(self.panel, "btn_replay")
	self.btn_notice = getConvertChildByName(self.panel, "btn_notice")

	self.btn_notice:setPressedActionEnabled(true)
	self.btn_notice:addEventListener(function()
		getUIManager():create("gameobj/login/clsLoginNoticeLayer")
	end,TOUCH_EVENT_ENDED)

	if GTab.IS_VERIFY then 
		self.btn_notice:setVisible(false)
	end 
	self.btn_replay:setPressedActionEnabled(true)
	self.btn_replay:addEventListener(function()
		playVideoClick()
	end,TOUCH_EVENT_ENDED)

	self:setViewTouchEnabled(false)
	local ClsUpdateAlert = require("update/updateAlert")
	local getNoticeData
	getNoticeData = function(times)
		times = times + 1
		ClsUpdateAlert:showStopSvrNoticeInfo(function()
			if times < 4 then
				getNoticeData(times)
				return
			end
			
			self:doAutoLogin()
		end) 
	end
	getNoticeData(0)
end

ClsLoginAuthLayer.doAutoLogin = function(self)
	self:setViewTouchEnabled(false)

	if not _G.auto_req_wakeup_info then
		_G.auto_req_wakeup_info = true
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.getWakeupInfo()
	else
		self:setViewTouchEnabled(true)
		local module_game_rpc = require("module/gameRpc")
		module_game_rpc.callLoginFun()
	end
end

ClsLoginAuthLayer.mkEfunLogin = function(self)
	self:mkKeyUIBegin()

	createKeyJson(self, function(open_id, pwd)
		self:loginKeyClick(open_id, pwd)
	end)
end

--以帐号密码来登录
ClsLoginAuthLayer.mkLoginKeyUI = function(self)
	self:mkKeyUIBegin()

	createKeyJson(self, function(open_id, pwd)
		self:loginKeyClick(open_id, pwd)
	end)
end

ClsLoginAuthLayer.mkKeyUIBegin = function(self)
	updateVersonInfo(LOG_1015)
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginLogin()
end

--以qq MSDK来登录
ClsLoginAuthLayer.mkTencentUI = function(self)
	createTencentJson(self)

	self.btn_visitor:setVisible(false)
	self.btn_visitor:setTouchEnabled(false)

	local pos_dis = -100
	local qq_pos = self.btn_qq:getPosition()
	self.btn_qq:setPosition(ccp(qq_pos.x + pos_dis, qq_pos.y))
	
	local wechat_pos = self.btn_wechat:getPosition()
	self.btn_wechat:setPosition(ccp(wechat_pos.x + pos_dis, wechat_pos.y))

	self.btn_qq:setPressedActionEnabled(true)
	self.btn_qq:addEventListener(function()
		self:checkClickOperate(function()
				self:tencentIosQQClick()
			end)
	end,TOUCH_EVENT_ENDED)

	self.btn_wechat:setPressedActionEnabled(true)
	self.btn_wechat:addEventListener(function()
		self:checkClickOperate(function()
				self:tencentIosWechatClick()
			end)
	end,TOUCH_EVENT_ENDED)
end

ClsLoginAuthLayer.mkTencentIosUI = function(self)
	createTencentJson(self)

	local has_wechat = QSDK:sharedQSDK():isPlatformInstalled(PLATFORM_WEIXIN)
	if has_wechat then
		self.btn_wechat:setPressedActionEnabled(true)
		self.btn_wechat:addEventListener(function()
			self:checkClickOperate(function()
				self:tencentIosWechatClick()
			end)
		end,TOUCH_EVENT_ENDED)
	else
		local pos_dis = 100
		local qq_pos = self.btn_qq:getPosition()
		self.btn_qq:setPosition(ccp(qq_pos.x + pos_dis, qq_pos.y))
		
		local visito_pos = self.btn_visitor:getPosition()
		self.btn_visitor:setPosition(ccp(visito_pos.x + pos_dis, visito_pos.y))

		self.btn_wechat:setVisible(false)
		self.btn_wechat:setTouchEnabled(false)
	end

	self.btn_qq:setPressedActionEnabled(true)
	self.btn_qq:addEventListener(function()
		self:checkClickOperate(function()
				self:tencentIosQQClick()
			end)
	end,TOUCH_EVENT_ENDED)

	self.btn_visitor:setPressedActionEnabled(true)
	self.btn_visitor:addEventListener(function()
		if not GTab.IS_VERIFY and (DEBUG and DEBUG <= 0) then
			self:showIosGuestTips()
			return
		end
		self:checkClickOperate(function()
				self:tencentIosVisitorClick()
			end)
	end,TOUCH_EVENT_ENDED)
end

ClsLoginAuthLayer.loginKeyClick = function(self, open_id, pwd)
	updateVersonInfo(LOG_1016)
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginLoginCallBack(0, open_id, pwd, {})
	
	require("gameobj/testTools"):setLoginAccount(open_id)
end

ClsLoginAuthLayer.tencentIosVisitorClick = function(self)
	updateVersonInfo(LOG_1012)
	print("==============visitor click")
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginLogin("qtz_guest")
end

ClsLoginAuthLayer.tencentIosQQClick = function(self)
	updateVersonInfo(LOG_1013)
	print("==========ClsLoginAuthLayer:tencentQQClick")
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginLogin("qq")
end

ClsLoginAuthLayer.tencentIosWechatClick = function(self)
	updateVersonInfo(LOG_1014)
	print("==========ClsLoginAuthLayer:tencentWechatClick")
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginLogin("wechat")
end

ClsLoginAuthLayer.showIosGuestTips = function(self)
	local layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_guest.json")
	convertUIType(panel)
	layer:addChild(panel)
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	
	local closeFunction
	closeFunction = function()
		getUIManager():close("ClsLoginIosGuestTipsUI")
	end 

	local btn_middle = getConvertChildByName(panel, "btn_middle")
	btn_middle:setPressedActionEnabled(true)
	btn_middle:addEventListener(closeFunction, TOUCH_EVENT_ENDED)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeFunction, TOUCH_EVENT_ENDED)

	getUIManager():create("ui/view/clsBaseTipsView", nil, "ClsLoginIosGuestTipsUI", {type =  UI_TYPE.DIALOG}, layer, true)
end

ClsLoginAuthLayer.onExit = function(self)
	UnLoadPlist(self.plist_tab)
	ClsLoginAuthLayer.super.onExit(self)
end

return ClsLoginAuthLayer
