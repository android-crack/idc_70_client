----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDlk_ready_boom = class("ClsAIDlk_ready_boom", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDlk_ready_boom:getId()
	return "dlk_ready_boom";
end


-- AI时机
function ClsAIDlk_ready_boom:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDlk_ready_boom:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<50
	if ( not (OHpRate<50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDlk_ready_boom:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetEnemy( ai_obj, last_targets )
	local battleData = getGameData():getBattleDataMt()

	-- 目标选择范围
	local fanwei = "enemy";
	-- 目标排序方法
	local sort_key = "";
	local sort_asc = 1;
	-- 目标选择数量
	local select_cnt = 999;

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

		-- 目标与宿主的距离
		local Tdistance = GetDistanceFor3D(owner.body.node, target_obj.body.node);
		if not (Tdistance<200) then return false end

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


-- [备注]
local function targetBoss( ai_obj, last_targets )
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

		-- 目标与宿主的距离
		local Tdistance = GetDistanceFor3D(owner.body.node, target_obj.body.node);
		if not (Tdistance<200) then return false end

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

-- [备注]设置-[T耐久=T耐久-0.4*T耐久上限]
local function dlk_ready_boom_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- T耐久
	local THp = target_obj:getHp();
	-- T耐久上限
	local THpMax = target_obj:getMaxHp();

	-- 公式原文:T耐久=T耐久-0.4*T耐久上限
	target_obj:AIsetHp( THp-0.4*THpMax );

end

-- [备注]设置-[num1=num1+1]
local function dlk_ready_boom_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1+1
	battleData:planningSetData("num1", num1+1);

end

-- [备注]设置-[O耐久=0]
local function dlk_ready_boom_act_11( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O耐久=0
	owner:AIsetHp( 0 );

end

-- [备注]设置-[OAI变速=-10000]
local function dlk_ready_boom_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-10000
	owner:setAISpeed( -10000 );

end

-- [备注]设置-[T耐久=T耐久-0.2*T耐久上限]
local function dlk_ready_boom_act_8( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- T耐久
	local THp = target_obj:getHp();
	-- T耐久上限
	local THpMax = target_obj:getMaxHp();

	-- 公式原文:T耐久=T耐久-0.2*T耐久上限
	target_obj:AIsetHp( THp-0.2*THpMax );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"del_skill", "", {1214, }, }, 
	{"op", "", {dlk_ready_boom_act_1, }, }, 
	{"add_status", "", {"unspeedable", }, }, 
	{"add_effect_to_ship", "", {1, "tx_zhaohuo_3", 0, 0, 150, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_skill_drop_red", 0, 0, 3, false, }, }, 
	{"op", "", {dlk_ready_boom_act_5, }, }, 
	{"delay", "", {2000, }, }, 
	{"op", targetEnemy, {dlk_ready_boom_act_7, }, }, 
	{"op", targetBoss, {dlk_ready_boom_act_8, }, }, 
	{"add_effect_to_ship", "", {2, "tx_judian_boom", 0, 0, 3, true, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {dlk_ready_boom_act_11, }, }, 
	{"delete_ai", "", {{"dlk_ready_boom", }, }, }, 
}

function ClsAIDlk_ready_boom:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDlk_ready_boom:getAllTargetMethod()
	return all_target_method
end

return ClsAIDlk_ready_boom

----------------------- Auto Genrate End   --------------------