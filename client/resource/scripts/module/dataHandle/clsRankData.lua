-- Author: pyq0639
-- Date: 2017-02-13 11:59:06
-- Function: 排行榜数据
local ClsRankData = class("ClsRankData")
local ui_word = require("game_config/ui_word")

function ClsRankData:ctor()
	self.rank_list = {}
	self.cd_list = {}
	self.rpc_cd = 40
	self.is_enter_new_grade = nil
	self.cur_rank_time = nil
	self.update_times = {}
end

function ClsRankData:getListByType(type)
	return self.rank_list[type]
end

function ClsRankData:setListByType(type, data)
	self.rank_list[type] = data
end

function ClsRankData:resetRankData()
	self.rank_list = {}
end

function ClsRankData:clearRankData(type)
	self.rank_list[type] = nil
end

function ClsRankData:setIsNewGrade(value)
	self.is_enter_new_grade = value
end

function ClsRankData:getIsNewGrade()
	return self.is_enter_new_grade
end

function ClsRankData:getGradeIntervalTip()
	local grade_tbl = {
		{max_grade = 10, grade_text = ui_word.STR_USER_GRADE_INTERVAL3,},
		{max_grade = 20, grade_text = ui_word.STR_USER_GRADE_INTERVAL3,},
		{max_grade = 30, grade_text = ui_word.STR_USER_GRADE_INTERVAL3,},
		{max_grade = 40, grade_text = ui_word.STR_USER_GRADE_INTERVAL4,},
		{max_grade = 50, grade_text = ui_word.STR_USER_GRADE_INTERVAL5,},
		{max_grade = 70, grade_text = ui_word.STR_USER_GRADE_INTERVAL6,},
		-- {max_grade = 70, grade_text = ui_word.STR_USER_GRADE_INTERVAL6,},
	}
	local user_grade = getGameData():getPlayerData():getLevel()
	for k,v in ipairs(grade_tbl) do
		if user_grade <= v.max_grade then
			return k, v.grade_text
		end
	end	
end 

--进入新区间时弹框
function ClsRankData:popNewGradeTip()
	local Alert = require("ui/tools/alert")
	local _, grade_tip = self:getGradeIntervalTip()
	Alert:showAttention(string.format(ui_word.STR_NEW_GRADE_INTERVAL_TIP, grade_tip), nil, nil, nil,{hide_cancel_btn = true})
end

function ClsRankData:whenLevelChange()
	local function getCurInterval()
		local grade_tbl = {10, 20, 30, 40, 50, 70}
		local user_grade = getGameData():getPlayerData():getLevel()
		for k,v in ipairs(grade_tbl) do
			if user_grade <= v then
				return k
			end
		end
	end
	local cur_level_interval = getCurInterval()--当前经验所在区间
	local pre_level_interval = getGameData():getPlayerData():getGradeInterval()
	if cur_level_interval ~= pre_level_interval and pre_level_interval ~= nil then
		local rank_main_ui = getUIManager():get("ClsRankMainUI")
		self:resetRankData()
		if not tolua.isnull(rank_main_ui) then
			self:popNewGradeTip()
			rank_main_ui:getListView(rank_main_ui:getSelectType()):updateView()
		else
			self:setIsNewGrade(true)
		end
	end
	return cur_level_interval
end

local update_time = 5*60
local ONE_DAY_SECOND = 24 * 60 * 60

function ClsRankData:isResetData(index)
	local pre_update_time = self.update_times[index]
	local palyer_data = getGameData():getPlayerData()
	local now_time = os.time() + palyer_data:getTimeDelta()
	local is_update = false
	if not pre_update_time then
		is_update = true
	else
		if self:getDayNum(now_time) > self:getDayNum(pre_update_time) then
			if self:getCurDayTime(now_time) >= update_time then
				is_update = true
			end 
		end
	end
	if is_update then
		self.update_times[index] = now_time
		self:clearRankData(index)
	end
end

--是否跨天
function ClsRankData:getDayNum(time)
	return math.ceil((time + 28800) / ONE_DAY_SECOND)
end

function ClsRankData:getCurDayTime(time)
	return (time + 28800) % ONE_DAY_SECOND
end

function ClsRankData:resetMyGuildInfo()
	local guild_rank = self:getListByType(GUILD_RANK_TYPE)
	if not guild_rank then return end
	local my_guild_id = getGameData():getGuildInfoData():getGuildId()
	guild_rank.is_in_rank = nil
	for k, v in ipairs(guild_rank.rank_list or {}) do
        if v.groupId == my_guild_id then
        	guild_rank.is_in_rank, guild_rank.user_pos, guild_rank.user_value = true, k, v.prestige
            self:setListByType(GUILD_RANK_TYPE, guild_rank)
        end
    end
end

-----------协议使用接口----------------
function ClsRankData:askRankList(type, gradeKey)
	--检查请求数据协议的CD
	local cur_click_time = os.time() + getGameData():getPlayerData():getTimeDelta()
	if self.cd_list[type] then
		if cur_click_time - self.cd_list[type] < self.rpc_cd then
			-- print("还处于CD中，=============剩余%ss",cur_click_time - self.cd_list[type])
			return
		end
	end
	self.cd_list[type] = cur_click_time

	if type == GUILD_RANK_TYPE then
		self:askGuildRank()
	else
		GameUtil.callRpc("rpc_server_rank_detail", {type, gradeKey})
	end
end

function ClsRankData:askGuildRank()
    GameUtil.callRpc("rpc_server_group_chart", {})
end

return ClsRankData