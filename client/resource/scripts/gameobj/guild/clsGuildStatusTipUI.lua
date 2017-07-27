local clsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")

local ClsGuildStatusTipUI = class("ClsGuildStatusTipUI", clsBaseView)

ClsGuildStatusTipUI.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsGuildStatusTipUI.onEnter = function(self)
	self:mkUI()
	self:configEvent()
end

ClsGuildStatusTipUI.mkUI = function(self)
	self.panel = createPanelByJson("json/guild_hall_state.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		btn_close = "btn_close",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end
end

ClsGuildStatusTipUI.configEvent = function(self)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

return ClsGuildStatusTipUI