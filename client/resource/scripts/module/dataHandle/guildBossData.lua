local tool = require("module/dataHandle/dataTools")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local guildBossConfig = require("game_config/guild/guild_boss_battle")
local ClsUiWord = require("game_config/ui_word")
local Alert = require("ui/tools/alert")

local GuildBossData = class("GuildBossData")

function GuildBossData:ctor()
	self.general_pirate_kill_num = 0
	self.advanced_pirate_kill_num = 0
	self.remian_pirate_amount = 0
	self.cur_sum_point = 0
	self.max_sum_point = 0
	self.boss_amount = 0
	self.skip_tag = nil
	self.cur_boss_difficulty = 0
	self.boss_info_tips_status = true --打公会boss时的右边的tips状态
	self.BOSS_STATUS = {UNOPEN = 0, OPEN = 1, CLOSE = 2} --UNOPEN 今天还没打，open 正在打，close 今天刚打完
	self.BOSS_OPEN_TIME = 19 --公会boss的开启时间
	self.BOSS_BOX_REWARD = {}  --公会boss宝箱奖励
	self:initTempData() --临时用的
	self.my_rank_info = {}
	self.fighting_ranks= {}
end

function GuildBossData:setSkipTag(tag)
	self.skip_tag = tag
end

function GuildBossData:getSkipTag()
	return self.skip_tag
end

function GuildBossData:askForGuildBossBattle()
    --首先考虑是否在队伍中
    local team_data = getGameData():getTeamData()
    if team_data:isInTeam() then
        Alert:showAttention(ClsUiWord.GUILDBOSS_INTO_TEAM_TIP, function() 
           team_data:askLeaveTeam()
        end)
        return
    end

	GameUtil.callRpc("rpc_server_group_boss_fight_start", {}, "rpc_client_group_boss_fight_start")
end

function GuildBossData:askGuildBossInfo()
	GameUtil.callRpc("rpc_server_group_boss_info", {}, "rpc_client_group_boss_info")
end

function GuildBossData:getGroupBossInfo()
	return self.groupBossInfo
end

function GuildBossData:investBoss()
	GameUtil.callRpc("rpc_server_group_boss_gift", {}, "rpc_client_group_boss_gift")
end

function GuildBossData:setInvest(invest_times)  
	if self.groupBossInfo == nil then
		return
	end

	self.groupBossInfo.investTimes = invest_times
end

function GuildBossData:updateBossHp(cur, max)
	if self.groupBossInfo == nil then
		return
	end
	
	self.groupBossInfo.curHp = cur
	self.groupBossInfo.maxHp = max
	self.groupBossInfo.maxAmount = max
	self.groupBossInfo.curAmount = cur
	local UI = getUIManager():get("GuildBossUI")
	if not tolua.isnull(UI) then
		UI:updateBossHpUI()
	end
	if cur == 0 then
		self:askGuildBossInfo()
	end
end

function GuildBossData:initBossInfo(data)
	table.print(data)
	self.groupBossInfo = {}
	self.groupBossInfo = data
	local bossConfig = nil
	if self.groupBossInfo.bossId == 0 then
		local guildInfoData = getGameData():getGuildInfoData()
		self.groupBossInfo.bossId = guildInfoData:getGuildGrade()
	end

	bossConfig = guildBossConfig[self.groupBossInfo.bossId]
	if not bossConfig then 
		print("没有公会bossid")
		return 
	end

	--load boss info by bossid
	local tool = require("module/dataHandle/dataTools")
	local bossSailorInfo = tool:getSailor(bossConfig.bossId)
	self.groupBossInfo.bossName = bossConfig.boss_name
	self.groupBossInfo.bossImage = bossSailorInfo.res
	self.groupBossInfo.bossLevel = bossConfig.boss_level
	self.groupBossInfo.guildlevel = bossConfig.guild_level
	
	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		guild_main_ui:updateBossState()
	end

	
	local UI = getUIManager():get("GuildBossUI")
	if not tolua.isnull(UI) then
		UI:showUI()--展示UI
	end
end

function GuildBossData:getGuildDonateInfo()
	local cost_list = {150, 300, 600, 600}
	local invest_index = math.min(self.groupBossInfo.investTimes + 1, #cost_list)
	return cost_list[invest_index], invest_index, invest_index > 3
end

function GuildBossData:sendRankInfo()
	GameUtil.callRpc("rpc_server_group_boss_rank", {}, "rpc_client_group_boss_rank")
end

function GuildBossData:getBoxReward()
	GameUtil.callRpc("rpc_server_group_boss_rank_reward", {}, "rpc_client_group_boss_rank_reward")
end


function GuildBossData:getGuildBossRank()
	local ranks = {}
	ranks = self.guildBossRanks or {}
	return ranks
end

function GuildBossData:getGuildBossRankByUid(uid)
	local rankInfo = nil
	if self.guildBossRanks then
		for key, value in pairs(self.guildBossRanks) do
			if value.uid == uid then
				rankInfo = table.clone(value)
				rankInfo.rank = key
				break
			end
		end
	end
	return rankInfo
end


function GuildBossData:GuildBossAttackRanks(ranks)

	self.guildBossRanks = ranks
	local UI = getUIManager():get("GuildBossUI")
	if not tolua.isnull(UI) then
		UI:updateRankUI()--展示UI
	end
end

function GuildBossData:getGuildBossRewards(rewards)
	local function func( )
		local UI = getUIManager():get("GuildBossUI")
		if not tolua.isnull(UI) then
			UI:showRewardView()
		end
	end
	Alert:showCommonReward(rewards, func)
	self:sendRankInfo() --发送协议
end

function GuildBossData:getFightCD()
	local cd = 0
	if self.fightCD == nil then
		cd = 0
	else
		cd = self.fightCD.time
	end
	cd = cd or 0
	return cd
end

function GuildBossData:setFightCD(value)
	self.fightCD = value
end

function GuildBossData:clearFightCD()
	self.fightCD = nil
	local scheduler = CCDirector:sharedDirector():getScheduler()

	if self.bossFightCDHandle then
		scheduler:unscheduleScriptEntry(self.bossFightCDHandle)
		self.bossFightCDHandle = nil
	end
	local UI = getUIManager():get("GuildBossUI")
	if not tolua.isnull(UI) then
		UI:playRight1View()
	end
end

function GuildBossData:bossFightCD(remainTime)
	self.fightCD = {}
	self.fightCD.time = remainTime
	local player_data = getGameData():getPlayerData()
	self.fightCD.startTime = os.time() + player_data:getTimeDelta()
	self.fightCD.endTime = self.fightCD.startTime +  self.fightCD.time

	local scheduler = CCDirector:sharedDirector():getScheduler()
	local function updateTime()
		if self.fightCD == nil then
			if self.bossFightCDHandle then
				scheduler:unscheduleScriptEntry(self.bossFightCDHandle)
				self.bossFightCDHandle = nil
			end
			return
		end
		local curTime = os.time() + player_data:getTimeDelta()
		if self.fightCD.endTime <= curTime then
			self:clearFightCD()
			return
		end
		local temp = self.fightCD.endTime - curTime 
		self.fightCD.time = temp 
		local UI = getUIManager():get("GuildBossUI")
		if not tolua.isnull(UI) then
			UI:updateLabelTime(temp)
		end
	end
	if self.bossFightCDHandle then
		scheduler:unscheduleScriptEntry(self.bossFightCDHandle)
		self.bossFightCDHandle = nil
	end
	self.bossFightCDHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

function GuildBossData:askGuildBossCD()
	GameUtil.callRpc("rpc_server_group_boss_fight_cd", {}, "rpc_client_group_boss_fight_cd")
end

function GuildBossData:askGuildBossReSetCD()
	GameUtil.callRpc("rpc_server_group_boss_fight_cd_reset", {})
end

function GuildBossData:getGeneralPirateKillNum()
	return self.general_pirate_kill_num
end

function GuildBossData:getAdvancePirateKillNum()
	return self.advanced_pirate_kill_num
end

function GuildBossData:getCurDifficulty()
	return self.cur_boss_difficulty
end

function GuildBossData:setCurDifficulty(difficulty)
	self.cur_boss_difficulty = difficulty
end

function GuildBossData:getBossTipsStatus()
	return self.boss_info_tips_status
end

function GuildBossData:setBossTipsStatus(status)
	self.boss_info_tips_status = status
end

function GuildBossData:initPirateKillNum(general_pirate, advanced_pirate, remain_pirate_amount, boss_amount, boss_difficulty)
	local battleData = getGameData():getBattleDataMt()
	local pirate_cnt = battleData:GetData("__pirate_cnt") or 0
	local sup_pirate_cnt = battleData:GetData("__sup_pirate_cnt") or 0
	self.general_pirate_kill_num = general_pirate
	self.advanced_pirate_kill_num = advanced_pirate
	self.remain_pirate_amount = remain_pirate_amount
	self.boss_amount = boss_amount
	self:setCurDifficulty(boss_difficulty)

	local general_pirate_kill_num_tmp = general_pirate + pirate_cnt
	local advanced_pirate_kill_num_tmp = advanced_pirate + sup_pirate_cnt

	EventTrigger(EVENT_BATTLE_GUILD_BOSS_PIRATE_KILL_UPDATE, general_pirate_kill_num_tmp, advanced_pirate_kill_num_tmp)
end

function GuildBossData:setGuildBossBoxReward(reward)
	self.BOSS_BOX_REWARD = reward
end

function GuildBossData:getGuildBossBoxReward(reward)
	return self.BOSS_BOX_REWARD
end

function GuildBossData:getRemianPirateAmount()
	return self.remain_pirate_amount
end

function GuildBossData:getBossMaxAmount()
	return self.boss_amount
end

function GuildBossData:setMyRank(myRank_info)
	self.my_rank_info = myRank_info
end

function GuildBossData:getMyRank()
	return self.my_rank_info
end

function GuildBossData:setFightingRanks(ranks)
	self.fighting_ranks = ranks
end

function GuildBossData:getFightingRanks()
	return self.fighting_ranks
end

function GuildBossData:setSumPoint(cur_point, max_point)
	self.cur_sum_point = cur_point
	self.max_sum_point = max_point
end

function GuildBossData:getSumPoint()
	self.cur_sum_point = self.cur_sum_point or 0
	self.max_sum_point = self.max_sum_point or 0
	return self.cur_sum_point, self.max_sum_point
end

-----------------------------类工会boss-------------------------------

function GuildBossData:initTempData()
	self.temp_boss_max_hp = 18
	self.cur_hp = 18
	self.temp_rank = {}
	self.my_temp_rank = 0
	self.my_temp_info = nil
end

function GuildBossData:killBoss()
	self.cur_hp = self.cur_hp - 1
end

function GuildBossData:getTempBossMaxHP()
	return self.temp_boss_max_hp
end

function GuildBossData:getTempBossCurHP()
	return self.cur_hp
end

local uid_to_name = {
	ClsUiWord.GUILLD_BOOS_NAME1,
	ClsUiWord.GUILLD_BOOS_NAME2,
}

function GuildBossData:tempSortRank()
	local battle_data = getGameData():getBattleDataMt()	
	local self_uid = getGameData():getPlayerData():getUid() 
	local killer_list = battle_data:GetData("killer_tab") or {}
	local sup_killer_tbl = battle_data:GetData("sup_killer_tbl") or {}
	local list = {}
	for k,v in pairs(killer_list) do
		local info = {}
		
		local rank_value = v + 2 * tonumber(sup_killer_tbl[k])
		info.uid = k
		info.rank = rank_value
		info.name = uid_to_name[k]
		if not info.name then
			info.name = getGameData():getPlayerData():getName()
		end
		list[#list + 1] = info
	end
	table.sort(list, function (a, b)
		return a.rank > b.rank
	end)
	self.temp_rank = list
	for k, v in ipairs(self.temp_rank) do
		if v.uid == getGameData():getPlayerData():getUid() then
			self.my_temp_rank = k
			self.my_temp_info = v
		end
	end
end

function GuildBossData:getTempRank()
	return self.temp_rank
end

function GuildBossData:getMyKillNomrol()
	local battle_data = getGameData():getBattleDataMt()	
	local killer_list = battle_data:GetData("killer_tab") or {}
	local sup_killer_tbl = battle_data:GetData("sup_killer_tbl") or {}
	return tonumber(killer_list[getGameData():getPlayerData():getUid()]) - 
	tonumber(sup_killer_tbl[getGameData():getPlayerData():getUid()])
end

function GuildBossData:getMyKillSup()
	local battle_data = getGameData():getBattleDataMt()	
	local sup_killer_tbl = battle_data:GetData("sup_killer_tbl") or {}
	return tonumber(sup_killer_tbl[getGameData():getPlayerData():getUid()])
end

function GuildBossData:getMyTempRank()
	return self.my_temp_rank or 0
end

function GuildBossData:getMyTeampInfo()
	return self.my_temp_info or {}
end

return GuildBossData
