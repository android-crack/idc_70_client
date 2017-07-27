----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move1_103 = class("ClsAIBat_move1_103", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move1_103:getId()
	return "bat_move1_103";
end


-- AI时机
function ClsAIBat_move1_103:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_move1_103:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_move1_103:getStopOtherFlg()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[嘿嘿，马上就好！]
local function bat_move1_103_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("嘿嘿，马上就好！")

	target_obj:say( name, word )

end

-- [备注]设置-[num2=num2+1]
local function bat_move1_103_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;

	-- 公式原文:num2=num2+1
	battleData:planningSetData("num2", num2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {226, 970, 50, }, }, 
	{"op", "", {bat_move1_103_act_1, }, }, 
	{"op", "", {bat_move1_103_act_2, }, }, 
	{"delete_ai", "", {{"bat_move1_103", }, }, }, 
}

function ClsAIBat_move1_103:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move1_103:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move1_103

----------------------- Auto Genrate End   --------------------
