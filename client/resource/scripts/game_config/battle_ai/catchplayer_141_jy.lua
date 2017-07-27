----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[15]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICatchplayer_141_jy = class("ClsAICatchplayer_141_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICatchplayer_141_jy:getId()
	return "catchplayer_141_jy";
end


-- AI时机
function ClsAICatchplayer_141_jy:getOpportunity()
	return AI_OPPORTUNITY.CATCH;
end

-- AI优先级别
function ClsAICatchplayer_141_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndCatchcntis1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 远程内目标数量
	local catchcnt = ai_obj:targetCnt("player");
	-- catchcnt==1
	if ( not (catchcnt==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICatchplayer_141_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndCatchcntis1(self, nil )
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


--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[既然你这么坚持，就别怪我了]
local function catchplayer_141_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("既然你这么坚持，就别怪我了")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delete_ai", "", {{"speed100_141_jy", }, }, }, 
	{"op", "", {catchplayer_141_jy_act_1, }, }, 
	{"show_prompt", "", {T("把敌方旗舰血量削减到50%以下"), }, }, 
	{"delete_ai", "", {{"catchplayer_141_jy", }, }, }, 
}

function ClsAICatchplayer_141_jy:getActions()
	return actions
end

local all_target_method = {
	["player"]=targetPlayer, 
}

function ClsAICatchplayer_141_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAICatchplayer_141_jy

----------------------- Auto Genrate End   --------------------
