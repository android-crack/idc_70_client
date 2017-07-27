local group_battle_objects = require("game_config/guildExplore/group_battle_objects")
local new_activity = require("game_config/activity/new_activity")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local clsGuildFightData = class("clsGuildFightData")
local error_info = require("game_config/error_info")

local GUILD_FIGHT_MATCH_STATUS = 0
local GUILD_FIGHT_READY_STATUS = 1
local GUILD_FIGHT_FIGHTING_STATUS = 2

local SMALL_MAP_H = 64

clsGuildFightData.ctor = function(self)
	self:initData()
end

clsGuildFightData.initData = function(self)
	self.vs_data = {}
	self.fight_time = 0
	self.chart_data = {}
	self.guard_data = {} --镇守的炮塔情况
	self.hasInitHash = false
	self.strong_hold_hash = {}
	self.guild_battle_status = GROUP_FIGHT_WAIT_STATUS
	self.our_name = nil
	self.your_name = nil
	self.our_point = nil
	self.your_point = nil
	self.our_users = nil
	self.your_users = nil
	self.solo_info = {}
end

clsGuildFightData.clearData = function(self)
	self:initData()
end

clsGuildFightData.setOurName = function(self, our_name)
	self.our_name = our_name
end

clsGuildFightData.getOurName = function(self)
	return self.our_name
end

clsGuildFightData.setYourName = function(self, your_name)
	self.your_name = your_name
end

clsGuildFightData.getYourName = function(self)
	return self.your_name
end

clsGuildFightData.setOurPoint = function(self, our_point)
	self.our_point = our_point
end

clsGuildFightData.getOurPoint = function(self)
	return self.our_point
end

clsGuildFightData.setYourPoint = function(self, your_point)
	self.your_point = your_point
end

clsGuildFightData.getYourPoint = function(self)
	return self.your_point
end

clsGuildFightData.setOurUsers = function(self, our_users)
	self.our_users = our_users
end

clsGuildFightData.getOurUsers = function(self)
	return self.our_users
end

clsGuildFightData.setYourUsers = function(self, your_users)
	self.your_users = your_users
end

clsGuildFightData.getYourUsers = function(self)
	return self.your_users
end

clsGuildFightData.setGroupFightStatus = function(self, status)
	self.guild_battle_status = status
end

clsGuildFightData.getGroupFightStatus = function(self)
	return self.guild_battle_status
end

clsGuildFightData.setChartData = function(self, charts)
	self.chart_data = charts
	table.sort(self.chart_data, function(a, b) return a.score > b.score end)
	local guild_fight_rank_ui = getUIManager():get("clsGuildFightRankUI")
	if not tolua.isnull(guild_fight_rank_ui) then
		guild_fight_rank_ui:updateRankUI()
	end
end

clsGuildFightData.getChartData = function(self)
	return self.chart_data
end

clsGuildFightData.setVSData = function(self, vs_data)
	self.vs_data = vs_data
	local guild_fight_ui = getUIManager():get("clsGuildFightUI")
	if not tolua.isnull(guild_fight_ui) then
		guild_fight_ui:updateUI()
	end
end

clsGuildFightData.getVSData = function(self)
	return self.vs_data
end

clsGuildFightData.setMVPData = function(self, mvp_info)
	self.mvp_data = mvp_info
	local ClsGuildFightMVPUi = getUIManager():get("ClsGuildFightMVPUi")
	if not tolua.isnull(ClsGuildFightMVPUi) then
		ClsGuildFightMVPUi:updateUI()
	end
end

clsGuildFightData.getMVPData = function(self)
	return self.mvp_data
end

clsGuildFightData.initStrongHoldHash = function(self)
	if self.hasInitHash then
		return
	end
	self.hasInitHash = true
	self.strong_hold_hash = {}
	for key, value in ipairs(group_battle_objects) do
		if value.map_pos then
			local hash_key = value.map_pos[1] * SMALL_MAP_H + value.map_pos[2]
			if not self.strong_hold_hash[hash_key] then
				self.strong_hold_hash[hash_key] = {}
			end
			self.strong_hold_hash[hash_key][#self.strong_hold_hash[hash_key] + 1] = key
		end
	end 
end

clsGuildFightData.isGuildStrongHoldPos = function(self, pos)
	self:initStrongHoldHash()
	local key = pos.x * SMALL_MAP_H + pos.y
	return self.strong_hold_hash[key]
end

clsGuildFightData.setFightTime = function(self, remain_time)
	if remain_time < 0 then
		remain_time = 0
	end
	self.fight_time = remain_time 
end

clsGuildFightData.getFightTime = function(self)
	return self.fight_time
end

clsGuildFightData.setGuardData = function(self, data)
	self.guard_data = data
	table.sort(self.guard_data, function(a, b) return a.checkpointId < b.checkpointId end)
end

clsGuildFightData.getGuardData = function(self, data)
	return self.guard_data
end

clsGuildFightData.isSameCamp = function(self, camp_n)
	local camp = nil
	local guild_name = getGameData():getGuildInfoData():getGuildName()
	table.print(self.vs_data)
	for k, v in pairs(self.vs_data) do
		if v.name == guild_name then
			camp = v.camp
			break
		end
	end
	return camp == camp_n
end

-- solo_info = {
-- [1] = {
	-- index = xx;
	-- name = xx;
	-- level = xx;
	-- roleId = xx;
	-- prestige = xx;
	-- isWin = xx;
-- }

clsGuildFightData.setSoloInfo = function(self, solo_info)
	self.solo_info = solo_info
end

clsGuildFightData.getSoloInfo = function(self)
	return self.solo_info
end

clsGuildFightData.askEnterGuildFightUI = function(self)
	local activity_id = 8
	local user_level = getGameData():getPlayerData():getLevel()
	if user_level < new_activity[activity_id].level_limit then
		ClsAlert:warning({msg = string.format(ui_word.ACTIVITY_LEVEL_LIMIT, new_activity[activity_id].level_limit)})
	elseif getGameData():getGuildInfoData():getGuildGrade() < 20 then 
		ClsAlert:warning({msg = error_info[7].message})
	else
		self:askBattleInfo()
	end
end

------------------------------ 协议请求相关 -------------------------
	
clsGuildFightData.askBattleInfo = function(self)
	GameUtil.callRpc("rpc_server_group_battle_info")
end

clsGuildFightData.askEnterBattleScene = function(self)
	GameUtil.callRpc("rpc_server_enter_group_battle")
end

clsGuildFightData.askGuildBattleChart = function(self)
	GameUtil.callRpc("rpc_server_group_battle_chart")
end

--商会战站前信息
clsGuildFightData.askSoleInfo = function(self)
	GameUtil.callRpc("rpc_server_group_battle_solo_info", {})
end

clsGuildFightData.askMVPInfo = function(self)
	GameUtil.callRpc("rpc_server_group_battle_mvp_info")
end

clsGuildFightData.askSoleApply = function(self, pos_index)
	GameUtil.callRpc("rpc_server_group_battle_solo_apply", {pos_index})
end

------------------------------ 协议请求相关 -------------------------

return clsGuildFightData
