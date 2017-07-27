----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed100_94 = class("ClsAISpeed100_94", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed100_94:getId()
	return "speed100_94";
end


-- AI时机
function ClsAISpeed100_94:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISpeed100_94:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndPhase2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local num1 = battleData:GetData("num1") or 0;
	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- num1==6 or O耐久百分比<100
	if ( not (num1==6 or OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISpeed100_94:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndPhase2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=20]
local function speed100_94_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=20
	owner:setAISpeed( 20 );

end

-- [备注]说话-[双子星，与我一同碾碎这群废物！]
local function speed100_94_act_6( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("双子星，与我一同碾碎这群废物！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"speed0_94", }, }, }, 
	{"op", "", {speed100_94_act_1, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"enter_scene", "", {16, 0, 0, 1, 7, 0, }, }, 
	{"enter_scene", "", {17, 0, 0, 1, 7, 0, }, }, 
	{"play_plot", "", {{4, 8, }, }, }, 
	{"op", "", {speed100_94_act_6, }, }, 
	{"delete_ai", "", {{"speed100_94", }, }, }, 
}

function ClsAISpeed100_94:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed100_94:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed100_94

----------------------- Auto Genrate End   --------------------
