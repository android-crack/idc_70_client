
-- [[
-- 所有AI的基类
-- 实现AI的基础元素
-- 1 AI的时机 Opportunity
-- 2 AI的条件 Condition
-- 3 AI的目标选择 Target
--   目标选择方法，不设定目标选取AI的owner
--   目标选择数量，默认目标数量为1
--   目标排序方式, 默认按照id顺序
-- 4 AI的
-- ]]
--
require("ui/tools/richlabel/pp")

local ClsAIBase = class("ClsAIBase");

-------------------------- 外部使用变量区域 ---------------------------
--DEFAULT_AI_DIR = "gameobj/battle/ai/"
DEFAULT_AI_DIR = "game_config/battle_ai/"
DEFAULT_AI_ACTION_DIR = "gameobj/battle/ai/action/"

SYS_CLEAR = "sys_clear"
SYS_USER_AUTOFIGHT = "sys_user_autofight"

-- AI执行时机
AI_OPPORTUNITY = {
	-- 显示战场前
	BEFORE_FIGHT_START = "before_fight_start",
	-- 进入战斗
	FIGHT_START = "fight_start",
	-- AI执行
	RUN = "ai_run",
	-- 策略
	TACTIC = "ai_tactic",
	-- 进入死亡
	DEATH = "death",
	-- 碰到
	CATCH = "catch",
	-- 被碰到
	BECATCH = "becatch",
	-- 血量变化
	HP_CHANGE = "hp_change",
    -- 受到攻击
	BE_HIT = "be_hit",
}

-- AI目标范围
AI_TARGET_TYPE = {
	SELF = "self",
	FRIEND = "friend",
	ENEMY = "enemy",
	OTHER = "other",
	TARGET = "target",
	ALL = "all",
	SCENE = "scene",
	PARTNER = "partner",
	-- 复用前一个Action的targets
	-- 用得时候过滤下目标是否在场
	LAST_TARGET = "last_target",
}

AI_OWNER_TYPE = {
    FIGHT_SHIP = 1,
    AUTO_TRADE = -1,
    SCENE = -2,
}

-- AI目标排序范围
AI_TARGET_SORT_METHOD = {
	ID_ASCE = 1,
	ID_DESC = 2,
	HP_RATE_ASCE = 3,
	HP_RATE_DESC = 4,
	-- 距离升序
	DIST_ASCE = 5,
	-- 距离降序
	DIST_DESC = 6,
}

AI_PRIORITY_MIN = 1
AI_PRIORITY_MAX = 999
AI_PRIORITY_DEFAULT = 500

-----------------------------------------------------------------------

function ClsAIBase:ctor(params, owner, type)
	-- AI参数，用来判定AI条件
	self.params =  params

    type = type or AI_OWNER_TYPE.FIGHT_SHIP
	self:setOwner( owner, type )

	-- 正在跑的action
	-- self.running_action = actionObj
	self.running_action = nil
	self.running_action_idx = 0

	-- AI数据
	self.data = {}
end

-- AI ID
function ClsAIBase:getId()
	return "ai_base"
end

-- getOpportunity返回AI执行的时机
function ClsAIBase:getOpportunity()
	return "nil"
end

-- 如果目标正在执行的AI优先级别高于本AI时，不能执行本AI
function ClsAIBase:getPriority()
	return AI_PRIORITY_DEFAULT
end

function ClsAIBase:getActions()
	return {}
end

function ClsAIBase:getAllTargetMethod()
	return {}
end

-- 返回true表示运行成功 返回false表示运行失败
function ClsAIBase:tryRun(opportunity)
	local thisOpportunity = self:getOpportunity()

	if opportunity ~= AI_OPPORTUNITY.RUN then
		if thisOpportunity ~= opportunity then return false end
	end

	-- 判断条件
	if not self:checkCondition() then return false end

	local owner = self:getOwner()
	if owner then
		local running_ai = owner.running_ai
		-- 自己正在运行，不能再次运行
		if running_ai[self:getId()] then return false end

		local myPriority = self:getPriority()

		for ai_id, ai_obj in pairs(running_ai) do
			local targetPriority = ai_obj:getPriority()

			-- 自己优先级别比正在运行的大,直接返回不执行
			if myPriority > targetPriority then return false end
		end

		-- 根据传入的参数中止
		if self.params.stop_other_flg or self:getStopOtherFlg() then
			for ai_id, ai_obj in pairs(running_ai) do
				local targetPriority = ai_obj:getPriority()

				-- 自己优先级别比正在运行的大,直接返回不执行
				if myPriority <= targetPriority then
					-- 如果同时机有比当前更小优先级别的AI正在运行
					--
					owner:completeAI(ai_obj)
				end
			end
		end

		-- 传入参数有删除标记或者AI本身有删除标记
		if self.params.delete_other_flg or self:getDeleteOtherFlg() then
			for ai_id, ai_obj in pairs(owner.new_ai) do
				local targetPriority = ai_obj:getPriority()

				if myPriority <= targetPriority and ai_obj:getId() ~= self:getId() then
					owner:deleteAI(ai_id)
				end
			end
		end
	end

	-- 运行AI Action
	-- TODO:运行Action
	-- 根据Action列表,取出第一个AIAction, 构建动作对象
	-- 交由AIHeartBeat去执行各个列表
	local torun_actions = self:getActions()

	--print("torun_actions:", #torun_actions )
	-- 没有动作啥也不做
	--if ( #torun_actions < 1) then return false end

	-- 给owner设上运行时AI
	owner:setRunningAI(self)

	self.last_targets = nil
	self:toRunAction(1)

	return true
end

function ClsAIBase:setOwner( owner, type )
	self.ownerID = owner:getId()
	self.ownerType = type
end

function ClsAIBase:getOwner(  )
	if self.ownerType == "explore_ship" then
		return getGameData():getExplorePlayerShipsData():getShipByUid(self.ownerID)
	end

	if ( self.ownerID == -1 ) then
		return getGameData():getAutoTradeAIHandler()
	end
	local battle_data = getGameData():getBattleDataMt()
    if ( self.ownerID == -2 ) then
        return battle_data
    end
	local ship = battle_data:getShipByGenID(self.ownerID)
	return ship
end

-- [[
-- 设置AI数据
-- ]]
function ClsAIBase:setData( key, value )
	self.data[key] =  value
end

-- [[
-- 获取AI数据
-- ]]
function ClsAIBase:getData( key )
	return self.data[key]
end

-- 选择目标
function ClsAIBase:selectTargets( targetType )
	if targetType == AI_TARGET_TYPE.SELF then
		local id = self:getOwner():getId()
		return {id,}
	end

    if targetType == AI_TARGET_TYPE.SCENE then return { -2, } end

	if targetType == AI_TARGET_TYPE.TARGET then
		local id = self:getOwner():getTargetId()
		return {id,}
	end

	local battleData = getGameData():getBattleDataMt()
	local owner_obj = self:getOwner()

	if targetType == AI_TARGET_TYPE.ENEMY then
		return battleData:getEnemyShipsId(owner_obj:getTeamId())
	end

	if targetType == AI_TARGET_TYPE.FRIEND then
		return battleData:getFriendShipsId(owner_obj)
	end

	if targetType == AI_TARGET_TYPE.ALL then
		return battleData:getAllShipsId(owner_obj)
	end

	if targetType == AI_TARGET_TYPE.PARTNER then
		return battleData:getPartnerShipsId(owner_obj)
	end

	-- 条件过滤
	print(T("ERROR:未知范围"), targetType)

	return {}
end

function ClsAIBase:__selectTargets(last_targets, target_method)
	if type(target_method) == "function" then
		return target_method(self, last_targets)
	end

    if (string.len(target_method) == 0) then
        target_method = AI_TARGET_TYPE.SELF
    end

	return self:selectTargets(target_method, 1, AI_TARGET_SORT_METHOD.ID_ASCE)
end

-- 开始跑一个Action
function ClsAIBase:toRunAction(idx)
	local torun_actions = self:getActions()

	if idx > #torun_actions then
		local ownerObj = self:getOwner()
		if ownerObj then
			ownerObj:completeAI(self)
		end
		return false
	end

	self.running_action_idx = idx

	local torun_action  = torun_actions[idx]

	local act_id, act_target_method, act_args = unpack(torun_action)

	local targets = self:__selectTargets( self.last_targets, act_target_method)

	self.last_targets = targets

	local ClsAct = require(string.format("%s%s", DEFAULT_AI_ACTION_DIR, act_id))
	local torun_act_obj = ClsAct.new(self, targets, unpack(act_args))

	self.running_action = torun_act_obj

	self:heartBeat(0)
	return true
end

-- AI的心跳
function ClsAIBase:heartBeat(dt)
	if self.running_action then
		-- 心跳
		self.running_action:heartBeat(dt)
	end

	if self.running_action then 
		local battle_data = getGameData():getBattleDataMt()

		local ownerObj = self:getOwner()
		if ownerObj and battle_data:GetBattleSwitch() then
			battle_data:setAiStepList(ownerObj:getId(), self:getId(), self.running_action_idx)
		end
		return 
	end

	self:toRunAction(self.running_action_idx + 1)
end

function ClsAIBase:completeAction(running_action)
	if running_action ~= self.running_action then
		return
	end

	self.running_action = nil
end

-- 判断条件
function ClsAIBase:checkCondition()
	return true
end

--------------------------  AI辅助函数开始 ------------------------------
-- AI中重置随机数
function ClsAIBase:resetRandom()
	local rnd = math.random(1, 1000)

	self:setData("__random", rnd)
	return rnd
end

function ClsAIBase:getRandom()
	return self:getData("__random")
end

function ClsAIBase:targetCnt(targetMethod, last_targets)
	local allTargetMethod = self:getAllTargetMethod()

	local method = allTargetMethod[targetMethod]
	if not method then return 0 end

	local result = method(self, last_targets)

	return #result
end
--------------------------  AI辅助函数结束 ------------------------------

function ClsAIBase:getStopOtherFlg()
	return false
end

function ClsAIBase:getDeleteOtherFlg()
	return false
end

function ClsAIBase:getRunningAction()
	return self.running_action
end

return ClsAIBase
