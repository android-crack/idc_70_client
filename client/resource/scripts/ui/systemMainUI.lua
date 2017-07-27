-- 系统界面
local music_info=require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local Tips = require("ui/tools/Tips")
local Alert = require("ui/tools/alert")
local MUSIC_KEY = "noMusic"
local SOUND_KEY = "noEffect"

local SystemMainUI = class("SystemMainUI", require("ui/view/clsBaseView"))
local needWidgetName = {
	"btn_close",
	"bg",
	"btn_music",
	"btn_sound",
	"btn_right",
	"btn_left",
	"language_text",
	"system_panel",
	"confirm_panel",
	"btn_confirm",
	"btn_cancel",
	"btn_back",
	"contract_btn",
	"privacypolicy_btn",
	"termsofservice_btn",
	"version_id",
	"text",
	"btn_feedback",
	"btn_feedback_text",
	"btn_service",
	"btn_service_text",
}
SystemMainUI.getViewConfig = function(self)
	return {
		effect = UI_EFFECT.SCALE,
		is_back_bg = true;
	}
end

SystemMainUI.onEnter = function(self)
	self.plistRes = {
		["ui/system_ui.plist"] = 1,
	}
	LoadPlist(self.plistRes)
	self:mkUi()
	self:addListener()
end

SystemMainUI.mkUi = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/captain_system.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	for k,v in ipairs(needWidgetName) do
		self[v] = getConvertChildByName(self.panel,v)
	end

	self.bg:setPosition(ccp(display.cx, display.cy))
	local bgWidth = self.bg:getSize().width
	local bgHeight = self.bg:getSize().height
	self.rect = CCRect(display.cx - bgWidth / 2,display.cy - bgHeight / 2,bgWidth,bgHeight)

	--下面为测试代码，用于多语言切换
	local ClsLanguage = require("language")
	local switch_cfg = {
		["zh-CN"] = {"zh-TW", T("简体中文"), "ja-JP"},
		["zh-TW"] = {"en-ESA", T("繁体中文"), "zh-CN"},
		["en-ESA"] = {"ja-JP", T("ENGLISH"), "zh-TW"},
		--["ko-KR"] = {"ja-JP", T("韩语"), "en-ESA"},
		["ja-JP"] = {"zh-CN", T("日本語"), "en-ESA"},
	}

	local lang_name = ClsLanguage:getLanguage()
	local cfg_item = switch_cfg[lang_name]
	local msg_str = cfg_item[2]
	self.msg_str = msg_str
	self.msg_str_save = msg_str
	self.language_text:setText(msg_str)
	self:updataView(false)

	local app_version = GTab.APP_VERSION
	local update_version = GTab.VERSION_UPDATE
	self.version_id:setText(string.format("%s - %s", app_version, update_version))

	self.btn_right:setPressedActionEnabled(true)
	self.btn_right:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local item_lang = cfg_item[1]
		cfg_item = switch_cfg[item_lang]
		msg_str = cfg_item[2]
		self.language_text:setText(msg_str)
		self.msg_str = msg_str
		lang_name = item_lang
	end,TOUCH_EVENT_ENDED)

	self.btn_left:setPressedActionEnabled(true)
	self.btn_left:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local item_lang = cfg_item[3]
		cfg_item = switch_cfg[item_lang]
		msg_str = cfg_item[2]
		self.language_text:setText(msg_str)
		self.msg_str = msg_str
		lang_name = item_lang
	end,TOUCH_EVENT_ENDED)

	-- 禁用语言切换
	self.btn_right:setEnabled(false)
	self.btn_left:setEnabled(false)

	self.btn_confirm:setPressedActionEnabled(true)
	self.btn_confirm:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		ClsLanguage:setLanguage(lang_name, true)
		self:close()
	end,TOUCH_EVENT_ENDED)

	self.btn_cancel:setPressedActionEnabled(true)
	self.btn_cancel:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res,false)
		self:close()
	end,TOUCH_EVENT_ENDED)
end

CCTime:gettimeofdayCocos2d(tp, tzp)

SystemMainUI.addListener = function(self)
	self.btn_music:addEventListener(function()
		if audioExt.isMusicEnabled() then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		audioExt.setMusicEnabled(true)
		local port_data = getGameData():getPortData():getPortInfo()
		audioExt.playMusic(music_info[port_data.music].res, true)
		self:setResult(MUSIC_KEY, false)
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_music:addEventListener(function()
		if not audioExt.isMusicEnabled() then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		audioExt.stopMusic(true)
		audioExt.setMusicEnabled(false)
		self:setResult(MUSIC_KEY, true)
	end, CHECKBOX_STATE_EVENT_UNSELECTED)

	self.btn_sound:addEventListener(function()
		if audioExt.isEffectEnabled() then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		audioExt.setEffectEnabled(true)
		self:setResult(SOUND_KEY, false)
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_sound:addEventListener(function()
		if not audioExt.isEffectEnabled() then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		audioExt.stopAllEffects()
		audioExt.setEffectEnabled(false)
		self:setResult(SOUND_KEY, true)
	end, CHECKBOX_STATE_EVENT_UNSELECTED)

	self.btn_back:setPressedActionEnabled(true)
	self.btn_back:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_rpc = require("module/gameRpc")
		require("module/gameRpc").reStartGame()
	end,TOUCH_EVENT_ENDED)

	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res,false)
		if self.msg_str_save == self.msg_str then
			self:close()
		else
			if self.confirm_panel:isVisible() then
				self:updataView(false)
				self.system_panel:setVisible(true)
			else
				self.system_panel:setVisible(false)
				local text_info = string.format(ui_word.SYS_LANGUAGE_CHANGE, self.msg_str)   
				self.text:setText(text_info)
				self:updataView(true)
			end
		end

	end,TOUCH_EVENT_ENDED)

	local is_music = audioExt.isMusicEnabled()
	local is_sound = audioExt.isEffectEnabled()
	self.btn_music:executeEvent(is_music and CHECKBOX_STATE_EVENT_SELECTED or CHECKBOX_STATE_EVENT_UNSELECTED)
	self.btn_music:setSelectedState(is_music)
	self.btn_sound:executeEvent(is_sound and CHECKBOX_STATE_EVENT_SELECTED or CHECKBOX_STATE_EVENT_UNSELECTED)
	self.btn_sound:setSelectedState(is_sound)

	self:addTencentBtn()
end

SystemMainUI.addTencentBtn = function(self)
	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()

	local need_show_btn = (platform == PLATFORM_WEIXIN or platform == PLATFORM_QQ or platform == PLATFORM_GUEST)
	if need_show_btn then
		self.btn_feedback:setPressedActionEnabled(true)
		self.btn_feedback:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local user_default = CCUserDefault:sharedUserDefault()
			local last_feed_time = getGameData():getPlayerData():getFeedBackTime()
			print("last_feed_time", last_feed_time)
			print("os.time()", os.time())
			local dt_time = tonumber(os.time()) - tonumber(last_feed_time)
			print("toNUMBER---",dt_time)
			if last_feed_time and dt_time < 60 then
				Alert:warning({msg = ui_word.FEED_BACK_TIPS, size = 26})
				return 
			end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			getUIManager():create("ui/clsFeedBackTips")
		end,TOUCH_EVENT_ENDED)

		self.contract_btn:setPressedActionEnabled(true)
		self.contract_btn:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.openURL("http://game.qq.com/contract.shtml")
		end, TOUCH_EVENT_ENDED)

		self.privacypolicy_btn:setPressedActionEnabled(true)
		self.privacypolicy_btn:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.openURL("http://www.tencent.com/en-us/zc/privacypolicy.shtml")
		end, TOUCH_EVENT_ENDED)

		self.termsofservice_btn:setPressedActionEnabled(true)
		self.termsofservice_btn:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.openURL("http://www.tencent.com/en-us/zc/termsofservice.shtml")
		end, TOUCH_EVENT_ENDED)
	else
		self.btn_feedback:setVisible(false)
		self.btn_feedback_text:setVisible(false)
		self.contract_btn:setVisible(false)
		self.privacypolicy_btn:setVisible(false)
		self.termsofservice_btn:setVisible(false)
	end

	local show_sevice_btn = (platform == PLATFORM_WEIXIN or platform == PLATFORM_QQ)
	self.btn_service:setVisible(show_sevice_btn)
	self.btn_service_text:setVisible(show_sevice_btn)
	if self.btn_service:isVisible() and GTab.IS_VERIFY then
		self.btn_service:setVisible(false)
		self.btn_service_text:setVisible(false)
	end

	self.btn_service:setPressedActionEnabled(true)
	self.btn_service:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.openSystemSetService()
	end, TOUCH_EVENT_ENDED)
end

SystemMainUI.updataView = function(self, enable)
	self.confirm_panel:setVisible(enable)
	self.btn_confirm:setTouchEnabled(enable)
	self.btn_cancel:setTouchEnabled(enable)
end
SystemMainUI.setTouch = function(self, enable)

end

SystemMainUI.setResult = function(self, key, value)
	CCUserDefault:sharedUserDefault():setBoolForKey(key, value)
	CCUserDefault:sharedUserDefault():flush()
end

SystemMainUI.onExit = function(self)
	UnLoadPlist(self.plistRes)
	ReleaseTexture(self)
end

return SystemMainUI




