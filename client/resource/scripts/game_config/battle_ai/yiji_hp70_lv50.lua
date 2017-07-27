----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIYiji_hp70_lv50 = class("ClsAIYiji_hp70_lv50", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIYiji_hp70_lv50:getId()
	return "yiji_hp70_lv50";
end


-- AI时机
function ClsAIYiji_hp70_lv50:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIYiji_hp70_lv50:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless70(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=70
	if ( not (OHpRate<=70) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIYiji_hp70_lv50:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless70(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=O近攻*0.5]
local function yiji_hp70_lv50_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=O近攻*0.5
	owner:setAINearAtt( ONearAtt*0.5 );

end

-- [备注]设置-[OAI远攻=O远攻*0.5]
local function yiji_hp70_lv50_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=O远攻*0.5
	owner:setAIFarAtt( OFarAtt*0.5 );

end

-- [备注]说话-[挺能干的嘛，接下来我要动真格的了！]
local function yiji_hp70_lv50_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("挺能干的嘛，接下来我要动真格的了！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {yiji_hp70_lv50_act_1, }, }, 
	{"op", "", {yiji_hp70_lv50_act_2, }, }, 
	{"add_skill", "", {1126, 10, }, }, 
	{"op", "", {yiji_hp70_lv50_act_4, }, }, 
	{"delete_ai", "", {{"yiji_hp70_lv50", }, }, }, 
}

function ClsAIYiji_hp70_lv50:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIYiji_hp70_lv50:getAllTargetMethod()
	return all_target_method
end

return ClsAIYiji_hp70_lv50

----------------------- Auto Genrate End   --------------------
