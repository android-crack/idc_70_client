----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[闪现时说话设置暴风雨]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_say = class("ClsAIDk_say", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_say:getId()
	return "dk_say";
end


-- AI时机
function ClsAIDk_say:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_say:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_say(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Say = battleData:GetData("__say") or 0;
	-- 说话>1
	if ( not (Say>1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_say:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_say(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[怎么回事？这些船突然消失了出现在后方。]
local function dk_say_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("怎么回事？这些船突然消失了出现在后方。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {dk_say_act_0, }, }, 
	{"forge_weather", "", {150, }, }, 
	{"delete_ai", "", {{"dk_say", }, }, }, 
}

function ClsAIDk_say:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_say:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_say

----------------------- Auto Genrate End   --------------------
