----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_201_time = class("ClsAIBat_201_time", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_201_time:getId()
	return "bat_201_time";
end


-- AI时机
function ClsAIBat_201_time:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_201_time:getPriority()
	return 10;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[时间=时间+1]
local function bat_201_time_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIME = battleData:GetData("__time") or 0;

	-- 公式原文:时间=时间+1
	battleData:planningSetData("__time", TIME+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {1000, }, }, 
	{"op", "", {bat_201_time_act_1, }, }, 
}

function ClsAIBat_201_time:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_201_time:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_201_time

----------------------- Auto Genrate End   --------------------
