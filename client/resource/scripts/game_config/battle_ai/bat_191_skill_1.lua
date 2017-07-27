----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_skill_1 = class("ClsAIBat_191_skill_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_skill_1:getId()
	return "bat_191_skill_1";
end


-- AI时机
function ClsAIBat_191_skill_1:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_191_skill_1:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O无视船只碰撞=是]
local function bat_191_skill_1_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O无视船只碰撞=是
	owner:setIgnorCollision( true );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1004, 5, }, }, 
	{"op", "", {bat_191_skill_1_act_1, }, }, 
	{"add_skill", "", {1042, 5, "passive", }, }, 
}

function ClsAIBat_191_skill_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_skill_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_skill_1

----------------------- Auto Genrate End   --------------------
