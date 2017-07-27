----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[吐槽1]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_say_1 = class("ClsAICity01_say_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_say_1:getId()
	return "city01_say_1";
end


-- AI时机
function ClsAICity01_say_1:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAICity01_say_1:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]4选1
local function cnd4xuan1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 记录随机数
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数<250
	if ( not (RandomCnt<250) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICity01_say_1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cnd4xuan1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[来啊，互相伤害啊]
local function city01_say_1_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("来啊，互相伤害啊")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {city01_say_1_act_0, }, }, 
}

function ClsAICity01_say_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_say_1:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_say_1

----------------------- Auto Genrate End   --------------------
