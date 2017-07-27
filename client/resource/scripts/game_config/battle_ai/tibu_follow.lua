----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[设置追随目标]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITibu_follow = class("ClsAITibu_follow", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITibu_follow:getId()
	return "tibu_follow";
end


-- AI时机
function ClsAITibu_follow:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITibu_follow:getPriority()
	return 1;
end

-- AI停止标记
function ClsAITibu_follow:getStopOtherFlg()
	return 1;
end

-- AI删除标记
function ClsAITibu_follow:getDeleteOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0;O无视船只碰撞=否]
local function tibu_follow_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=0
	owner:setAISpeed( 0 );
	-- 公式原文:O无视船只碰撞=否
	owner:setIgnorCollision( false );

end

-- [备注]设置-[追随目标=O旗舰;O无视船只碰撞=是;OAI变速=200]
local function tibu_follow_act_0( ai_obj, act_obj, target, delta_time )
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
	-- 公式原文:O无视船只碰撞=是
	owner:setIgnorCollision( true );
	-- 公式原文:OAI变速=200
	owner:setAISpeed( 200 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {tibu_follow_act_0, }, }, 
	{"follow", "", {400, }, }, 
	{"op", "", {tibu_follow_act_2, }, }, 
	{"system_tip", "", {T("替补船只加入战斗!"), }, }, 
	{"stop_ai", "", {{"tibu_follow", }, }, }, 
	{"delete_ai", "", {{"tibu_follow", }, }, }, 
	{"run_ai", "", {{"sys_user_autofight", }, }, }, 
}

function ClsAITibu_follow:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITibu_follow:getAllTargetMethod()
	return all_target_method
end

return ClsAITibu_follow

----------------------- Auto Genrate End   --------------------
