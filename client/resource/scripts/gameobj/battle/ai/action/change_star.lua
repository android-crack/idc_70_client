
-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionChangeStar = class("ClsAIActionChangeStar", ClsAIActionBase) 

function ClsAIActionChangeStar:getId()
	return "change_star"
end

-- 
function ClsAIActionChangeStar:initAction( star_val )
	self.star_val = star_val
end

function ClsAIActionChangeStar:__dealAction( target_id, delta_time )
	local battleData = getGameData():getBattleDataMt()
	local extdata = battleData:GetExtData()
	if not tolua.isnull(battleData:GetLayer("battle_ui")) and extdata["must_star"] and
		(not extdata["star_mark"] or (extdata["star_mark"] and not extdata["star_mark"][self.star_val])) then

		battleData:GetLayer("battle_ui"):subStar(self.star_val)
		extdata["must_star"] = extdata["must_star"] - 1

		if not extdata["star_mark"] then
			extdata["star_mark"] = {}
		end
		extdata["star_mark"][self.star_val] = true
	end
end

return ClsAIActionChangeStar
