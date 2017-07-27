----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[13]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_angry_81 = class("ClsAIBat_angry_81", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_angry_81:getId()
	return "bat_angry_81";
end


-- AI时机
function ClsAIBat_angry_81:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_angry_81:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless100(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<100
	if ( not (OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_angry_81:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num1=num1+1]
local function bat_angry_81_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1+1
	battleData:planningSetData("num1", num1+1);

end

-- [备注]说话-[不能放过这些多管闲事的，干掉他们！]
local function bat_angry_81_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("不能放过这些多管闲事的，干掉他们！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_angry_81_act_0, }, }, 
	{"stop_ai", "", {{"bat_move2_81", }, }, }, 
	{"delete_ai", "", {{"bat_move2_81", }, }, }, 
	{"op", "", {bat_angry_81_act_3, }, }, 
	{"delete_ai", "", {{"bat_angry_81", }, }, }, 
}

function ClsAIBat_angry_81:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_angry_81:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_angry_81

----------------------- Auto Genrate End   --------------------
