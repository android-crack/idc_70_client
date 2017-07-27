----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[游弋AI，攻击时以与目标的切线方向行走。]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_youyi = class("ClsAISys_youyi", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_youyi:getId()
	return "sys_youyi";
end


-- AI时机
function ClsAISys_youyi:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISys_youyi:getPriority()
	return 904;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndSys_youyi(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 宿主与目标的距离
	local OTargetDistance = owner:getTargetDistance();
	-- 宿主的远程射程
	local OFarRange = owner:getFarRange();
	-- O目标距离>O远程攻击距离*0.6
	if ( not (OTargetDistance>OFarRange*0.6) ) then  return false end

	-- O目标距离<O远程攻击距离
	if ( not (OTargetDistance<OFarRange) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISys_youyi:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndSys_youyi(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {500, }, }, 
	{"stop_ai", "", {{"sys_dodge", }, }, }, 
	{"cruise", "", {}, }, 
}

function ClsAISys_youyi:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_youyi:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_youyi

----------------------- Auto Genrate End   --------------------
