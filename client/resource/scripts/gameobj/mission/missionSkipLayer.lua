---任务跳转到指定层
require("ui/tools/MyMenu")
require("ui/tools/MyMenuItem")
require("gameobj/port/clsPortEffect")
require("gameobj/port/portAnimation")
require("gameobj/port/portFunc")
require("gameobj/mission/missionInfo")
local BoatsCollectUI=require("gameobj/collectRoom/clsCollectMainUI")
local Alert = require("ui/tools/alert")
local clsGuildMultiDetails = require("gameobj/guild/clsGuildTaskMulDetails")
local ClsCollectSailorUI = require("gameobj/collectRoom/clsCollectSailorUI")
local ClsUiWord = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local error_info = require("game_config/error_info")
local skipLayer = {}

local toPeerages
toPeerages = function()
	return getUIManager():create("ui/clsNobilityUI")
end
local toActivity
toActivity = function()
	return getUIManager():create("gameobj/activity/clsActivityMain")
end

local toTreasureMapLayer
toTreasureMapLayer = function()
	return getUIManager():create("gameobj/treasureMapLayer")
end

--执行任务绿字触发的藏宝图
local toTreasureMap
toTreasureMap = function()
	-- 判断是否使用藏宝图
	local is_use_treasuremap = getGameData():getPropDataHandler():isUseTreasureMap()
	if is_use_treasuremap then
		return getUIManager():create("gameobj/treasureMapLayer")
	else
		return getUIManager():create("gameobj/activity/clsActivityMain")
	end
end

local toSeaStar
toSeaStar = function()
	return getUIManager():create("gameobj/welfare/clsWelfareMain",nil,5)
end

local toGrowthFund
toGrowthFund = function()
	return getUIManager():create("gameobj/welfare/clsWelfareMain",nil,3)
end

---主角技能
local toRoleSkillLayer
toRoleSkillLayer = function()
	return getUIManager():create("gameobj/playerRole/clsRoleSkill", nil, INITIATIVE_SKILL)
end

---基础技能
local toRoleBaseSkillLayer
toRoleBaseSkillLayer = function()
	return getUIManager():create("gameobj/playerRole/clsRoleSkill", nil, ATTRIBUTE_SKILL)
end

--奖励界面
local toRewardLayer
toRewardLayer = function()
	return getUIManager():create("gameobj/welfare/clsWelfareMain", nil, 8)
end

---公会研究所学习页签
local toGuildSkillStudyTab
toGuildSkillStudyTab = function()
	return getUIManager():create("ui/clsGuildMainUI",nil,"guild_skill_study")
end

---公会研究所研究页签
local toGuildSkillResearchTab
toGuildSkillResearchTab = function()
	return getUIManager():create("ui/clsGuildMainUI",nil,"guild_skill_research")
end

---声望不足界面
local toPrestigeView
toPrestigeView = function()
	return getUIManager():create("ui/clsPrestigeMainUI")
end

---航海士任命列表
local toSailorAppointView
toSailorAppointView = function(  )
	return getUIManager():create("gameobj/port/clsAppointSailorUI",{},true)
end

--市政厅
local toTownLayer
toTownLayer = function()
	-- return createTown(ccp(0, 0))
	-- return clsPortTownUI.new()

	-- 等后续Ui框架优化,现在先这么处理
	-- 尝试获取
	local target_ui = getUIManager():get('clsPortTownUI')
	-- 如果不为空
	if not tolua.isnull(target_ui) then
		-- 先移除
		getUIManager():get("clsPortTownUI"):close()
	end
	-- 再添加
	return getUIManager():create('gameobj/port/clsPortTownUI',nil,1)
end

local toInvestReward
toInvestReward = function()
	return getUIManager():create("gameobj/welfare/clsInvestRewardView")
end

--交易所
local toMarketLayer
toMarketLayer = function()
	return getUIManager():create("gameobj/port/portMarket")
end

--酒馆
local toHotelLayer
toHotelLayer = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain")
	return hotelMain
end

--酒馆悬赏界面
local toHotelRewardLayer
toHotelRewardLayer = function()
	-- 等后续Ui框架优化,现在先这么处理
	-- 尝试获取
	local target_ui = getUIManager():get('clsPortTownUI')
	-- 如果不为空
	if not tolua.isnull(target_ui) then
		-- 先移除
		getUIManager():get("clsPortTownUI"):close()
	end
	-- 再添加
	return getUIManager():create('gameobj/port/clsPortTownUI',nil,2)
	-- return clsPortTownUI.new(2)
end

--酒馆招募界面
local toHotelRecruitLayer
toHotelRecruitLayer = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain")
	--hotelMain:skipPanel(HOTEL_RECRUIT)
	return hotelMain
end

--出海
local toPortSupply
toPortSupply = function()
	return getUIManager():create("gameobj/explore/portMap")
end

--出海-据点
local toPortShSupply
toPortShSupply = function()
	local portMap = getUIManager():create("gameobj/explore/portMap", nil, PortMap.TAB_INDEX_PVE)
	if portMap then
		portMap.defaultPveItemSelectTag = PortMap.ENEMY_SEA_STRONGHOLD
	end
	return portMap
end

--战役
local toBattleUI
toBattleUI = function(params, parent)
	return getUIManager():create("gameobj/battle/clsEliteBattle")
end

--港口掠夺
local toActivityLootUI
toActivityLootUI = function()
	return getUIManager():create("gameobj/explore/portMap", nil, PortMap.TAB_INDEX_LOOT)
end

--港口竞技场
local toArenaUI
toArenaUI = function(params, port)
	return getUIManager():create("gameobj/arena/clsArenaMainUI")
end


--航海士任命
local toRoomLayer
toRoomLayer = function()
	local layer = createRoomLayer()
	return layer
end

--收藏室
local toCollectUI
toCollectUI = function()

	local target_ui = getUIManager():get('ClsCollectMainUI')
	-- 如果不为空
	if not tolua.isnull(target_ui) then
		-- 先移除
		getUIManager():get("ClsCollectMainUI"):close()
	end
	-- 再添加
	target_ui = getUIManager():create('gameobj/port/clsCollectMainUI')
	return target_ui
end

--航海士列表
local toSailorList
toSailorList = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain", {}, 2)
	return hotelMain
end


---航海士宝物
local toSailorEquik
toSailorEquik = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain")
	return hotelMain
end

--水手招募
local toSailorRecruit
toSailorRecruit = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain")
	--hotelMain:skipPanel(HOTEL_RECRUIT)
	return hotelMain
end

--单挑设置
local toBattleAppoint
toBattleAppoint = function()
	local layer = sailorSetChallenge.new()
	return layer
end

--航海士列表
local toSailorStudy
toSailorStudy = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain", {}, HOTEL_REWARD)
	return hotelMain
end

--商店
local toShopLayer
toShopLayer = function()
	getUIManager():create("gameobj/mall/clsMallMain")
end

--商店充值界面
local toMallUIRecharge
toMallUIRecharge = function()
	getUIManager():create("gameobj/mall/clsMallMain", nil, 3)
end

local toMallUIItem
toMallUIItem = function()
	getUIManager():create("gameobj/mall/clsMallMain", nil, 2)
end

--系统界面
local toSystemLayer
toSystemLayer = function()
	return createSystemLayer()
end

--好友界面
local toFriendLayer
toFriendLayer = function()
	return getUIManager():create("gameobj/friend/clsFriendMainUI")
end

local toRegVipView
toRegVipView = function()
    -- if tolua.isnull(ClsElementMgr:get_element("ClsDailyCourseMain")) then
    --     return ClsDailyCourseMain.new(3)
    -- end
end

--每日活动主界面
local toDailyCourseMain
toDailyCourseMain = function()
	-- if tolua.isnull(getUIManager():get("ClsActivityMain")) then
	-- 	return getUIManager():create("gameobj/activity/clsActivityMain",nil,3)
	-- end
end

--传说活动
local toLegendActivityView
toLegendActivityView = function(params)
	-- if tolua.isnull(ClsElementMgr:get_element("ClsDailyCourseMain")) then
	-- 	return ClsDailyCourseMain.new(2, params)
	-- end
end

---投资收益
local toInvestRewardView
toInvestRewardView = function()
	-- if tolua.isnull(ClsElementMgr:get_element("ClsDailyCourseMain")) then
	-- 	return ClsDailyCourseMain.new(5)
	-- end
end

--公会系统
local toGuildUI
toGuildUI = function()
	-- return ClsGuildMainUI.new()
	return getUIManager():create("ui/clsGuildMainUI")
end

--公会大厅系统
local toGuildHallUI
toGuildHallUI = function()
	-- return ClsGuildMainUI.new("hall")
	return getUIManager():create("ui/clsGuildMainUI",nil,"hall")
end

--公会悬赏任务系统
local toGuildTaskUI = function()
	-- return ClsGuildMainUI.new("task")
	return getUIManager():create("ui/clsGuildMainUI",nil,"task")
end

--公会多人任务系统
local toGuildMultiTaskUI = function()
	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		return guild_main_ui:skipToPanel("guild_multi_task")
	end
	return getUIManager():create("ui/clsGuildMainUI",nil,"guild_multi_task")
end

local toGuildDetailMulti = function()
	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		return guild_main_ui:skipToPanel("task_detail_multi")
	end

	return getUIManager():create("ui/clsGuildMainUI",nil,"task_detail_multi")
end

--公会据点站前界面
local toGuildFightUI = function()
	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		return guild_main_ui:skipToPanel("guild_fight")
	end
	return getUIManager():create("ui/clsGuildMainUI",nil,"guild_fight")
end

--公会boss界面
local toGuildBossUI = function()
	local guild_id = getGameData():getGuildInfoData():getGuildId()
	if guild_id and guild_id > 0 then
		local guild_main_ui = getUIManager():get("ClsGuildMainUI")
		if not tolua.isnull(guild_main_ui) then
			return guild_main_ui:skipToPanel("boss")
		end
		return getUIManager():create("ui/clsGuildMainUI",nil,"boss")
	else
		Alert:warning({msg = ClsUiWord.PRESTIGE_NO_GUILD, size = 26})
		return
	end
end

local toGuildBossRankUI
toGuildBossRankUI = function()
	return toGuildBossUI()
end

--公会仓库界面
local toGuildShopMainUI
toGuildShopMainUI = function()
	-- return ClsGuildMainUI.new("shop")
	return getUIManager():create("ui/clsGuildMainUI",nil,"shop")
end

--公会仓库礼包界面
local toGuildShopGiftUI
toGuildShopGiftUI = function()
	-- return ClsGuildMainUI.new("gift")
	return getUIManager():create("ui/clsGuildMainUI",nil,"gift")
end

--成就界面
local toAchieveUI
toAchieveUI = function()
	return getUIManager():create("ui/ClsAchievement")
end

--聊天界面
local toChatSystemUI
toChatSystemUI = function()
	return
end

local toSyllabusUI
toSyllabusUI = function()
	--return ClsDailyCourseMain.new()
end

local toFleetMainUI
toFleetMainUI = function(param)
end

local toMapUI
toMapUI = function(id, nav_type)
	local portMap = getUIManager():create("gameobj/explore/portMap")
	if portMap then
		portMap:showMax()
		if id and nav_type then
			portMap:turnToPointArea(id, nav_type)
		end
	end
	return portMap
end

--船厂界面船只商店
local toShipyardMain1
toShipyardMain1 = function()
	return getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_SHOP)
end

--造船厂建造
local toShipyardMain3
toShipyardMain3 = function()
	return getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_BUILD)
end

local toPortTeamUI
toPortTeamUI = function()
	getUIManager():create("gameobj/team/clsPortTeamUI")
end

local toGuildTaskMulti
toGuildTaskMulti = function()

end

local toMeleeEnterUI
toMeleeEnterUI = function()
	return getUIManager():create("ui/clsMeleeEnterUI")
end

--跳转到组队寻宝
local toTeamTreasure
toTeamTreasure = function()
	getUIManager():create("gameobj/team/clsPortTeamUI", nil, 4, nil, nil, true)
end

--跳转到海神的跳转
local toTeamHaishenFight
toTeamHaishenFight = function()
	getUIManager():create("gameobj/team/clsPortTeamUI", nil, 5, nil, nil, true)
end

--组队海域争霸
local toTeamMineralPoint
toTeamMineralPoint = function()
	-- getUIManager():create("gameobj/team/clsPortTeamUI", nil, , nil, nil, true)
end

local toTradeCompete
toTradeCompete = function()
	return getUIManager():create("gameobj/activity/clsTradeCompete")
end

-- local toDailyRace
-- toDailyRace = function()
-- 	return ClsDailyCompetitionView.new()
-- end

--跳转到委任经商
local toAutoTrade
toAutoTrade = function()
    return getUIManager():create("gameobj/port/portMarket", nil, nil, 1) --1再打开委任经商界面
end

--任务跳转到背包
local toBackPack
toBackPack = function()
	return getUIManager():create("gameobj/backpack/clsBackpackMainUI")
end

local toBackPackOther
toBackPackOther = function()
	return getUIManager():create("gameobj/backpack/clsBackpackMainUI", nil, BACKPACK_TAB_OTHER)
end

--跳转到背包船舶装备界面
local toBackpackBoatEquipUI
toBackpackBoatEquipUI = function()
    return getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_EQUIP)
end

--跳转到背包船舶强化界面
local toBackpackBoatStrengthenUI
toBackpackBoatStrengthenUI = function()
    return getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_STRENGTHEN)
end

--跳转到背包船舶洗练界面
local toBackpackBoatRefineUI
toBackpackBoatRefineUI = function()
	return getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_REFINE)
end

--跳转到背包船舶洗练界面
local toBackpackBaowuRefineUI
toBackpackBaowuRefineUI = function()
    return getUIManager():create("gameobj/backpack/clsBaowuRefineUI")
end

--任务跳转到伙伴
local toPartnerLayer
toPartnerLayer = function()

end

--任务跳转到主角
local toCharacterLayer
toCharacterLayer = function()
	getUIManager():create("gameobj/playerRole/clsRoleInfoView")
end

--跳转到组队经商
local toTeamMarket
toTeamMarket = function()
	getUIManager():create("gameobj/team/clsPortTeamUI", nil, 2, nil, nil, true)
end

--跳转到组队掠夺
local toTeamPlunder
toTeamPlunder = function()
	-- getUIManager():create("gameobj/team/clsPortTeamUI", nil, 2, 1)
end

--组队精英战役
local toTeamBattleFight
toTeamBattleFight = function()
	-- local team_data = getGameData():getTeamData()
	-- if not team_data:isInTeam() then
 --        Alert:warning({msg = ClsUiWord.ELITE_BATTLE_CRAETE_TEAM_TIPS})
 --    end
 --    getUIManager():create("gameobj/team/clsPortTeamUI", nil, 3, 1, nil, not team_data:isInTeam())
end

--跳转到组队悬赏
local toTeamWanted
toTeamWanted = function()
	getUIManager():create("gameobj/team/clsPortTeamUI", nil, 3, nil, nil, true)
end

--跳到组队贸易竞争
local toTeamTrade
toTeamTrade = function()
	-- getUIManager():create("gameobj/team/clsPortTeamUI",, nil, 4, 1, nil, nil, true)
end

-- 跳转到风云大赛组队
local toTeamFarArena
toTeamFarArena = function()
	-- getUIManager():create("gameobj/team/clsPortTeamUI",, nil, 4, 3, nil, nil, true)
end

local toTeamSevenSea
toTeamSevenSea = function()
	-- getUIManager():create("gameobj/team/clsPortTeamUI",, nil, 4, 2)
end
--限时活动
local toTimeActivity
toTimeActivity = function()
	if tolua.isnull(getUIManager():get("ClsActivityMain")) then
		return getUIManager():create("gameobj/activity/clsActivityMain",nil,2)
	end
end
--跳转到编制界面
local toFleetStaffUI
toFleetStaffUI = function()
	return getUIManager():create("gameobj/fleet/clsFleetPartner")
end

local toFarArena
toFarArena = function()
	print("功能被删除了-------------------")
end

local toRoleSkillPage
toRoleSkillPage = function()
	getUIManager():create("gameobj/playerRole/clsRoleInfoView",nil,nil, 3)
end

local toGoSeaSmallMap
toGoSeaSmallMap = function()
	local activity_panel = getUIManager():get("ClsActivityMain")
	if activity_panel and not tolua.isnull(activity_panel) then
		-- activity_panel:removeFromParentAndCleanup(true)
		activity_panel:destroy()
	end
    skipLayer:skipPortLayer()
end

local toVipMonthCard
toVipMonthCard = function()
	return getUIManager():create("gameobj/welfare/clsWelfareMain",nil,1)
end

local toMunicipalWork
toMunicipalWork = function()
	local on_off_data = getGameData():getOnOffData()
	if not on_off_data:isOpen(on_off_info.TOWN_WORK.value) then
		return
	end
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		getUIManager():create("gameobj/port/clsPortTownUI", nil, 2)
	end
end


--小地图海域争霸
local toMineralPoint
toMineralPoint = function(mineral_point_id)
	skipLayer:skipPortLayer({mineral_point_id = mineral_point_id})
end

--展开大地图
local toWorldMap
toWorldMap = function()
	skipLayer:skipPortWorldMapLayer()
end

--传奇航海士觉醒
local toSailorAwake
toSailorAwake = function()
	local hotelMain = getUIManager():create("gameobj/hotel/clsHotelMain", {}, 3)
	return hotelMain
end

local toActivitySailorAwake
toActivitySailorAwake = function()
	if tolua.isnull(getUIManager():get("ClsActivityMain")) then
		return getUIManager():create("gameobj/activity/clsActivityMain",nil,5)
	end
end

--每日礼包
toDailyGift = function()
	return getUIManager():create("gameobj/welfare/clsWelfareMain",nil,4)
end

local toPortFight
toPortFight = function()
	-- local port_battle_data = getGameData():getPortBattleData()
	-- port_battle_data:askApplyPortsInfo()
	if getGameData():getGuildInfoData():getGuildGrade() < 30 then 
		Alert:warning({msg = error_info[870].message})
	else
		getUIManager():create("gameobj/port/clsPortBattleMainUI")
	end
end

--此接口不提供策划使用，如果策划需要跳转则通过toPortFight跳转
local toPortFightUI
toPortFightUI = function()
	getUIManager():create("gameobj/port/clsPortTownUI", nil, 3)
end

local toCityChallenge
toCityChallenge = function()
	if getGameData():getTeamData():isLock(true) then return end
	getUIManager():close("ClsActivityMain")
	getGameData():getCityChallengeData():askCityTask()
end

local toGoPortSmallMap
toGoPortSmallMap = function(port_id)
	skipLayer:skipPortLayer({port_id = port_id})
end

local toFestivalActivity
toFestivalActivity = function()
	local error_code = 643
	-- 关闭背包跳过去
	if getGameData():getFestivalActivityData():isAlredayStarted() then 
		getUIManager():close("ClsBackpackMainUI")
		getUIManager():create("gameobj/festival/clsFestivalActivityMain")
	else
		Alert:warning({msg = require("game_config/error_info")[error_code].message})
	end
end

--跳转到QQ/微信特权界面
local toGameCenter
toGameCenter = function()
	getUIManager():create("gameobj/tips/clsBootRewardTips")
end

--公会捐赠
local function toGuildDoanteUI()
	return getUIManager():create("ui/clsGuildMainUI", nil, "donate")
end

--各界面对应的跳转名
local SKIP_LAYER = {
	["time_activity"] = toTimeActivity,
	["reward"] = toRewardLayer,
	["role_skill"] = toRoleSkillLayer,
	["role_base_skill"] = toRoleBaseSkillLayer,
	["town"] = toTownLayer,
	["market"] = toMarketLayer,
	["hotel"] = toHotelLayer,
	["ports"] = toPortSupply,
	["stronghold"] = toPortShSupply,
	["fight"] = toBattleUI,
	["loot"] = toActivityLootUI,
	["arena"] = toArenaUI,
	["recruit"] = toSailorRecruit,
	["system"] = toSystemLayer,
	["friend"] = toFriendLayer,
	["foster"] = toSailorStudy,
	["singled"] = toBattleAppoint,
	["guild"] = toGuildUI,
	["guild_hall"] = toGuildHallUI,
	["guild_task"] = toGuildTaskUI,
	["guild_multi_task"] = toGuildMultiTaskUI,
	["guild_detail_multi"] = toGuildDetailMulti,
	["guild_stronghold_fire"] = toGuildFightUI,
	["guild_boss"] = toGuildBossUI,
	["guild_boss_rank"] = toGuildBossRankUI,
	["guild_shop"] = toGuildShopMainUI,
	["guild_gift"] = toGuildShopGiftUI,
	["achieve"] = toAchieveUI,
	["hotelReward"] = toHotelRewardLayer,
	["hotelRecruit"] = toHotelRecruitLayer,
	["regVipView"] = toRegVipView,
	["captainLv"] = toCaptainUI,
	["chatSystem"] = toChatSystemUI,
	["competition"] = toDailyCourseMain,
	["syllabus"] = toSyllabusUI,
	["map"] = toMapUI,
	["daily_gift"] = toDailyGift,
	["switch_mission"] = toSwitchMission,
	["fleet_main"] = toFleetMainUI,
	["daily_course_main"] = toDailyCourseMain,
	["daily_invest_reward"] = toInvestRewardView,
	["legend_activity"] = toLegendActivityView,
	["shipyard_shop"] = toShipyardMain1,
	["shipyard_create"] = toShipyardMain3,
	["sailor_list"] = toSailorList,
	["sailor_equik"] = toSailorEquik,
	["invest_reward"] = toInvestReward,
	["shop_main"] = toShopLayer,
	["mall_charge"] = toMallUIRecharge,
	["mall_item"] = toMallUIItem,
	["team"] = toPortTeamUI,
	["guild_task_multi"] = toGuildTaskMulti,
	["team_treasure"] = toTeamTreasure,
	["team_haishen"] = toTeamHaishenFight,
	["team_mineral_point"] = toTeamMineralPoint,
	['team_plunder_trade'] = toTradeCompete,
	-- ['everyday_race'] = toDailyRace,
	['newstar'] = toSeaStar,
	["far_arena"] = toFarArena,
	["treasure_map"] = toTreasureMapLayer,
	["auto_trade"] = toAutoTrade,
	["backpack"] = toBackPack,
	["backpack_other"] = toBackPackOther,
	["backpack_boat_equip"] = toBackpackBoatEquipUI,
	["backpack_boat_Strengthen"] = toBackpackBoatStrengthenUI,
	["backpack_boat_refine"] = toBackpackBoatRefineUI,
	["backpack_baowu_refine"] = toBackpackBaowuRefineUI,
	["partner"] = toPartnerLayer,
	["character"] = toCharacterLayer,
	["activity"] = toActivity,
	["peerages"] = toPeerages,
	["team_market"] = toTeamMarket,
	["team_plunder"] = toTeamPlunder,
	["team_fight"] = toTeamBattleFight,
	["team_wanted"] = toTeamWanted,
	["team_trade"] = toTeamTrade,
	["explore_pos"] = toPortSupply,
	["ship_build"] = toShipyardMain3,
	["fomation"] = toFleetStaffUI,
	["skill_page"] = toRoleSkillPage,
	["small_map"] = toGoSeaSmallMap,
	["vip_monthcard"] = toVipMonthCard,
	["team_seven_sea"] = toTeamSevenSea,
	["team_seven"] = toTeamSevenSea,
	["team_far_arena"] = toTeamFarArena,
	["smash"] = toMeleeEnterUI,
	["yijiX_explore"] = toPortSupply,
	["mineral_point"] = toMineralPoint,
	["pool"] = toPortSupply,
	["municipal_work"] = toMunicipalWork,
	["world_mission"] = toWorldMap,
	["guild_study"] = toGuildSkillStudyTab,
	["guild_research"] = toGuildSkillResearchTab,
	["prestige"] = toPrestigeView,
	["sailor_awake"] = toSailorAwake,
	["activity_sailor_awake"] = toActivitySailorAwake,
	["sailor_appoint"] = toSailorAppointView,
	["growth_fund"] = toGrowthFund,
	["port_fight"] = toPortFight,
	["port_fight_ui"] = toPortFightUI,
	["city_challenge"] = toCityChallenge,
	["small_map_port"] = toGoPortSmallMap,
	["special_picture"] = toTreasureMap,
	["wuyi_activity"] = toFestivalActivity,
	["duanwu_activity"] = toFestivalActivity,
	["start_gamecenter"] = toGameCenter,
	["guild_donate"] = toGuildDoanteUI,
}

local SKIP_LAYER_EFFECT = {
	["reward"] = false,
	["peerages"] = false,
	["fight"] = false,
}


--得到跳转界面的name(SKIP_LAYER里对应的)
--missionId：任务ID；skipId：该任务对应的第几个跳转(默认第一个)
skipLayer.getSkipName = function(self, missionId, skipId)
	skipId = skipId or 1
	local mission_info = getMissionInfo()
	local mission_tab = mission_info[missionId]
	if not mission_tab then
		return
	end
	local skip_info = mission_tab.skip_info
	if skip_info then
		local skipTab = skip_info[skipId].skip
		local skip = skipTab[1]
		if type(skip) == "string" and SKIP_LAYER[skip] then
			return skip
		end
	end
	return nil
end

--跳转到“出海”
--[[parameter = {
		port_id = ,
		time_private_id = ,
		mineral_point_id = ,

	}
]]

skipLayer.skipPortLayer = function(self, parameter)
	local portMap = getUIManager():create("gameobj/explore/portMap")
	if tolua.isnull(portMap) then return end

	portMap:showMax()
	parameter = parameter or {}
	if parameter.port_id then
		-- 请求任务指向的港口的投资信息
		print('----------------------port_id--------- ',parameter.port_id)
		getGameData():getInvestData():sendPortInvest(parameter.port_id)
		portMap:turnToPointArea(parameter.port_id, EXPLORE_NAV_TYPE_PORT)
	elseif parameter.time_private_id then
		portMap:turnToPointArea(parameter.time_private_id, EXPLORE_NAV_TYPE_TIME_PIRATE)
	-- elseif parameter.mineral_point_id then
	-- 	portMap:turnToPointArea(parameter.mineral_point_id, EXPLORE_NAV_TYPE_MINERAL_POINT)
	end
end

skipLayer.skipPortWorldMapLayer = function(self)
	local explore_map = getUIManager():get("ExploreMap")
	if not tolua.isnull(explore_map) then
		getUIManager():removeViewOnFront("ClsExploreBackLayer")
		explore_map:showMax()
		explore_map:turnToWorldExt()
		return
	end
	local portMap = getUIManager():create("gameobj/explore/portMap")
	if tolua.isnull(portMap) then return end
	portMap:showMax()
	portMap:turnToWorldExt()
end

skipLayer.skipSailorCollectUI = function(self, parent, uid, from, sailor_id)
	local collectData = getGameData():getCollectData()
	collectData:askFriendOwnSailors(uid, function()
		local data = {}
		data.player_id = uid
		data.from = from 
		data.sailor_id = sailor_id
		getUIManager():create('gameobj/collectRoom/clsCollectSailorUI',nil,data)
	end)
end

--如果name名是出海，则跳转到出海，否则返回nil
skipLayer.isSkipPortLayer = function(self, name)
	if name == "ports" then
		self:skipPortLayer()
	end
	return nil
end

--返回需要跳转的层(跳转层name，需要的参数)
skipLayer.skipLayerByName = function(self, name, params, parent)
	if SKIP_LAYER[name] == nil then return nil end
	return SKIP_LAYER[name](params, parent)
end

--返回需要跳转的层(跳转层name，需要的参数)
skipLayer.skipToLayer = function(self, name, params)
	local layer = self:skipLayerByName(name, params)
	if layer then
		EventTrigger(EVENT_ADD_PORT_ITEM, layer, nil, false)
	end
end

--返回需要跳转的层是否需要界面淡入淡出效果
skipLayer.needSkipEffectByName = function(self, name)
	if SKIP_LAYER_EFFECT[name] == nil then return true end
	return SKIP_LAYER_EFFECT[name]
end

return skipLayer
