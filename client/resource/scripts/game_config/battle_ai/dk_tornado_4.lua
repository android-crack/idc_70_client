----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_tornado_4 = class("ClsAIDk_tornado_4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_tornado_4:getId()
	return "dk_tornado_4";
end


-- AI时机
function ClsAIDk_tornado_4:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIDk_tornado_4:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_tornado_4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数<1000
	if ( not (RandomCnt<1000) ) then  return false end

	-- 记录随机数>= 750
	if ( not (RandomCnt>= 750) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_tornado_4:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_tornado_4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OX=1280;OY=960;]
local function dk_tornado_4_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OX=1280
	owner:setPositionX( 1280 );
	-- 公式原文:OY=960
	owner:setPositionY( 960 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {6, "sf_tujin", 0, 0, 1, false, }, }, 
	{"op", "", {dk_tornado_4_act_1, }, }, 
}

function ClsAIDk_tornado_4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_tornado_4:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_tornado_4

----------------------- Auto Genrate End   --------------------
