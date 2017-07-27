----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_201_enter5 = class("ClsAIBat_201_enter5", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_201_enter5:getId()
	return "bat_201_enter5";
end


-- AI时机
function ClsAIBat_201_enter5:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_201_enter5:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndEnter_5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 死亡数量==4
	if ( not (DEAD==4) ) then  return false end

	-- 战场测试变量
	local TIMES = battleData:GetData("__times") or 0;
	-- 次数==1
	if ( not (TIMES==1) ) then  return false end

	-- 战场测试变量
	local TIME = battleData:GetData("__time") or 0;
	-- 时间<20
	if ( not (TIME<20) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_201_enter5:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnter_5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetPlayer( ai_obj, last_targets )
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

		-- T玩家标记
		local TIsPlayer = target_obj:is_player();
		if not (TIsPlayer) then return false end

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

-- [备注]说话-[别得意，还没完！]
local function bat_201_enter5_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("别得意，还没完！")

	target_obj:say( name, word )

end

-- [备注]设置-[死亡数量=死亡数量-4]
local function bat_201_enter5_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;

	-- 公式原文:死亡数量=死亡数量-4
	battleData:planningSetData("__dead", DEAD-4);

end

-- [备注]设置-[时间=时间-20]
local function bat_201_enter5_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIME = battleData:GetData("__time") or 0;

	-- 公式原文:时间=时间-20
	battleData:planningSetData("__time", TIME-20);

end

-- [备注]说话-[小心，又有新的敌人！]
local function bat_201_enter5_act_8( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("小心，又有新的敌人！")

	target_obj:say( name, word )

end

-- [备注]设置-[次数=次数+1]
local function bat_201_enter5_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIMES = battleData:GetData("__times") or 0;

	-- 公式原文:次数=次数+1
	battleData:planningSetData("__times", TIMES+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_201_enter5_act_0, }, }, 
	{"op", "", {bat_201_enter5_act_1, }, }, 
	{"op", "", {bat_201_enter5_act_2, }, }, 
	{"enter_scene", "", {11, }, }, 
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"enter_scene", "", {14, }, }, 
	{"op", "ship6", {bat_201_enter5_act_7, }, }, 
	{"op", targetPlayer, {bat_201_enter5_act_8, }, }, 
	{"delete_ai", "", {{"bat_201_enter5", }, }, }, 
}

function ClsAIBat_201_enter5:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_201_enter5:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_201_enter5

----------------------- Auto Genrate End   --------------------
