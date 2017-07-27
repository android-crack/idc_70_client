--
-- 邮箱介绍
--

local ClsBaseView = require("ui/view/clsBaseView")
local ClsMusicInfo = require("scripts/game_config/music_info")

local ClsMailInstruction = class("ClsMailInstruction", ClsBaseView)
local JSON_URL = "json/mail_tips.json";

-- 静态方法，页面属性
function ClsMailInstruction:getViewConfig()
	return {
        is_back_bg = true,        -- 半透明黑背景
        effect = UI_EFFECT.SCALE, -- 特效
    }
end

-- 初始化
function ClsMailInstruction:onEnter()
	local txt_panel = GUIReader:shareReader():widgetFromJsonFile(JSON_URL);
	convertUIType(txt_panel);
	self:addWidget(txt_panel)

	local btn_close = getConvertChildByName(txt_panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(function()
		audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
        self:close()
	end, TOUCH_EVENT_ENDED)
end

return ClsMailInstruction
