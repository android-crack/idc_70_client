-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionSailorBattle = class("ClsAIActionSailorBattle", ClsAIActionBase) 

function ClsAIActionSailorBattle:getId()
	return "sailor_battle"
end

-- 
function ClsAIActionSailorBattle:initAction()

end

function ClsAIActionSailorBattle:__dealAction( target_id, delta_time )
	local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		fight_ui:sailorbattle()
	end
end

return ClsAIActionSailorBattle
