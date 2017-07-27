----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_goto_3_151 = class("ClsAIBat_goto_3_151", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_goto_3_151:getId()
	return "bat_goto_3_151";
end


-- AI时机
function ClsAIBat_goto_3_151:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_goto_3_151:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_goto_3_151:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[位置3=位置3+1]
local function bat_goto_3_151_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local SIT3 = battleData:GetData("__sit_3") or 0;

	-- 公式原文:位置3=位置3+1
	battleData:planningSetData("__sit_3", SIT3+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {10, 900, 50, }, }, 
	{"op", "", {bat_goto_3_151_act_1, }, }, 
	{"run_ai", "", {{"bat_end_3_151", }, }, }, 
	{"delete_ai", "", {{"bat_goto_3_151", }, }, }, 
}

function ClsAIBat_goto_3_151:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_goto_3_151:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_goto_3_151

----------------------- Auto Genrate End   --------------------
