----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_72_change_team_2 = class("ClsAIBat_72_change_team_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_72_change_team_2:getId()
	return "bat_72_change_team_2";
end


-- AI时机
function ClsAIBat_72_change_team_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_72_change_team_2:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_72_change_team_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Death_Cnt_2 = battleData:GetData("_death_cnt_2") or 0;
	-- 敌人2死亡>=1
	if ( not (Death_Cnt_2>=1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_72_change_team_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_72_change_team_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[自由了！自由了！]
local function bat_72_change_team_2_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("自由了！自由了！")

	target_obj:say( name, word )

end

-- [备注]设置-[O阵营=1]
local function bat_72_change_team_2_act_0( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_72_change_team_2_act_0, }, }, 
	{"op", "", {bat_72_change_team_2_act_1, }, }, 
	{"add_ai", "", {{"bat_72_leave_2", }, }, }, 
}

function ClsAIBat_72_change_team_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_72_change_team_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_72_change_team_2

----------------------- Auto Genrate End   --------------------
