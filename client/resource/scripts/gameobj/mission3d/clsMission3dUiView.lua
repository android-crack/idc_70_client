--2017/02/15
--create by wmh0497
--用于显示3d的任务页面

local game3d = require("game3d")
local ui_word = require("game_config/ui_word")
local ClsU3dSceneParse = require("gameobj/u3d/u3dSceneParse")
local ClsDialogQuene = require("gameobj/quene/clsDialogQuene")
local music_info = require("game_config/music_info")

local ClsMission3dUiView = class("ClsMission3dUiView", require("ui/view/clsBaseView"))

function ClsMission3dUiView:getViewConfig()
	return {
		is_swallow = true,
		hide_before_view = true,
	}
end

function ClsMission3dUiView:onEnter(mission3d_cfg, params)
	ClsDialogQuene:pauseQuene("ShowMission3dScene")
	self.m_params = params or {}
	self.m_close_callback = self.m_params.close_callback
	local ui = require("gameobj/mission3d/clsMission3dUi").new(self, mission3d_cfg, function() self:close() end)
end

function ClsMission3dUiView:onFinish()
	if type(self.m_close_callback) == "function" then
		self.m_close_callback()
		self.m_close_callback = nil
	end
	ClsDialogQuene:resumeQuene("ShowMission3dScene")
	require("module/preload/preload_mission3d").clear_preload()
end

return ClsMission3dUiView