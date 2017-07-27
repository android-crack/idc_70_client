----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[根据自己旗舰目标来攻击]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIFlt_2 = class("ClsAIFlt_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIFlt_2:getId()
	return "flt_2";
end


-- AI时机
function ClsAIFlt_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIFlt_2:getPriority()
	return 805;
end

-- AI停止标记
function ClsAIFlt_2:getStopOtherFlg()
	return 805;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTarget_change(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 控制船的目标
	local OControlShipTargetID = owner:getControlShipTargetID();
	-- 宿主目标
	local OTargetId = owner:getTargetId();
	-- 宿主与目标的距离
	local OTargetDistance = owner:getTargetDistance();
	-- 宿主的远程射程
	local OFarRange = owner:getFarRange();
	-- O控制船的目标~=O目标 or O目标距离>=O远程攻击距离
	if ( not (OControlShipTargetID~=OTargetId or OTargetDistance>=OFarRange) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIFlt_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTarget_change(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"flt_2_real", }, }, }, 
}

function ClsAIFlt_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIFlt_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIFlt_2

----------------------- Auto Genrate End   --------------------
