----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIPve15_say1 = class("ClsAIPve15_say1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIPve15_say1:getId()
	return "pve15_say1";
end


-- AI时机
function ClsAIPve15_say1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIPve15_say1:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[被财宝诱惑的凡人，一起下地狱吧！哈哈！]
local function pve15_say1_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("被财宝诱惑的凡人，一起下地狱吧！哈哈！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {pve15_say1_act_0, }, }, 
	{"delete_ai", "", {{"pve15_say1", }, }, }, 
}

function ClsAIPve15_say1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIPve15_say1:getAllTargetMethod()
	return all_target_method
end

return ClsAIPve15_say1

----------------------- Auto Genrate End   --------------------
