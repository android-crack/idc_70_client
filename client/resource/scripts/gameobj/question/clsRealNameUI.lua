local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsRealNameUI = class("ClsRealNameUI", ClsBaseView)

local DIAMOND_NUM = 200
--页面参数配置方法，注意，是静态方法
ClsRealNameUI.getViewConfig = function(self)
	return {
		type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
		is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
		is_back_bg = true,
		effect = UI_EFFECT.SCALE,
	}
end

--页面创建时调用
ClsRealNameUI.onEnter = function(self)
	self:configUI()
	self:configEvent()
end

ClsRealNameUI.configUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_real_name.json")
	self:addWidget(self.panel)

	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.btn_go = getConvertChildByName(self.panel, "btn_go")
end

ClsRealNameUI.configEvent = function(self)
	self.btn_go:setPressedActionEnabled(true)
	self.btn_go:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_sdk = require("module/sdk/gameSdk")
		local platform = module_game_sdk.getPlatform()
		if platform == PLATFORM_WEIXIN then
			module_game_sdk.openURL("https://zhen.qq.com/act/authenticate/sy.html")
		elseif platform == PLATFORM_QQ then
			module_game_sdk.openURL("http://jkyx.qq.com/")
		end
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

ClsRealNameUI.closeView = function(self)
	self:close()
end

return ClsRealNameUI
