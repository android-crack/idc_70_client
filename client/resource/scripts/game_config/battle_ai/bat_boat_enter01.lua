----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[船只死亡5只或离场达到5只，重新进场一批]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boat_enter01 = class("ClsAIBat_boat_enter01", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boat_enter01:getId()
	return "bat_boat_enter01";
end


-- AI时机
function ClsAIBat_boat_enter01:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_boat_enter01:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]海盗数量大于5时，召唤另一批海盗
local function cndNumber5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;
	-- 离场数量==5
	if ( not (PirateLeaveCnt==5) ) then  return false end

	-- 计数2
	local NUM2 = battleData:GetData("num2") or 0;
	-- 召唤==0
	if ( not (NUM2==0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_boat_enter01:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNumber5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[召唤=1]
local function bat_boat_enter01_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:召唤=1
	battleData:planningSetData("num2", 1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {2, }, }, 
	{"enter_scene", "", {3, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"op", "", {bat_boat_enter01_act_5, }, }, 
}

function ClsAIBat_boat_enter01:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boat_enter01:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boat_enter01

----------------------- Auto Genrate End   --------------------
