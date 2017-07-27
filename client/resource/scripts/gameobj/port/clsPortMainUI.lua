--
-- Author: clr
-- Date: 2016-02-16 14:54:22
--
local on_off_info = require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local news = require("game_config/news")
local voice_info = getLangVoiceInfo()
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local UiCommon = require("ui/tools/UiCommon")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local info_title = require("game_config/title/info_title")
local composite_effect = require("gameobj/composite_effect")
local sailor_info = require("game_config/sailor/sailor_info")
local item_info = require("game_config/propItem/item_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

local POP_WINDOW_ITEM = 1 --获得道具弹框
local POP_WINDOW_INVEST = 2 --投资奖励弹框
local POP_WINDOW_BOAT = 3  --装备中的船
local POP_WINDOW_BAOWU = 4 --装备中的宝物类


local TREASURE_MAP_ID = 80 ---藏宝图id

local CLICK_CLOSE_BTN = 1 --点击了关闭按钮
local TRUELY_USE_ITEM = 0 --使用掉了弹框

local ITEM_USE_TYPE = 1  --图纸类型
local ITEM_USE_BAOWU_BOX = 2  --宝物盒子

local STAR_STATUS_OPEN = 1 --海上新星
local STAR_STATUS_CLOSE = 0

local ACTIVITY_PRE_OPEN = 1 --活动预开放
local ACTIVITY_OPEND = 2 --活动开始中
local FUNC_PRE_OPEN = 3 --功能预开放
local NO_SAIL_MISSION = {
	70,
	72,
}

local ClsPortMainUI = class("ClsPortMainUI", function()
	return UIWidget:create()
end)

ClsPortMainUI.ctor = function(self)
	self.MAX_POWER = 900
	self.key_open_list = {}
	self.btn_list = {}
	self:mkUi()
	self:askBaseData()
	local player_data = getGameData():getPlayerData()
	self:setName(player_data:getName() or "")
	self:resetTimer()
end

ClsPortMainUI.askBaseData = function(self)
	-- 改为登录的时候请求活动数据
	-- local activityData = getGameData():getActivityData()
 --    activityData:askActivityInfo()

	local nobilityData = getGameData():getNobilityData()
	nobilityData:sendSyncNobilityInfo()

	local municipal_work_data = getGameData():getMunicipalWorkData()
	municipal_work_data:askTaskInfo()

	-- 请求世界任务数据.
	-- local controller = getGameData():getWorldMissionData()
	-- controller:askWorldMissionList()

end

ClsPortMainUI.mkUi = function(self)
	self.main_panel = GUIReader:shareReader():widgetFromJsonFile("json/main_port.json")
	convertUIType(self.main_panel)
	self:addChild(self.main_panel)

	self.info_effect_list = {}--玩家信息效果列表
	self.top_btn_effect_list = {}--顶部按钮效果列表
	self.building_effect_list = {}--左侧建筑效果列表
	self.buttom_effect_list = {}--底部按钮效果列表

	self.task_btn_list = {}

	local player_info_res = {
		{res = "top_banner", effect = {type = PORT_EFFECT_EASEINOUT, change = {0, -95}, delay = 0.2, action = {{0.2, 0, -18.8}, {0.13, 0, -67.75}, {0.2, 0, -8.45}}}},
		{res = "btn_player",on_off_key = on_off_info.CHARACTER_BUTTON.value, task_keys = {
				on_off_info.PORT_BULLY.value,
			}, click_fun = function() return self:openPlayerInfoHandler() end, effect = {type = PORT_EFFECT_EASEINOUT, change = {212, 0}, delay = 0.63, action = {{0.2, 218, 0}, {0.1, -12.8, 0}, {0.13, 6, 0}}}},
		{res = "player_name"},
		-- {res = "player_title_pic"},
		{res = "player_photo"},
		{res = "player_exp"},
		{res = "player_level"},
		-- {res = "player_title_icon"},
		{res = "player_title"},
		{res = "combat_ability_bg", effect = {type = PORT_EFFECT_EASEINOUT, change = {212, 0}, delay = 0.53, action = {{0.2, 218, 0}, {0.1, -13, 0}, {0.17, 6, 0}}}},
		{res = "combat_ability_num"},
		{res = "coin_icon_bg", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 1}, delay = 1.16, action = {{0.2, 1.114, 1.114}, {0.14, 1, 1}}}},
		{res = "coin_num_bg", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 1}, delay = 1.5, action = {{0.1, 1.114, 1}, {0.1, 0.94, 1}, {0.1, 1, 1}}}},
		{res = "coin_num"},
		{res = "diamond_icon_bg", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 1}, delay = 1.33, action = {{0.17, 1.114, 1.114}, {0.16, 1, 1}}}},
		{res = "diamond_num_bg", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 1}, delay = 1.66, action = {{0.1, 1.114, 1}, {0.1, 0.94, 1}, {0.1, 1, 1}}}},
		{res = "diamond_num"},
		{res = "port_name", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 0}, delay = 1.33, action = {{0.27, 0.405, 1}, {0.26, 1.115, 1}, {0.27, 0.965, 1}, {0.1, 1, 1}}, effect_res = {"tx_0119", 0, 20}, voice = "ENTER_PORT_NAME"}},
		{res = "btn_port_name", click_fun = function() return self:openPortInfoHandler() end},
		{res = "port_type"},
		{res = "port_name_text"},
		{res = "power_bg", effect = {type = PORT_EFFECT_ZOOMINOUT, change = {0, 1}, delay = 1.0, action = {{0.43, 1, 1}}, effect_res = {"tx_0120", 0, 0}}},
		{res = "power_progress"},
		{res = "power_btn_panel"},
		{res = "power_num"},
		{res = "btn_shop",on_off_key = on_off_info.SHOP_BUTTON.value, click_fun = function() return self:clickShopBtnHandler() end},
		{res = "tips_bg"},
		{res = "open_tips"},
		{res = "btn_buff_exp", click_fun = function() return self:clickExpBuffHandler() end},
		{res = "vip_qq", click_fun = function() return self:clickQQVipBtnHandler() end},
		{res = "btn_start", click_fun = function() return self:clickBootBtnHandler() end},
		{res = "wechat_icon"},
	}

	--左侧的建筑
	local building_res = {
		["building_bg"] = {res = "building_bg", effect_index = BUILDING_BTN_BG },
		["btn_town"] = {res = "btn_cityhall", on_off_key = on_off_info.PORT_TOWN.value, task_keys = {
				on_off_info.PORT_TOWN.value,
				on_off_info.TOWN_WORK.value,
			}, effect_index = BUILDING_BTN_1,
			animation = "tx_0124", animation_pos = {98, 4}, click_fun = function() return self:clickTownBtnHandler() end},
		["btn_market"] = {res = "btn_market", on_off_key = on_off_info.PORT_MARKET.value, task_keys = {
				on_off_info.PORT_MARKET.value,
			}, effect_index = BUILDING_BTN_2,
			animation = "tx_0122", animation_pos = {100, 4}, click_fun = function() return self:clickMarketBtnHandler() end, music = music_info.PORT_MARKET.res},
		["btn_shipyard"] = {res = "btn_shipyard", on_off_key = on_off_info.PORT_SHIPYARD.value, task_keys = {
				on_off_info.SHIPYARD_CREATE.value,
				on_off_info.DARK_MARKET.value,
				on_off_info.ASSEMBLE_BOX1.value,
				on_off_info.ASSEMBLE_BOX2.value,
				on_off_info.ASSEMBLE_BOX3.value,
				on_off_info.ASSEMBLE_BOX4.value,
				on_off_info.ASSEMBLE_BOX5.value,
				on_off_info.SHIPYARD_EQUIP_BOX1.value,
				on_off_info.SHIPYARD_EQUIP_BOX2.value,
				on_off_info.SHIPYARD_EQUIP_BOX3.value,
				on_off_info.SHIPYARD_EQUIP_BOX4.value,
				on_off_info.SHIPYARD_EQUIP_BOX5.value,
			}, effect_index = BUILDING_BTN_3,
			animation = "tx_0125", animation_pos = {101, 2}, click_fun = function() return self:clickShipyardBtnHandler() end, music = music_info.PORT_SHIPYARD.res},
		["btn_hotel"] = {res = "btn_tavern", on_off_key = on_off_info.PORT_HOTEL.value, task_keys = {
				on_off_info.WINE_ENLIST.value,--普通招募，包含免费次数
				on_off_info.PORT_HOTEL_ENLIST.value
				--on_off_info.RECRUIT_DIAMOND.value,--有免费豪爽招募次数
			}, effect_index = BUILDING_BTN_4,
			animation = "tx_0123", animation_pos = {104, 2}, click_fun = function() return self:clickHotelBtnHandler() end, music = music_info.PORT_PUB.res},
	}
	--上部的按钮
	local top_btn_list = {
		["btn_51"] = {res = "btn_51",  on_off_key = on_off_info.MAYDAY_ACTIVITY.value, effect_index = TOP_BTN_RIGHT_ROW_2_INDEX_3,
			click_fun = function() return self:openFestivalPanel() end},
		["btn_friend"] = {res = "btn_friend", on_off_key = on_off_info.MAIN_FRIEND.value, task_keys = {
				on_off_info.FRIEND_LIST.value,
				on_off_info.FRIEND_ADD.value,
				on_off_info.FRIEND_MY.value,
				on_off_info.ACCEPT_GIFTPAGE.value,
			}, effect_index = TOP_BTN_LEFT_ROW_1_INDEX_1,
			click_fun = function() return self:clickFriendBtnHandler() end, lab_padding = {"btn_friend_text", -5}},
		["btn_rank"] = {res = "btn_rank", on_off_key = on_off_info.RANKING_LIST_UI_BUTTON.value, effect_index = TOP_BTN_LEFT_ROW_1_INDEX_2,
			click_fun = function() return self:clickRankBtnHandler() end, lab_padding = {"btn_rank_text", -5}},
		["btn_mail"] = {res = "btn_mail", on_off_key = on_off_info.MAIL_SYSTEM.value, task_keys = {
				on_off_info.MAIL_SYSTEM.value,
			}, effect_index = TOP_BTN_LEFT_ROW_1_INDEX_3,
			click_fun = function() return self:clickMailBtnHandler() end, lab_padding = {"btn_mail_text", -5}},
		["btn_activity"] = {res = "btn_activity", on_off_key = on_off_info.ACTIVITY_BUTTON.value, task_keys = {
				on_off_info.ACTIVITY_DAILY.value, --每日目标有奖励可以领取
				on_off_info.ACTIVITY_EVERYDAY.value, --有活动（部分限定要求的活动）
				on_off_info.LEGEND_SAILOR_ACTIVITY.value, --新一轮的传奇航海士更新时
			}, effect_index = TOP_BTN_RIGHT_ROW_1_INDEX_2,
			click_fun = function() return self:clickActivityBtnHandler() end, lab_padding = {"btn_activity_text", -5}},
		["btn_award"] = {res = "btn_award", on_off_key = on_off_info.WELFARE_BUTTON.value, task_keys = {
				on_off_info.WELFARE_BUTTON.value, --福利按钮
				on_off_info.PEERAGES_FENHONG.value, --爵位分红
				on_off_info.WELFARE_LIXIAN.value, --离线收益
				on_off_info.SEA_STAR.value, --海上新星
				on_off_info.SEA_STAR_FIRST.value,
				on_off_info.SEA_STAR_SECOND.value,
				on_off_info.SEA_STAR_THIRD.value,
				on_off_info.SEA_STAR_FORTH.value,
				on_off_info.SEA_STAR_FIFTH.value,
				on_off_info.INCOME_BACK.value,--增益找回
				on_off_info.VIP_DIAMONDGET.value, --【vip】VIP特权界面-领取按钮
				on_off_info.SIGNIN_REWARD.value,--签到奖励
				on_off_info.DAILY_COMPETITION.value, ---每周奖励
				on_off_info.RECHARGE_REWARD.value, ---首冲充值
				on_off_info.GROWTH_FUND.value, ---成长基金
			}, effect_index = TOP_BTN_RIGHT_ROW_1_INDEX_1,
			click_fun = function() return self:clickAwardBtnHandler() end},
		["btn_treasure"] = {res = "btn_map_1", on_off_key = on_off_info.TRSASURE_MAP.value,
			effect_index = TOP_BTN_RIGHT_ROW_2_INDEX_1, lab_padding = {"btn_map_time_1", -15}, click_fun = function() return self:openTreasureMapUI() end},

		["btn_treasure_vip"] = {res = "btn_map_2", on_off_key = on_off_info.TRSASURE_MAP.value,
			effect_index = TOP_BTN_RIGHT_ROW_2_INDEX_1, lab_padding = {"btn_map_time_2", -15}, click_fun = function() return self:openVipTreasureMapUI() end},

		["btn_community"] = {res = "btn_community",effect_index = TOP_BTN_RIGHT_ROW_1_INDEX_3,click_fun = function() return self:openCommunityUI() end, lab_padding = {"btn_community_text", -5}},

		["btn_recharge"] = {res = "btn_recharge",on_off_key = on_off_info.RECHARGE_PAGE.value,
			effect_index = TOP_BTN_RIGHT_ROW_2_INDEX_2, click_fun = function() return self:openFristRecharge() end, lab_padding = {"btn_recharge_text", -5}},

		["btn_real_name"] = {res = "btn_real_name",effect_index = TOP_BTN_LEFT_ROW_2_INDEX_2,click_fun = function() return self:openRealNameUrl() end, lab_padding = {"txt_real_name", -5}},
	}

	--右下角按钮  effect_index对应为从右侧 为 1 开始算起，不算码头出海按钮，对应clsPortEffect里面的动画数据
	local buttom_btn_list = {
		["btn_sail"] = {res = "btn_sail", on_off_key = on_off_info.PORT_QUAY_EXPLORE.value,
			effect_index = BUTTOM_BTN_SAIL,
			click_fun = function() return self:clickSailBtnHandler() end},
		["btn_backpack"] = {res = "btn_backpack", on_off_key = on_off_info.TREASURE_WAREHOUSE.value, task_keys = {
				on_off_info.TREASURE_WAREHOUSE.value,
			}, effect_index = BUTTOM_BTN_HORIZONTAL_1,
			animation = "tx_0126", animation_pos = {-2, 13}, click_fun = function() return self:clickWarehouseBtnHandler() end, music = music_info.PORT_WAREHOUSE.res},
		["btn_title"] = {res = "btn_title", on_off_key = on_off_info.PEERAGES.value, task_keys = {
				on_off_info.PEERAGES.value,
				on_off_info.PEERAGES_UP.value,
			}, effect_index = BUTTOM_BTN_VERTICAL_1,
			animation = "tx_0186", animation_pos = {-1, 3}, click_fun = function() return self:clickTitleBtnHandler() end, music = music_info.PORT_TITLE.res},
		["btn_guild"] = {res = "btn_guild", on_off_key = on_off_info.PORT_UNION.value, task_keys = {
				on_off_info.GUILD_MULTI_TASK.value,
				on_off_info.GUILD_TASK.value,
				on_off_info.MEMBERSHIP.value,
				on_off_info.GUILD_DEPOT_GIFT.value,
				on_off_info.GUILD_STRONGHOLD_GET.value,
				on_off_info.GUILD_SALUTE_REWARD.value,
				on_off_info.GUILD_ADD.value,
				on_off_info.GRADUATE_BUILD_BUILDBUTTON.value, 
				on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value,
			}, effect_index = BUTTOM_BTN_HORIZONTAL_4,
			animation = "tx_0129", animation_pos = {-7, 11}, click_fun = function() return self:clickGuildBtnHandler() end, music = music_info.PORT_GUILD.res},
		["btn_staff"] = {res = "btn_staff", on_off_key = on_off_info.FOMATION_USE.value, task_keys = {
				on_off_info.APPOINT_SAILOR_1.value,
				on_off_info.APPOINT_SAILOR_2.value,
				on_off_info.APPOINT_SAILOR_3.value,
				on_off_info.APPOINT_SAILOR_4.value,
			}, effect_index = BUTTOM_BTN_HORIZONTAL_3, animation = "tx_0131", animation_pos = {-5, 8},
			click_fun = function() return self:clickStaffBtnHandler() end, music = music_info.PORT_STAFF.res},

		["btn_skill"] = {res = "btn_skill", on_off_key = on_off_info.SKILL_SYSTEM.value, task_keys = {
				on_off_info.SKILL_PAGE.value,
			}, effect_index = BUTTOM_BTN_HORIZONTAL_2,
			animation = "tx_0196", animation_pos = {-18, 7}, animation_scale = 0.8, click_fun = function() return self:clickSkillBtnHandler() end},
	}

	local center_btn_list = {
		["btn_report"] = {res = "btn_report", on_off_key = on_off_info.PORT_REPORT.value, task_keys = {
				on_off_info.PORT_REPORT.value,
			}, click_fun = function() return self:clickReportBtnHandler() end},
	}

	local onOffData = getGameData():getOnOffData()

	for k,v in pairs(player_info_res) do
		self[v.res] = getConvertChildByName(self.main_panel, v.res)
		if v.click_fun then
			self.btn_list[#self.btn_list + 1] = self[v.res]
			self[v.res]:setPressedActionEnabled(true)
			self[v.res]:addEventListener(function()
				if v.music then
					audioExt.playEffect(v.music)
				end
				v.click_fun()
			end, TOUCH_EVENT_ENDED)
		end
		if v.effect then
			self.info_effect_list[#self.info_effect_list + 1] = {node = self[v.res], effect = v.effect}
		end
		if v.on_off_key then
			self[v.res].on_off_key = v.on_off_key
			self.key_open_list[v.on_off_key] = self[v.res]
			if not onOffData:isOpen(v.on_off_key) then
				self[v.res]:setVisible(false)
			end
			if v.task_keys then
				self.task_btn_list[#self.task_btn_list + 1] = {btn = self[v.res], data = v, task_x = 38, task_y = 38, is_widget = true}
			end
		end
	end

	for k,v in pairs(building_res) do
		self[k] = getConvertChildByName(self.main_panel, v.res)

		if v.animation then
			self[k].icon = CCArmature:create(v.animation)
			self[k].icon:setCascadeOpacityEnabled(true)
			self[k].icon:setPosition(v.animation_pos[1], v.animation_pos[2])
			self[k]:addCCNode(self[k].icon)
			self[k].icon:setZOrder(ZORDER_INDEX_TWO)

			self[k].icon:getAnimation():playByIndex(0)
			self[k].icon:getAnimation():gotoAndPause(0)
		end

		if v.click_fun then
			self.btn_list[#self.btn_list + 1] = self[k]
			self[k]:setPressedActionEnabled(true)
			self[k]:addEventListener(function()
				local armature_animation = self[k].icon:getAnimation()
				armature_animation:playByIndex(0, -1, -1, 0)
				armature_animation:addMovementCallback(function(eventType) end)
				if v.music then
					audioExt.playEffect(v.music)
				end
				v.click_fun()
			end, TOUCH_EVENT_ENDED)
		end

		if v.on_off_key then
			self[k].on_off_key = v.on_off_key
			self[k].enable_res = {btnRes = "#main_building_btn.png", pos = ccp(63, 0)}
			onOffData:pushOpenBtn(v.on_off_key, {openBtn = self[k], openEnable = true, addLock = true,
				btn_pos = ccp(63, 0), btnRes = "#main_building_btn.png", parent = "ClsPortLayer"})
			if v.task_keys then
				self.task_btn_list[#self.task_btn_list + 1] = {btn = self[k], data = v, task_x = 120, task_y = 23, is_widget = true}
			end
		end
		if v.effect_index then
			self.building_effect_list[#self.building_effect_list + 1] = {node = self[k], effect_index = v.effect_index}
		end
	end

	for k,v in pairs(top_btn_list) do
		self[k] = getConvertChildByName(self.main_panel, v.res)
		if v.lab_padding then
			print(v.lab_padding[1])
			local lab = getConvertChildByName(self[k], v.lab_padding[1])
			lab:setPaddingLength(v.lab_padding[2])
			self[k].label = lab
		end
		if v.on_off_key then
			self.key_open_list[v.on_off_key] = self[k]
			if not onOffData:isOpen(v.on_off_key) then
				self[k]:setVisible(false)
			end
			if v.task_keys then
				self.task_btn_list[#self.task_btn_list + 1] = {btn = self[k], data = v, task_x = 19, task_y = 19, is_widget = true}
			end
		end

		self.btn_list[#self.btn_list + 1] = self[k]
		self[k]:setPressedActionEnabled(true)
		self[k]:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				if v.click_fun then
					v.click_fun()
				end
			end, TOUCH_EVENT_ENDED)

		if v.effect_index then
			self.top_btn_effect_list[#self.top_btn_effect_list + 1] = {node = self[k], effect_index = v.effect_index}
		end
	end

	for k,v in pairs(buttom_btn_list) do
		self[k] = getConvertChildByName(self.main_panel, v.res)
		if v.animation then
			self[k].icon = CCArmature:create(v.animation)
			if v.animation_scale then
				self[k].icon:setScale(v.animation_scale)
			end

			self[k].icon:setCascadeOpacityEnabled(true)
			self[k].icon:setPosition(v.animation_pos[1], v.animation_pos[2])
			self[k]:addCCNode(self[k].icon)
			self[k].icon:setZOrder(ZORDER_INDEX_TWO)
			self[k].icon:getAnimation():playByIndex(0)
			self[k].icon:getAnimation():gotoAndPause(0)
		end

		self.btn_list[#self.btn_list + 1] = self[k]
		self[k]:setPressedActionEnabled(true)
		self[k]:addEventListener(function()
				if v.click_fun then
					if v.music then
						audioExt.playEffect(v.music)
					end
					v.click_fun()
				end
			end, TOUCH_EVENT_ENDED)

		if v.on_off_key then
			self[k].on_off_key = v.on_off_key
			onOffData:pushOpenBtn(v.on_off_key, {openBtn = self[k], openEnable = false, addLock = true,
				btnRes = "#main_btn_bottom.png", parent = "ClsPortLayer"})
			if v.task_keys then
				self.task_btn_list[#self.task_btn_list + 1] = {btn = self[k], data = v, task_x = 23, task_y = 27, is_widget = true}
			end
		end
		if v.effect_index then
			self.buttom_effect_list[#self.buttom_effect_list + 1] = {node = self[k], effect_index = v.effect_index}
		end
	end
	--中间按钮，会动态显现隐藏
	for k,v in pairs(center_btn_list) do
		self[k] = getConvertChildByName(self.main_panel, v.res)
		if v.on_off_key and v.task_keys then
			self[k].task_keys = v.task_keys
			self.task_btn_list[#self.task_btn_list + 1] = {btn = self[k], data = v, task_x = 19, task_y = 19, is_widget = true}
		end

		self.btn_list[#self.btn_list + 1] = self[k]
		self[k]:setPressedActionEnabled(true)
		self[k]:addEventListener(function()
				if v.click_fun then
					v.click_fun()
				end
			end, TOUCH_EVENT_ENDED)
	end

	self:initInfo()
	ClsGuideMgr:tryGuide("ClsGuidePortLayer")
	self:initBtn51()
	self:checkShowActivityEffect()
	self:initTreasureInfo()
	self:updateLockExploreTimer()
	self:checkShowWelfareEffect()
	self:initFirstRechargeBtn()
	self:updateExpBuffStatus()
	self:updateQQVipBtn()
	self:updateBootStatus()
	self:updateRealNameBtn()
	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()
	if platform == PLATFORM_QQ then
		self.btn_community:setVisible(true)
	elseif platform == PLATFORM_WEIXIN then
		self.btn_community:setVisible(true)   	
	else
		self.btn_community:setVisible(false)
	end
	if self.btn_community:isVisible() and GTab.IS_VERIFY then
		self.btn_community:setVisible(false)
	end
end

ClsPortMainUI.updateQQVipBtn = function(self)
	if GTab.IS_VERIFY then
		self.vip_qq:setVisible(false)
		self.vip_qq:setTouchEnabled(false)
		return
	end
	local module_game_sdk = require("module/sdk/gameSdk")
	platform = module_game_sdk.getPlatform()
	--self.vip_qq:setPosition(ccp(display.cx, display.cy))
	if platform == PLATFORM_QQ and device.platform == "android" then
		self.vip_qq:setVisible(true)
		self.vip_qq:setTouchEnabled(true)
		local task_data = getGameData():getTaskData()
		task_data:regTask(self.vip_qq, {on_off_info.PENGUIN.value}, KIND_CIRCLE, on_off_info.PENGUIN.value, 10, 10, true)
		
	else
		self.vip_qq:setVisible(false)
		self.vip_qq:setTouchEnabled(false)
	end
end

--启动特权
ClsPortMainUI.updateBootStatus = function(self)
	if GTab.IS_VERIFY then
		self.btn_start:setVisible(false)
		self.btn_start:setTouchEnabled(false)
		return
	end

	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()
	if platform == PLATFORM_WEIXIN then
		self.btn_start:setVisible(true)
		self.btn_start:changeTexture("common_wechat_1.png", "common_wechat_1.png", "common_wechat_1.png", UI_TEX_TYPE_PLIST)
		self.btn_start:setTouchEnabled(true)
		local boot_status = getGameData():getBuffStateData():getBootStatus()
		if boot_status == BOOT_WX then  --微信启动
			self.wechat_icon:setVisible(true)
		end
	else
		self.btn_start:setVisible(false)
		self.btn_start:setTouchEnabled(false)
	end
end

ClsPortMainUI.updateRealNameBtn = function(self)
	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()
	if platform == PLATFORM_WEIXIN or platform == PLATFORM_QQ then
		local version = "1.7.10" --ios
		if device.platform == "android" then
			version = "1.0.5"
		end 
		if compareTwoVersion(GTab.APP_VERSION, version) < 0 then
			self.btn_real_name:setVisible(true)
			self.btn_real_name:setTouchEnabled(true)
			return
		end
	end
	self.btn_real_name:setVisible(false)
	self.btn_real_name:setTouchEnabled(false)
end

ClsPortMainUI.clickBootBtnHandler = function(self)
	print("----clickBootBtnHandler----")
	getUIManager():create("gameobj/tips/clsBootRewardTips")
end

ClsPortMainUI.clickQQVipBtnHandler = function(self)
	local task_data = getGameData():getTaskData()
	task_data:setTask(on_off_info.PENGUIN.value, false)
	local module_game_sdk = require("module/sdk/gameSdk")
	local url = "http://mq.vip.qq.com/m/game/vipembed"
	module_game_sdk.openQQVip(url)
end

ClsPortMainUI.initFirstRechargeBtn = function(self)
	local onOffData = getGameData():getOnOffData()
	if onOffData:isOpen(on_off_info.RECHARGE_PAGE.value) then
		local fund_data = getGameData():getGrowthFundData()
		local is_frist_recharge = fund_data:isFristRecharge()
		self.btn_recharge:setVisible(not is_frist_recharge)

		if fund_data:getVipEffectStatus(1) == 0 then
			self.frist_effect = composite_effect.new("tx_0188", 1, 1, self.btn_recharge, nil, nil, nil, nil, true)
			self.frist_effect:setZOrder(2)
		end

	end
end



ClsPortMainUI.checkShowWelfareEffect = function(self)
	local remain_day = getGameData():getPlayerData():getVipRemainDay()
	if remain_day and remain_day < 1 then
		if tolua.isnull(self.welfare_effect) then
			self.welfare_effect = composite_effect.new("tx_wenjuan_liuguang", 1, 1, self.btn_award, nil, nil, nil, nil, true)
			self.welfare_effect:setZOrder(2)
		end
	end
end

--海神bug
ClsPortMainUI.updateExpBuffStatus = function(self)

	local buff_status = getGameData():getPlayerData():getExpBuffStatus()

	if buff_status and buff_status > 0 then
		self.btn_buff_exp:setVisible(true)
		local is_show = getGameData():getPlayerData():getOldExpBuff(buff_status)
		if not is_show then
			getUIManager():create("gameobj/exp_buff/clsExpBuffAlert")
		end
	elseif buff_status == 0 then
		self.btn_buff_exp:setVisible(false)
		local is_show = getGameData():getPlayerData():getOldExpBuff(buff_status)
		if not is_show then
			getUIManager():create("gameobj/exp_buff/clsExpBuffAlert")
		end
	else
		self.btn_buff_exp:setVisible(false)
	end

end

ClsPortMainUI.clickExpBuffHandler = function(self)
	getUIManager():create("gameobj/exp_buff/clsExpBuffTips")
end

ClsPortMainUI.clearWelfareEffect = function(self)
	if self.welfare_effect and not tolua.isnull(self.welfare_effect) then
		self.welfare_effect:removeFromParentAndCleanup(true)
		self.welfare_effect = nil
	end
end

ClsPortMainUI.setFireEffectState = function(self, visible)
	if visible then
		if not self.fire_effect and self.btn_activity then
			self.fire_effect = composite_effect.new("tx_0188", 1, 1, self.btn_activity, nil, nil, nil, nil, true)
			self.fire_effect:setZOrder(2)
		end
	else
		if self.fire_effect then
			self.fire_effect:removeFromParentAndCleanup(true)
			self.fire_effect = nil
		end
	end
end

--检测是否要显示特效
ClsPortMainUI.checkShowActivityEffect = function(self)
	local new_activity_count = getGameData():getActivityData():getNewActivityCount()
	local effect_id = nil
	if new_activity_count > 0 then
		effect_id = "tx_wenjuan_liuguang"
	else
		self:setActivityEffect()
	end

	self:setActivityEffect(effect_id)
end

ClsPortMainUI.setActivityEffect = function(self, id)
	if not tolua.isnull(self.activity_effect) then
		if self.activity_effect.id ~= id then
			self.activity_effect:removeFromParentAndCleanup(true)
			self.activity_effect = nil
		end
	end

	if tolua.isnull(self.activity_effect) and id ~= nil then
		self.activity_effect = composite_effect.new(id, 1, 1, self.btn_activity, nil, nil, nil, nil, true)
		self.activity_effect:setZOrder(2)
	end
end

ClsPortMainUI.showActivityEffect = function(self, bVisible)
	local activityData = getGameData():getActivityData()

	if tolua.isnull(self.activity_effect) then
		self.activity_effect = composite_effect.new("tx_0188", 1, 1, self.btn_activity, nil, nil, nil, nil, true)
		self.activity_effect:setZOrder(2)
	end
	self.activity_effect:setVisible(bVisible)
end


---藏宝图
ClsPortMainUI.initTreasureInfo = function(self)
	---藏宝图vip隐藏
	self.btn_treasure_vip:setVisible(false)
	self:clearTreasureScheduler()

	local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
	if treasure_info and treasure_info.treasure_id ~= 0 then
		self.btn_treasure:setVisible(treasure_info.treasure_id == TREASURE_MAP_ID )
		self.btn_treasure_vip:setVisible(treasure_info.treasure_id ~= TREASURE_MAP_ID)
		local scheduler = CCDirector:sharedDirector():getScheduler()
		self.treasure_time= scheduler:scheduleScriptFunc(function()
			self:updateTreasureUpdate()
		end, 1, false)
	else
		self.btn_treasure:setVisible(false)
		self.btn_treasure_vip:setVisible(false)
	end

end

ClsPortMainUI.clearSeaStarScheduler = function(self)
	if self.sea_star_scheduler then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.sea_star_scheduler)
		self.sea_star_scheduler = nil
	end
end

ClsPortMainUI.updataSeaStarTask = function(self)
	self:clearSeaStarScheduler()
	local task_keys = {
		on_off_info.SEA_STAR_FIRST.value, --第一天
		on_off_info.SEA_STAR_SECOND.value, --第二天
		on_off_info.SEA_STAR_THIRD.value, --第三天
		on_off_info.SEA_STAR_FORTH.value, --第四天
		on_off_info.SEA_STAR_FIFTH.value, --第五天
	}

	local task_data = getGameData():getTaskData()
	local onOffData = getGameData():getOnOffData()
	local seaStarData = getGameData():getSeaStarData()
	if not onOffData:isOpen(on_off_info.SEA_STAR.value) then
		self:clearSeaStarScheduler()
		seaStarData:setSeaStarStatus(false)
		return
	end

	local seaStarInfo = seaStarData:getInfoData()
	local arr_action = CCArray:create()
	local star_open_time = seaStarInfo.remainTime

	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.sea_star_scheduler = scheduler:scheduleScriptFunc(function()    
		local seaStarInfo = seaStarData:getInfoData()
		if seaStarInfo.isOpen == STAR_STATUS_OPEN and star_open_time ~= 0 then
			star_open_time = star_open_time - 1
			seaStarData:setSeaStarStatus(true)
			--没解锁不显示红点
			local today = seaStarInfo.today
			local new_today = seaStarData:getUnlockDay()
			if today > 5 then
				today = 5
			end

			if new_today <= today then
				new_today = today
			end

			if new_today > 5 then
				new_today = 5
			end
			for k, task_key in ipairs(task_keys) do
				if k > new_today then
					task_data:setTask(task_key, false)
				end
			end

			if not seaStarData:getIsNotReward() then
				task_data:setTask(on_off_info.SEA_STAR.value, true)
			else
				task_data:setTask(on_off_info.SEA_STAR.value, false)
			end
		else
			if not seaStarData:getIsNotReward() then
				task_data:setTask(on_off_info.SEA_STAR.value, true)
				seaStarData:setSeaStarStatus(true)
			else
				task_data:setTask(on_off_info.SEA_STAR.value, false)
				seaStarData:setSeaStarStatus(false)
				self:clearSeaStarScheduler()
			end
		end
	end, 1, false)
end

ClsPortMainUI.updateTreasureUpdate = function(self)
	local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
	if not treasure_info then
		self:clearTreasureScheduler()
		return 
	end
	local end_time = treasure_info.end_time
	local new_time = os.time()
	local time = end_time - new_time
	if time > 0 then
		if not tolua.isnull(self.btn_treasure) and  not tolua.isnull(self.btn_treasure_vip) then
			local time_text = ClsDataTools:getTimeStrNormal(time)
			if treasure_info.treasure_id == TREASURE_MAP_ID then
				self.btn_treasure.label:setText(time_text)
			else
				self.btn_treasure_vip.label:setText(time_text)
			end
		end
	else
		if not tolua.isnull(self.btn_treasure) and  not tolua.isnull(self.btn_treasure_vip) then
			self.btn_treasure:setVisible(false)
			self.btn_treasure_vip:setVisible(false)    		
		end

		self:clearTreasureScheduler()
		local list = {treasure_id = 0, mapId = 0, positionId = 0, time = 0}
		getGameData():getPropDataHandler():setTreasureInfo(list)
	end
end

ClsPortMainUI.clearTreasureScheduler = function(self)
	if self.treasure_time then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.treasure_time)
		self.treasure_time = nil
	end
end

ClsPortMainUI.setName = function(self, name)
	self.player_name:setText(name)
	-- 显示名字前面的称号
	local nobility_data = getGameData():getNobilityData()
	local nobility_id = nobility_data:getNobilityID()
	local nobility_data = getGameData():getNobilityData()
	local nobility_info = nobility_data:getCurrentNobilityData()
	if nobility_info then
		local file_name = nobility_info.peerage_before
		file_name = convertResources(file_name)
		if not self.nobility_effect then
			self.nobility_effect = composite_effect.new("tx_0197" , -46 , 1 , self.player_title , nil , nil , nil , nil , true)
		end
		-- 如果称号是骑士，则没有特效
		self.nobility_effect:setVisible(file_name ~= "title_name_knight.png")
		self.player_title:changeTexture(file_name , UI_TEX_TYPE_PLIST)
		self:alignWidgetCenter()
	end
end

ClsPortMainUI.alignWidgetCenter = function(self)
	local title_width = self.player_title:getContentSize().width * self.player_title:getScaleX()
	local name_width = self.player_name:getContentSize().width
	local title_pos = self.player_title:getPosition()
	local name_pos = self.player_name:getPosition()
	local off_x = (title_width + name_width + 2)/2
	self.player_title:setPosition(ccp(-off_x + title_width, title_pos.y))
	self.player_name:setPosition(ccp(-off_x + title_width + 2, name_pos.y))
end

--将主界面的红点注册等显示往后延，等特效结束后再处理
ClsPortMainUI.updateUIAfterEffect = function(self)
	if self.task_btn_list then
		local task_data = getGameData():getTaskData()
		for k,v in pairs(self.task_btn_list) do
			task_data:regTask(v.btn, v.data.task_keys, KIND_CIRCLE, v.data.on_off_key, v.task_x, v.task_y, v.is_widget)
		end
	end
	self:updateCenterBtn()

	--功能预开放
	self:recentOpenActivity()
	-- self:updateFeatureTips()

	self:updateItemTips()

	--等主港口的动作完成后,再请求数据
	-- local seaStarData = getGameData():getSeaStarData()
 --    seaStarData:askSeaStarList()

	local teamData = getGameData():getTeamData()
	if teamData:getIsPopMainUI() then
		getUIManager():create("gameobj/team/clsPortTeamUI", nil, nil, true)
		teamData:setIsPopMainUI(false)
	end

	local mission_team_ui = getUIManager():get("ClsTeamMissionPortUI")
	if not tolua.isnull(mission_team_ui) then
		mission_team_ui:setTouch(true)
	end
end

--[[
--创建倒计时定时器
]]
ClsPortMainUI.createCDTimer = function(self, callBack)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self:removeTimeHander()
	self.hander_time = scheduler:scheduleScriptFunc(callBack, 60, false)
end

ClsPortMainUI.removeTimeHander = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
end

ClsPortMainUI.recentOpenActivity = function(self)
	if self.has_activity_id then return end

	--活动状态
	local activity_data = getGameData():getActivityData()
	local is_has_limit_activity, activity_id = activity_data:isHasDoingLimitActivity()
	if is_has_limit_activity then --有限时活动
		self:showActivityTips(activity_id)
		return
	end

	--功能预开放
	self:showFuncTips()

end

ClsPortMainUI.showFuncTips = function(self)
	local port_data = getGameData():getPortData()
	local cur_feature_id = port_data:getFeatureId()

	--print("==========cur_feature_id:" .. cur_feature_id)
	if type(cur_feature_id) == "number" and cur_feature_id ~= 0 and not self.has_activity_id then
		self:updateFeatureTips(FUNC_PRE_OPEN, cur_feature_id)
	end
end

ClsPortMainUI.showActivityTips = function(self, id, real_time)
	-- if self.activity_doing then return end
	-- self:closeFeatureTips(id, true)

	if real_time then
		self:updateFeatureTips(ACTIVITY_PRE_OPEN, id, real_time)  --活动预开放
		-- self.activity_doing = nil
	else
		self:updateFeatureTips(ACTIVITY_OPEND, id) --活动进行中
		-- self.activity_doing = id
	end
	self.has_activity_id = id
end

ClsPortMainUI.closeFeatureTips = function(self, id, is_activity)

	if not self.feature_id then return end
	-- if not id then return end
	if id == 0 and self.has_activity_id then return end

	if not tolua.isnull(self.open_tips) then
		self.open_tips:setVisible(false)		
	end

	if is_activity then
		self.has_activity_id = nil
		self.feature_id = nil
		self:showFuncTips()
	else
		self:resetTimer()
	end


end

ClsPortMainUI.resetTimer = function(self)
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
	end
	self.timer = nil
end


--活动进行中UI
ClsPortMainUI.updateDoingActivityTips = function(self, id)
	-- print(debug.traceback())
	-- print("========updateDoingActivityTips====" .. id)
	local config = require("game_config/activity/new_activity")

	if not config[id] then
		self.open_tips:setVisible(false)
		return
	end
	local activity_data = getGameData():getActivityData()
	local is_show = activity_data:isShowThisActivityOpenTips(id)
	
	if not is_show then
		getUIManager():create('gameobj/tips/clsActivityRemindTips',nil, id)
	end
	
	local icon = display.newSprite(string.format("#%s", config[id].activity_icon))
	icon:setZOrder(2)
	icon:setScale(0.6)
	self.effNode:addChild(icon)


	local open_tips_banner = getConvertChildByName(self.open_tips, "open_tips_banner")
	open_tips_banner:setVisible(false)

	local index = 1
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1.5))
	arr:addObject(CCCallFunc:create(function ()
		open_tips_banner:setVisible(true)
		-- open_tips_banner:runAction(CCFadeOut:create(2.5))
		-- print('----------run -------------')
		open_tips_banner:setCascadeOpacityEnabled(true)
		open_tips_banner:runAction(CCFadeIn:create(1.3))
	end))
	open_tips_banner:stopAllActions()
	open_tips_banner:runAction(CCSequence:create(arr))

	--名字
	local open_name = getConvertChildByName(self.open_tips, "open_name")
	open_name:setText(config[id].name)

	open_name:removeAllChildren()
	local wgt = UIWidget:create()
	open_name:addChild(wgt)
	local effect = composite_effect.new("tx_main_swift_arrow", 90, 0, wgt, nil, nil, nil, nil, true)


	--内容
	local open_text = getConvertChildByName(self.open_tips, "open_text")
	open_text:setText(ui_word.PRE_FUNC_DOING)
	open_text:setVisible(false)

	-- 剩余
	local txt = getConvertChildByName(self.open_tips, "open_last")
	txt:setVisible(true)
	txt = getConvertChildByName(self.open_tips,"open_last_time")
	txt:setVisible(true)

	local list = getGameData():getActivityData():getLimitTimeActivityList()
	local res_sec = 0
	local item = {}
	for k,v in pairs(list) do
		if v.id == id then
			item = v
		end
	end

	res_sec = item.remain_time
	
	if res_sec >= 0 then
		local updateTimer
		updateTimer = function()
			res_sec = res_sec - 1
			if res_sec <= 1 then
				self:resetTimer()
				if self then
					self:closeFeatureTips(id,false)
					open_tips_banner:stopAllActions()
				end
				getUIManager():close('clsActivityRemindTips')
			end
			str = os.date("%M:%S", res_sec)
			if not tolua.isnull(self.open_tips) then
				local txt = getConvertChildByName(self.open_tips, "open_last_time")
				txt:setText(str)
			end
		end
		self:resetTimer()
		updateTimer()
		self.timer = scheduler:scheduleScriptFunc(updateTimer, 1, false)
	else
		self:closeFeatureTips(id,false)
		open_tips_banner:stopAllActions()
		getUIManager():close('clsActivityRemindTips')
	end

	local reward_icons = {}
	for i=1,3 do
		local icon = getConvertChildByName(self.open_tips, string.format("open_ward_iocn_%d",i))
		local icon_data = item.activity_reward[i]
		if icon_data then
			icon:changeTexture(icon_data,UI_TEX_TYPE_PLIST)
			-- icon:setScale(0.9)
			icon:setVisible(true)
		else
			icon:setVisible(false)
		end
	end

	--几点
	local open_level = getConvertChildByName(self.open_tips, "open_level")
	open_level:setVisible(false)
	-- open_tips_banner:runAction(CCFadeTo:create(0.5 , 0.5 * 255))
	-- open_tips_banner:runAction(CCFadeIn:create(0.5))

	-- open_text:setPosition(ccp(6, open_level_pos.y))

	self:setOpenTipPosition()

	self.open_tips:setTouchEnabled(true)
	self.open_tips:addEventListener(function()
		--print("=====doing activity===")
		local new_activity = require("game_config/activity/new_activity")

		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local layer_name = new_activity[id].skip_info[1]

		if layer_name == "ports" then
			local mapAttrs = getGameData():getWorldMapAttrsData()
			local portData = getGameData():getPortData()
			local port_id = portData:getPortId() -- 当前港口id
			mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE)
			return
		end

		if layer_name == "arena" then
			getUIManager():create("gameobj/arena/clsArenaMainUI")
			return
		end

		local layer = missionSkipLayer:skipLayerByName(layer_name)

	end, TOUCH_EVENT_ENDED)
end

--设置开启提示的位置
ClsPortMainUI.setOpenTipPosition = function(self)
	local open_name = getConvertChildByName(self.open_tips, "open_name")
	local open_level = getConvertChildByName(self.open_tips, "open_level")
	local open_text = getConvertChildByName(self.open_tips, "open_text")

	local level_str = open_level:getStringValue()
	local level_width = 0
	if open_level:isVisible() == true then
	-- if level_str ~= nil and level_str ~= "" then
		level_width = open_level:getContentSize().width
	end

	local center_x = open_name:getPosition().x - (level_width + open_text:getContentSize().width) / 2

	local MIN_X = 6 -- 判断最小边界
	if center_x < MIN_X then
		center_x = MIN_X
	end
	local center_y = open_level:getPosition().y

	open_level:setPosition(ccp(center_x + level_width,center_y))
	open_text:setPosition(ccp(center_x + level_width,center_y))
end

--活动预开放UI
ClsPortMainUI.updateActivityTips = function(self, id, real_time)
	-- print(debug.traceback())
	-- print("========活动预开放====" .. real_time,id)
	local config = require("game_config/activity/new_activity")

	if not config[id] then return end

	local icon = display.newSprite(string.format("#%s", config[id].activity_icon))
	icon:setZOrder(2)
	icon:setScale(0.6)
	self.effNode:addChild(icon)

	--名字
	local open_name = getConvertChildByName(self.open_tips, "open_name")
	open_name:setText(config[id].name)

	--几点
	local open_level = getConvertChildByName(self.open_tips, "open_level")


	local _, time_tab = ClsDataTools:getMostCnTimeStr(real_time)
	local show_time_str = ""
	
	local show_time_str = string.format("%02d:%02d",time_tab.h, time_tab.m)
	
	open_level:setText(show_time_str)
	open_level:setVisible(true)

	local open_tips_banner = getConvertChildByName(self.open_tips, "open_tips_banner")
	open_tips_banner:setVisible(false)

	--内容
	local open_text = getConvertChildByName(self.open_tips, "open_text")
	-- open_text:setText(config[cur_feature_id].describe_1)
	open_text:setText(ui_word.ACTIVITY_COME_SOON_TIP)
	open_text:setVisible(true)
	self:setOpenTipPosition()
	open_level:setPosition(ccp(8,15))
	local txt = getConvertChildByName(self.open_tips, "open_last")
	txt:setVisible(false)
	txt = getConvertChildByName(self.open_tips,"open_last_time")
	txt:setVisible(false)
end

--功能预开放UI
ClsPortMainUI.updateFuncTips = function(self, cur_feature_id)

	local config = require("game_config/mission/feature_tip")
	local icon = display.newSprite("#main_task_icon.png")
	icon:setZOrder(2)
	self.effNode:addChild(icon)

	--名字
	local open_name = getConvertChildByName(self.open_tips, "open_name")
	open_name:setText(config[cur_feature_id].describe_2)

	--等级
	local open_level = getConvertChildByName(self.open_tips, "open_level")
	open_level:setVisible(config[cur_feature_id].describe_3 ~= "")
	open_level:setText(config[cur_feature_id].describe_3)
	open_level:setPosition(ccp(8,15))

	local open_level_pos = open_level:getPosition()

	--内容
	local open_text = getConvertChildByName(self.open_tips, "open_text")
	open_text:setText(config[cur_feature_id].describe_1)
	open_text:setVisible(true)

	if config[cur_feature_id].describe_3 == "" then
		open_text:setPosition(ccp(8, open_level_pos.y))
	else
		open_text:setPosition(ccp(48, open_level_pos.y))
	end

	local ui =  getConvertChildByName(self.open_tips,"open_last")
	ui:setVisible(false)

	-- self:setOpenTipPosition()
end


ClsPortMainUI.updateFeatureTips = function(self, open_type, id, real_time)

	-- print(debug.traceback())
	-- print("===========updateFeatureTips:" .. open_type, id,real_time)
	if not id then return end
	-- if self.activity_doing then return end

	self.open_tips:setTouchEnabled(false)
	self.open_tips:setVisible(false)
	if not tolua.isnull(self.effNode) then
		self.effNode:removeFromParentAndCleanup(true)
	end

	local pos = self.open_tips:getPosition()
	local end_x, end_y = pos.x, pos.y

	self.open_tips:setPosition(ccp(-500, end_y))

	self.open_panel = getConvertChildByName(self.open_tips, "open_panel")
	self.open_panel:setVisible(false)
	self.open_tips:setVisible(true)

	-- bar
	local open_tips_banner = getConvertChildByName(self.open_tips, "open_tips_banner")
	open_tips_banner:setVisible(false)
	open_tips_banner:stopAllActions()
	local txt = getConvertChildByName(self.open_tips,"open_last_time")
	txt:setVisible(false)

	--特效
	local effNode = composite_effect.new("tx_0191_in", 10, 26, self.open_tips, 0, nil, nil, nil, true)
	effNode:setZOrder(-1)
	self.effNode = effNode

	local open_name = getConvertChildByName(self.open_tips, "open_name")
	open_name:removeAllChildren()

	if open_type == ACTIVITY_OPEND then --2:活动进行中
		-- print('------------------------------2')
		self:updateDoingActivityTips(id)
	elseif open_type == ACTIVITY_PRE_OPEN then --1:活动预开放
		-- print('------------------------------1')
		self:updateActivityTips(id, real_time)
	elseif open_type == FUNC_PRE_OPEN then --功能预开放
		-- print('------------------------------0')
		self:updateFuncTips(id)
	end

	self.open_tips:setPosition(ccp(-500, end_y))

	local array = CCArray:create()
	array:addObject(CCMoveTo:create(0.3, ccp(150, end_y)))
	array:addObject(CCDelayTime:create(0.3))
	array:addObject(CCCallFunc:create(function()
		self.open_tips:setPosition(ccp(150, end_y))
		self.open_panel:setVisible(true)
	end))
	self.open_tips:stopAllActions()
	self.open_tips:runAction(CCSequence:create(array))

	self.feature_id = id
end

--获得道具
ClsPortMainUI.popItemEvent = function(self, data)
	self.key = data.id
	local temp = {
		["id"] = data.id,
		["amount"] = data.amount,
		["key"] = ITEM_INDEX_PROP,
	}
	local icoStr, amount, scale, name,a,b,color= getCommonRewardIcon(temp)
	--品质框
	self.tips_bg.award_bg:changeTexture(string.format("item_box_%s.png", color), UI_TEX_TYPE_PLIST)
	--名字
	self.tips_bg.tips_port_name:setText(name)
	self.tips_bg.tips_port_name:setPosition(ccp(0,55))

	--图标
	self.tips_bg.award_info:changeTexture(convertResources(icoStr), UI_TEX_TYPE_PLIST)
	self.tips_bg.award_info:setScale(0.8)
	--数量
	self.tips_bg.award_num:setVisible(true)
	self.tips_bg.award_num:setText(data.amount)
	self.tips_bg.btn_get:setPressedActionEnabled(true)

	self.tips_bg.btn_get_text:setText(ui_word.MAIN_UI_USE)
	self.tips_bg.btn_get:addEventListener(function()
		-- self:setTouch(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local prop_item = item_info[data.id]
		if prop_item.use_item_type and prop_item.use_item_type == ITEM_USE_BAOWU_BOX then
			local baowu_data = getGameData():getBaowuData()
			baowu_data:askUseBaowuBox(data.id)
		elseif prop_item.use_item_type and prop_item.use_item_type == ITEM_USE_TYPE then
			local collectDataHandle = getGameData():getCollectData()
			collectDataHandle:sendUseItemMessage(data.id)
		end

	end, TOUCH_EVENT_ENDED)
end

--投资奖励弹出框
ClsPortMainUI.popInvestEvent = function(self, data)
	self.key = data.id
	local port_info = ClsDataTools:getPort(data.id)
	--港口名
	self.tips_bg.tips_port_name:setText(port_info.name)
	self.tips_bg.tips_port_name:setPosition(ccp(0,75))
	--几级奖励
	self.tips_bg.invest_award:setVisible(true)
	self.tips_bg.invest_award:setText(string.format(ui_word.MAIN_POP_INVEST, data.amount))
	self.tips_bg.invest_award:setPosition(ccp(0,55))

	local invest_data = getGameData():getInvestData()
	local is_lock, img, star,is_item = invest_data:getReward(data.id, data.amount)

	--品质框
	self.tips_bg.award_bg:changeTexture(string.format("item_box_%s.png", star), UI_TEX_TYPE_PLIST)

	--图标
	if not is_item  then --只用在这里
		self.tips_bg.award_info:changeTexture(img, UI_TEX_TYPE_LOCAL)
		local seaman_width = self.tips_bg.award_info:getContentSize().width
		self.tips_bg.award_info:setScale(46 / seaman_width)
	else
		local str = string.sub(img, 1, 1)
		if str == "#" then
			self.tips_bg.award_info:changeTexture(convertResources(img), UI_TEX_TYPE_PLIST)
		else
			self.tips_bg.award_info:changeTexture(convertResources(img), UI_TEX_TYPE_LOCAL)
		end

		self.tips_bg.award_info:setScale(0.8)
	end

	--解锁
	local str = ui_word.MAIN_UI_GET
	self.tips_bg.award_goods:setVisible(false)
	if is_lock == 1 then --1：解锁商品
		str = ui_word.MAIN_OK
		self.tips_bg.award_goods:setVisible(true)
	end

	self.tips_bg.btn_get_text:setText(str)

	self.tips_bg.btn_get:setPressedActionEnabled(true)
	self.tips_bg.btn_get:addEventListener(function()
		-- self:setTouch(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local port_data = getGameData():getPortData()
		if is_lock == 1 then --1：解锁商品
			port_data:askForCloseWindow()
		else
			port_data:askInvestReward(data.id, data.amount)
		end
	end, TOUCH_EVENT_ENDED)
end

--装备船
ClsPortMainUI.popEquipBoatEvent = function(self, data)
	self.key = data.id
	local boat_info = require("game_config/boat/boat_info")

	local ship_data = getGameData():getShipData()
	local boat = ship_data:getBoatDataByKey(data.id)

	local boat_config = boat_info[boat.id]
	self.tips_bg.tips_port_name:setText(boat.name)
	self.tips_bg.tips_port_name:setPosition(ccp(0,55))

	self.tips_bg.award_info:changeTexture(convertResources(boat_config.res), UI_TEX_TYPE_PLIST)
	--品质框
	self.tips_bg.award_bg:changeTexture(string.format("item_box_%s.png", boat.quality), UI_TEX_TYPE_PLIST)

	self.tips_bg.btn_get_text:setText(ui_word.BOAT_BATTLE_NAME)
	self.tips_bg.btn_get:addEventListener(function()
		-- self:setTouch(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local portData = getGameData():getPortData()
		portData:askUpLoadBoat(data.id)
	end, TOUCH_EVENT_ENDED)
end

--装备宝物
ClsPortMainUI.popEquipBaowuEvent = function(self, data)
	self.key = data.key
	local baozang_info = require("game_config/collect/baozang_info")

	local baowu_data = getGameData():getBaowuData()
	local baowu_info = baowu_data:getInfoById(data.key)
	if not baowu_info then--为了防止玩家身上没有该宝物
		self.tips_bg:setVisible(false)
		return
	else
		self.tips_bg:setVisible(true)
	end

	local baowu = baozang_info[baowu_info.baowuId]

	self.tips_bg.tips_port_name:setText(baowu.name)
	self.tips_bg.tips_port_name:setPosition(ccp(0,55))
	--品质框
	self.tips_bg.award_bg:changeTexture(string.format("item_box_%s.png", baowu_info.color or 0), UI_TEX_TYPE_PLIST)

	self.tips_bg.award_info:changeTexture(convertResources(baowu.res), UI_TEX_TYPE_PLIST)
	self.tips_bg.award_info:setScale(0.8)

	self.tips_bg.btn_get_text:setText(ui_word.BOAT_EQUIP_NAME)
	self.tips_bg.btn_get:addEventListener(function()
		-- self:setTouch(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local portData = getGameData():getPortData()
		portData:askUpLoadBaowu(data.key)
	end, TOUCH_EVENT_ENDED)
end

--道具/投资奖励弹窗提示
ClsPortMainUI.updateItemTips = function(self)
	local portData = getGameData():getPortData()
	local has_pop_win = portData:hasPopWindow()
	if not has_pop_win then return end

	self.key = nil
	local data = portData:getPopWindowInfo()
	self.pop_type = data.type

	-- body
	self.tips_bg:setVisible(true)
	local widget_name = {
		"tips_port_name",
		"invest_award",
		"award_info",
		"award_num",
		"award_goods",
		"btn_get",
		"btn_get_text",
		"btn_close",
		"award_bg"
	}

	for k, v in pairs(widget_name) do
		self.tips_bg[v] = getConvertChildByName(self.tips_bg, v)
	end
	self.tips_bg.invest_award:setVisible(false)
	self.tips_bg.award_num:setVisible(false)
	self.tips_bg.award_goods:setVisible(false)

	self.tips_bg.award_info:setScale(1)

	if data.type == POP_WINDOW_ITEM then
		self:popItemEvent(data)
	elseif data.type == POP_WINDOW_INVEST then
		self:popInvestEvent(data)
	elseif data.type == POP_WINDOW_BOAT then
		self:popEquipBoatEvent(data)
	elseif data.type == POP_WINDOW_BAOWU then
		self:popEquipBaowuEvent(data)
	end

	--关闭
	self.tips_bg.btn_close:setPressedActionEnabled(true)
	self.tips_bg.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:setPopDisappear(true)
	end, TOUCH_EVENT_ENDED)
	ClsGuideMgr:tryGuide("ClsGuidePortLayer")
end

--清楚弹出状态 同时隐藏
ClsPortMainUI.setPopDisappear = function(self, close)
	if self.tips_bg:isVisible() then
		self.tips_bg:setVisible(false)

		local portData = getGameData():getPortData()
		portData:clearPopWindow()

		if close then
			portData:askForCloseWindow()
		end
	end
end

ClsPortMainUI.updateHead = function(self, res)
	self.player_photo:changeTexture(sailor_info[tonumber(res)].res, UI_TEX_TYPE_LOCAL)
 --    local scale = 1
	-- local sailor_star = sailor_info[tonumber(res)].star

	-- if sailor_star == SAILOR_STAR_SIX then
	-- 	scale = 0.28
	-- else
	-- 	scale = 0.55
	-- end
	local head_size = self.player_photo:getContentSize()
	local scale =  90 / head_size.height
	self.player_photo:setScale(scale)
end

ClsPortMainUI.initInfo = function(self)
	local player_data = getGameData():getPlayerData()
	local icon = player_data:getIcon()
	self:updateHead(icon)

	self.old_level = player_data:getLevel()
	if self.old_level then
		self.player_level:setText("Lv."..tostring(self.old_level))
	end

	local cur_exp, max_exp = player_data:getExp(), player_data:getMaxExp()
	if cur_exp then
		self.player_exp:setPercent(cur_exp / max_exp * 100)
	end


	-- self.player_name:setText(player_data:getName() or "")

	if DEBUG > 0 then
		local uid = player_data:getUid() or ""
		self.uid_label = createBMFont({text ="uid:"..uid, fontFile = FONT_COMMON, size = 23, x = 240, y = 440})
		self:addCCNode(self.uid_label)
	end

	local current_power = player_data:getPower()
	local power_rate = current_power / player_data:getMaxPower() * 100
	self.power_progress:setPercent(math.min(power_rate, 100))
	self.power_num:setText(string.format("%d / %d", current_power, player_data:getMaxPower()))
	self.power_btn_panel:setTouchEnabled(true)
	self.power_btn_panel:addEventListener(function (  )
		self:clickPowerBtnHandler()
	end,TOUCH_EVENT_ENDED)

	self.coin_num:setText(player_data:getCash() or 0) -- player_data:getMaxCash()
	self.diamond_num:setText(player_data:getGold() or 0)
	self.combat_ability_num:setText(getGameData():getPlayerData():getBattlePower())

	local port_data = getGameData():getPortData()
	local cur_port_info = port_data:getPortInfo()
	self.port_name_text:setText(cur_port_info.name)

	local mapAttrs = getGameData():getWorldMapAttrsData()
	local cur_port_status = mapAttrs:getPortStatus(port_data:getPortId())
	local tempString
	if cur_port_info.type == PORT_TYPE_MARKET then
		if cur_port_status == PORT_STATUS_ZHONGLI then
			tempString = "common_port_business_neutrality.png"
		else
			tempString = "common_port_business_friendly.png"
		end
	elseif cur_port_info.type == PORT_TYPE_SHIP then
		if cur_port_status == PORT_STATUS_ZHONGLI then
			tempString = "common_port_industry_neutrality.png"
		else
			tempString = "common_port_industry_friendly.png"
		end
	else
		if cur_port_status == PORT_STATUS_ZHONGLI then
			tempString = "common_port_culture_neutrality.png"
		else
			tempString = "common_port_culture_friendly.png"
		end
	end
	self.port_type:changeTexture(tempString, UI_TEX_TYPE_PLIST)
end

---点击体力
ClsPortMainUI.clickPowerBtnHandler = function(self)
	getUIManager():create("gameobj/exp_buff/clsExpBuffTips",{},true)
end


--玩家头像点击
ClsPortMainUI.openPlayerInfoHandler = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	getUIManager():create("gameobj/playerRole/clsRoleInfoView")
end

--打开港口信息界面
ClsPortMainUI.openPortInfoHandler = function(self)
	if not self:closePortInfoPanel() then
		audioExt.playEffect(music_info.TOWN_CARD.res)
		getUIManager():create("gameobj/port/clsPortMainInfoTips", nil, "ClsPortMainInfoTips", {effect = false, is_back_bg = false, type = UI_TYPE.VIEW, is_swallow = false})
	end
end

ClsPortMainUI.closePortInfoPanel = function(self)
	local port_info_layer = getUIManager():get("ClsPortMainInfoTips")
	if not tolua.isnull(port_info_layer) then
		port_info_layer:closePortInfoPanel()
		return true
	end
end

--打开商店界面
ClsPortMainUI.clickShopBtnHandler = function(self)
	audioExt.playEffect(music_info.PORT_MALL.res)
	local shop_effect = composite_effect.new("tx_0128", 5, 11, self.btn_shop, 1, nil, nil, nil, true)
	--getUIManager():create("ui/shopMainUI")
	getUIManager():create("gameobj/mall/clsMallMain")
end

--市政厅按钮点击
ClsPortMainUI.clickTownBtnHandler = function(self)

	getUIManager():close('clsPortTownUI')
	getUIManager():create('gameobj/port/clsPortTownUI')

	local checkTask
	checkTask = function()
		local missionDataHandler = getGameData():getMissionData()
		local missionInfo = missionDataHandler:getMissionInfo()
		for i, v in ipairs(missionInfo) do
			local status = v.status
			local id = v.id
		end
	end
	checkTask()
end

--交易所按钮点击
ClsPortMainUI.clickMarketBtnHandler = function(self)
	getUIManager():create("gameobj/port/portMarket")
end

--船厂按钮点击
ClsPortMainUI.clickShipyardBtnHandler = function(self)
	getUIManager():create("gameobj/shipyard/clsShipyardMainUI")
end

--酒馆按钮点击
ClsPortMainUI.clickHotelBtnHandler = function(self)
	getUIManager():create("gameobj/hotel/clsHotelMain")
end

--好友按钮点击
ClsPortMainUI.clickFriendBtnHandler = function(self)
	getUIManager():create("gameobj/friend/clsFriendMainUI")
end

--排行按钮点击
ClsPortMainUI.clickRankBtnHandler = function(self)
	getUIManager():create('gameobj/rank/clsRankMainUI')
end

---藏宝图
ClsPortMainUI.openTreasureMapUI = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	missionSkipLayer:skipLayerByName("treasure_map")
end

ClsPortMainUI.openQuestionUI = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	getUIManager():create("gameobj/question/clsQuestionUI")
end

ClsPortMainUI.openCommunityUI = function(self)
	getUIManager():create("gameobj/port/clsCommunityUI")
	-- local module_game_sdk = require("module/sdk/gameSdk")
	-- local platform = module_game_sdk.getPlatform()
	-- if platform == PLATFORM_QQ then
	-- 	module_game_sdk.openURL("https://buluo.qq.com/p/barindex.html?bid=356512&from=share_copylink")
	-- elseif platform == PLATFORM_WEIXIN then
	-- 	module_game_sdk.openURL("https://game.weixin.qq.com/cgi-bin/h5/static/circle/index.html?jsapi=1&appid=wxa228fbbb06c2cb79&auth_type=2&ssid=12")
	-- end
   
end

---首充
ClsPortMainUI.openFristRecharge = function(self)

	local fund_data = getGameData():getGrowthFundData()
	if fund_data:getVipEffectStatus(1) == 0 then

		if self.frist_effect and not tolua.isnull(self.frist_effect) then
			self.frist_effect:removeFromParentAndCleanup(true)
			self.frist_effect = nil
		end

		fund_data:askEffectStatusById(1,1)
		--print("==================上行改变特效的协议=====")
		fund_data:setEffectStatus(1,1)
	end

	getUIManager():create("gameobj/welfare/clsWelfareMain", nil, 2)
end

---高级藏宝图
ClsPortMainUI.openVipTreasureMapUI = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	missionSkipLayer:skipLayerByName("treasure_map")
end

ClsPortMainUI.clickAwardBtnHandler = function(self)
	getUIManager():create("gameobj/welfare/clsWelfareMain")
end

--邮件按钮点击
ClsPortMainUI.clickMailBtnHandler = function(self)
	local mail_data = getGameData():getmailData()
	local mail_count = mail_data:getMailCount()
	if mail_count > 0 then
		getUIManager():create("gameobj/mail/clsMailMain")--创建
	else
		Alert:warning({msg = ui_word.YOU_NO_MAIL, size = 26})
	end
end

--活动按钮点击
ClsPortMainUI.clickActivityBtnHandler = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local port_layer = getUIManager():get("ClsPortLayer")
	getUIManager():create("gameobj/activity/clsActivityMain")
	-- port_layer:addItem()
end

--出海按钮点击
ClsPortMainUI.clickSailBtnHandler = function(self)
	if not getGameData():getBuffStateData():IsCanGoExplore(true) then
		return
	end

	local canTouch = true
	for _, mid in pairs(NO_SAIL_MISSION) do
		local missionInfo = getGameData():getPlayerData():getMission(mid)
		if missionInfo and missionInfo.status ~= MISSION_STATUS_COMPLETE_REWARD then
			canTouch = false
			break
		end
	end
	if not canTouch then return end

	audioExt.playEffect(voice_info["VOICE_PLOT_1028"].res, false)
	local skip_to_layer = require("gameobj/mission/missionSkipLayer")
	skip_to_layer:skipPortLayer()
end

--背包界面
ClsPortMainUI.clickWarehouseBtnHandler = function(self)
	local port_layer = getUIManager():get("ClsPortLayer")

	local armature_animation = self.btn_backpack.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)

	getUIManager():create("gameobj/backpack/clsBackpackMainUI")
end

--打开商会界面
ClsPortMainUI.clickGuildBtnHandler = function(self)
	local armature_animation = self.btn_guild.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)

	-- local ClsGuildMainUI = require("ui/clsGuildMainUI")
 --    local port_layer = getUIManager():get("ClsPortLayer")
 --    port_layer:addItem(ClsGuildMainUI.new())
	getUIManager():create("ui/clsGuildMainUI")
end

--技能界面
ClsPortMainUI.clickSkillBtnHandler = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local armature_animation = self.btn_skill.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)

	getUIManager():create("gameobj/playerRole/clsRoleSkill")
end

--爵位界面
ClsPortMainUI.clickTitleBtnHandler = function(self)
	local armature_animation = self.btn_title.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)

	getUIManager():create("ui/clsNobilityUI")
end

--编制界面
ClsPortMainUI.clickStaffBtnHandler = function(self)
	local armature_animation = self.btn_staff.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)

	getUIManager():create("gameobj/fleet/clsFleetPartner")
end

--战报界面
ClsPortMainUI.clickReportBtnHandler = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	-- local ClsLootedBattleReportUI = require("ui/lootedBattleReportUI")
	-- local port_layer = getUIManager():get("ClsPortLayer")
	-- port_layer:addItem(ClsLootedBattleReportUI.new(), nil, true)
	getUIManager():create("ui/lootedBattleReportUI")

	local task_data = getGameData():getTaskData()
	for i,v in ipairs(self.btn_report.task_keys) do --有战报按钮就直接显示红点
		task_data:setTask(v, false)
	end
end

ClsPortMainUI.updatePlayerInfo = function(self, kind, value, max)
	if kind == TYPE_INFOR_CASH then
		UiCommon:numberEffect(self.coin_num, tonumber(self.coin_num:getStringValue()), value)
	elseif kind == TYPE_INFOR_COLD then
		UiCommon:numberEffect(self.diamond_num, tonumber(self.diamond_num:getStringValue()), value)
	-- elseif kind == TYPE_INFOR_HONOUR then
		-- UiCommon:numberEffect(self.honour_num, tonumber(self.honour_num:getStringValue()), value)
		-- UiCommon:numberEffect(self.honour_max_num, tonumber(self.honour_max_num:getStringValue()), max)
		-- self:progressAction(self.honour_pro, 100 * value / max)
	elseif kind == TYPE_INFOR_LEVEL then
		-- self:upgrade(value) -- 旧的升级特效接口
		UiCommon:numberEffect(self.player_level, self.old_level, value, nil, nil, "Lv.")
		self.old_level = value
	elseif kind == TYPE_INFOR_POWER then
		local player_data = getGameData():getPlayerData()
		self.power_num:setText(string.format("%d / %d", value, player_data:getMaxPower()))
		local power_rate = value / player_data:getMaxPower() * 100
		self:progressAction(self.power_progress, math.min(power_rate, 100))
	elseif kind == TYPE_INFOR_EXPERIENCE then
		self:progressAction(self.player_exp, value * 100/ max)
	elseif kind == TYPE_PROSPERITY then --势力等级
		self:updateProsperLevel(value)
	end
end

--更新势力等级信息
ClsPortMainUI.updateProsperLevel = function(self)
	local nobility_data = getGameData():getNobilityData()
	local nobility_id = nobility_data:getNobilityID()
	local nodility_info = nobility_data:getNobilityDataByID(nobility_id)
	if nodility_info then
		self.btn_player:changeTexture(nodility_info.frame, nodility_info.frame, nodility_info.frame, UI_TEX_TYPE_PLIST)
	end
	local player_data = getGameData():getPlayerData()
	self:setName(player_data:getName() or "")
end

--更新战斗力 -- 改为从玩家数据中获取
ClsPortMainUI.updateBattlePower = function(self)
	local playerData = getGameData():getPlayerData()
	self.combat_ability_num:setText(playerData:getBattlePower())
end

ClsPortMainUI.progressAction = function(self, progress_bar, cur)
	if not tolua.isnull(progress_bar) then
		local time = 1.0
		local last_percent = progress_bar:getPercent()
		local run_time = 0.5--(cur - last_percent) * time / 100
		local LoadingAction = require("gameobj/LoadingBarAction")
		LoadingAction.new(cur, last_percent, run_time, progress_bar)
	end
end

--升级界面 -- 旧的升级特效接口
ClsPortMainUI.upgrade = function(self, value)
	-- if self.old_level < 1 then return end
	-- if self.old_level ~= value then
	--     local running_scene = GameUtil.getRunningScene()
	--     if tolua.isnull(running_scene) then return end
	--     local upgrade_alert = require("gameobj/quene/clsUpgradeAlert")
	--     local ClsUpgradeAlert = require("gameobj/quene/clsUpgradeAlert")
	--     local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	--     ClsDialogSequence:insertTaskToQuene(ClsUpgradeAlert.new(value))
	-- end
end

--打开facebook主页
ClsPortMainUI.openFacebookUrl = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.openURL("https://www.facebook.com/166224653775380")
end

ClsPortMainUI.openRealNameUrl = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	getUIManager():create("gameobj/question/clsRealNameUI")
end

ClsPortMainUI.updateCenterBtn = function(self)

end

ClsPortMainUI.updateLockExploreTimer = function(self)
	if not tolua.isnull(self.btn_sail.lock_explore_timer_lab) then
		self.btn_sail.lock_explore_timer_lab:removeFromParentAndCleanup(true)
		self.btn_sail.lock_explore_timer_lab = nil
	end
	local buffStateData = getGameData():getBuffStateData()
	if buffStateData:getLockGoExploreTime() > 0 then
		local callback = function()
				local time_n = buffStateData:getLockGoExploreTime()
				if time_n > 0 then
					self.btn_sail.lock_explore_timer_lab:setString(string.format("%ds", time_n))
				else
					if not tolua.isnull(self.btn_sail.lock_explore_timer_lab) then
						self.btn_sail.lock_explore_timer_lab:removeFromParentAndCleanup(true)
						self.btn_sail.lock_explore_timer_lab = nil
					end
				end
			end
		local lock_explore_timer_lab = createBMFont({text = "", size = 16, x = 0, y = 43})
		local repeat_act = UiCommon:getRepeatAction(1, callback)
		lock_explore_timer_lab:runAction(repeat_act)
		self.btn_sail.lock_explore_timer_lab = lock_explore_timer_lab
		self.btn_sail:addCCNode(lock_explore_timer_lab)
		callback()
	end
end

ClsPortMainUI.open = function(self, key)
	if self.key_open_list[key] and not tolua.isnull(self.key_open_list[key]) then
		self.key_open_list[key]:setVisible(true)
	end

	---首充
	if key == on_off_info.RECHARGE_PAGE.value then
		self:initFirstRechargeBtn()
	end

	-- 51活动
	if key == on_off_info.MAYDAY_ACTIVITY.value then
		self:initBtn51()
	end
end

ClsPortMainUI.setTouch = function(self, enable)
	-- self.ui_layer:setTouchEnabled(enable)
	--港口按钮触摸有异常，单独处理
	for k,v in pairs(self.btn_list) do
		v:setTouchEnabled(enable)
	end

	if enable then
		local investData = getGameData():getInvestData()
		local allEnable = investData:isUnlock()  --其他的判断条件
		-- local townEnable = enable --市政厅特殊判断条件
		local buttons = {
			-- {button = self.btn_town, enable = townEnable}, --市政按钮
			{button = self.btn_market, enable = allEnable},
			{button = self.btn_shipyard, enable = allEnable},
			{button = self.btn_hotel, enable = allEnable},
		}

		local onOffData = getGameData():getOnOffData()
		for k,v in pairs(buttons) do
			if not tolua.isnull(v.button) and onOffData:isOpen(v.button.on_off_key) then
				v.button:setTouchEnabled(v.enable)
				if v.enable then
					if not tolua.isnull(v.button.gray_sprite) then
						v.button.gray_sprite:setVisible(false)
					end
				else
					if tolua.isnull(v.button.gray_sprite) then
						v.button.gray_sprite = newQtzGraySprite(v.button.enable_res.btnRes, 0, 0, 0.6)
						v.button.gray_sprite:setPosition(v.button.enable_res.pos)
						v.button:addCCNode(v.button.gray_sprite)
						v.button.gray_sprite:setZOrder(ZORDER_UI_LAYER)
					end
					v.button.gray_sprite:setVisible(true)
				end
			end
		end

		local taskData = getGameData():getTaskData()
		taskData:onOffAllEffect()
	end
end

ClsPortMainUI.preClose = function(self)
	self:removeTimeHander()
	self:clearSeaStarScheduler()
	self:clearTreasureScheduler()
	self:resetTimer()
end

ClsPortMainUI.onExit = function(self)

end

---- 51活动相关 ----
local ACTIVITY_STATUS         = 			 -- 活动状态定义
{
	WAITING					  = -1,
	NOT_YET_STARTED 		  = 0, 
	ALREDAY_STARTED  		  = 1, 
	HAS_ENDED        		  = 2
}

ClsPortMainUI.initBtn51 = function(self)
	self.btn_51:setVisible(getGameData():getFestivalActivityData():getBtn51Status())
end

ClsPortMainUI.openFestivalPanel = function(self)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local status = getGameData():getFestivalActivityData():getActivityStatus()
	if status == ACTIVITY_STATUS.NOT_YET_STARTED then
		getUIManager():create("gameobj/festival/clsFestivalPortUITips")
	elseif status == ACTIVITY_STATUS.ALREDAY_STARTED then
		getUIManager():create("gameobj/festival/clsFestivalActivityMain")
	end
end

ClsPortMainUI.removeBtn51 = function(self)
	self.btn_51:setVisible(false)
	getUIManager():close("ClsFestivalActivityMain")
end
-------------

return ClsPortMainUI
