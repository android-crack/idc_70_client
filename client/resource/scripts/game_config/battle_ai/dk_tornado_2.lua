----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_tornado_2 = class("ClsAIDk_tornado_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_tornado_2:getId()
	return "dk_tornado_2";
end


-- AI时机
function ClsAIDk_tornado_2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIDk_tornado_2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_tornado_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数<500
	if ( not (RandomCnt<500) ) then  return false end

	-- 记录随机数>= 250
	if ( not (RandomCnt>= 250) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_tornado_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_tornado_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OX=1920;OY=640;]
local function dk_tornado_2_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OX=1920
	owner:setPositionX( 1920 );
	-- 公式原文:OY=640
	owner:setPositionY( 640 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {4, "sf_tujin", 0, 0, 1, false, }, }, 
	{"op", "", {dk_tornado_2_act_1, }, }, 
}

function ClsAIDk_tornado_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_tornado_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_tornado_2

----------------------- Auto Genrate End   --------------------
