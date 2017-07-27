local clsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")

local clsDonateExplainUI = class("clsDonateExplainUI", clsBaseView)

function clsDonateExplainUI:onEnter()
	self:mkUI()
	self:configEvent()
end

function clsDonateExplainUI:mkUI()
	self.panel = createPanelByJson("json/portfight_build_hint.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		btn_close = "btn_close",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end
end

function clsDonateExplainUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

return  clsDonateExplainUI
