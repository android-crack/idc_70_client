--
-- Author: lzg0496
-- Date: 2016-12-03 20:51:20
-- Function: 比分组件

local ui_word = require("scripts/game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsAlert = require("ui/tools/alert")
local music_info = require("scripts/game_config/music_info")
local on_off_info = require("game_config/on_off_info")

local clsVSUIComponent = class("clsVSUIComponent", ClsComponentBase)

function clsVSUIComponent:onStart()
	self.armature = {
		"effects/tx_0126.ExportJson", --仓库
		"effects/tx_0187.ExportJson", --组队
		"effects/tx_0196.ExportJson", --技能
		"effects/tx_0131.ExportJson", --伙伴
	}
	LoadArmature(self.armature)
	self.key_list = {}
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.m_explore_sea_ui = self.m_parent:getJsonUi()
	self:initUI()
	self:configEvent()
	self:initTopLeftBtn()
end

function clsVSUIComponent:initUI()
	local need_widget_name = {
		pal_copy_stronghold = "copy_stronghold",
		lbl_time = "time",
		lbl_me_people = "me_people",
		lbl_me_point = "me_point",
		lbl_me_name = "me_text",
		lbl_enemy_point = "enemy_point",
		lbl_enemy_people = "enemy_people",
		lbl_enemy_name = "enemy_text",
		btn_back = "btn_back",
		btn_rank = "btn_rank",
		pal_port_icon = "port_icon",
		stronghold_panel = "stronghold_head",
		btn_rank_txt = "btn_rank_text",
		lbl_countdown_time = "countdown_time",
		lbl_countdown_txt = "countdown",
		pal_copy_port_battle = "copy_portfight",
		lbl_port_battle_countdown_time = "portfight_countdown_time",
		lbl_port_battle_countdown_txt = "portfight_countdown_text",
		lbl_port_battle_time = "portfight_time",
		lbl_attacker_left_name = "portfight_text_1",
		lbl_attacker_right_name = "portfight_text_2",
		lbl_defender_name = "portfight_text_3",
		lbl_attacker_left_people = "portfight_people_1",
		lbl_attacker_right_people = "portfight_people_2",
		spr_left_ship = "portfight_ship_1",
		spr_right_ship = "portfight_ship_2",
		btn_hidden_ui = "btn_hidden_ui",
		btn_rule = "rule_btn",
		pal_portfight_angry = "portfight_angry",
		bar_hall = "bar_hall",
		bar_hall_bg = "bar_bg_hall",
		bar_right_ship_bg = "bar_bg_ship_2",
		bar_left_ship_bg = "bar_bg_ship_1",
		bar_right_ship = "bar_ship_2",
		bar_left_ship = "bar_ship_1",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.m_explore_sea_ui, v)
	end

	for i = 1, 6 do
		local key = "portfight_turret_" .. i
		self[key] = getConvertChildByName(self.m_explore_sea_ui, key)
		key = "bar_bg_" .. i
		self[key] = getConvertChildByName(self.m_explore_sea_ui, key)
		key = "bar_" .. i
		self[key] = getConvertChildByName(self.m_explore_sea_ui, key)
	end

	for i = 1, 3 do
		local key = "buff_camp_" .. i
		self[key] = getConvertChildByName(self.m_explore_sea_ui, key)
	end

	self.btn_back:setVisible(true)

	self.btn_hidden_ui:setVisible(true)
	self.pal_port_icon:setVisible(true)
	self.spr_left_ship:setVisible(false)
	self.spr_right_ship:setVisible(false)
	self.pal_portfight_angry:setVisible(false)
end

function clsVSUIComponent:showCopyStronghold(value)
	self.pal_copy_stronghold:setVisible(value)
	 self.btn_rule:setEnabled(not value)
end

function clsVSUIComponent:touchSkillEvent()
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local armature_animation = self.btn_skill.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	getUIManager():create("gameobj/playerRole/clsRoleSkill")
end

function clsVSUIComponent:touchWareHouseEvent()
	audioExt.playEffect(music_info.OPEN_BOX.res)
	local armature_animation = self.btn_backpack.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	require("gameobj/mission/missionSkipLayer"):skipLayerByName("backpack")
end

function clsVSUIComponent:touchStaffEvent()
	audioExt.playEffect(music_info.PORT_GOTOSEA.res)
	local armature_animation = self.btn_staff.icon:getAnimation()
	armature_animation:playByIndex(0, -1, -1, 0)
	armature_animation:addMovementCallback(function(eventType) end)
	getUIManager():create("gameobj/fleet/clsFleetPartner")
end

local click_event = {
	clsVSUIComponent.touchWareHouseEvent,
	clsVSUIComponent.touchSkillEvent,
	clsVSUIComponent.touchStaffEvent,
}

--爵位，仓库按钮
function clsVSUIComponent:initTopLeftBtn()
	local btns = {
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
		self[v.name] = getConvertChildByName(self.pal_port_icon, v.name)
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

function clsVSUIComponent:configEvent()
	self.btn_back:addEventListener(function()
		local exit_func = self:getExitCallBack()
		if type(exit_func) == "function" then
			exit_func()
			return
		end
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
		local tips_str = ClsSceneManage:doLogic("getExitTips")
		ClsAlert:showAttention(tips_str, function()
				ClsSceneManage:sendExitSceneMessage()
			end, nil, nil, {hide_cancel_btn = true})
	end, TOUCH_EVENT_ENDED)

	self.btn_rank:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:showRankUI()
	end, TOUCH_EVENT_ENDED)
end

function clsVSUIComponent:setExitCallBack(func)
	self.exit_cb = func
end

function clsVSUIComponent:getExitCallBack()
	return self.exit_cb
end

function clsVSUIComponent:showRankUI(is_guide, guide_call_back)
	local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
	copy_scene_manage:doLogic("showRankUI", is_guide, guide_call_back)
end

function clsVSUIComponent:updateGuildBattleTime(end_time)
	local lbl_time = self.lbl_time
	local guild_fight_data = getGameData():getGuildFightData()
	local player_data = getGameData():getPlayerData()
	local status = guild_fight_data:getGroupFightStatus()
	self.lbl_countdown_txt:setVisible(status == GROUP_FIGHT_WAIT_STATUS)
	self.lbl_countdown_time:setVisible(status == GROUP_FIGHT_WAIT_STATUS)
	self.lbl_time:setVisible(status == GROUP_FIGHT_FIGHTING_STATUS or status == GROUP_FIGHT_END_STATUS)
	local remain_time = end_time - (os.time() + player_data:getTimeDelta())
	if status == GROUP_FIGHT_WAIT_STATUS then
		lbl_time = self.lbl_countdown_time
		remain_time = remain_time - GUILD_BATTLE_ACTITY_TIME
	end

	self.lbl_time:stopAllActions()
	self.lbl_countdown_time:stopAllActions()
	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		remain_time = remain_time - 1
		if remain_time <= 0 then
			remain_time = 0
			lbl_time:stopAllActions()
			return
		end
		lbl_time:setText(ClsDataTools:getTimeStrNormal(remain_time))
	end))
	arr_action:addObject(CCDelayTime:create(1))
	lbl_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function clsVSUIComponent:updatePortBattleTime(end_time)
	local lbl_time = self.lbl_port_battle_time
	local port_battle_data = getGameData():getPortBattleData()
	local player_data = getGameData():getPlayerData()
	local status = port_battle_data:getPortBattleStatus()
	self.lbl_port_battle_countdown_txt:setVisible(status == PORT_BATTLE_WAIT_STATUS)
	self.lbl_port_battle_countdown_time:setVisible(status == PORT_BATTLE_WAIT_STATUS)
	self.lbl_port_battle_time:setVisible(status == PORT_BATTLE_FIGHTING_STATUS or status == PORT_BATTLE_END_STATUS)
	local remain_time = end_time - (os.time() + player_data:getTimeDelta())
	if status == PORT_BATTLE_WAIT_STATUS then
		lbl_time = self.lbl_port_battle_countdown_time
		remain_time = remain_time - POPT_BATTLE_ACTITY_TIME
	end

	self.lbl_port_battle_time:stopAllActions()
	self.lbl_port_battle_countdown_time:stopAllActions()
	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		remain_time = remain_time - 1
		if remain_time <= 0 then
			remain_time = 0
			lbl_time:stopAllActions()
			return
		end
		lbl_time:setText(ClsDataTools:getTimeStrNormal(remain_time))
	end))
	arr_action:addObject(CCDelayTime:create(1))
	lbl_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function clsVSUIComponent:updateMePeople(my_people, color)
	self.lbl_me_people:setText(string.format(ui_word.STR_PEOPLE, my_people))
	setUILabelColor(self.lbl_me_people, color)
end

function clsVSUIComponent:updateEnemyPeople(enemy_people, color)
	self.lbl_enemy_people:setText(string.format(ui_word.STR_PEOPLE, enemy_people))
	setUILabelColor(self.lbl_enemy_people, color)
end

function clsVSUIComponent:updateMePoint(my_point, color)
	self.lbl_me_point:setText(string.format(ui_word.STR_POINT, my_point))
	setUILabelColor(self.lbl_me_point, color)
end

function clsVSUIComponent:updateEnemyPoint(enemy_point, color)
	self.lbl_enemy_point:setText(string.format(ui_word.STR_POINT, enemy_point))
	setUILabelColor(self.lbl_enemy_point, color)
end

function clsVSUIComponent:updateMyName(my_name, color)
	self.lbl_me_name:setText(my_name)
	setUILabelColor(self.lbl_me_name, color)
end

function clsVSUIComponent:updateEnemyName(enemy_name, color)
	self.lbl_enemy_name:setText(enemy_name)
	setUILabelColor(self.lbl_enemy_name, color)
end

function clsVSUIComponent:setAttackerLeftName(name)
	if not name then self.lbl_attacker_left_name:setVisible(false) return end
	self.lbl_attacker_left_name:setVisible(true)
	self.lbl_attacker_left_name:setText(name)
end

function clsVSUIComponent:setAttackerLeftPeople(pepole)
	if not pepole then self.lbl_attacker_left_people:setVisible(false) return end
	self.lbl_attacker_left_people:setVisible(true)
	self.lbl_attacker_left_people:setText(string.format(ui_word.STR_PEOPLE, pepole))
end

function clsVSUIComponent:setAttackerRightName(name)
	if not name then self.lbl_attacker_right_name:setVisible(false) return end
	self.lbl_attacker_right_name:setVisible(true)
	self.lbl_attacker_right_name:setText(name)
end

function clsVSUIComponent:setAttackerRightPeople(pepole)
	if not pepole then self.lbl_attacker_right_people:setVisible(false) return end
	self.lbl_attacker_right_people:setVisible(true)
	self.lbl_attacker_right_people:setText(string.format(ui_word.STR_PEOPLE, pepole))
end

function clsVSUIComponent:setDefenderName(name)
	if not name then self.lbl_defender_name:setVisible(false) return end
	self.lbl_defender_name:setVisible(true)
	self.lbl_defender_name:setText(name)
end

function clsVSUIComponent:setShipVisible(dir_ship, is_visible)
	if "left" ~= dir_ship and "right" ~= dir_ship then return end
	local ship_name = string.format("spr_%s_ship", dir_ship)
	local bar_bg = string.format("bar_%s_ship_bg", dir_ship)
	if tolua.isnull(self[ship_name]) then return end
	self[ship_name]:setVisible(is_visible)
	self[bar_bg]:setVisible(is_visible)
	if not is_visible then
		self[ship_name]:stopAllActions()
		return 
	end
	arr_action = CCArray:create()
	arr_action:addObject(CCBlink:create(1, 1))
	self[ship_name]:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function clsVSUIComponent:setShipPos(dir_ship, set_pos)
	if "left" ~= dir_ship and "right" ~= dir_ship then return end
	local ship_name = string.format("spr_%s_ship", dir_ship)
	local bar_bg = string.format("bar_%s_ship_bg", dir_ship)
	if tolua.isnull(self[ship_name]) then return end
	if set_pos then self[ship_name]:setPosition(set_pos) end
	if tolua.isnull(self[bar_bg]) then return end
	self[bar_bg]:setPosition(ccp(set_pos.x, set_pos.y - 17))
end

function clsVSUIComponent:setShipHp(dir_ship, percent)
	if "left" ~= dir_ship and "right" ~= dir_ship then return end
	local bar = string.format("bar_%s_ship", dir_ship)
	if tolua.isnull(self[bar]) then return end
	self[bar]:setPercent(percent)
end

function clsVSUIComponent:setTurretVisible(index, is_visible)
	if not self["portfight_turret_" .. index] then return  end
	self["portfight_turret_" .. index]:setVisible(is_visible)
	self["bar_bg_" .. index]:setVisible(is_visible)
end

function clsVSUIComponent:setTurretHP(index, percent)
	if not self["bar_" .. index] then return  end
	self["bar_" .. index]:setPercent(percent)
end

function clsVSUIComponent:setHallHp(percent)
	self.bar_hall_bg:setVisible(true)
	self.bar_hall:setPercent(percent)
end

function clsVSUIComponent:changeUIToSeaGod()
	self.btn_rank:setVisible(false)
	self.btn_rank:setTouchEnabled(false)
	self.stronghold_panel:setVisible(false)
end

function clsVSUIComponent:changeUIToPortBattle()
	self.stronghold_panel:setVisible(false)
	self:showPortBattleUI()
end

function clsVSUIComponent:showPortBattleUI()
	self.pal_copy_port_battle:setVisible(true)
	self.pal_portfight_angry:setVisible(true)

	for i = 1, 3 do
		self["buff_camp_" .. i]:setText("0")
	end
end

function clsVSUIComponent:setCampBuff(buff, camp)
	self["buff_camp_" .. camp]:setText(buff)
end

--修改积分排行榜的按钮文字
function clsVSUIComponent:changePointText(text)
	self.btn_rank_txt:setText(text)
end


return clsVSUIComponent
