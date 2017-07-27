----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_notes = class("ClsAIBat_172_notes", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_notes:getId()
	return "bat_172_notes";
end


-- AI时机
function ClsAIBat_172_notes:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_172_notes:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录防御=O防御*3;OAI防御=O防御*3;]
local function bat_172_notes_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主防御
	local ODefense = owner:getDefense();

	-- 公式原文:记录防御=O防御*3
	battleData:planningSetData("_def_notes", ODefense*3);
	-- 公式原文:OAI防御=O防御*3
	owner:setAIDefense( ODefense*3 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_172_notes_act_0, }, }, 
}

function ClsAIBat_172_notes:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_notes:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_notes

----------------------- Auto Genrate End   --------------------
