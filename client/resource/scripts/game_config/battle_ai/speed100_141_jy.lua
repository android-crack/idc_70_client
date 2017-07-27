----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10+13]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed100_141_jy = class("ClsAISpeed100_141_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed100_141_jy:getId()
	return "speed100_141_jy";
end


-- AI时机
function ClsAISpeed100_141_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISpeed100_141_jy:getPriority()
	return 1;
end

-- AI停止标记
function ClsAISpeed100_141_jy:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==1
	if ( not (num1==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISpeed100_141_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[像你这么弱，还不够资格知道我是谁，回去练练吧！]
local function speed100_141_jy_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("像你这么弱，还不够资格知道我是谁，回去练练吧！")

	target_obj:say( name, word )

end

-- [备注]设置-[O阵营=1]
local function speed100_141_jy_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=1
	battleData:changeTeam(owner, 1 );

end

-- [备注]设置-[OAI变速=O速度]
local function speed100_141_jy_act_0( ai_obj, act_obj, target, delta_time )
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

-- [备注]说话-[有敌人来了，先撤退。]
local function speed100_141_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("有敌人来了，先撤退。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {speed100_141_jy_act_0, }, }, 
	{"op", "", {speed100_141_jy_act_1, }, }, 
	{"show_prompt", "", {T("追上敌方旗舰(触发近战攻击)。"), }, }, 
	{"move_to", "", {2500, 1200, 50, }, }, 
	{"op", "", {speed100_141_jy_act_4, }, }, 
	{"op", "", {speed100_141_jy_act_5, }, }, 
	{"delay", "", {1000, }, }, 
	{"play_plot", "", {{8, 9, }, }, }, 
	{"battle_stop", "", {0, }, }, 
}

function ClsAISpeed100_141_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed100_141_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed100_141_jy

----------------------- Auto Genrate End   --------------------
