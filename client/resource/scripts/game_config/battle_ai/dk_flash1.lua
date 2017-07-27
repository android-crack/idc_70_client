----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_flash1 = class("ClsAIDk_flash1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_flash1:getId()
	return "dk_flash1";
end


-- AI时机
function ClsAIDk_flash1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_flash1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_flash1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<80
	if ( not (OHpRate<80) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_flash1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_flash1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OX=2300;OY=640;说话=说话+1]
local function dk_flash1_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Say = battleData:GetData("__say") or 0;

	-- 公式原文:OX=2300
	owner:setPositionX( 2300 );
	-- 公式原文:OY=640
	owner:setPositionY( 640 );
	-- 公式原文:说话=说话+1
	battleData:planningSetData("__say", Say+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_0171", 0, 0, 3, false, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {dk_flash1_act_2, }, }, 
	{"delete_ai", "", {{"dk_flash1", }, }, }, 
}

function ClsAIDk_flash1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_flash1:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_flash1

----------------------- Auto Genrate End   --------------------
