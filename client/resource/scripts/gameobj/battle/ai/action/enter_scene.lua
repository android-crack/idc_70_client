local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionEnterScene = class("ClsAIActionEnterScene", ClsAIActionBase) 

function ClsAIActionEnterScene:getId()
	return "enter_scene"
end

function ClsAIActionEnterScene:initAction(base_id, is_prop, is_radar_hide, is_leader, dir, boat_trans_star)
	self.base_id = base_id
	self.is_prop = is_prop or 0
	self.is_radar_hide = is_radar_hide or 0
	self.is_leader = is_leader or 0
	self.dir = dir or 7  -- 向左
	self.boat_trans_star = boat_trans_star or 1
end

function ClsAIActionEnterScene:__dealAction(target_id, delta_time)
	local battleRecording = require("gameobj/battle/battleRecording")
	battleRecording:recordVarArgs("battle_enter_scene", self.base_id, self.is_prop, self.is_radar_hide, self.is_leader, 
		self.dir, self.boat_trans_star)
end

return ClsAIActionEnterScene
