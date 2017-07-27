-- 显示杀人榜
-- Author: Ltian
-- Date: 2016-08-15 10:55:11
--

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowKillRank = class("ClsAIActionShowKillRank", ClsAIActionBase) 

function ClsAIActionShowKillRank:getId()
	return "show_kill_rank"
end

 
function ClsAIActionShowKillRank:initAction()
	
end

function ClsAIActionShowKillRank:__dealAction( target, delta_time )
	local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		fight_ui:showKillRankUI()
	end
end

return ClsAIActionShowKillRank