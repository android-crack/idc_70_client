----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_die4 = class("ClsAIBat_152_die4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_die4:getId()
	return "bat_152_die4";
end


-- AI时机
function ClsAIBat_152_die4:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_152_die4:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead_4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 海军死亡数>=4
	if ( not (DEAD>=4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_152_die4:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead_4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[海军死亡数=0]
local function bat_152_die4_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:海军死亡数=0
	battleData:planningSetData("__dead", 0);

end

-- [备注]说话-[我还有帮手，别得意]
local function bat_152_die4_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("我还有帮手，别得意")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_152_die4_act_0, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"op", "", {bat_152_die4_act_5, }, }, 
}

function ClsAIBat_152_die4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_die4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_die4

----------------------- Auto Genrate End   --------------------
