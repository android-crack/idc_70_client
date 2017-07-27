local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionBattleStop = class("ClsAIActionBattleStop", ClsAIActionBase) 

local battlePlot = require("gameobj/battle/battlePlot")

function ClsAIActionBattleStop:getId()
	return "battle_stop"
end

-- 
function ClsAIActionBattleStop:initAction( is_win )
	self.is_win = false
	if is_win ~= nil and is_win ~= 0 then
		self.is_win = true
	end
end

function ClsAIActionBattleStop:__dealAction( target_id, delta_time )
	local win = battle_config.our_win
	if not self.is_win then
		win = battle_config.our_lose
	end

	print("===========================================AI 决定胜负", win == battle_config.our_win)

	require("gameobj/battle/battleRecording"):recordVarArgs("set_win_side", win)
end

return ClsAIActionBattleStop
