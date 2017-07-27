----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_dead7 = class("ClsAIBat_152_dead7", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_dead7:getId()
	return "bat_152_dead7";
end


-- AI时机
function ClsAIBat_152_dead7:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_152_dead7:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead_7(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 海军死亡数>=7
	if ( not (DEAD>=7) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_152_dead7:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead_7(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetLeader( ai_obj, last_targets )
	local battleData = getGameData():getBattleDataMt()

	-- 目标选择范围
	local fanwei = "all";
	-- 目标排序方法
	local sort_key = "";
	local sort_asc = 1;
	-- 目标选择数量
	local select_cnt = 1;

	local tmp_targets = ai_obj:selectTargets(fanwei)

	local owner = ai_obj:getOwner()

	-- sort_method
	tmp_targets = battleData:sortShipsByKey(owner, tmp_targets, sort_key, sort_asc)

	-- 目标处于状态列表
	local lst_in_buff = {}
	-- 目标不处于状态列表
	local lst_no_in_buff = {}

	local func_condition = function(ai_obj, target_obj)
		for k, v in pairs(lst_in_buff) do
			if not target_obj:hasBuff(v) then return false end
		end

		for k, v in pairs(lst_no_in_buff) do
			if target_obj:hasBuff(v) then return false end
		end

		-- 如果是条件直接调用，如果是普通条件，解析

		-- 指战役ship表第一列的ID
		local TBaseID = target_obj:getBaseId();
		if not (TBaseID==2) then return false end

		return true
	end

	local tmp_cnt = 0
	local targets_result = {}
	for _, target in ipairs(tmp_targets) do
		local target_obj = battleData:getShipByGenID(target)
		if target == -2 then
			target_obj = battleData
		end
		if target_obj and func_condition(ai_obj, target_obj) then
			table.insert(targets_result, target)
			tmp_cnt = tmp_cnt + 1
			if tmp_cnt >= select_cnt then break end
		end
	end

	return targets_result
end


--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[我还有帮手，别得意]
local function bat_152_dead7_act_0( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[OAI变速=O速度]
local function bat_152_dead7_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=O速度
	owner:setAISpeed( OSpeed );

end

-- [备注]设置-[海军死亡数=0]
local function bat_152_dead7_act_6( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[事件标记=事件标记+1]
local function bat_152_dead7_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local EVE = battleData:GetData("__eve") or 0;

	-- 公式原文:事件标记=事件标记+1
	battleData:planningSetData("__eve", EVE+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", targetLeader, {bat_152_dead7_act_0, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"op", "", {bat_152_dead7_act_5, }, }, 
	{"op", "", {bat_152_dead7_act_6, }, }, 
	{"op", "", {bat_152_dead7_act_7, }, }, 
}

function ClsAIBat_152_dead7:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_dead7:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_dead7

----------------------- Auto Genrate End   --------------------
