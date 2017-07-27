local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsPanelPopView = class("ClsPanelPopView", ClsQueneBase)

local panel_tbl = {
	["team_world_mission"] = "gameobj/mission/clsTeamWorldMissionUI", --组队世界任务
	["unlock_activity_anounce"] = "gameobj/activity/clsUnlockActivityPop", --新活动解锁通知
	["city_challenge"] = "gameobj/quene/clsCityChallengePop" --市政厅活动任务
}
local panel_quene_types = {
	["team_world_mission"] = team_world_mission_pop,
	["unlock_activity_anounce"] = unlock_activity_pop,
	["city_challenge"] = city_challenge_pop,
}

function ClsPanelPopView:ctor(type, params)
	self.panel_type = type
	self.params = params
end

function ClsPanelPopView:getQueneType()
	local panel_quene_type = panel_quene_types[self.panel_type]
	return self:getDialogType().panel_quene_type
end

function ClsPanelPopView:excTask()
	local call_back = function()
		self:TaskEnd()
	end
	if not self.params then self.params = {} end
	self.params.call_back = call_back
	getUIManager():create(panel_tbl[self.panel_type], nil, self.params)
end

return ClsPanelPopView