
-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionHideScene = class("ClsAIActionHideScene", ClsAIActionBase) 

function ClsAIActionHideScene:getId()
	return "hide_scene"
end

function ClsAIActionHideScene:initAction()
end

function ClsAIActionHideScene:__dealAction( target_id, delta_time )
	local battle_data = getGameData():getBattleDataMt()
	local sprite = CCLayerColor:create(ccc4(0,0,0,255))
	GameUtil.getRunningScene():addChild(sprite, ZORDER_UI_LAYER - 1)
	battle_data:SetData("black_layer", sprite)
end

return ClsAIActionHideScene
