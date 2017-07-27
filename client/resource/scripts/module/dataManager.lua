-- 整个游戏的数据管理
local baowuData = require("module/dataHandle/baowuData")
local playerData = require("module/dataHandle/playerDataHandle")
local shopData = require("module/dataHandle/shopData")
local guildTaskData = require("module/dataHandle/guildTaskData")
local activityData = require("module/dataHandle/activityData")
local guildInfoData = require("module/dataHandle/guildInfoData")
local ClsFleetData = require("module/dataHandle/clsFleetData")
local friendDataHandle = require("module/dataHandle/friendDataHandle")
local lootDataHandle = require("module/dataHandle/lootDataHandle")
local missionDataHandle = require("module/dataHandle/missionDataHandle")
local loginVipAwardData = require("module/dataHandle/loginVipAwardDataHandle")
local portPveData = require("module/dataHandle/portPveData")
local onOffData = require("module/dataHandle/onOffData")
local captainInfoData = require("module/dataHandle/captainInfoData")
local materialDataHandle = require("module/dataHandle/materialDataHandle")
local exploreMapData = require("module/explore/exploreMapData")
local taskData = require("module/dataHandle/TaskData")
local investData=require("module/dataHandle/investData")
local relicDataHandle = require("module/dataHandle/relicDataHandle")
local supplyData = require("module/dataHandle/supplyData")
local collectDataHandle = require("module/dataHandle/collectDataHandle")
local sailorData = require("module/dataHandle/sailorData")
local boatData = require("module/dataHandle/boatData")
local ClsShipData = require("module/dataHandle/clsShipData")
local achieveData=require("module/dataHandle/achieveData")
local sailorUpLevelData = require("module/dataHandle/sailorUpLevelData")
local marketData = require("module/dataHandle/marketData")
local portData = require("module/dataHandle/portDataHandle")
local arenaDataHandle = require("module/dataHandle/arenaDataHandle")
local chatDataHandle = require("module/dataHandle/chatDataHandle")
local tipsData = require("module/dataHandle/tipsData")
local battleData = require("module/dataHandle/battleData")
local guildBossData = require("module/dataHandle/guildBossData")
local guildPrestigeData = require("module/dataHandle/guildPrestigeData")
local guildShopData = require("module/dataHandle/guildShopData")
local exploreData = require("module/explore/exploreData")
local dailyActivityData = require("module/dataHandle/clsDailyActivityDataHandle")
local battleDataMt = require("module/battleAttrs/battle_data")
local ClsGuildSearchData = require("module/dataHandle/guildSearchData")
local ClsGuildBuffData = require("module/dataHandle/guildBuffData")
local ClsDailyCourseData = require("module/dataHandle/clsDailyCourseDataHandle")
local ClsTitleData = require("module/dataHandle/ClsTitleData")
local ClsWorldMapAttrs = require("module/worldMap/worldMapAttrs")
local ClsMailData = require("module/dataHandle/clsMailData")
local ClsAutoTradeAIHandler = require("module/dataHandle/clsAutoTradeAIHandler")
local ClsStartAndLoginData = require("module/dataHandle/clsStartAndLoginData")
local ClsPropDataHandle = require("module/dataHandle/propDataHandle")
local ClsBagDataHandle = require("module/dataHandle/bagDataHandle")
local ClsBattleInfoConfigDataHandle = require("module/dataHandle/battleInfoConfigDataHandle")
local ClsSkillData = require("module/dataHandle/skillData")
local ClsSeaStarDataHandle = require("module/dataHandle/clsSeaStarDataHandle")
local ClsBuffStateData = require("module/dataHandle/buffStateData")
local ClsBayData = require("module/dataHandle/clsBayData")
local ClsExplorePlayerShipsData = require("module/dataHandle/explorePlayerShipsData")
local ClsPlayersDetailData = require("module/dataHandle/playersDetailData")
local ClsTeamData = require("module/dataHandle/teamData")
local ClsCopySceneData = require("module/dataHandle/copySceneData")
local ClsTradeCompleteDataHandler = require("module/dataHandle/tradeCompleteDataHandler")
local ClsQuestionPaperDataHandler = require("module/dataHandle/questionPaperDataHandler")
local ClsPartnerData = require("module/dataHandle/clsPartnerData")
local ClsNobilityDataHandle = require("module/dataHandle/nobilityDataHandle")
local ClsExploreNpcData = require("module/dataHandle/exploreNpcData")
local ClsExplorePirateEventData = require("module/dataHandle/explorePirateEventData")
local ClsSceneDataHandler = require("module/dataHandle/sceneDataHandler")
local ClsExploreRewardPirateEventData = require("module/dataHandle/exploreRewardPirateData")
local ClsAreaCompetitionData = require("module/dataHandle/clsAreaCompetitionData")
local ClsWarningData = require("module/dataHandle/warningData")
local ClsBroadcastData = require("module/dataHandle/broadcastDataHandler")
local ClsVirtualTeamData = require("module/dataHandle/clsVirtualTeamData")
local clsWorldMissionData = require("module/dataHandle/clsWorldMissionData")
local clsConvoyMissionData = require("module/dataHandle/clsConvoyMissionData")
local ClsMissionPirateData = require("module/dataHandle/missionPirateData")
local ClsRankData = require("module/dataHandle/clsRankData")
local ClsNetRes = require("module/dataHandle/clsNetRes")
local ClsGrowthFundData = require("module/dataHandle/growthFundData")
local ClsGuildFightData = require("module/dataHandle/clsGuildFightData")
local ClsShareData = require("module/dataHandle/clsShareData")
local ClsMunicipalWorkData = require("module/dataHandle/clsMunicipalWorkData")
local ClsGainBackData = require("module/dataHandle/clsGainBackData")
local ClsGuildResearchData = require("module/dataHandle/clsGuildResearchData")
local ClsAreaRewardData = require("module/dataHandle/clsAreaRewardData")
local ClsBaseSkillData = require("module/dataHandle/clsBaseSkillData")
local ClsPortBattleData = require("module/dataHandle/clsPortBattleData")
local ClsCityChallengeData = require("module/dataHandle/clsCityChallengeData")
local ClsFestivalActivityData = require("module/dataHandle/clsFestivalActivityData")

------------------------------------------------------------
-- DataManager class

local DataManager = class("DataManager")

function DataManager:ctor()
	self._baowuData = nil
	self._playerData = nil
	self._missionData = nil
	self._shopData = nil
	self._guildTaskData = nil
	self._frientHandlerData = nil
	self._activityData = nil
	self._guildInfoData = nil
	self._fleetData = nil
	self._newFleetData = nil
	self._lootData = nil
	self._equipData =  nil
	self._sailorData = nil
	self._loginVipAwardData = nil
	self._portPveData = nil
	self._onOffData = nil
	self._captainInfoData = nil
	self._materialData = nil
	self._exploreMapData = nil
	self._taskData = nil
	self._investData = nil
	self._relicData = nil
	self._supplyData = nil
	self._collectData = nil
	self._boatData = nil
	self._achieveData = nil
	self._sailorUpLevelData = nil
	self._marketData = nil
	self._portData = nil
	self._arenaData = nil
	self._chatDataHandle = nil
	self._tradeCompleteDataHandler = nil
	self._questionPaperData = nil
	self._tipsData = nil
	self._battleData = nil
	self._guildBossData = nil
	self._guildPrestigeData = nil
	self._guildShopData = nil
	self._battleDataMt = nil
	self._dailyActivityData = nil
	self._titleData = nil
	self._seaStarData = nil
	self._buff_state_data = nil
	self._explore_player_ships_data = nil
	self._players_detail_data = nil
	self._team_data = nil
	self._festivalActivityData = nil

	self.guild_search_data = nil
	self._daily_course_data =nil
	self.world_map_attrs = nil
	self.mail_data = nil
	self.auto_trade_ai_handler = nil --自动经商出海管理

	self.sailor_fight_data = nil

	self.prop_data_handler = nil
	self.battle_info_config_data = nil
	self.skill_data = nil

	self.guild_bay_data = nil
	self._municipal_work_data = nil


	--登录相关的数据
	self._start_and_login_data = nil

	self.copy_scene_data = nil
	self.ship_data = nil
	self._nobility_data = nil
	self.partner_data = nil
	self._far_arena = nil
	self.explore_npc_data = nil
	self.explore_pirvate_event_data = nil
    self.scene_data_handler = nil
    self.explore_reward_pirvate_event_data = nil
    self.area_competition_data = nil
    self._broadcast_data = nil
    self._virtual_team_data = nil
    self._world_mission_data = nil
    self._convoy_mission_data = nil

    self._mission_pirate_data = nil
    self._net_res = nil
	self._guild_fight_data = nil
    self._growth_fund_data = nil 
    self._share_data = nil
    self._guild_researc_data = nil
	self._port_battle_data = nil
    self._area_reward_data = nil
    self._base_skill_data = nil
    self._rank_data = nil
    self._city_challenge_data = nil
end

function DataManager:getBaseSkillData()
	if self._base_skill_data == nil then
		self._base_skill_data = ClsBaseSkillData.new()
	end
	return self._base_skill_data	
end

function DataManager:clearBaseSkillData()
	self._base_skill_data = nil
end

function DataManager:getAreaRewardData()
	if self._area_reward_data == nil then
		self._area_reward_data = ClsAreaRewardData.new()
	end
	return self._area_reward_data	
end

function DataManager:clearAreaRewardData()
	self._area_reward_data = nil
end


function DataManager:getPortBattleData()
	if not self._port_battle_data then
	 	self._port_battle_data = ClsPortBattleData.new()
	end
	return self._port_battle_data
end

function DataManager:clearPortBattleData()
	self._port_battle_data = nil
end

function DataManager:getGuildResearchData(  )
	if self._guild_researc_data == nil then
		self._guild_researc_data = ClsGuildResearchData.new()
	end
	return self._guild_researc_data	
end

function DataManager:clearGuildResearchData()
	self._guild_researc_data = nil
end


function DataManager:getMunicipalWorkData()
	if self._municipal_work_data == nil then
		self._municipal_work_data = ClsMunicipalWorkData.new()
	end
	return self._municipal_work_data
end

function DataManager:clearMunicipalWorkData()
	self._municipal_work_data = nil
end

function DataManager:getGainBackData()
	if self._gain_back_data == nil then
		self._gain_back_data = ClsGainBackData.new()
	end
	return self._gain_back_data
end

function DataManager:clearGainBackData()
	self._gain_back_data = nil
end

function DataManager:getShareData()
	if self._share_data == nil then
		self._share_data = ClsShareData.new()
	end
	return self._share_data
end

function DataManager:clearShareData( ... )
	self._share_data = nil
end

function DataManager:getGrowthFundData()
	if self._growth_fund_data == nil then
		self._growth_fund_data = ClsGrowthFundData.new()
	end
	return self._growth_fund_data
end

function DataManager:cleanGrowthFundData()
	self._growth_fund_data = nil
end

function DataManager:getGuildFightData()
	if not self._guild_fight_data then
		self._guild_fight_data = ClsGuildFightData.new()
	end
	return self._guild_fight_data
end

function DataManager:clearGuildFightData()
	self._guild_fight_data = nil
end

function DataManager:getNetRes()
	if not self._net_res then
		self._net_res = ClsNetRes.new()
	end
	return self._net_res
end

function DataManager:clearNetRes()
	self._net_res = nil
end

function DataManager:getRankData()
	if not self._rank_data then
		self._rank_data = ClsRankData.new()
	end
	return self._rank_data
end

function DataManager:clearRankData()
	self._rank_data = nil
end

function DataManager:getCityChallengeData()
	if not self._city_challenge_data then
		self._city_challenge_data = ClsCityChallengeData.new()
	end
	return self._city_challenge_data
end

function DataManager:clearCityChallengeData()
	self._city_challenge_data = nil
end

function DataManager:getMissionPirateData()
	if not self._mission_pirate_data then
		self._mission_pirate_data = ClsMissionPirateData.new()
	end
	return self._mission_pirate_data
end

function DataManager:clearMissionPirateData()
	self._mission_pirate_data = nil
end

function DataManager:getVirtuaTeamData()
	if not self._virtual_team_data then
		self._virtual_team_data = ClsVirtualTeamData.new()
	end
	return self._virtual_team_data
end

function DataManager:clearVirtuaTeamData()
	self._virtual_team_data = nil
end
function DataManager:getExploreRewardPirateEventData()
	if not self.explore_reward_pirvate_event_data then
		self.explore_reward_pirvate_event_data = ClsExploreRewardPirateEventData.new()
	end
	return self.explore_reward_pirvate_event_data
end

function DataManager:cleanExploreRewardPirateEventData()
	self.explore_reward_pirvate_event_data = nil
end

function DataManager:getAreaCompetitionData()
	if not self.area_competition_data then
		self.area_competition_data = ClsAreaCompetitionData.new()
	end
	return self.area_competition_data
end

function DataManager:cleanAreaCompetitionData()
	self.area_competition_data = nil
end

function DataManager:getSceneDataHandler()
	if not self.scene_data_handler then
		self.scene_data_handler = ClsSceneDataHandler.new()
	end
	return self.scene_data_handler
end

function DataManager:cleanSceneDataHandler()
	self.scene_data_handler = nil
end

function DataManager:getExplorePirateEventData()
	if not self.explore_pirvate_event_data then
		self.explore_pirvate_event_data = ClsExplorePirateEventData.new()
	end
	return self.explore_pirvate_event_data
end

function DataManager:cleanExplorePirateEventData()
	self.explore_pirvate_event_data = nil
end

function DataManager:getExploreNpcData()
	if not self.explore_npc_data then
		self.explore_npc_data = ClsExploreNpcData.new()
	end
	return self.explore_npc_data
end

function DataManager:cleanExploreNpcData()
	self.explore_npc_data = nil
end


function DataManager:getPartnerData()
	if self.partner_data == nil then
		self.partner_data = ClsPartnerData.new()
	end
	return self.partner_data
end

function DataManager:cleanPartnerData()
	self.partner_data = nil
end

function DataManager:getNobilityData()
	if self._nobility_data == nil then
		self._nobility_data = ClsNobilityDataHandle.new()
	end
	return self._nobility_data
end

function DataManager:clearNobiliyData()
	self._nobility_data = nil
end

function DataManager:getCopySceneData()
	if self.copy_scene_data == nil then
		self.copy_scene_data = ClsCopySceneData.new()
	end
	return self.copy_scene_data
end

function DataManager:cleanCopySceneData()
	self.copy_scene_data = nil
end

function DataManager:getBayData()
	if self.bay_data == nil then
		self.bay_data = ClsBayData.new()
	end
	return self.bay_data
end

function DataManager:clearBayData()
	self.bay_data = nil
end

function DataManager:getmailData()
	if self.mail_data == nil then
		self.mail_data = ClsMailData.new()
	end
	return self.mail_data
end

function DataManager:clearMailData()
	self.mail_data = nil
end

function DataManager:cleanWorldMapAttrsData()
	self.world_map_attrs = nil
end

function DataManager:getWorldMapAttrsData()
	if self.world_map_attrs == nil then
		self.world_map_attrs = ClsWorldMapAttrs.new()
	end
	return self.world_map_attrs
end

function DataManager:cleanTitleData()
	self._titleData = nil
end

function DataManager:getTitleData() --称号系统
	if self._titleData == nil then
		self._titleData = ClsTitleData.new()
	end
	return self._titleData
end

function DataManager:getDailyCourseData()
	if self._daily_course_data == nil then
		self._daily_course_data = ClsDailyCourseData.new()
	end
	return self._daily_course_data
end

function DataManager:cleanDailyCourseData()
	self._daily_course_data = nil
end

function DataManager:getDailyActivityData()
	if self._dailyActivityData == nil then
		self._dailyActivityData = dailyActivityData.new()
	end
	return self._dailyActivityData
end

function DataManager:cleanDailyActivityData()
	self._dailyActivityData = nil
end

function DataManager:getGuildShopData()
	if self._guildShopData == nil then
		self._guildShopData = guildShopData.new()
	end
	return self._guildShopData
end

function DataManager:cleanGuildShopData()
	self._guildShopData = nil
end

function DataManager:getGuildPrestigeData()
	if self._guildPrestigeData == nil then
		self._guildPrestigeData = guildPrestigeData.new()
	end
	return self._guildPrestigeData
end

function DataManager:cleanGuildPrestigeData()
	self._guildPrestigeData = nil
end

function DataManager:getGuildBossData()
	if self._guildBossData == nil then
		self._guildBossData = guildBossData.new()
	end
	return self._guildBossData
end

function DataManager:cleanGuildBossData()
	self._guildBossData = nil
end

function DataManager:getGuildSearchData()
	if self.guild_search_data == nil then
		self.guild_search_data = ClsGuildSearchData.new()
	end
	return self.guild_search_data
end

function DataManager:cleanGuildSearchData()
	self.guild_search_data = nil
end

function DataManager:getGuildBuffData()
	if self.guild_buff_data == nil then
		self.guild_buff_data = ClsGuildBuffData.new()
	end
	return self.guild_buff_data
end

function DataManager:cleanGuildBuffData()
	self.guild_buff_data = nil
end

function DataManager:getBattleData()
	if self._battleData == nil then
		self._battleData = battleData.new()
	end
	return self._battleData
end

function DataManager:cleanBattleData()
	self._battleData = nil
end

function DataManager:getTipsData()
	if self._tipsData == nil then
		self._tipsData = tipsData.new()
	end
	return self._tipsData
end

function DataManager:getStartAndLoginData()
	if self._start_and_login_data == nil then
		self._start_and_login_data = ClsStartAndLoginData.new()
	end
	return self._start_and_login_data
end

function DataManager:cleanStartAndLoginData()
	self._start_and_login_data = nil
end

function DataManager:cleanTipsData()
	self._tipsData = nil
end

function DataManager:getChatData()
	if self._chatDataHandle == nil then
		self._chatDataHandle = chatDataHandle.new()
	end
	return self._chatDataHandle
end

function DataManager:cleanChatData()
	self._chatDataHandle = nil
end

function DataManager:getTradeCompleteData()
	if self._tradeCompleteDataHandler == nil then
		self._tradeCompleteDataHandler = ClsTradeCompleteDataHandler.new()
	end
	return self._tradeCompleteDataHandler
end

function DataManager:cleanTradeCompleteData()
	self._tradeCompleteDataHandler = nil
end

function DataManager:getQuestionPaperData()
	if self._questionPaperData == nil then
		self._questionPaperData = ClsQuestionPaperDataHandler.new()
	end
	return self._questionPaperData
end

function DataManager:cleanQuestionPaperData()
	self._questionPaperData = nil
end

function DataManager:getArenaData()
	if self._arenaData == nil then
		self._arenaData = arenaDataHandle.new()
	end
	return self._arenaData
end

function DataManager:cleanArenaData()
	self._arenaData = nil
end

function DataManager:getPortData()
	if self._portData == nil then
		self._portData = portData.new()
	end
	return self._portData
end

function DataManager:cleanPortData()
	self._portData = nil
end

function DataManager:getMarketData()
	if self._marketData == nil then
		self._marketData = marketData.new()
	end
	return self._marketData
end

function DataManager:cleanMarketData()
	self._marketData = nil
end

function DataManager:getSailorUpLevelData()
	if self._sailorUpLevelData == nil then
		self._sailorUpLevelData = sailorUpLevelData.new()
	end
	return self._sailorUpLevelData
end

function DataManager:cleanSailorUpLevelData()
	self._sailorUpLevelData = nil
end

function DataManager:getBoatData()
	if self._boatData == nil then
		self._boatData = boatData.new()
	end
	return self._boatData
end

function DataManager:cleanBoatData()
	self._boatData = nil
end

function DataManager:getShipData()
	if self.ship_data == nil then
		self.ship_data = ClsShipData.new()
	end
	return self.ship_data
end

function DataManager:cleanShipData()
	self.ship_data = nil
end

function DataManager:getBattleDataMt()
	if self._battleDataMt == nil then
		self._battleDataMt = battleDataMt.new()
	end
	return self._battleDataMt
end

function DataManager:cleanBattleDataMt()
	self._battleDataMt = nil
end

-- 新舰队数据
function DataManager:getNewFleetData()
	if self._newFleetData == nil then
		self._newFleetData = ClsFleetData.new()
	end
	return self._newFleetData
end

function DataManager:cleanNewFleetData()
	self._newFleetData = nil
end

--公会任务
function DataManager:getGuildTaskData()
	if self._guildTaskData == nil then
		self._guildTaskData = guildTaskData.new()
	end
	return self._guildTaskData
end

function DataManager:cleanGuildTaskData()
	self._guildTaskData = nil
end

function DataManager:getGuildInfoData()
	if self._guildInfoData == nil then
		self._guildInfoData = guildInfoData.new()
	end
	return self._guildInfoData
end

function DataManager:cleanGuildInfoData()
	self._guildInfoData = nil
end

--好友数据
function DataManager:getFriendDataHandler()
	if self._frientHandlerData == nil then
		self._frientHandlerData = friendDataHandle.new()
	end
	return self._frientHandlerData
end

function DataManager:cleanFriendDataHandler()
	self._frientHandlerData = nil
end

-- 玩家数据
function DataManager:getPlayerData()
	if self._playerData == nil then
		self._playerData = playerData.new()
	end
	return self._playerData
end

function DataManager:cleanPlayerData()
	self._playerData = nil
	IS_SYNC_SERVER_TIME = false
end

--任务数据
function DataManager:getMissionData()
	if self._missionData == nil then
		self._missionData = missionDataHandle.new()
	end
	return self._missionData
end

function DataManager:cleanMissionData()
	-- require("gameobj/mission/dialogSequence"):resetSequence()
	require("gameobj/mission/gamePlot"):resetPlot()
	require("gameobj/guide/clsGuideMgr"):cleanAllGuide()
	self._missionData = nil
end

--登录奖励数据
function DataManager:getLoginVipAwardData()
	if self._loginVipAwardData == nil then
		self._loginVipAwardData = loginVipAwardData.new()
	end
	return self._loginVipAwardData
end

function DataManager:cleanLoginVipAwardData()
	self._loginVipAwardData = nil
end

--港口pve数据
function DataManager:getPortPveData()
	if self._portPveData == nil then
		self._portPveData = portPveData.new()
	end
	return self._portPveData
end

function DataManager:cleanPortPveData()
	self._portPveData = nil
end

--系统开关数据
function DataManager:getOnOffData()
	if self._onOffData == nil then
		self._onOffData = onOffData.new()
	end
	return self._onOffData
end

function DataManager:cleanOnOffData()
	self._onOffData = nil
end

--船长系统数据
function DataManager:getCaptainInfoData()
	if self._captainInfoData == nil then
		self._captainInfoData = captainInfoData.new()
	end
	return self._captainInfoData
end

function DataManager:cleanCaptainInfoData()
	self._captainInfoData = nil
end

--材料数据
function DataManager:getMaterialData()
	if self._materialData == nil then
		self._materialData = materialDataHandle.new()
	end
	return self._materialData
end

function DataManager:cleanMaterialData()
	self._materialData = nil
end

--地图数据
function DataManager:getExploreMapData()
	if self._exploreMapData == nil then
		self._exploreMapData = exploreMapData.new()
	end
	return self._exploreMapData
end

function DataManager:cleanExploreMapData()
	self._exploreMapData = nil
end

--红点数据
function DataManager:getTaskData()
	if self._taskData == nil then
		self._taskData = taskData.new()
	end
	return self._taskData
end

function DataManager:cleanTaskData()
	self._taskData = nil
end

--成就数据
function DataManager:getAchieveData()
	if self._achieveData == nil then
		self._achieveData = achieveData.new()
	end
	return self._achieveData
end

function DataManager:cleanAchieveData()
	self._achieveData = nil
end

--投资数据
function DataManager:getInvestData()
	if self._investData == nil then
		self._investData = investData.new()
	end
	return self._investData
end

function DataManager:cleanInvestData()
	self._investData = nil
end

-- 宝物
function DataManager:getBaowuData()
	if self._baowuData == nil then
		self._baowuData = baowuData.new()
	end
	return self._baowuData
end

function DataManager:cleanBaowuData()
	self._baowuData = nil
end

--补给
function DataManager:getSupplyData()
	if self._supplyData == nil then
		self._supplyData = supplyData.new()
	end
	return self._supplyData
end

function DataManager:cleanSupplyData()
	self._supplyData = nil
end


--收集其中包括了藏宝图和黑人商店
function DataManager:getCollectData()
	if self._collectData == nil then
		self._collectData = collectDataHandle.new()
	end
	return self._collectData
end

function DataManager:cleanCollectData()
	self._collectData = nil
end

--道具数据
function DataManager:getPropDataHandler()
	if self.prop_data_handler == nil then
		self.prop_data_handler = ClsPropDataHandle.new()
	end
	return self.prop_data_handler
end

function DataManager:cleanPropdataHandler()
	self.prop_data_handler = nil
end

--物品数据类
function DataManager:getBagDataHandler()
	if self.bag_data_handler == nil then
		self.bag_data_handler = ClsBagDataHandle.new()
	end
	return self.bag_data_handler
end

function DataManager:cleanBagdataHandler()
	self.bag_data_handler = nil
end

-- 商店
function DataManager:getShopData()
	if self._shopData == nil then
		self._shopData = shopData.new()
	end
	return self._shopData
end

function DataManager:cleanShopData()
	self._shopData = nil
end

--掠夺数据
function DataManager:getLootData()
	if self._lootData == nil then
		self._lootData = lootDataHandle.new()
	end
	return self._lootData
end

function DataManager:cleanLootData()
	self._lootData = nil
end

--遗迹
function DataManager:getRelicData()
	if self._relicData == nil then
		self._relicData = relicDataHandle.new()
	end
	return self._relicData
end

function DataManager:cleanRelicData()
	self._relicData = nil
end

-- 活动
function DataManager:getActivityData()
	if self._activityData == nil then
		self._activityData = activityData.new()
	end
	return self._activityData
end

function DataManager:cleanActivityData()
	if self._activityData and type(self._activityData.stopHeartBeat) == "function" then
		self._activityData:stopHeartBeat()
	end
	self._activityData = nil
end

--探索
function DataManager:getExploreData()
	if self._exploreData == nil then
		self._exploreData = exploreData.new()
	end
	return self._exploreData
end

function DataManager:cleanExploreData()
	if not self._exploreData then return end
	self._exploreData:clearData()
	self._exploreData = nil
end

--自动经商出海AI数据管理
function DataManager:getAutoTradeAIHandler()
	if self.auto_trade_ai_handler == nil then
		self.auto_trade_ai_handler = ClsAutoTradeAIHandler.new()
	end
	return self.auto_trade_ai_handler
end

function DataManager:cleanAutoTradeAIHandler()
	if self.auto_trade_ai_handler then--当有自动经商AI过程中，处理下
		self.auto_trade_ai_handler:stopTradeAI()
	end
	self.auto_trade_ai_handler = nil
end

-- 精英战役数据类
function DataManager:getBattleInfoConfigData()
	if self.battle_info_config_data == nil then
		self.battle_info_config_data = ClsBattleInfoConfigDataHandle.new()
	end

	return self.battle_info_config_data
end

function DataManager:cleanBattleInfoConfigData()
	self.battle_info_config_data = nil
end

-- 技能数据类
function DataManager:getSkillData()
	if self.skill_data == nil then
		self.skill_data = ClsSkillData.new()
	end

	return self.skill_data
end

function DataManager:cleanSkillData()
	self.skill_data = nil
end

function DataManager:getBuffStateData()
	if self._buff_state_data == nil then
		self._buff_state_data = ClsBuffStateData.new()
	end
	return self._buff_state_data
end

function DataManager:cleanBuffStateData()
	self._buff_state_data = nil
end

function DataManager:getExplorePlayerShipsData()
	if self._explore_player_ships_data == nil then
		self._explore_player_ships_data = ClsExplorePlayerShipsData.new()
	end
	return self._explore_player_ships_data
end

function DataManager:cleanExplorePlayerShipsData()
	self._explore_player_ships_data = nil
end

function DataManager:getPlayersDetailData()
	if self._players_detail_data == nil then
		self._players_detail_data = ClsPlayersDetailData.new()
	end
	return self._players_detail_data
end

function DataManager:cleanPlayersDetailData()
	self._players_detail_data = nil
end

function DataManager:getTeamData()
	if self._team_data == nil then
		self._team_data = ClsTeamData.new()
	end
	return self._team_data
end

function DataManager:cleanTeamData()
	self._team_data = nil
end

function DataManager:getWarningData()
	if not self._warning_data then
		self._warning_data = ClsWarningData.new()
	end
	return self._warning_data
end

function DataManager:cleanWarningData()
	self._warning_data = nil
end

function DataManager:getBroadcastData()
	if not self._broadcast_data then
		self._broadcast_data = ClsBroadcastData.new()
	end
	return self._broadcast_data
end

function DataManager:cleanBroadcastData()
	self._broadcast_data = nil
end

function DataManager:getWorldMissionData()
	if not self._world_mission_data then
		self._world_mission_data = clsWorldMissionData.new()
	end
	return self._world_mission_data
end

function DataManager:clearWorldMissionData()
	self._world_mission_data = nil
end

function DataManager:getConvoyMissionData()
	if not self._convoy_mission_data then
		self._convoy_mission_data = clsConvoyMissionData.new()
	end
	return self._convoy_mission_data
end

function DataManager:clearConvoyMissionData()
	self._convoy_mission_data = nil
end

function DataManager:getSailorData()
	if self._sailorData == nil then
		self._sailorData = sailorData.new()
	end
	return self._sailorData
end

function DataManager:cleanSailorData()
	self._sailorData = nil
end

function DataManager:cleanSeaStarData()
	self._seaStarData = nil
end

function DataManager:getSeaStarData()
	if self._seaStarData == nil then
		self._seaStarData = ClsSeaStarDataHandle.new()
	end
	return self._seaStarData
end

function DataManager:getFestivalActivityData()
	if self._festivalActivityData == nil then 
		self._festivalActivityData = ClsFestivalActivityData.new()
	end
	return self._festivalActivityData
end

function DataManager:cleanFestivalActivityData()
	self._festivalActivityData = nil
end

-- 清除所有数据
function DataManager:cleanAll()
	self:cleanBaowuData()
	self:cleanBroadcastData()
	self:cleanPlayerData()
	self:cleanMissionData()
	self:cleanShopData()
	self:cleanGuildTaskData()
	self:cleanFriendDataHandler()
	self:cleanActivityData()
	self:cleanGuildInfoData()
	self:cleanNewFleetData()
	self:cleanLoginVipAwardData()
	self:cleanPortPveData()
	self:cleanOnOffData()
	self:cleanCaptainInfoData()
	self:cleanMaterialData()
	self:cleanExploreMapData()
	self:cleanTaskData()
	self:cleanInvestData()
	self:cleanLootData()
	self:cleanSailorData()
	self:cleanRelicData()
	self:cleanSupplyData()
	self:cleanCollectData()
	self:cleanBoatData()
	self:cleanShipData()
	self:cleanAchieveData()
	self:cleanSailorUpLevelData()
	self:cleanMarketData()
	self:cleanPortData()
	self:cleanArenaData()
	self:cleanChatData()
	self:cleanTradeCompleteData()
	self:cleanQuestionPaperData()
	self:cleanTipsData()
	self:cleanBattleData()
	self:cleanGuildBossData()
	self:cleanGuildPrestigeData()
	self:cleanGuildShopData()
	self:cleanBattleDataMt()
	self:cleanGuildSearchData()
	self:cleanGuildBuffData()
	self:cleanTitleData()
	self:cleanDailyCourseData()
	self:cleanDailyActivityData()
	self:cleanWorldMapAttrsData()
	self:cleanAutoTradeAIHandler()
	self:clearMailData()
	self:cleanExploreData()
	self:cleanStartAndLoginData()
	self:cleanPropdataHandler()
	self:cleanBagdataHandler()
	self:cleanBattleInfoConfigData()
	self:cleanSkillData()
	self:cleanSeaStarData()
	self:cleanBuffStateData()
	self:clearBayData()
	self:cleanExplorePlayerShipsData()
	self:cleanPlayersDetailData()
	self:cleanTeamData()
	self:cleanCopySceneData()
	self:clearNobiliyData()
	self:cleanPartnerData()
	self:cleanExploreNpcData()
    self:cleanExplorePirateEventData()
    self:cleanSceneDataHandler()
    self:cleanExploreRewardPirateEventData()
    self:cleanAreaCompetitionData()
    self:clearVirtuaTeamData()
    self:cleanWarningData()
    self:clearWorldMissionData()
    self:clearConvoyMissionData()
    self:clearMissionPirateData()
    self:clearNetRes()
    self:clearGuildFightData()
    self:cleanGrowthFundData()
    self:clearShareData()
	self:clearMunicipalWorkData()
	self:clearGainBackData()
	self:clearAreaRewardData()
	self:clearBaseSkillData()
	self:clearPortBattleData()
	self:clearRankData()
	self:clearCityChallengeData()
	self:cleanFestivalActivityData()
end


---------------------------------------------------------
-- global 单例
local game_data = nil

function getGameData()
	if game_data == nil then
		game_data = DataManager.new()
	end
	return game_data
end

function cleanGameData()
	print("=============================调用了cleanGameData")
	if game_data then
		game_data:cleanAll()
		game_data = nil
	end
end


return DataManager
