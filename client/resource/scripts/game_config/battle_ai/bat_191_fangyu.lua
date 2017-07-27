----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_fangyu = class("ClsAIBat_191_fangyu", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_fangyu:getId()
	return "bat_191_fangyu";
end


-- AI时机
function ClsAIBat_191_fangyu:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_fangyu:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI防御=10000*次数]
local function bat_191_fangyu_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIMES = battleData:GetData("__times") or 0;

	-- 公式原文:OAI防御=10000*次数
	owner:setAIDefense( 10000*TIMES );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_191_fangyu_act_0, }, }, 
}

function ClsAIBat_191_fangyu:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_fangyu:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_fangyu

----------------------- Auto Genrate End   --------------------
