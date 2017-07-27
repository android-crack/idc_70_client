--
-- 活动奖品介绍
--

local ClsBaseView  = require("ui/view/clsBaseView")
local ClsMusicInfo = require("scripts/game_config/music_info")

local ClsFestivalRewardTips = class("ClsFestivalRewardTips", ClsBaseView)

local JSON_URL              = "json/activity_dw_award.json"

function ClsFestivalRewardTips:getViewConfig()
	return {
		["is_back_bg"] = true,            -- 半透明黑背景
		["effect"]     = UI_EFFECT.SCALE, -- 特效
	}
end

function ClsFestivalRewardTips:onEnter(reward_data)
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


return ClsFestivalRewardTips