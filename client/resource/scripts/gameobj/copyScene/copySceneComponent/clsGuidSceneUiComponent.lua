--2016/07/23
--create by wmh0497
--组件基类
local ui_word = require("scripts/game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local UiCommon= require("ui/tools/UiCommon")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local ClsComponentBase = require("ui/view/clsComponentBase")
local music_info = require("scripts/game_config/music_info")

local ClsGuidSceneUiComponent = class("ClsGuidSceneUiComponent", ClsComponentBase)

ClsGuidSceneUiComponent.onStart = function(self)
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.m_explore_sea_ui = self.m_parent:getJsonUi()
	self.m_notices_tab = {}
	self:initJsonUi()
end

ClsGuidSceneUiComponent.initJsonUi = function(self)
	local disable_tab = {"btn_back"}
	for _, v in pairs(disable_tab) do
		local ui = getConvertChildByName(self.m_explore_sea_ui, v)
		ui:setEnabled(false)
	end

	self.m_stronghold_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_stronghold.json")
	self.m_parent:addWidget(self.m_stronghold_ui)
	
	self.m_time_lab = getConvertChildByName(self.m_stronghold_ui, "time_count")
	self.m_time_lab.left_tip_lab = getConvertChildByName(self.m_stronghold_ui, "time_left")
	self.m_time_lab.open_tip_lab = getConvertChildByName(self.m_stronghold_ui, "before_start")
	self.m_time_lab.clean_tip_lab = getConvertChildByName(self.m_stronghold_ui, "time_clean")
	self.m_notice_panel = getConvertChildByName(self.m_stronghold_ui, "notice_panel")
	self.m_notice_panel.width = self.m_notice_panel:getSize().width
	
	-- 信息
	self.m_back_btn = getConvertChildByName(self.m_stronghold_ui, "btn_back")
	self.m_back_btn:setPressedActionEnabled(true)
	self.m_back_btn:addEventListener(function()  -- 探索返回按钮
		local teamData = getGameData():getTeamData()
		local tips_str = ui_word.GUILD_STRONGHOLD_STATION_LEVEA_LEADER_TIPS
		if teamData:isLock() then
			tips_str = ui_word.GUILD_STRONGHOLD_STATION_LEVEA_TIPS
		end
		ClsAlert:showAttention(tips_str, function()
				if teamData:isLock() then
					teamData:askLeaveTeam()
				end
				ClsSceneManage:sendExitSceneMessage()
			end, nil, nil, {hide_cancel_btn = true})
	end, TOUCH_EVENT_ENDED)

	--排行按钮
	self.m_rank_btn = getConvertChildByName(self.m_stronghold_ui, "btn_stop")
	self.m_rank_btn:setPressedActionEnabled(true)
	self.m_rank_btn:addEventListener(function()  -- 据点排行按钮
		local explore_player_ships_data = getGameData():getExplorePlayerShipsData()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/clsGuildFightRankUI")
	end, TOUCH_EVENT_ENDED)

	self.m_backpack_btn = getConvertChildByName(self.m_stronghold_ui, "btn_backpack")
	self.m_backpack_btn:setPressedActionEnabled(true)
	self.m_backpack_btn:addEventListener(function()  -- 仓库按钮
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local ClsMissionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local backpack_ui = ClsMissionSkipLayer:skipLayerByName("backpack")
	end, TOUCH_EVENT_ENDED)
	
	self:initTimeHander()
	
end

ClsGuidSceneUiComponent.initTimeHander = function(self)
	self.m_time_lab:setText("")
	self.m_time_lab.left_tip_lab:setVisible(false)
	self.m_time_lab.open_tip_lab:setVisible(false)
	
	local repeat_act = UiCommon:getRepeatAction(1, function()
			self:updateLeftTimeShow()
		end)
	self.m_time_lab:runAction(repeat_act)
end

ClsGuidSceneUiComponent.updateLeftTimeShow = function(self)
	local start_time = ClsSceneManage:getSceneAttr("cur_ghost_time")
	local end_time = ClsSceneManage:getSceneAttr("cur_remain_time")
	local clean_time = ClsSceneManage:getSceneAttr("cur_clean_time") 
	if start_time and end_time then
		local now_time = os.clock()
		local left_time = 0
		local is_prepare = false
		local is_clean = false
		if start_time > now_time then
			left_time = Math.ceil(start_time - now_time)
			is_prepare = true
		else
			if (end_time - now_time) >= 0 or (not clean_time)  then
				left_time = Math.ceil(end_time - now_time)
				if left_time <= 0 then left_time = 0 end
			else
				left_time = Math.ceil(clean_time - now_time)
				is_clean = true
			end
		end
		local time_str = ClsDataTools:getTimeStrNormal(left_time)
		self.m_time_lab:setText(time_str)

		if not is_clean then
			self.m_time_lab.clean_tip_lab:setVisible(false)
			self.m_time_lab.left_tip_lab:setVisible(not is_prepare)
			self.m_time_lab.open_tip_lab:setVisible(is_prepare)
		else
			self.m_time_lab.left_tip_lab:setVisible(false)
			self.m_time_lab.open_tip_lab:setVisible(false)
			self.m_time_lab.clean_tip_lab:setVisible(true)
		end
	end
end

local label_offset_y = 30
ClsGuidSceneUiComponent.putNoticeMsg = function(self, msg_str)
	local richlabel = createRichLabel(msg_str, 40, 10, 20, nil, true)
	local pos_center_x = (self.m_notice_panel.width - richlabel:getContentSize().width)/2
	richlabel:setPosition(ccp(pos_center_x, 0))
	richlabel.pos_center_x = pos_center_x
	if tolua.isnull(self.m_notices_tab[1]) then
		richlabel:setPosition(ccp(pos_center_x, -1*label_offset_y))
	else
		local pos_y = self.m_notices_tab[1]:getPositionY()
		richlabel:setPosition(ccp(pos_center_x, pos_y - label_offset_y))
	end
	self.m_notice_panel:addCCNode(richlabel)
	table.insert(self.m_notices_tab, 1, richlabel)

	--延时删除
	local delay_act = CCDelayTime:create(5)
	local callback_act = CCCallFunc:create(function()
			if not tolua.isnull(richlabel) then
				self:runRemoveAction(richlabel)
			end
		end)
	richlabel:runAction(CCSequence:createWithTwoActions(delay_act, callback_act))

	--移动
	self:allNoticeMove()
end

ClsGuidSceneUiComponent.allNoticeMove = function(self)
	for k, v in pairs(self.m_notices_tab) do
		local target_y = (k - 1)*label_offset_y
		local now_y = v:getPositionY()
		local before_move_act = v.move_act
		if not tolua.isnull(before_move_act) then
			if not before_move_act:isDone() then
				v:stopAction(before_move_act)
			end
		end
		local now_move_act = CCMoveTo:create((target_y - now_y)/label_offset_y, ccp(v.pos_center_x, target_y))
		v.move_act = now_move_act
		v:runAction(now_move_act)
	end
end

ClsGuidSceneUiComponent.runRemoveAction = function(self, target_spr)
	if target_spr.is_removeing then
		return
	end
	target_spr.is_removeing = true
	local fade_act = CCFadeOut:create(0.5)
	local callback_act = CCCallFunc:create(function()
			for k, v in pairs(self.m_notices_tab) do
				if v == target_spr then
					v:removeFromParentAndCleanup()
					table.remove(self.m_notices_tab, k)
					break
				end
			end
		end)
	target_spr:runAction(CCSequence:createWithTwoActions(fade_act, callback_act))
end



return ClsGuidSceneUiComponent



