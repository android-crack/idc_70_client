
-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowScene = class("ClsAIActionShowScene", ClsAIActionBase) 

function ClsAIActionShowScene:getId()
	return "show_scene"
end

function ClsAIActionShowScene:initAction()
end

function ClsAIActionShowScene:__dealAction( target_id, delta_time )
	local battle_data = getGameData():getBattleDataMt()
	local sprite = battle_data:GetData("black_layer")
	if not tolua.isnull(sprite) then
		sprite:removeFromParentAndCleanup(true)
		battle_data:SetData("black_layer", nil)
	end
end

return ClsAIActionShowScene
