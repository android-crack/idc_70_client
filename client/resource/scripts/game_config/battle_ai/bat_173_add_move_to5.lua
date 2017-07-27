----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_add_move_to5 = class("ClsAIBat_173_add_move_to5", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_add_move_to5:getId()
	return "bat_173_add_move_to5";
end


-- AI时机
function ClsAIBat_173_add_move_to5:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_173_add_move_to5:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_173_add_move_to5:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function bat_173_add_move_to5_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {2180, 293, 50, }, }, 
	{"op", "", {bat_173_add_move_to5_act_1, }, }, 
}

function ClsAIBat_173_add_move_to5:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_add_move_to5:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_add_move_to5

----------------------- Auto Genrate End   --------------------
