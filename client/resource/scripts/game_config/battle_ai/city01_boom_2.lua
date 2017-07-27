----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[爆破宣言2]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_boom_2 = class("ClsAICity01_boom_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_boom_2:getId()
	return "city01_boom_2";
end


-- AI时机
function ClsAICity01_boom_2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAICity01_boom_2:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]4选2
local function cnd4xuan2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 记录随机数
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数>=250
	if ( not (RandomCnt>=250) ) then  return false end

	-- 记录随机数<500
	if ( not (RandomCnt<500) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICity01_boom_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cnd4xuan2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[兄弟们，跟我冲啊！]
local function city01_boom_2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("兄弟们，跟我冲啊！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {city01_boom_2_act_0, }, }, 
	{"add_skill", "", {1213, 1, }, }, 
}

function ClsAICity01_boom_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_boom_2:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_boom_2

----------------------- Auto Genrate End   --------------------
