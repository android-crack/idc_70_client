local port_info = require("game_config/port/port_info")
local boat_attr = require("game_config/boat/boat_attr")
local sailor_info = require("game_config/sailor/sailor_info")
local area_info = require("game_config/port/area_info")
local music_info = require("game_config/music_info")
local role_info = require("game_config/role/role_info")
local relic_info = require("game_config/collect/relic_info")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local error_info=require("game_config/error_info")
local composite_effect= require("gameobj/composite_effect")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local UI_WORD = require("game_config/ui_word")
local tool = require("module/dataHandle/dataTools")
local ui = require ("base/ui/ui")
local ClsExplorePlayerUI = require("gameobj/explore/explorePlayerUI")
local scheduler = CCDirector:sharedDirector():getScheduler()
local LONG_TOUCH_TAG = 1
local voice_info = getLangVoiceInfo()
local ClsBaseView = require("ui/view/clsBaseView")
local base_info = require("game_config/base_info")

local function resetLablePos(bg, value, totalValue, is_ignore_label_text)
	bg.progressBar:setPercent(value / totalValue * 100)
	if true ~= is_ignore_label_text then
		bg.valueLable:setText(tostring(value).."/"..tostring(totalValue))
	end
	bg.valueLable.cur_value = value
	bg.valueLable.total_value = totalValue
end

local function resetSpeedDesc(speed_lab, cur_value, total_value)
	speed_lab:setText(cur_value .. "/" .. total_value .. UI_WORD.EXPLORE_JIE)
end

local TREASURE_MAP_ID = 80  ---藏宝图id

local ExploreUI = class("ExploreUI", ClsBaseView)

function ExploreUI:getViewConfig()
	return {is_swallow = false}
end

ExploreUI.onEnter = function(self, parent)
	-- map
	self.plistTab = {
		["ui/relic/relic.plist"] = 1,
		["ui/explore_sea.plist"] = 1,
		["ui/map.plist"] = 1,
	}

	self.m_cur_voice_hander = nil

	self.armature = {
		"effects/tx_0126.ExportJson", --仓库
		"effects/tx_0186.ExportJson", --爵位
		"effects/tx_0187.ExportJson", --组队
		"effects/tx_0196.ExportJson", --技能
		"effects/tx_0131.ExportJson", --伙伴
		"effects/tx_explore_qte.ExportJson", --qte
	}

	LoadArmature(self.armature)
	LoadPlist(self.plistTab)
	local exploreData = getGameData():getExploreData()

	self.is_enabled = true -- 是否可点击UI

	self.speed_rate = -1
	local ship_data = exploreData:getShipInfo()
	local speed = ship_data.speed  -- 真实速度
	self.speed_to_jie = 0.1
	self.ship_speed = (speed + ship_data.add_speed/2) * self.speed_to_jie  --节数（并非真实速度）

	self.scheduler = CCDirector:sharedDirector():getScheduler()

	self.portNameLabelDic = {}
	self.key_list = {}

	self.curListPanel = nil

	self.m_is_man = false
	local role_data = role_info[getGameData():getPlayerData():getRoleId()]
	if role_data and role_data.sex == SEX_M then
		self.m_is_man = true
	end

	self.m_is_show_detail = true
	self.m_is_show_top_btns = true
	self.m_is_show_drop_btn = true
	self.m_is_show_food_warning = false
	self.m_auto_go_supply_info = {is_open = false, is_go = false}
	self.m_cur_sail_state = SAIL_UP


	self:askActivityData()
	self:initUI()
	self:regFuns()

	self.world_map = self:getUIManager():create("gameobj/explore/exploreMap")
	self.world_map:showMin()

	self.m_map_pos_ui = self:getUIManager():create("gameobj/explore/clsExploreLocalUI")
	
	--添加任务遮盖层
	if ClsGuideMgr:needGuideMaskLayer() then
		self.explore_task_clound_layer = self:getUIManager():create("gameobj/explore/exploreTaskCloud")
	end
end

function ExploreUI:askActivityData()
	local activityData = getGameData():getActivityData()
	activityData:requestActivityInfo()
end

function ExploreUI:initUI()
	-- 信息
	local explore_sea_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_sea.json")
	self.m_explore_sea_ui = explore_sea_ui
	self:addWidget(explore_sea_ui)

	self:updateExpUI()

	self.m_map_panel = getConvertChildByName(explore_sea_ui, "map_panel_1")
	self.m_map_vip_panel = getConvertChildByName(explore_sea_ui, "map_panel_2")

	--self.m_btn_map = getConvertChildByName(self.m_map_panel, "btn_map_1")
	self.m_time_lable = getConvertChildByName(self.m_map_panel, "btn_map_time_1")
	--self.m_btn_map_2 = getConvertChildByName(self.m_map_vip_panel, "btn_map_2")
	self.m_time_lable_2 = getConvertChildByName(self.m_map_vip_panel, "btn_map_time_2")

	self.m_left_panel = getConvertChildByName(explore_sea_ui, "ship_control")
	self.m_right_panel = getConvertChildByName(explore_sea_ui, "food_panel")

	self.m_hide_btn = getConvertChildByName(explore_sea_ui, "btn_hidden_ui")
	self.m_stop_btn = getConvertChildByName(explore_sea_ui, "btn_stop")
	self.m_stop_btn.stop_tip_spr = getConvertChildByName(explore_sea_ui, "btn_stop_ban")
	self.m_port_icon = getConvertChildByName(explore_sea_ui, "port_icon")
	self.m_top_panel = getConvertChildByName(explore_sea_ui, "top_hide_panel")
	
	local pos = self.m_top_panel:getPosition()
	self.m_top_panel.show_pos = {x = pos.x, y = pos.y}
	self.m_top_panel.hide_pos = {x = pos.x, y = pos.y + 150}
	
	local stop_btn_pos = self.m_stop_btn:getPosition()
	self.m_stop_btn.show_pos = {x = stop_btn_pos.x, y = stop_btn_pos.y}
	self.m_stop_btn.hide_pos = {x = stop_btn_pos.x - 120, y = stop_btn_pos.y}
	self.m_stop_btn.is_drop = false

	self:initTopLeftBtn()
	self:initTopBtnUI()
	self.tip_bg = getConvertChildByName(explore_sea_ui, "tip_bg")

	local text_info = {
		[1] = {status = false},
		[2] = {status = true}
	}

	self.tip_bg.texts = {}
	for k, v in ipairs(text_info) do
		local name = string.format("text_area_%s", k)
		local item = getConvertChildByName(self.tip_bg, name)
		item.status = v.status
		self.tip_bg.texts[#self.tip_bg.texts + 1] = item
	end

	local temp_func = self.tip_bg.setVisible
	function self.tip_bg:setVisible(enable, who)
		temp_func(self, enable)
		for k, v in ipairs(self.texts) do
			v:setVisible(enable and v.status == who)
		end
	end

	self:initTradeBtn()
	ClsGuideMgr:tryGuide("ExploreUI")

	self.m_player_ui = ClsExplorePlayerUI.new(self, nil, self.m_port_icon)
	self:addWidget(self.m_player_ui)

	self.wind_dir = getConvertChildByName(self.m_right_panel, "wind_text")
	self.seaway_state = {}
	self.seaway_state.wind_state = WIND_NO_EFFECT

	local supplyData = getGameData():getSupplyData()  --补给数据
	--food \sailor
	self.totalFood = supplyData:getTotalFood()
	self.curFood = supplyData:getCurFood()
	self.foodBg = getConvertChildByName(self.m_right_panel, "food_bar_bg")
	self.foodBg.progressBar = getConvertChildByName(self.foodBg, "food_bar")
	self.foodBg.valueLable = getConvertChildByName(self.m_right_panel, "food_num")
	resetLablePos(self.foodBg, self.curFood, self.totalFood)

	self.totalSailor = supplyData:getTotalSailor()
	self.curSailor = supplyData:getCurSailor()
	self.sailorBg = getConvertChildByName(self.m_right_panel, "sailor_bar_bg")
	self.sailorBg.progressBar = getConvertChildByName(self.sailorBg, "sailor_bar")
	self.sailorBg.valueLable = getConvertChildByName(self.m_right_panel, "sailor_num")
	resetLablePos(self.sailorBg, self.curSailor, self.totalSailor)

    local playerData = getGameData():getPlayerData()
    self.totalPower = playerData:getMaxPower()
	self.curPower = playerData:getPower()
	self.powerBg = getConvertChildByName(self.m_right_panel, "power_bar_bg")
	self.powerBg.progressBar = getConvertChildByName(self.powerBg, "power_bar")
	self.powerBg.valueLable = getConvertChildByName(self.m_right_panel, "power_num")
	resetLablePos(self.powerBg, self.curPower, self.totalPower)

	--速度
	self.m_speed_lab = getConvertChildByName(self.m_right_panel, "speed_num")
	resetSpeedDesc(self.m_speed_lab, 0, 0)
	self:updateTeamSpeedInfo() --在组队时更新速度

	self.btn_helm = getConvertChildByName(self.m_explore_sea_ui, "helm")
	self.btn_helm:setTouchEnabled(true)

	self.crossUnknowAreaLb = createBMFont({text = UI_WORD.EXPLORE_CROSS_UNKONW_AREA, size = 20, fontFile = FONT_MICROHEI_BOLD, color = ccc3(dexToColor3B(COLOR_RED))})
	self.crossUnknowAreaLb:setPosition(ccp(display.cx, display.top - 20))
	self.crossUnknowAreaLb:setVisible(false)
	self:addChild(self.crossUnknowAreaLb)
	self.crossUnknowAreaSchHandler = nil

	self:initButton()
	self:updateWindDir()
	self:changeWindHeadDown(WIND_NO_EFFECT)

	self.mision_port_ui = getUIManager():create("gameobj/team/clsTeamMissionPortUI")
	self.mision_port_ui:setPosition(781, 200)

	--------------------------------------------------------------
	-- 测试用
	if DEBUG > 0 then
		self.speedUpButton = self:createButton({scale=SMALL_BUTTON_SCALE, image = "#common_btn_blue1.png", x = 160, y = 250,
			text = UI_WORD.EXPLORE_ADD_SPEED, fsize = 16})
		self.count = 0
		self.speedUpButton:regCallBack(function()
			if self.count > 3 then
				return
			end
			self.count = self.count + 1
			getExploreLayer():getShipsLayer():setMyShipTestChangeSpeedRate(math.pow(2, self.count))
		end)
		self.speedDownButton = self:createButton({scale = SMALL_BUTTON_SCALE, image = "#common_btn_blue1.png", x = 160, y = 200,
			text = UI_WORD.EXPLORE_SUB_SPEED, fsize = 16, fontFile = FONT_TITLE})
		self.speedDownButton:regCallBack(function()
			if self.count < -3 then
				return
			end
			self.count = self.count - 1
			getExploreLayer():getShipsLayer():setMyShipTestChangeSpeedRate(math.pow(2, self.count))
		end)
		self.stopFooodButton = self:createButton({scale = SMALL_BUTTON_SCALE, image = "#common_btn_blue1.png", x = 160, y = 150,
			text = UI_WORD.EXPLORE_STOP_FOOD, fsize = 16, fontFile = FONT_TITLE})
		self.is_stop_food = false
		self.stopFooodButton:regCallBack(function()
			self.is_stop_food = not self.is_stop_food
			local text_str = UI_WORD.EXPLORE_STOP_FOOD
			if self.is_stop_food then
				text_str = UI_WORD.EXPLORE_RESUME_FOOD
				getExploreLayer():getShipsLayer():setStopFoodReason("test_stop")
			else
				getExploreLayer():getShipsLayer():releaseStopFoodReason("test_stop")
			end
			self.stopFooodButton:getTitleLabel():setString(text_str)
		end)
		
		self.checkBlockButton = self:createButton({scale = SMALL_BUTTON_SCALE, image = "#common_btn_blue1.png", x = 160, y = 300,
			text = "Check map block", fsize = 12})
		self.checkBlockButton:regCallBack(function()
			local astar = getExploreLayer():getLand().AStar
			local checkSeaPos = {
					{cfg_tab = require("game_config/port/port_info"), 
						pos_key = "ship_pos", type_str = "port info"},
					{cfg_tab = require("game_config/explore/explore_whirlpool"), 
						pos_key = "sea_pos", type_str = "explore_whirlpool"},
					{cfg_tab = require("game_config/collect/relic_info"), 
						pos_key = "ship_pos", type_str = "relic_info"},
				}
				
			for _, check_item in ipairs(checkSeaPos) do
				print("check-------------------------", check_item.type_str)
				for id, cfg_item in pairs(check_item.cfg_tab) do
					local pos = cfg_item[check_item.pos_key]
					local block_n = astar:getWeight(pos[1],pos[2])
					if MAP_LAND == block_n then
						print(string.format("error!!!!!!!!!!!!    id = %s, name = %s", tostring(id), tostring(cfg_item.name)))
					end
				end
			end
			print("----------check end-----------")
		end)
		self:addChild(self.speedUpButton)
		self:addChild(self.speedDownButton)
		self:addChild(self.stopFooodButton)
		self:addChild(self.checkBlockButton)
	end
	--一般掠夺的必要操作
	self:updateTreasureBtn()
	self:tryPlaySunSeagull()
	--创建探索聊天框
	self:createChatComponent()


	-- 优化 #51957 新手阶段隐藏部分海上UI 巴塞罗那任务之前
	self:setVisibleStateOfNewman()
end

function ExploreUI:setVisibleStateOfNewman()

	-- -- 未完成巴塞罗那任务前 出海点头像不要打开主角界面
	local status = getGameData():getOnOffData():isOpen(on_off_info.EXPLORE_UI_HIDE.value)
	-- -- print(' --------- setVisibleStateOfNewman ------------- status : ',status)
	if not status then
		self.m_hide_btn:executeEvent(TOUCH_EVENT_ENDED)
	end

	-- local wgts = {}
	-- -- m_explore_sea_ui 对应的json explore_sea.json
	-- wgts.top_right_ui = self.m_top_panel -- 右上按钮 海盗经商按钮
	-- wgts.bottom_right_ui = self.m_port_icon -- 右下按钮
	-- wgts.navi_btn = self.btn_helm -- 导航按钮
	-- wgts.chat_ui = getUIManager():get("ClsChatComponent")
	-- wgts.left_hide_btn = self.m_hide_btn -- 左边隐藏按钮
	-- wgts.task_ui = self.mision_port_ui

	-- for k,v in pairs(wgts) do
	-- 	if not status then
	-- 		wgts[k]:setVisible(false)
	-- 	else
	-- 	end
	-- end
end

--播放阳光与海鸥特效
function ExploreUI:tryPlaySunSeagull()
	local is_play_sun_seagull = getGameData():getExploreData():getPlaySunshineSeagull()
	if is_play_sun_seagull then
		self.sunEffect = composite_effect.new("tx_0035sun", display.width, display.height, self.m_explore_sea_ui)
		local arr_action = CCArray:create()
	    arr_action:addObject(CCDelayTime:create(8))

	    arr_action:addObject(CCCallFunc:create(function()
	        self.sunEffect:stopAllActions()
            self.sunEffect:removeFromParentAndCleanup(true)
            self.sunEffect = nil
	    end))

	    self.sunEffect:runAction(CCSequence:create(arr_action))
	end
end

function ExploreUI:createChatComponent(enable)
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	local Alert = require("ui/tools/alert")
	if auto_trade_data:getIsAutoTrade() then--自动经商的话，界面由自动经商那边创建
		return
	end

	---自动悬赏
    local missionDataHandler = getGameData():getMissionData()
    local is_auto_task = missionDataHandler:getAutoPortRewardStatus()
    if is_auto_task then
    	return 
    end
    
    local battle_data = getGameData():getBattleDataMt()
    if battle_data:IsBattleStart() then
    	return
    end

	cclog("删除聊天，在探索创建聊天")
    getUIManager():close("ClsChatComponent")
    getUIManager():create("gameobj/chat/clsChatComponent", {before_view = "ExploreUI"}, {panel_pos = ccp(0, 10)})
end

local TOP_BTN_MAIL = 1
local TOP_BTN_AWARD = 2
local TOP_BTN_ACTIVITY = 3
local TOP_BTN_RANK = 4
local TOP_BTN_FRIEND = 5
local TOP_BTN_COMMUNITY = 6
local BG_COLOR = ccc4(0, 0, 0, 180)

function ExploreUI:touchMailEvent()
	if not tolua.isnull(self.mail_ui) then return end
	local mail_data = getGameData():getmailData()
	local mail_count = mail_data:getMailCount()
	if mail_count > 0 then
		self.mail_ui = getUIManager():create("gameobj/mail/clsMailMain")
	else
		Alert:warning({msg = UI_WORD.YOU_NO_MAIL, size = 26})
	end
end

function ExploreUI:touchAwardEvent()
	if not tolua.isnull(self.welfare_ui) then return end
	self.welfare_ui = getUIManager():create("gameobj/welfare/clsWelfareMain")
end

function ExploreUI:touchActivityEvent()
	if not tolua.isnull(getUIManager():get("ClsActivityMain")) then return end
	getUIManager():create("gameobj/activity/clsActivityMain")
end

function ExploreUI:touchGuildEvent()
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	if getGameData():getTeamData():isLock(true) then return end

	local port_info = require("game_config/port/port_info")
	local Alert = require("ui/tools/alert")
	local portData = getGameData():getPortData()
	local portName = port_info[portData:getPortId()].name
	local tips = require("game_config/tips")
	local str = string.format(tips[18].msg, portName)
	Alert:showAttention(str, function()
		---回港
		portData:setEnterPortCallBack(function()
			getUIManager():create("ui/clsGuildMainUI")
		end)
		portData:askBackEnterPort()
	end, nil, nil, {hide_cancel_btn = true})
end

function ExploreUI:touchTitleEvent()
	audioExt.playEffect(music_info.PORT_TITLE.res)
	local nobility_data = getGameData():getNobilityData()
	nobility_data:sendSyncNobilityInfo()
	local armature_animation = self.btn_title.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	require("gameobj/mission/missionSkipLayer"):skipLayerByName("peerages")
end

function ExploreUI:touchSkillEvent()
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local armature_animation = self.btn_skill.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	getUIManager():create("gameobj/playerRole/clsRoleSkill")
end

function ExploreUI:touchWareHouseEvent()
	audioExt.playEffect(music_info.PORT_WAREHOUSE.res)
	local armature_animation = self.btn_backpack.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	require("gameobj/mission/missionSkipLayer"):skipLayerByName("backpack")
end

function ExploreUI:touchStaffEvent()
	audioExt.playEffect(music_info.PORT_STAFF.res)
	local armature_animation = self.btn_staff.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	getUIManager():create("gameobj/fleet/clsFleetPartner")
end

function ExploreUI:touchRankEvent()
	getUIManager():create('gameobj/rank/clsRankMainUI')
end

function ExploreUI:touchFriendEvent()
	getUIManager():create("gameobj/friend/clsFriendMainUI")
end

function ExploreUI:touchCommuntyEvent()
	getUIManager():create("gameobj/port/clsCommunityUI", nil, 335)
end

local event_by_index = {
	[TOP_BTN_MAIL] = ExploreUI.touchMailEvent,
	[TOP_BTN_AWARD] = ExploreUI.touchAwardEvent,
	[TOP_BTN_ACTIVITY] = ExploreUI.touchActivityEvent,
	[TOP_BTN_RANK] = ExploreUI.touchRankEvent,
	[TOP_BTN_FRIEND] = ExploreUI.touchFriendEvent,
	[TOP_BTN_COMMUNITY] = ExploreUI.touchCommuntyEvent,
}

local click_event = {
	ExploreUI.touchTitleEvent,
	ExploreUI.touchWareHouseEvent,
	ExploreUI.touchSkillEvent,
	ExploreUI.touchStaffEvent,
}

--爵位，仓库按钮
function ExploreUI:initTopLeftBtn()
	local btns = {
		{name = "btn_title", on_off_key = on_off_info.PEERAGES.value, task_keys = {
				on_off_info.PEERAGES.value,
				on_off_info.PEERAGES_UP.value,
			}, animation = "tx_0186", animation_pos = {-1, 3}},
		{name = "btn_backpack", on_off_key = on_off_info.TREASURE_WAREHOUSE.value, task_keys = {
				on_off_info.TREASURE_WAREHOUSE.value,
			}, animation = "tx_0126", animation_pos = {-2, 13}},
		{name = "btn_skill", on_off_key = on_off_info.SKILL_SYSTEM.value, task_keys = {
				on_off_info.SKILL_PAGE.value,
			}, animation = "tx_0196", animation_pos = {-18, 7}, animation_scale = 0.8},
		{name = "btn_staff", on_off_key = on_off_info.FOMATION_USE.value, task_keys = {
				on_off_info.APPOINT_SAILOR_1.value,
				on_off_info.APPOINT_SAILOR_2.value,
				on_off_info.APPOINT_SAILOR_3.value,
				on_off_info.APPOINT_SAILOR_4.value,
			}, animation = "tx_0131", animation_pos = {-5, 8},
		},
	}


	local onOffData = getGameData():getOnOffData()
	for k, v in ipairs(btns) do
		self[v.name] = getConvertChildByName(self.m_port_icon, v.name)
		self[v.name]:setPressedActionEnabled(true)
		self[v.name]:addEventListener(function()
			click_event[k](self)
		end, TOUCH_EVENT_ENDED)

		if v.on_off_key then
			if not onOffData:isOpen(v.on_off_key) then
				self[v.name]:setVisible(false)
				self[v.name]:setTouchEnabled(false)
				self[v.name].not_open = true
				self.key_list[v.on_off_key] = self[v.name]
			end
			if v.task_keys then
				local task_data = getGameData():getTaskData()
				task_data:regTask(self[v.name], v.task_keys, KIND_CIRCLE, v.on_off_key, 22, 27, true)
			end
		end

		if v.animation then
			self[v.name].icon = CCArmature:create(v.animation)
			if v.animation_scale then
				self[v.name].icon:setScale(v.animation_scale)
			end
			self[v.name].icon:setCascadeOpacityEnabled(true)
			self[v.name].icon:setPosition(v.animation_pos[1], v.animation_pos[2])
			self[v.name]:addCCNode(self[v.name].icon)
			self[v.name].icon:setZOrder(ZORDER_INDEX_TWO)

			self[v.name].icon:getAnimation():playByIndex(0)
			self[v.name].icon:getAnimation():gotoAndPause(0)
		end
	end
end

function ExploreUI:open(key)
	if self.key_list[key] and not tolua.isnull(self.key_list[key]) then
		self.key_list[key]:setVisible(true)
		self.key_list[key]:setTouchEnabled(true)
		self.key_list[key].not_open = false
	end
end

function ExploreUI:initTopBtnUI()
	local top_btn_info = {
		[1] = {name = "btn_mail", index = TOP_BTN_MAIL, on_off_key = on_off_info.MAIL_SYSTEM.value, task_keys = {
				on_off_info.MAIL_SYSTEM.value,
			}},
		[2] = {name = "btn_award", index = TOP_BTN_AWARD, on_off_key = on_off_info.WELFARE_BUTTON.value, task_keys = {
				on_off_info.WELFARE_BUTTON.value, --每日签到
				on_off_info.PEERAGES_FENHONG.value, --爵位分红
				on_off_info.WELFARE_LIXIAN.value, --离线收益
				on_off_info.SEA_STAR.value, --海上新星
				on_off_info.SEA_STAR_FIRST.value,
				on_off_info.SEA_STAR_SECOND.value,
				on_off_info.SEA_STAR_THIRD.value,
				on_off_info.SEA_STAR_FORTH.value,
				on_off_info.SEA_STAR_FIFTH.value,
				on_off_info.VIP_DIAMONDGET.value, --【vip】VIP特权界面-领取按钮
                on_off_info.SIGNIN_REWARD.value,--签到奖励
			}},
		[3] = {name = "btn_activity", index = TOP_BTN_ACTIVITY, on_off_key = on_off_info.ACTIVITY_BUTTON.value, task_keys = {
				on_off_info.ACTIVITY_DAILY.value, --有部分限时活动
				on_off_info.ACTIVITY_EVERYDAY.value, --每日目标有奖励可以领取
			}},
		[4] = {name = "btn_rank", index = TOP_BTN_RANK, on_off_key = on_off_info.RANKING_LIST_UI_BUTTON.value},
		[5] = {name = "btn_friend", index = TOP_BTN_FRIEND, on_off_key = on_off_info.MAIN_FRIEND.value, task_keys = {
				on_off_info.FRIEND_LIST.value,
				on_off_info.FRIEND_ADD.value,
				on_off_info.FRIEND_MY.value,
				on_off_info.ACCEPT_GIFTPAGE.value,
			}},

		[6] =  {name = "btn_community", index = TOP_BTN_COMMUNITY},
	}

	for k, v in ipairs(top_btn_info) do
		self[v.name] = getConvertChildByName(self.m_top_panel, v.name)
		self[v.name].name = v.name
		self[v.name].index = v.index
		self[v.name]:setPressedActionEnabled(true)
		self[v.name]:addEventListener(function()
			event_by_index[v.index](self)
		end, TOUCH_EVENT_ENDED)

		local onOffData = getGameData():getOnOffData()
		if v.on_off_key then
			self.key_list[v.on_off_key] = self[v.name]
			if not onOffData:isOpen(v.on_off_key) then
				self[v.name]:setVisible(false)
			end
			if v.task_keys then
				local task_data = getGameData():getTaskData()
				task_data:regTask(self[v.name], v.task_keys, KIND_CIRCLE, v.on_off_key, 19, 19, true)
			end
		end
	end

	local module_game_sdk = require("module/sdk/gameSdk")
    local platform = module_game_sdk.getPlatform()
    if platform == PLATFORM_QQ then
    	self.btn_community:setVisible(true)
    elseif platform == PLATFORM_WEIXIN then
    	self.btn_community:setVisible(true)   	
    else
    	self.btn_community:setVisible(false)
    end
	self:setActivityEffect(nil)
	if self.btn_community:isVisible() and GTab.IS_VERIFY then
    	self.btn_community:setVisible(false)
    end
end

--经商海盗模式切换
function ExploreUI:initTradeBtn()
	local btn_trade_info = {
		[1] = {name = "btn_trade", time = "trade_time", red = false, on_off_key = on_off_info.PLUNDEOPEN_SYSTEM.value},
		[2] = {name = "btn_pirate", time = "pirate_time", red = true, on_off_key = on_off_info.PLUNDEOPEN_SYSTEM.value},
	}
	self.btn_trade_tab = {}
	local onOffData = getGameData():getOnOffData()
	for k, v in ipairs(btn_trade_info) do
		local item = getConvertChildByName(self.m_explore_sea_ui, v.name)
		item.on_off_key = v.on_off_key
		item.name = v.name
		item.time = getConvertChildByName(item, v.time)
		item.time:setVisible(false)
		item.red = v.red--红名
		item.long_touch = false
		item.touch_time = 0
		item:setPressedActionEnabled(true)

		function item:closeLongTouchScheduler()
			if self.long_touch_scheduler then
				scheduler:unscheduleScriptEntry(self.long_touch_scheduler)
				self.long_touch_scheduler = nil
			end
			self.touch_time = 0
		end

		function item:openLongTouchScheduler()
			local function updateCount()
				if tolua.isnull(self) then return end
				self.touch_time = self.touch_time + 0.5
				if self.touch_time > LONG_TOUCH_TAG then
					self.long_touch = true
					self:closeLongTouchScheduler()
					local explore_ui = getUIManager():get("ExploreUI")
					explore_ui.tip_bg:setVisible(true, self.red)
				end
			end
			self:closeLongTouchScheduler()
			self.long_touch_scheduler = scheduler:scheduleScriptFunc(updateCount, 0.5, false)
		end

		--重写setVisible方法
		local func = item.setVisible
		function item:setVisible(enable)
			func(self, enable)
			self:setTouchEnabled(enable)
			if not enable then
				self:closeScheduler()
			else
				local player_data = getGameData():getPlayerData()
				current_time = player_data:getCurServerTime()
				if type(self.cd) ~= "number" then return end
				if self.cd > current_time then
					self:openScheduler()
				end
			end
		end

		function item:closeScheduler()
			if self.update_scheduler then
				scheduler:unscheduleScriptEntry(self.update_scheduler)
				self.update_scheduler = nil
			end
			if not tolua.isnull(self.time) then
				self.time:setVisible(false)
			end
		end

		function item:openScheduler()
			local function updateCount()
				if tolua.isnull(self) then
					self:closeScheduler()
					return
				end
				local current_time = os.time()
				local player_data = getGameData():getPlayerData()
				current_time = current_time + player_data:getTimeDelta()
				local time = self.cd
				if time >= current_time then
					local show_txt = tostring(tool:getTimeStrNormal(time - current_time))
					self.time:setText(show_txt)
					self.time:setVisible(true)
				else
					self:closeScheduler()
				end
			end
			self:closeScheduler()
			self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
		end

		function item:closeTip()
			self:closeLongTouchScheduler()
			if self.long_touch then
				self.long_touch = false
				local explore_ui = getUIManager():get("ExploreUI")
				explore_ui.tip_bg:setVisible(false)
				return true
			end
		end

		--began事件
		item:addEventListener(function()
			item:openLongTouchScheduler()
		end, TOUCH_EVENT_BEGAN)

		--cancel事件
		item:addEventListener(function()
			item:closeTip()
		end, TOUCH_EVENT_CANCELED)

		--end事件
		item:addEventListener(function()
			if item:closeTip() then return end
			if getGameData():getTeamData():isLock() then
				Alert:warning({msg = UI_WORD.LOCK_COMMON_TIP})
				return
			end
			local loot_data_handler = getGameData():getLootData()
			local red_name_info = loot_data_handler:getRedNameInfo() or {}

			local function switchCallBack()
				local loot_data_handler = getGameData():getLootData()
				loot_data_handler:askSwitchTradeMode()
			end

			if not red_name_info.is_red then--白名切红名
				local show_tip = UI_WORD.LOOT_SWITCH_TIP
				Alert:showAttention(show_tip, switchCallBack, nil, nil, {is_hide_cancel_btn = true})
				return
			end
			switchCallBack()
		end, TOUCH_EVENT_ENDED)

		item:setVisible(false)
		self[v.name] = item
		self.btn_trade_tab[#self.btn_trade_tab + 1] = item
	end

	self:updateTradeBtn()

	for k, v in ipairs(self.btn_trade_tab) do
		if not onOffData:isOpen(v.on_off_key) then
			v:setVisible(false)
		end
	end
end

function ExploreUI:getExplorePlayerUI()
	return self.m_player_ui
end

--闪动导航按钮
function ExploreUI:lightBtnHelm()
	self.btn_helm:stopAllActions()
	self.btn_helm:setOpacity(180)
	local light_act = CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 100), CCFadeTo:create(0.5, 255))
	self.btn_helm:runAction(CCRepeatForever:create(light_act))
end

function ExploreUI:stopLightBtnHelm()
	self.btn_helm:stopAllActions()
	self.btn_helm:setOpacity(255)
end

function ExploreUI:updateTradeBtn()
	local loot_data_handler = getGameData():getLootData()
	local red_name_info = loot_data_handler:getRedNameInfo() or {}

	if self.btn_trade_tab then
		for k, v in ipairs(self.btn_trade_tab) do
			if v.red == red_name_info.is_red then--相对应的按钮
				v.cd = red_name_info.cd or 0
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
	end
end

--检测是否要显示特效
function ExploreUI:checkShowActivityEffect()
	local doing_activities = getGameData():getActivityData():getDoingActivities()
	local new_open_num = getGameData():getActivityData():getNewOpenActivityNum()
	local effect_id = nil
	if new_open_num > 0 then
		effect_id = "tx_wenjuan_liuguang"
	-- elseif #doing_activities > 0 then
		-- effect_id = "tx_0188"
	end

	self:setActivityEffect(effect_id)
end

function ExploreUI:setFireEffectState(visible)
	if visible then
		if not self.fire_effect and self.btn_activity then
			self.fire_effect = composite_effect.new("tx_0188", 1, 1, self.btn_activity, nil, nil, nil, nil, true)
			self.fire_effect:setZOrder(1)
		end
	else
		if self.fire_effect then
			self.fire_effect:removeFromParentAndCleanup(true)
			self.fire_effect = nil
		end
	end
end

function ExploreUI:setActivityEffect(id)
	if not tolua.isnull(self.activity_effect) then
		if self.activity_effect.id ~= id then
			self.activity_effect:removeFromParentAndCleanup(true)
			self.activity_effect = nil
		end
	end

	if tolua.isnull(self.activity_effect) and id ~= nil then
    	self.activity_effect = composite_effect.new(id, 1, 1, self.btn_activity, nil, nil, nil, nil, true)
    	self.activity_effect:setZOrder(1)
    end
end

function ExploreUI:showActivityEffect(bool)
	local activityData = getGameData():getActivityData()
	if tolua.isnull(self.activity_effect) then
		self.activity_effect = composite_effect.new("tx_0188", 1, 1, self.btn_activity, nil, nil, nil, nil, true)
		self.activity_effect:setZOrder(1)
	end
	self.activity_effect:setVisible(bool)
end

function ExploreUI:updateTreasureTime()
	local treasure_info  = getGameData():getPropDataHandler():getTreasureInfo()
	local end_time = treasure_info.end_time
	local new_time = os.time()
	local time = end_time - new_time

	if time > 0 then
		local time_text = tool:getTimeStrNormal(time)
		if treasure_info.treasure_id == TREASURE_MAP_ID then
			self.m_time_lable:setText(time_text)
		else
			self.m_time_lable_2:setText(time_text)
		end
	else
		self.m_map_panel:setVisible(false)
		self.m_map_vip_panel:setVisible(false)
		self:removeTreasureScheduler()
		local list = {treasure_id = 0, mapId = 0, positionId = 0, time = 0}
		getGameData():getPropDataHandler():setTreasureInfo(list)
		----自动导航取消
		getGameData():getExploreData():setAutoPos(nil)
	end
end

function ExploreUI:removeTreasureScheduler()
	if self.hasTreasureInfoHandle then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.hasTreasureInfoHandle)
		self.hasTreasureInfoHandle = nil
	end
end

function ExploreUI:updateTreasureBtn()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hasTreasureInfoHandle then
		scheduler:unscheduleScriptEntry(self.hasTreasureInfoHandle)
		self.hasTreasureInfoHandle = nil
	end
	local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
	if treasure_info and treasure_info.treasure_id ~= 0 then
		self.m_map_panel:setVisible(treasure_info.treasure_id == TREASURE_MAP_ID)
		self.m_map_vip_panel:setVisible(treasure_info.treasure_id ~= TREASURE_MAP_ID)

		self.hasTreasureInfoHandle= scheduler:scheduleScriptFunc(function()
			self:updateTreasureTime()
		end, 1, false)
	else
		self.m_map_panel:setVisible(false)
		self.m_map_vip_panel:setVisible(false)
	end

	self.m_map_vip_panel:addEventListener(function ()
		self.m_map_panel:executeEvent(TOUCH_EVENT_ENDED)
	end,TOUCH_EVENT_ENDED)

	self.m_map_panel:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/treasureMapLayer")
	end, TOUCH_EVENT_ENDED)

end

function ExploreUI:setTouch(enabled)
end

function ExploreUI:setIsDropAnchor(is_drop, is_back_auto)
	if self.m_stop_btn.is_drop == is_drop then return end
	self.m_stop_btn.is_drop = is_drop
	
	self.m_stop_btn.stop_tip_spr:setVisible(is_drop)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) and not tolua.isnull(explore_layer:getLand()) then
		if is_drop then
			self.m_stop_btn.is_auto = IS_AUTO
			self:playAudio({f = "VOICE_EXPLORE_1020", m = "VOICE_EXPLORE_1000"})
			explore_layer:getLand():showDropAnchorTips(nil)
		else
			explore_layer:getLand():showDropAnchorTips(true)
		end
		explore_layer:getShipsLayer():setIsDroping(is_drop)
		
		if not is_drop and is_back_auto and self.m_stop_btn.is_auto then
			explore_layer:continueAutoNavigation(true)
		end
	end
end

--保留接口，防止策划加回来
function ExploreUI:releaseDropAchnor()
	self:setIsDropAnchor(false)
end

function ExploreUI:setIsShowDetailUI(is_show)
	if self.m_is_show_detail == is_show then return end
	self.m_is_show_detail = is_show
	local mission_ui = getUIManager():get("ClsTeamMissionPortUI")
	if not tolua.isnull(mission_ui) then
		mission_ui:setIsShowPanel(self.m_is_show_detail)
	end
	if self.m_is_show_detail then
		self.m_player_ui:showPortIcon()
		self.m_player_ui:hideSelectUI()
	else
		self.m_player_ui:hidePortIcon()
		self.m_player_ui:hideSelectUI()
	end
	self:setIsShowTopBottons(is_show)

	local chat_component = getUIManager():get("ClsChatComponent")
	if not tolua.isnull(chat_component) then
		chat_component:setIsShow(self.m_is_show_detail)
	end
end

function ExploreUI:getIsShowDetailUI()
	return self.m_is_show_detail
end

function ExploreUI:setIsShowTopBottons(is_show)
	if self.m_is_show_top_btns == is_show then return end
	self.m_is_show_top_btns = is_show
	self.m_top_panel:stopAllActions()
	local move_act = nil
	if self.m_is_show_top_btns then
		move_act = CCEaseBackOut:create(CCMoveTo:create(0.3, ccp(self.m_top_panel.show_pos.x,  self.m_top_panel.show_pos.y)))
	else
		move_act = CCEaseBackIn:create(CCMoveTo:create(0.3, ccp(self.m_top_panel.hide_pos.x,  self.m_top_panel.hide_pos.y)))
	end
	self.m_top_panel:runAction(move_act)
end

function ExploreUI:setIsShowDropButton(is_show)
	if self.m_is_show_drop_btn == is_show then return end
	self.m_is_show_drop_btn = is_show
	self.m_stop_btn:stopAllActions()
	local move_act = nil
	if self.m_is_show_drop_btn then
		move_act = CCEaseBackOut:create(CCMoveTo:create(0.3, ccp(self.m_stop_btn.show_pos.x,  self.m_stop_btn.show_pos.y)))
	else
		move_act = CCEaseBackIn:create(CCMoveTo:create(0.3, ccp(self.m_stop_btn.hide_pos.x,  self.m_stop_btn.hide_pos.y)))
	end
	self.m_stop_btn:runAction(move_act)
end

function ExploreUI:playAudio(audioParam)
	local voice_res_key = audioParam.f--
	if self.m_is_man then
		voice_res_key = audioParam.m--
	end
	local voice_info = getLangVoiceInfo()
	local voiceRes = voice_info[voice_res_key].res

	if self.m_cur_voice_hander then
		if audioExt.isPlayEffect(self.m_cur_voice_hander) then
			self.m_cur_voice_hander = nil
			return
		end
	end
	self.m_cur_voice_hander = audioExt.playEffectOneTime(voice_res_key, voiceRes)
end

function ExploreUI:initButton()
	self.btn_helm:setPressedActionEnabled(true)
	self.btn_helm:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
		if getGameData():getTeamData():isLock(true) then
			return
		end
		if not IS_AUTO then
			if not getExploreLayer():continueAutoNavigation(true) then
				Alert:warning({msg = UI_WORD.AUTO_MOV_SET_TIPS})
			end
		end
	end, TOUCH_EVENT_ENDED)

	self.m_hide_btn:setPressedActionEnabled(true)
	self.m_hide_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
		local is_show = not self.m_is_show_detail
		if is_show then
			self.m_hide_btn:changeTexture("explore_hidden_1.png", "explore_hidden_2.png", "explore_hidden_2.png", UI_TEX_TYPE_PLIST)
		else
			self.m_hide_btn:changeTexture("explore_hidden_2.png", "explore_hidden_1.png", "explore_hidden_1.png", UI_TEX_TYPE_PLIST)
		end
		self:setIsShowDetailUI(is_show)
	end, TOUCH_EVENT_ENDED)
	
	self.m_stop_btn:setPressedActionEnabled(true)
	self.m_stop_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
		if getGameData():getTeamData():isLock(true) then return end
		self:setIsDropAnchor(not self.m_stop_btn.is_drop, true)
	end, TOUCH_EVENT_ENDED)
end

function ExploreUI:setSailState(state)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		self.m_cur_sail_state = state
		explore_layer:getPlayerShip():setShipMoveStatus(state)
		explore_layer:getPlayerShip():playSailAnimation(state)
		explore_layer:getShipsLayer():setSailState(state)
	end
end

function ExploreUI:getSailState()
	return self.m_cur_sail_state
end

function ExploreUI:isEnabledUI()
	return self:getViewTouchEnabled()
end

-------------触摸事件---------------


function ExploreUI:shipUIRotate(pos_info)
	local angle = pos_info.angle % 360
	pos_info.is_add_value = true
	self.world_map:setShipPosInfo(pos_info)
end

function ExploreUI:updateMapPointLab(tx, ty)
	if not tolua.isnull(self.m_map_pos_ui) then
		self.m_map_pos_ui:updataUI(tx, ty)
	end
end

function ExploreUI:changeWindHeadDown(wind_state)
	if self.seaway_state.wind_state ~= wind_state then
		self.seaway_state.wind_state = wind_state
		local sail_state = getExploreLayer():getShipsLayer():getSailState()
		if wind_state == WIND_HEAD then
			-- 当前是逆风 升帆状态，通知降帆
			if sail_state == SAIL_UP then
				EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, {tip_id = 30})
			end
		elseif wind_state == WIND_DOWN then
			-- 当前是顺风 降帆状态，通知升帆
			if sail_state == SAIL_DOWN then
				EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, {tip_id = 29})
			end
		end
		self:updateWindDir()
	end
end

--更新风向的显示
local WIND_DIR_CONFIG = {
	[WIND_DOWN] = UI_WORD.EXPLORE_STATE_DOWNWIND,  -- 顺
	[WIND_HEAD] = UI_WORD.EXPLORE_STATE_HEADWIND,  -- 逆
	[WIND_NO_EFFECT] = UI_WORD.EXPLORE_WIND_NONE,  -- 无风标志
}
function ExploreUI:updateWindDir()
	local wind_dir = getGameData():getExploreData():getWindInfo().dir
	self.wind_dir:setText(WIND_DIR_CONFIG[wind_dir])
end

function ExploreUI:updateTeamSpeedInfo()
	local teamData = getGameData():getTeamData()
	if (not teamData:isLock()) and teamData:isInTeam() then
		return
	end
	local ship_id = getGameData():getPlayersDetailData():getPlayerShipId(teamData:getTeamLeaderUid()) or 0
	boat_attr_item = boat_attr[ship_id]
	if boat_attr_item then
		local speed_n = (EXPLORE_BASE_SPEED) * self.speed_to_jie
		local speed_str = tonumber(string.format("%.1f", speed_n))
		local max_speed_str = tonumber(string.format("%.1f", speed_n * SPEED_RATE_DOWNWIND))
		resetSpeedDesc(self.m_speed_lab, speed_str, max_speed_str)
	end
end

function ExploreUI:changeSpeed(rate)
	--因为是可能每帧都会调用，所以打tolua.isnull的判断放到里面，来提高性能
	if self and rate and (not getGameData():getTeamData():isLock()) then
		if self.speed_rate ~= rate then
			if not tolua.isnull(self) then
				self.speed_rate = rate
				local speed = string.format("%.1f", self.speed_rate * self.ship_speed)
				local maxSp = string.format("%.1f", self.ship_speed * SPEED_RATE_DOWNWIND)
				speed = tonumber(speed)
				maxSp = tonumber(maxSp)
				resetSpeedDesc(self.m_speed_lab, speed, maxSp)
			end
		end
	end
end

function ExploreUI:updateFood()
	if not tolua.isnull(self.foodBg) then
		local beginValue = self.foodBg.valueLable.cur_value or 0
		self.curFood = getGameData():getSupplyData():getCurFood()
		self.totalFood = getGameData():getSupplyData():getTotalFood()
		local value = self.curFood
		local UiCommon = require("ui/tools/UiCommon")
		local function endBack()
			resetLablePos(self.foodBg, value, self.totalFood)
		end
		local function updateCallback(cur_num, goal_num)
			resetLablePos(self.foodBg, cur_num, self.totalFood, true)
		end
		UiCommon:numberEffect(self.foodBg.valueLable, beginValue, value, nil, endBack, nil, "/"..tostring(self.totalFood), updateCallback)

		if self.curFood <= self.totalFood*0.3 then
			if not self.m_is_show_food_warning then
				self:playAudio({f = "VOICE_EXPLORE_1024", m = "VOICE_EXPLORE_1004"})
				local ships_layer = getExploreLayer():getShipsLayer()
				local began_call = function()
					if not tolua.isnull(ships_layer) then
						ships_layer:setStopFoodReason("food_warning_stop_food")
					end
				end
				local end_call = function()
					if not tolua.isnull(ships_layer) then
						ships_layer:releaseStopFoodReason("food_warning_stop_food")
					end
				end
				EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {tip_id = 19, beganCallBack = began_call, call_back = end_call}, port_name)
				self.m_is_show_food_warning = true
			end
		else
			self.m_is_show_food_warning = false
		end

		local exploreData = getGameData():getExploreData()
		local after_auto_info = nil
		if IS_AUTO then
			if self.curFood <= self.totalFood*0.2 then
				if self.m_auto_go_supply_info.is_open and (not self.m_auto_go_supply_info.is_go) then
					self.m_auto_go_supply_info.is_go = true
					local port_info = require("game_config/port/port_info")
					local explore_layer = getExploreLayer()
					if not tolua.isnull(explore_layer) then
						local sx, sy = explore_layer:getPlayerShip():getPos()
						--获取距离最近的港口
						local near_port_id = 0
						local near_port_dis2_n = 0
						for port_id, port_cfg_item in pairs(port_info) do
							local px, py = explore_layer:getShipsLayer():tileToCocos(port_cfg_item.ship_pos[1], port_cfg_item.ship_pos[2])
							local port_dis2 = (px - sx)*(px - sx) + (py - sy)*(py - sy)
							if (near_port_id <= 0) or (near_port_dis2_n >= port_dis2) then
								near_port_id = port_id
								near_port_dis2_n = port_dis2
							end
						end
						
						--获取距离最近的遗迹
						local near_relic_id = 0
						local near_relic_dis2_n = 0
						for relic_id, relic_item in pairs(relic_info) do
							local px, py = explore_layer:getShipsLayer():tileToCocos(relic_item.ship_pos[1], relic_item.ship_pos[2])
							local relic_dis2 = (px - sx)*(px - sx) + (py - sy)*(py - sy)
							if (near_relic_id <= 0) or (near_relic_dis2_n >= relic_dis2) then
								near_relic_id = relic_id
								near_relic_dis2_n = relic_dis2
							end
						end
						
						local auto_pos = exploreData:getAutoPos()
						local after_auto_key = "Time_"..Math.floor(os.clock()*1000)
						if near_port_id > 0 and ((near_port_dis2_n <= near_relic_dis2_n) or near_relic_id <= 0) then
							local auto_pos = exploreData:getAutoPos()
							if auto_pos then
								if auto_pos.portId ~= near_port_id then
									local after_auto_info = auto_pos
									EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = near_port_id, navType = EXPLORE_NAV_TYPE_PORT})
									local now_auto_pos = exploreData:getAutoPos()
									now_auto_pos.after_auto_key = after_auto_key
									after_auto_info.after_auto_key = after_auto_key
									exploreData:setAfterAutoPos(after_auto_info)
								end
							end
						elseif near_relic_id > 0 and ((near_relic_dis2_n <= near_port_dis2_n) or near_port_id <= 0) then
							if auto_pos then
								if auto_pos.relicId ~= near_relic_id then
									local after_auto_info = auto_pos
									EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = near_relic_id, navType = EXPLORE_NAV_TYPE_RELIC})
									local now_auto_pos = exploreData:getAutoPos()
									now_auto_pos.after_auto_key = after_auto_key
									after_auto_info.after_auto_key = after_auto_key
									exploreData:setAfterAutoPos(after_auto_info)
								end
							end
						end
					end
				end
			else
				self.m_auto_go_supply_info.is_open = true
				self.m_auto_go_supply_info.is_go = false
				exploreData:setAfterAutoPos(nil)
			end
		else
			self.m_auto_go_supply_info.is_open = false
			self.m_auto_go_supply_info.is_go = false
			exploreData:setAfterAutoPos(nil)
		end
	end
end

function ExploreUI:updateSailor()
	if not tolua.isnull(self.sailorBg) then
		local beginValue = self.sailorBg.valueLable.cur_value or 0
		self.curSailor = getGameData():getSupplyData():getCurSailor()
		self.totalSailor = getGameData():getSupplyData():getTotalSailor()
		local value = self.curSailor
		local UiCommon = require("ui/tools/UiCommon")
		local function endBack()
			resetLablePos(self.sailorBg, value, self.totalSailor)
		end
		local function updateCallback(cur_num, goal_num)
			resetLablePos(self.sailorBg, cur_num, self.totalSailor, true)
		end
		UiCommon:numberEffect(self.sailorBg.valueLable, beginValue, value, nil, endBack, nil, "/"..tostring(self.totalSailor), updateCallback)

		if self.curSailor <= 0 then
			getGameData():getMissionData():clearPlot()
			--播放音效
			self:playAudio({f = "VOICE_EXPLORE_1025", m = "VOICE_EXPLORE_1005"})
			local explore_data = getGameData():getExploreData()
			explore_data:exploreOver()
			explore_data:exploreBreak()
		end
	end
end

function ExploreUI:updateExpUI()
	if tolua.isnull(self.m_explore_sea_ui) then return end
	local exp_bar = getConvertChildByName(self.m_explore_sea_ui, "exp_bar")
	local exp_num = getConvertChildByName(self.m_explore_sea_ui, "exp_num")
	local exp = getGameData():getPlayerData():getExp()
	local total_exp = getGameData():getPlayerData():getMaxExp()
	local percent = exp/total_exp*100
	exp_num:setText(exp.."/"..total_exp)
	exp_bar:setPercent(percent)
end

function ExploreUI:updatePlayerInfo(kind, value, max)
    if kind == TYPE_INFOR_POWER and (not tolua.isnull(self.powerBg)) then
        local beginValue = self.powerBg.valueLable.cur_value or 0
        local playerData = getGameData():getPlayerData()
        self.totalPower = playerData:getMaxPower()
        self.curPower = playerData:getPower()
        local value = self.curPower
        local UiCommon = require("ui/tools/UiCommon")
        local function endBack()
            resetLablePos(self.powerBg, value, self.totalPower)
        end
        local function updateCallback(cur_num, goal_num)
            resetLablePos(self.powerBg, cur_num, self.totalPower, true)
        end
        UiCommon:numberEffect(self.powerBg.valueLable, beginValue, value, nil, endBack, nil, "/"..tostring(self.totalPower), updateCallback)
    end
end
------------------------------------------

function ExploreUI:regFuns()

	local function showPortInfo(id) --探索港口信息
		if not getUIManager():isLive("ExploreUI") then return end

		local portPveData = getGameData():getPortPveData()
		local function closeCallBack()
			portPveData:clearOpponentData()
		end

		if portPveData:isPortFree(id) then
			local is_direct_enter = true
			local explore_layer = getExploreLayer()
			if not tolua.isnull(explore_layer) then
				local touch_info = explore_layer:getShipsLayer():getPlayerAttr("touch_something")
				--如果是点击大地图上的港口图标的话，不用出现港口提示牌，直接进入港口
				if touch_info and (type(touch_info) == "table") and (touch_info.type == "touch_land_port") and (touch_info.port_id == id) then
					is_direct_enter = false
				end
			end
			--玩家身上有要弹进港框的任务
			local missionInfo = getGameData():getMissionData():getMissionInfo()
			for _, info in ipairs(missionInfo) do
				if info.arrivemission_open and info.arrivemission_open == id then
					is_direct_enter = false
					return
				end
			end

			if is_direct_enter then
				EventTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT, id)
			else
				local params = {portId = id, closeCallBack = closeCallBack, quickEnterPort = true}
				getUIManager():create("gameobj/pve/clsEnterPortUI", nil, params)
			end
		end
	end

	RegTrigger(EVENT_EXPLORE_SHOW_PORT_INFO, showPortInfo)

	RegTrigger(EVENT_EXPLORE_CROSS_UNKNOW_AREA,function()
		if tolua.isnull(self) then return end
		if self.crossUnknowAreaSchHandler == nil then
			local function crossUnknowAreaTimerCB(dt)
				if self.crossUnknowAreaLb:isVisible() then
					self.crossUnknowAreaLb:setVisible(false)
				else
					self.crossUnknowAreaLb:setVisible(true)
				end
			end
			self.crossUnknowAreaSchHandler = self.scheduler:scheduleScriptFunc(crossUnknowAreaTimerCB, 1, false)
		end
	end)

	RegTrigger(EVENT_EXPLORE_CROSS_KNOW_AREA,function()
		if tolua.isnull(self) then return end
		if self.crossUnknowAreaSchHandler ~= nil then
			self.scheduler:unscheduleScriptEntry(self.crossUnknowAreaSchHandler)
			self.crossUnknowAreaSchHandler = nil
		end
		self.crossUnknowAreaLb:setVisible(false)
	end)
end

function ExploreUI:onExit()
	UnLoadPlist(self.plistTab)
	UnLoadArmature(self.armature)
	if self.hander_time_ship then
		self.scheduler:unscheduleScriptEntry(self.hander_time_ship)
		self.hander_time_ship = nil
	end

	self:removeTreasureScheduler()

	if self.crossUnknowAreaSchHandler ~= nil then
		self.scheduler:unscheduleScriptEntry(self.crossUnknowAreaSchHandler)
		self.crossUnknowAreaSchHandler = nil
	end

	if self.btn_trade_tab then
		for k, v in ipairs(self.btn_trade_tab) do
			if not tolua.isnull(v) then
				v:closeScheduler()
			end
		end
	end

	UnRegTrigger(EVENT_EXPLORE_SHOW_PORT_INFO)
	UnRegTrigger(EVENT_EXPLORE_CROSS_UNKNOW_AREA)
	UnRegTrigger(EVENT_EXPLORE_CROSS_KNOW_AREA)
end

return ExploreUI
