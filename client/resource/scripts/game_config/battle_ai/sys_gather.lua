----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[设置追随目标]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_gather = class("ClsAISys_gather", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_gather:getId()
	return "sys_gather";
end


-- AI时机
function ClsAISys_gather:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISys_gather:getPriority()
	return 56;
end

-- AI停止标记
function ClsAISys_gather:getStopOtherFlg()
	return 56;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录数量=记录数量+1]
local function sys_gather_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local __Record_Num__ = battleData:GetData("__record_num__") or 0;

	-- 公式原文:记录数量=记录数量+1
	battleData:planningSetData("__record_num__", __Record_Num__+1);

end

-- [备注]设置-[追随目标=O旗舰;]
local function sys_gather_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主旗舰
	local OLeaderId = owner:getLeaderId();

	-- 公式原文:追随目标=O旗舰
	ai_obj:setData( "__follow_target_id", OLeaderId );

end

-- [备注]说话不同步-[,收到指令,准备集合！]
local function sys_gather_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("收到指令,准备集合！")

	target_obj:say( name, word, true )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {sys_gather_act_0, }, }, 
	{"op", "", {sys_gather_act_1, }, }, 
	{"follow", "", {125, }, }, 
	{"op", "", {sys_gather_act_3, }, }, 
	{"add_ai", "", {{"sys_gather_2", }, }, }, 
	{"delete_ai", "", {{"sys_gather", }, }, }, 
}

function ClsAISys_gather:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_gather:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_gather

----------------------- Auto Genrate End   --------------------
