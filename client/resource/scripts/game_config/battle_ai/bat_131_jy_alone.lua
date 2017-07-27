----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[24]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_131_jy_alone = class("ClsAIBat_131_jy_alone", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_131_jy_alone:getId()
	return "bat_131_jy_alone";
end


-- AI时机
function ClsAIBat_131_jy_alone:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_131_jy_alone:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[什么情况？其他人呢？不是说好等我的吗！]
local function bat_131_jy_alone_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("什么情况？其他人呢？不是说好等我的吗！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {2, "tx_tujin_jiasu", 0, 0, 120, false, }, }, 
	{"delay", "", {3000, }, }, 
	{"op", "", {bat_131_jy_alone_act_2, }, }, 
}

function ClsAIBat_131_jy_alone:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_131_jy_alone:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_131_jy_alone

----------------------- Auto Genrate End   --------------------
