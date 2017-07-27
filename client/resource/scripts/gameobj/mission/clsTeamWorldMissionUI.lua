local ClsBaseView = require("ui/view/clsBaseView")
local ClsTeamWorldMissionUI = class("ClsTeamWorldMissionUI", ClsBaseView)
local ui_word = require("scripts/game_config/ui_word")
local alert = require("ui/tools/alert")

local widget_name = {
	"btn_go",
	"btn_close",
}

function ClsTeamWorldMissionUI:getViewConfig()
    return {
        name = "ClsTeamWorldMissionUI",
        is_swallow = true
    }
end

function ClsTeamWorldMissionUI:onEnter(params)
	self.mission = params.data
	self.call_back = params.call_back
	self:mkUI()
	self:initEvent()
end

function ClsTeamWorldMissionUI:mkUI()
	local json_ui = GUIReader:shareReader():widgetFromJsonFile("json/tips_world.json")
	self:addWidget(json_ui)
	for k,name in ipairs(widget_name) do
        self[name] = getConvertChildByName(json_ui, name)
    end
end

function ClsTeamWorldMissionUI:initEvent()
	self.btn_go:addEventListener(function()
		if getGameData():getTeamData():isLock() then
			alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_ACCEPT_TIP})
			self:closeUI()
			return
		end

		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		missionSkipLayer:skipPortWorldMapLayer()

		local data = {}
		data.type = EXPLORE_NAV_TYPE_WORLD_MISSION
		data.id = self.mission.id
		if getUIManager():isLive("clsMissionTipUI") then
			getUIManager():close("clsMissionTipUI")
		end
		getUIManager():create("gameobj/explore/clsMissionTipUI", nil, data)
		self:closeUI()
	end, TOUCH_EVENT_ENDED)

	self.btn_close:addEventListener(function()
		self:closeUI()
	end, TOUCH_EVENT_ENDED)
end

function ClsTeamWorldMissionUI:closeUI()
	self:close()
end

function ClsTeamWorldMissionUI:onExit()
	if type(self.call_back) == "function" then
		self.call_back()
	end
end

return ClsTeamWorldMissionUI