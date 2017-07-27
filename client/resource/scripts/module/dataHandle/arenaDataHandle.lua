local ui_word = require("game_config/ui_word")
local arena_stage = require("game_config/arena/arena_stage")
local Alert = require("ui/tools/alert")

local FIGHT_MAX_NUM = 9
local FAIL_MAX_NUM = 3

local ClsArenaDataHandler = class("ClsArenaDataHandler")
function ClsArenaDataHandler:ctor()
	self.arena_info = nil         --玩家竞技场信息
	self.match_info = nil         --匹配对手信息
	self.cur_stage_info = nil     --当前段位信息
	self.reward_stage_info = nil  --奖励段位信息
	self.fighter_info = nil       --对手(包括搜索和上次失败的)
	self.latest_stage_grade = nil --最近一次记录的段位分数
	self.stage_up_rewards = nil  --段位奖励
	self.stage_up_id = nil
	self.target_info = nil        --用于查看船长信息时使用
	self.legend_info = {}
	self.change_info = {}
end

function ClsArenaDataHandler:setLegendChangePlayerInfo(change_info)
	self.change_info = change_info
end

function ClsArenaDataHandler:getLegendChangePlayerInfo()
	return self.change_info
end

function ClsArenaDataHandler:setLegendPlayerInfo(info)
	self.legend_info = info
	table.sort(self.legend_info.ranks, function(a, b)
		return a.index < b.index
	end)
end

function ClsArenaDataHandler:getLegendPlayerInfo()
	return self.legend_info
end

function ClsArenaDataHandler:setTargetInfo(info)
	self.target_info = info
	getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, info.role_info.uid, info)
end

function ClsArenaDataHandler:setStageUpReward(stage_id, rewards)
	self.stage_up_id = stage_id
	self.stage_up_rewards = rewards
	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if not tolua.isnull(arena_ui) then
		getUIManager():create("gameobj/arena/clsArenaUpRewardUI", nil, {stage_id = stage_id, rewards = rewards})
		self.stage_up_rewards = nil
		self.stage_up_id = nil
	end
end

function ClsArenaDataHandler:setArenaInfo(info)
	--当前需求最大的积分值
	if info.stage_exp > 9998 then
		info.stage_exp = 9998
	end

	self.arena_info = info
	self:setCurStageInfo()
	self:setRewardStageInfo()

	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if tolua.isnull(arena_ui) then return end
	arena_ui:tryShowCommonUI()
	arena_ui:updateView(info)

	if self:isOver() then
		local reason = self:getOverReason()
		if reason == ARENA_WIN_END then

		else
			arena_ui:showFailView()
		end
	else
		self.fighter_info = info.target
		arena_ui:showMatchInfo(info.target, false)
		if info.target.uid ~= 0 and info.target_reset_count > 0 then
			arena_ui:setResetBtnVisible(true)
		end
	end

	if self.stage_up_rewards then
		getUIManager():create("gameobj/arena/clsArenaUpRewardUI", nil, {stage_id = self.stage_up_id, rewards = self.stage_up_rewards})
		self.stage_up_rewards = nil
		self.stage_up_id = nil
	end
end

function ClsArenaDataHandler:isHaveTarget()
	if self.fighter_info then
		if self.fighter_info.uid ~= 0 then
			return true
		end
	else
		return false
	end
end

function ClsArenaDataHandler:isOver()
	if self.arena_info.fighted_count == FIGHT_MAX_NUM then
		return true
	end

	if self.arena_info.target.fails == FAIL_MAX_NUM then
		return true
	end

	return false
end

function ClsArenaDataHandler:getOverReason()
	if self.arena_info.fighted_count == FIGHT_MAX_NUM then
		return ARENA_WIN_END
	end

	if self.arena_info.target.fails == FAIL_MAX_NUM then
		return ARENA_FAIL_END
	end
end

function ClsArenaDataHandler:getArenaInfo()
	return self.arena_info
end

--当前段位的信息
function ClsArenaDataHandler:setCurStageInfo()
	local cur_exp = self.arena_info.stage_exp
	local cur_info = {}
	for k, v in ipairs(arena_stage) do
		if v.exp >= cur_exp then
			local pos = nil
			if v.exp > cur_exp then
				pos = k - 1
			else
				pos = k
			end
			local cur_stage = arena_stage[pos]
			for g, h in pairs(cur_stage) do
				cur_info[g] = h
			end
			cur_info.index = pos
			self.cur_stage_info = cur_info
			return
		end
	end
end

function ClsArenaDataHandler:setRewardStageInfo()
	local reward_stage_id = self.arena_info.reward_stage_id
	for k, v in ipairs(arena_stage) do
		if k == reward_stage_id then
			self.reward_stage_info = v
		end
	end	
end

function ClsArenaDataHandler:getRewardStageInfo(  )
	return self.reward_stage_info
end

function ClsArenaDataHandler:getCurStageInfo()
	return self.cur_stage_info
end

function ClsArenaDataHandler:isHaveTask(index)
	for k, v in pairs(self.cur_stage_info.task) do
		if k == index then
			return true
		end
	end
	return false
end	

function ClsArenaDataHandler:getTaskExp(index)
	for k, v in pairs(self.cur_stage_info.task) do
		if k == index then
			return v
		end
	end
end

function ClsArenaDataHandler:getWinPeopleNum()
	return self.arena_info.fighted_count or 0
end

function ClsArenaDataHandler:getCurFigherNum()
	local base_num = self.arena_info.fighted_count
	if self:isHaveTarget() then
		return (base_num + 1)
	else
		return base_num
	end
end

function ClsArenaDataHandler:isCurHaveFighter()
	return (self.fighter_info and self.fighter_info.uid ~= 0)
end

function ClsArenaDataHandler:getCurFighter()
	return self.fighter_info
end

function ClsArenaDataHandler:setMatchInfo(info)
	self.match_info = info
	self.fighter_info = info
	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if not tolua.isnull(arena_ui) then
		arena_ui:showMatchInfo(info, true)
	end
end

function ClsArenaDataHandler:getMatchInfo()
	return self.match_info
end

function ClsArenaDataHandler:setLatestGrade()
	self.latest_stage_grade = self.arena_info.stage_exp
end

-- ARENA_EXP_NOT_CHANGE = 0
-- ARENA_EXP_UP = 1
-- ARENA_EXP_DOWN = 2

function ClsArenaDataHandler:getExpStatus()
	if not self.latest_stage_grade then
		return ARENA_EXP_NOT_CHANGE
	else
		if self.arena_info.stage_exp - self.latest_stage_grade > 0 then
			return ARENA_EXP_UP
		elseif self.arena_info.stage_exp - self.latest_stage_grade == 0 then
			return ARENA_EXP_NOT_CHANGE
		else
			return ARENA_EXP_DOWN
		end
	end
end

function ClsArenaDataHandler:getLatestExp()
	return self.latest_stage_grade
end

function ClsArenaDataHandler:getUpExpOffset()
	return self.arena_info.stage_exp - self.latest_stage_grade
end

function ClsArenaDataHandler:getDownExpOffset()
	return self.latest_stage_grade - self.arena_info.stage_exp
end

--判断是否升阶了
function ClsArenaDataHandler:getUpStageInfo()
	local start_grade = self.latest_stage_grade
	for k = start_grade + 1, self.arena_info.stage_exp do
		for i, j in ipairs(arena_stage) do
			if j.exp == k then
				return {name = j.name, index = i, exp = j.exp}
			end
		end
	end
end

--判断是否降阶了
function ClsArenaDataHandler:getDownStageInfo()
	local start_grade = self.arena_info.stage_exp
	for k = start_grade + 1, self.latest_stage_grade do
		for i, j in ipairs(arena_stage) do
			if j.exp == k then
				return {name = j.name, index = i, exp = j.exp}
			end
		end
	end
end

function ClsArenaDataHandler:getBoxRewardInfo()
	if not self.arena_info then return end
	return self.arena_info.rewards_list
end

--0不能领取, 1可领取, 2已领取
function ClsArenaDataHandler:getBoxStatus()
	return self.arena_info.reward_status
end

function ClsArenaDataHandler:askAreaInfo()
	cclog("请求竞技场信息")
	GameUtil.callRpc("rpc_server_arena_info", {})
	-- local info = {
	-- 	stage_exp = 320,   --当前总的段位经验
	-- 	fighted_count = 2,   --打过的对手人数
	-- 	reward_status = 1,   --奖励状态
	-- 	reward_stage_id = 2, --这个奖励是什么段位的奖励
	-- 	target_reset_count = 1, --剩余重置次数
	-- 	rewards_list = {
	-- 		[1] = {
	-- 			['type'] = ITEM_INDEX_GOLD,
	-- 			['amount'] = 100,
	-- 		},
	-- 		[2] = {
	-- 			['type'] = ITEM_INDEX_PROP,
	-- 			['amount'] = 90,
	-- 			['id'] = 10
	-- 		}
	-- 	},
	-- 	target = {
	-- 		uid = 10226,
	-- 		role = 1,
	-- 		name = "杰克逊",
	-- 		icon = "101",
	-- 		level = 10,
	-- 		power = 10000,
	-- 		fails = 2,
	-- 		nobility = 10001
	-- 	},
	-- }
	-- self:setArenaInfo(info)
end

function ClsArenaDataHandler:askMatchInfo()
	cclog("请求匹配对手的信息")
	GameUtil.callRpc("rpc_server_arena_match", {})
end

function ClsArenaDataHandler:askGetSalary()
	cclog("请求获取每日俸禄")
	GameUtil.callRpc("rpc_server_arena_take_day_reward", {})
end

function ClsArenaDataHandler:askFight()
	self.latest_stage_grade = self.arena_info.stage_exp
	local portData = getGameData():getPortData()
	portData:setEnterPortCallBack(function() 
		getUIManager():create("gameobj/arena/clsArenaMainUI")
	end)

	GameUtil.callRpc("rpc_server_arena_fight", {})
end

function ClsArenaDataHandler:askTargetInfo()
	GameUtil.callRpc("rpc_server_arena_target_info", {})
end

function ClsArenaDataHandler:askResetTarget()
	GameUtil.callRpc("rpc_server_arena_reset_target", {})
end

function ClsArenaDataHandler:askArenaStatus()
	GameUtil.callRpc("rpc_server_arena_status", {})
end

function ClsArenaDataHandler:askLegendFight(uid)
	local portData = getGameData():getPortData()
	portData:setEnterPortCallBack(function() 
		getUIManager():create("gameobj/arena/clsArenaMainUI")
	end)
	GameUtil.callRpc("rpc_server_legend_arena_fight", {uid})
end

function ClsArenaDataHandler:setActivityArenaStatus(status)
	self.activity_arena_status = status
end

function ClsArenaDataHandler:getActivityArenaStatus()
	return self.activity_arena_status or 0
end

return ClsArenaDataHandler
