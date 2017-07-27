----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[刷新第二波]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISy_second_pve = class("ClsAISy_second_pve", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISy_second_pve:getId()
	return "sy_second_pve";
end


-- AI时机
function ClsAISy_second_pve:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISy_second_pve:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]刷第二波
local function cndDead5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local death = battleData:GetData("death") or 0;
	-- 死亡==5
	if ( not (death==5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISy_second_pve:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
}

function ClsAISy_second_pve:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISy_second_pve:getAllTargetMethod()
	return all_target_method
end

return ClsAISy_second_pve

----------------------- Auto Genrate End   --------------------
