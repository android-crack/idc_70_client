-- 副本数据
local copy_scene_mission = require("game_config/copyScene/copy_scene_mission")
local cfg_melee_score = require("game_config/copyScene/melee_score")

local ClsCopySceneData = class("CopySceneData")

ClsCopySceneData.ctor = function(self)
	self:initProperty()
	self:initData()
	self.m_melee_status = nil
end

ClsCopySceneData.initData = function(self)
	self.treasure_mission_list = {} --寻宝副本的任务列表
	self.treasure_win_uid = nil --寻宝副本的获胜玩家
	self.treasure_win_reward = nil --寻宝副本的获胜玩家奖励
	self.rank_list = {} --大乱斗的排行榜
	self.my_rank = 0
	self.my_life = 5
	self.m_melee_time = 0
	self.m_melee_isApply = false
	self.tips_t = {}
	self.copy_end_camp = nil
end

ClsCopySceneData.addTips = function(self, explore_info, show_time_n)
	self.tips_t[1] = {
        ["explore_info"] = explore_info,
        ["show_time"] = show_time_n,
    }
	local copy_scene_ui = getUIManager():get("ClsCopySceneUI")
    if not tolua.isnull(copy_scene_ui) then
        copy_scene_ui:showTipsUI()
    end
end

ClsCopySceneData.setCopyWinCamp = function(self, camp)
	self.copy_end_camp = camp
end

ClsCopySceneData.getCopyWinCamp = function(self)
	return self.copy_end_camp
end

ClsCopySceneData.getTips = function(self)
	return self.tips_t
end

ClsCopySceneData.clearTips = function(self)
	self.tips_t = {}
end

ClsCopySceneData.addRankInfo = function(self, player_info)
	if #self.rank_list == 0 then
		self.rank_list[1] = player_info
		self:updateRankUI()
		return
	end

	for k, v in ipairs(self.rank_list) do
		if v.uid == player_info.uid then
			self.rank_list[k] = player_info
			break
		end

		if k == #self.rank_list then
			self.rank_list[#self.rank_list + 1] = player_info
			break
		end
	end

	self:updateRankUI()
end

ClsCopySceneData.updateRankUI = function(self)
	table.sort(self.rank_list, function(a, b)
		return a.rank > b.rank
	end)

	local playerData = getGameData():getPlayerData()
	local my_uid = playerData:getUid()

	for k, v in ipairs(self.rank_list) do
		if v.uid == my_uid then
			self.my_rank = k
			break
		end
	end

	local copySceneManage = require("gameobj/copyScene/copySceneManage")
	copySceneManage:doLogic("updateRankUI", self.rank_list, self.my_rank)
end

ClsCopySceneData.getRankNameColor = function(self, uid)
	if not self.rank_list[1] then return cfg_melee_score[1].name_color end

	if self.rank_list then
		for k, v in pairs(self.rank_list) do
			for k1, v1 in ipairs(cfg_melee_score) do
				if v.uid == uid then
					if v.rank >= cfg_melee_score[#cfg_melee_score].all_score then
						return cfg_melee_score[#cfg_melee_score].name_color
					end
					if v.rank < v1.all_score then
						return cfg_melee_score[k1 - 1].name_color
					end
				end
			end
		end
	end

	return COLOR_WHITE_STROKE
end

ClsCopySceneData.setRankList = function(self, list)
	self.rank_list = list
	self:updateRankUI()
end

ClsCopySceneData.getRankList = function(self)
	return self.rank_list
end

ClsCopySceneData.getMyRank = function(self)
	return self.my_rank
end

ClsCopySceneData.setMyLife = function(self, life)
	self.my_life = life
end

ClsCopySceneData.getMyLife = function(self)
	return self.my_life
end

ClsCopySceneData.setWinUid = function(self, uid)
	self.treasure_win_uid = uid
end

ClsCopySceneData.getWinUid = function(self)
	return self.treasure_win_uid
end

ClsCopySceneData.setWinReward = function(self, rewards)
	self.treasure_win_reward = rewards
end

ClsCopySceneData.getWinReward = function(self)
	return self.treasure_win_reward
end

ClsCopySceneData.initProperty = function(self)
	self.scene_id = 0
	self.event_lists= {}
end

ClsCopySceneData.clearData = function(self)
	self:initProperty()
	self:initData()
end

ClsCopySceneData.sendMessage = function(self)

end

ClsCopySceneData.setTreasureMissions = function(self, mission_list)
	self.treasure_mission_list = mission_list
end

ClsCopySceneData.setTreasureMission = function(self, mission_info)
	for i = 1, #self.treasure_mission_list do
		if self.treasure_mission_list[i].uid == mission_info.uid then
			self.treasure_mission_list[i] = mission_info
			return
		end
	end
end

ClsCopySceneData.getTreasureMissions = function(self)
	return self.treasure_mission_list
end

ClsCopySceneData.clearTreasureMission = function(self)
	self.treasure_mission_list = {}
end

ClsCopySceneData.getMissionInfo = function(self, event_id)
	local mission_info = {}
	for _, v in pairs(copy_scene_mission) do
		if v.event_id == event_id then
			mission_info = v
		end
	end
	return mission_info
end

ClsCopySceneData.setMeleeTime = function(self, time)
	self.m_melee_time = time
end

ClsCopySceneData.getMeleeTime = function(self, time)
	return self.m_melee_time
end

ClsCopySceneData.setMeleeStatus = function(self, status)
	self.m_melee_status = status
end

ClsCopySceneData.getMeleeStatus = function(self)
	return self.m_melee_status
end

ClsCopySceneData.setInteractEvent = function(self, eventId)
	self.auto_event = eventId
end

ClsCopySceneData.getInteractEvent = function(self)
	return self.auto_event
end

ClsCopySceneData.setPopProlusion = function(self, is_pop)
	self.is_pop = is_pop
end

ClsCopySceneData.getPopProlusion = function(self)
	return self.is_pop
end

ClsCopySceneData.setDialogPopSwitch = function(self, val)
	self.is_pop_dialog = val
end

ClsCopySceneData.getDialogPopSwitch = function(self)
	return self.is_pop_dialog
end

ClsCopySceneData.setIsNewRound = function(self, val)
	self.is_new_round = val
end

ClsCopySceneData.getIsNewRound = function(self)
	return self.is_new_round
end

ClsCopySceneData.setIsSeaGodFail = function(self, val)
	self.is_sea_god_failed = val
end

ClsCopySceneData.getIsSeaGodFail = function(self)
	return self.is_sea_god_failed
end

ClsCopySceneData.setSeaGodBossId = function(self, boss_id)
	self.sea_god_boss = boss_id
end

ClsCopySceneData.getSeaGodBossId = function(self)
	return self.sea_god_boss
end
------------------------------------- 协议 ---------------------------------------------

ClsCopySceneData.askMeleeStatus = function(self)
	GameUtil.callRpc("rpc_server_top_fight_status", {}, "rpc_client_top_fight_status")
end

ClsCopySceneData.askfight = function(self)
	GameUtil.callRpc("rpc_server_enter_top_fight", {})
end

ClsCopySceneData.askClickEvent = function(self, event_id)
	GameUtil.callRpc("rpc_server_seagod_leader_click_pillar", {event_id})
end

ClsCopySceneData.askMoveCamera = function(self)
	GameUtil.callRpc("rpc_server_seagod_move_camera", {})
end

return ClsCopySceneData
