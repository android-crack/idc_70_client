-- 港口主界面任务-组队显示UI
-- Author: pyq
-- Date: 2016-08-20  0:00:00
--
local music_info = require("game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local ClsMissionMainUI = require("gameobj/mission/clsMissionMainUI")
local ClsMissionPortItem = require("gameobj/mission/clsMissionPortItem")
local ClsTeamPortItem = require("gameobj/team/clsTeamPortItem")
local ClsFriendInvite = require("gameobj/team/clsFriendInvite")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local commonBase  = require("gameobj/commonFuns")
local composite_effect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsTeamMissionPortUI = class("ClsTeamMissionPortUI", ClsBaseView)

local FINAL_MAIN_LINE = '2690'
local NEW_BIE_MID = '10'
local START_MID = '70'
local DELAY_TIME = 0.25
local EFFECT_TIME = 1.5
local SELECT_TEAM = 2
local SELECT_MISSION = 1

local widget_name = {
	"btn_task",
	"btn_team",
	"btn_arrow",
	"task_panel",
	"task_bg",
	"btn_creat",
	"btn_invite",
	"btn_find",
	"btn_arrow",
	"chapter_name",
	"chapter_panel",
	"icon_selected_1",
	"icon_selected_2",
}

function ClsTeamMissionPortUI:getViewConfig()
    return {
        name = "ClsTeamMissionPortUI",
        is_swallow = false
    }
end

local function setBtnStatus(btn, bool)
	btn:setVisible(bool)
	btn:setTouchEnabled(bool)
end

function ClsTeamMissionPortUI:onEnter(hideTaskBtn)
	self.plist = {
		["ui/head_frame.plist"] = 1,
		["ui/team_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.chat_bubbles = {} --气泡列表
	self.guide_tbl = {}
	self.list_view = nil
	self.s_type = nil
	self.enable = true
	self.isRunning = false
	self.is_panel_hide = false
	self.isNeedTaskBtn = not hideTaskBtn
	self.is_click_task_or_team_btn = false
	self.cell_width = 162
	self.cell_height = 78

	self:mkUI()
	self:regEvent()
	self:defaultSelect()
	self:checkIsHide()
end

function ClsTeamMissionPortUI:regEvent()
	for btn_type, btn in ipairs(self.btn_tab) do
		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.is_click_task_or_team_btn = true
			self:selectTab(btn_type)
		end, TOUCH_EVENT_ENDED)

		btn:addEventListener(function()
			self:selectEffect(self.s_type)
		end, TOUCH_EVENT_CANCELED)
	end

	self.btn_creat:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local team_data = getGameData():getTeamData()
		local NO_TARGET_TEAM_TYPE = 1
		team_data:setTeamType(NO_TARGET_TEAM_TYPE)
		team_data:askCreateTeam()
	end, TOUCH_EVENT_ENDED)

	self.btn_invite:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/team/clsFriendInvite")
	end, TOUCH_EVENT_ENDED)

	self.btn_find:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not getUIManager():isLive("ClsPortLayer") then
			Alert:warning({msg = ui_word.GO_BACK_PORT})
			return
		end
		getUIManager():create("gameobj/team/clsPortTeamUI")
	end, TOUCH_EVENT_ENDED)

	RegTrigger(EVENT_MISSION_OR_DAILY_UPDATE,function()
		if self.s_type ~= SELECT_MISSION then return end
		if tolua.isnull(self) then return end
		self:updateMissionViewInfo()
	end)
end

function ClsTeamMissionPortUI:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_task_box.json")
	convertUIType(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.btn_tab = {
		self.btn_task,
		self.btn_team,
	}
	self.chapter_panel:setVisible(false)
	self.btn_creat:setPressedActionEnabled(true)
	self.btn_invite:setPressedActionEnabled(true)
	self.btn_arrow:setPressedActionEnabled(true)
	self.btn_arrow:addEventListener(function()
		if self.isRunning then return end
		self:showOrHidePanel(not self.is_panel_hide)
	end, TOUCH_EVENT_ENDED)
	self:addWidget(self.panel)

	local pos = self.btn_arrow:getPosition()
	self.btn_arrow.org_pos = {x = pos.x, y = pos.y}

	setBtnStatus(self.btn_task, self.isNeedTaskBtn)
	local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.ORGANIZETEAM.value, {openBtn = self.btn_team, openEnable = true, addLock = true, btnRes = "#common_task_btn1.png", parent = "ClsTeamMissionPortUI"})
end

--添加一个外部调用方法，统一接口
function ClsTeamMissionPortUI:setIsShowPanel(is_show)
	if ClsGuideMgr:checkHasStrengthGuide() then
		self:showOrHidePanel(false)
		return
	end
	self:showOrHidePanel(not is_show)
end

function ClsTeamMissionPortUI:showOrHidePanel(is_hide, delay_time)
	if self.is_panel_hide == is_hide then return end
	self.is_panel_hide = is_hide
	delay_time = delay_time or DELAY_TIME
	self.isRunning = true
	audioExt.playEffect(music_info.PORT_INFO_UP.res)

	self.btn_arrow:stopAllActions()
	self.task_panel:stopAllActions()

	local arrow_action
	local panel_action
	if self.is_panel_hide then
		arrow_action = CCMoveTo:create(delay_time, ccp(self.btn_arrow.org_pos.x + 179, self.btn_arrow.org_pos.y))
		panel_action = CCScaleTo:create(delay_time, 0, 1)
	else
		arrow_action = CCMoveTo:create(delay_time, ccp(self.btn_arrow.org_pos.x, self.btn_arrow.org_pos.y))
		panel_action = CCScaleTo:create(delay_time, 1, 1)
	end

	local arrow_arr = CCArray:create()
	arrow_arr:addObject(arrow_action)
	arrow_arr:addObject(CCCallFunc:create(function()
		if self.is_panel_hide then
			self.btn_arrow:setRotation(180)
		else
			self.btn_arrow:setRotation(0)
		end
	end))
	self.btn_arrow:runAction(CCSequence:create(arrow_arr))
	self:updateChatBubble()
	local bg_arr = CCArray:create()
	bg_arr:addObject(panel_action)
	bg_arr:addObject(CCCallFunc:create(function()
		self.isRunning = false
	end))
	self.task_panel:runAction(CCSequence:create(bg_arr))
end

--绿字跳转
function ClsTeamMissionPortUI:getGuideInfo(mid)
	if not self.cells then return end

	if self:getSelectType() == SELECT_TEAM then return end
	local guide_layer = self.list_view:getInnerLayer()
	for k, cell in ipairs(self.cells) do
		if cell.mid == mid then
			self.guide_tbl[mid] = true
			local world_pos = cell:convertToWorldSpace(ccp(79, 36))
			local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
			local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
			return guide_layer, guide_node_pos, {['w'] = 160, ['h'] = 71}
		end
	end
end

local function checkIsInLine(main_line, branch_line)
	if not main_line then return end

	local temp_main_id = nil
	local temp_branch_id = nil
	local branch_tag = string.find(branch_line.id, "_", 0)
	local main_tag = string.find(main_line.id, "_", 0)
	if branch_tag then
		temp_branch_id = string.sub(branch_line.id, 1, branch_tag - 1)
	else
		temp_branch_id = branch_line.id
	end
	if main_tag then
		temp_main_id = string.sub(main_line.id, main_tag - 1)
	else
		temp_main_id = main_line.id
	end

	for index, threshold in ipairs(main_line.mission_before) do
		if tonumber(temp_branch_id) <= threshold and tonumber(temp_branch_id) > tonumber(temp_main_id) then
			return true, index
		end
	end
end

local function spliteString(str, number)
	local strTable = {}
	local strLen = commonBase:utfstrlen(str)
	local reminder = strLen % number
	local n = 0
	if reminder == 0 then
		n = math.floor(strLen / number)
	else
		n = math.floor(strLen / number) + 1
	end
	local startIndex = 1
	for i = 1, n do
		local tmpStr = commonBase:utf8sub(str, startIndex, number)
		startIndex = startIndex + number
		strTable[#strTable + 1] = tmpStr
	end
	return strTable
end

function ClsTeamMissionPortUI:showTitleFollowEffect(str)
	if tolua.isnull(self.chapter_name) then return end
	local widget = self.chapter_name
	if not widget.is_playing_act then
		widget.is_playing_act = true
		local dec_lab_cut_tab = spliteString(str, 1)
		local dec_lab_cut_count_n = 1
		local effect_time = EFFECT_TIME / (#dec_lab_cut_tab)
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(effect_time))
		array:addObject(CCCallFunc:create(function()
			if type(dec_lab_cut_tab) == "table" then
				if dec_lab_cut_count_n > #dec_lab_cut_tab then
					widget:stopAllActions()
					widget.is_playing_act = false
					if self.chapter_effect and not tolua.isnull(self.chapter_effect) then
						self.chapter_effect:setVisible(true)
					end
					return
				end
			end
			if not tolua.isnull(widget) then
				local str = ""
				for i = 1, dec_lab_cut_count_n do
					str = str .. dec_lab_cut_tab[i]
				end
				widget:setText(str)
			else
				widget:stopAllActions()
				return
			end
			dec_lab_cut_count_n = dec_lab_cut_count_n + 1
		end))
		widget:runAction(CCRepeatForever:create(CCSequence:create(array)))
	end
end

function ClsTeamMissionPortUI:showTitleEffect(mid)
	if not mid then mid = FINAL_MAIN_LINE end
	local effect_id = "tx_chapter_txt"
	local pos = self.chapter_name:getPosition()
	self.title_effect = composite_effect.new(effect_id, pos.x + 40, pos.y, self.chapter_panel, EFFECT_TIME, nil, nil, nil, true)

	local title_str = getMissionInfo()[mid].chapter_title
	self:alignTitle(title_str)
	self:showTitleFollowEffect(title_str)
end

function ClsTeamMissionPortUI:cleanTitleEffect()
	if self.title_effect and not tolua.isnull(self.title_effect) then
		self.title_effect:removeFromParentAndCleanup(true)
		self.title_effect = nil
	end
	if self.chapter_effect and not tolua.isnull(self.chapter_effect) then
		self.chapter_effect:setVisible(false)
	end
	self.chapter_name:setText("")
end

function ClsTeamMissionPortUI:alignTitle(text)
	local title_str = nil
	if text then
		title_str = text
	else
		local main_mission_id = getGameData():getMissionData():getMainLineMission()
		if not main_mission_id then main_mission_id = FINAL_MAIN_LINE end
		title_str = getMissionInfo()[main_mission_id].chapter_title
	end
	self.chapter_name:setText(title_str)

	local bg_size = self.chapter_panel:getSize()
	local chapter_name_size = self.chapter_name:getSize()
	self.chapter_name:setPosition(ccp(bg_size.width/2 - chapter_name_size.width/2, self.chapter_name:getPosition().y))

	if tolua.isnull(self.chapter_effect) then
		self.chapter_effect = composite_effect.new("tx_chapter_frame", 79, 18, self.chapter_panel, nil, nil, nil, nil, true)
	end

	if text then
		self.chapter_name:setText("")
		self.chapter_effect:setVisible(false)
	else
		self.chapter_effect:setVisible(true)
	end
end

function ClsTeamMissionPortUI:initMissionEffect(mission_list)
	local is_new_bie_stage = false
	local is_start_chapter = false
	if #mission_list > 0 then
		for _, mission_info in pairs(mission_list) do
			if mission_info.id == NEW_BIE_MID then
				is_new_bie_stage = true
				break
			end
			if mission_info.id == START_MID then
				is_start_chapter = true
				break
			end
		end
		if not is_lock_effect then --任务栏气泡文字特效是否需要添加
			self.chapter_panel:setVisible(true)
			self:alignTitle()
		else
			self.chapter_name:setText("")
			if self.chapter_effect and not tolua.isnull(self.chapter_effect) then
				self.chapter_effect:setVisible(false)
			end
		end
	end
	if is_new_bie_stage or is_start_chapter then --章节特效是否添加
		self.chapter_panel:setVisible(true)
		if self.chapter_effect and not tolua.isnull(self.chapter_effect) then
			self.chapter_effect:setVisible(false)
		end
	end
end

function ClsTeamMissionPortUI:updateMissionViewInfo()
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParent()
		self.list_view = nil
	end
	self:hideTeamBtn()
	local mission_data_handler = getGameData():getMissionData()
	local is_lock_effect = mission_data_handler:getEffectSwitch()
	local mission_list = mission_data_handler:getMissionAndDailyMissionInfo()
	if not mission_list then
		return
	end
	self:initMissionEffect(mission_list)

	local multi_main_line_mission = nil
	local mission = {}
	local normal_mission = {}
	self.cells = {}
	self.list_view = ClsScrollView.new(168, 114, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/main_task_view.json")
		return cell_ui
	end)
	for i,v in ipairs(mission_list) do
		if v.mission_before then
			multi_main_line_mission = v
		else
			local is_in_line, change_index = checkIsInLine(multi_main_line_mission, v)
			if multi_main_line_mission and is_in_line then
				if not multi_main_line_mission.branch_exchange then multi_main_line_mission.branch_exchange = {} end
				multi_main_line_mission.branch_exchange[change_index] = v
			else
				table.insert(normal_mission, v)
			end
		end
	end
	if multi_main_line_mission then table.insert(mission, multi_main_line_mission) end
	for i, v in ipairs(normal_mission) do
		table.insert(mission, v)
	end
	for i, v in ipairs(mission) do
		self.cells[i] = ClsMissionPortItem.new(CCSize(self.cell_width, self.cell_height), v)
		self.cells[i].mid = v.id
	end
	self:addDetailBtn()
	self.list_view:addCells(self.cells)
	self.list_view:setPosition(ccp(6, 7))
	self.task_bg:addChild(self.list_view)

	ClsGuideMgr:tryGuide("ClsTeamMissionPortUI")
	self:setTouch(self.enable)
end

function ClsTeamMissionPortUI:updateTeamViewInfo()
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParent()
		self.list_view = nil
	end
	getUIManager():close("ClsTeamExpandWin")

	local teamData = getGameData():getTeamData()
	local myTeamList = teamData:getMyTeamInfo()
	local isInTeam = teamData:isInTeam()
	local isTeamFull = teamData:isTeamFull()
	setBtnStatus(self.btn_creat, not isInTeam)
	setBtnStatus(self.btn_find, not isInTeam)
	setBtnStatus(self.btn_invite, isInTeam and not isTeamFull)
	self.chapter_panel:setVisible(false)

	if isInTeam and myTeamList then
		self.cells = {}
		local rW, rH = 190, 104
		local sX, sY = 6, 57
		if isTeamFull then
			rH = 152
			sY = 8
		end
		self.list_view = ClsScrollView.new(rW, rH, true, function()
			local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/main_team_member.json")
			return cell_ui
		end)
		for i,v in ipairs(myTeamList.info) do
			if tonumber(v.name_status) > 0 then
				v.isRed = true
			end
			if myTeamList.leader == v.uid then
				v.is_leader = true
			end
			v.order = i
			self.cells[i] = ClsTeamPortItem.new(CCSize(190, 52), v)
		end
		self.list_view:addCells(self.cells)
		self.list_view:setPosition(ccp(sX, sY))
		self.list_view.onTouchMoved = function()
		end
		self.task_bg:addChild(self.list_view)
	end
	self:setTouch(self.enable)
	self:updateChatBubble()
end

function ClsTeamMissionPortUI:getListView()
	return self.list_view
end

function ClsTeamMissionPortUI:updateChatBubble()
	local teamData = getGameData():getTeamData()
	for k, v in pairs(self.chat_bubbles) do
		if self.is_panel_hide then
			v:removeFromParentAndCleanup(true)
		else
			if not tolua.isnull(v) then
				if teamData:getTeamUserInfoByUid(v.sender) then
					local myTeamList = teamData:getMyTeamInfo()
					for i, info in ipairs(myTeamList.info) do
						if info.uid == v.sender then
							local cell_height = self.cells[i]:getHeight()
							local pos_y = cell_height * 3 - cell_height * i
							v:setPosition(ccp(-156, pos_y))
							self.chat_bubbles[i] = v
							self.chat_bubbles[k] = nil
						end
					end
				else
					v:removeFromParentAndCleanup(true)
					self.chat_bubbles[k] = nil
				end
			end
		end
	end

	if self.is_panel_hide then
		self.chat_bubbles = {}
	end
end

function ClsTeamMissionPortUI:showChatBubble(chat_parameter)
	if self.is_panel_hide then return end
	if self.s_type == SELECT_MISSION then return end
	if tolua.isnull(self.list_view) then return end

	local pos = ccp(0, 0)
	local show_chat_cell = nil
	local teamData = getGameData():getTeamData()
	local myTeamList = teamData:getMyTeamInfo()
	local index = nil
	for i,v in ipairs(myTeamList.info) do
		if v.uid == chat_parameter.sender then
			index = i
			local cell_height = self.cells[i]:getHeight()
			local pos_y = cell_height * 3 - cell_height * i
			pos = ccp(-156, pos_y)
			break
		end
	end

	if not tolua.isnull(self.chat_bubbles[index]) then
		self.chat_bubbles[index]:removeFromParentAndCleanup(true)
	end
	local chat_bubble = require("gameobj/team/clsTeamChatBubble").new(chat_parameter)
	self:addChild(chat_bubble)
	chat_bubble:setPosition(pos)
	self.chat_bubbles[index] = chat_bubble
end

function ClsTeamMissionPortUI:gotoMissionPanel()
	if not tolua.isnull(getExploreUI()) then 
		Alert:warning({msg = ui_word.GO_BACK_PORT})
		return 
	end
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	getUIManager():create("gameobj/mission/clsMissionMainUI")
end

function ClsTeamMissionPortUI:gotoTeamPanel()
	if not tolua.isnull(getExploreUI()) then
		Alert:warning({msg = ui_word.GO_BACK_PORT})
		return
	end
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	getUIManager():create("gameobj/team/clsPortTeamUI", nil, 1, true)
end

local event_by_index = {
	{["first_tap"] = ClsTeamMissionPortUI.updateMissionViewInfo, ["second_tap"] = ClsTeamMissionPortUI.gotoMissionPanel},
	{["first_tap"] = ClsTeamMissionPortUI.updateTeamViewInfo, ["second_tap"] = ClsTeamMissionPortUI.gotoTeamPanel},
}

--添加可滑动任务详情按钮
function ClsTeamMissionPortUI:addDetailBtn()
	local BTN_CELL_HEIGHT = 36
	local btn_info = {
		is_detail_btn = true,
		res = "#common_9_grey3.png",
		anchor_point = ccp(0,0),
		pos = ccp(38,4),
		cell_pos = ccp(44,16),
		text_size = 14,
		btn_text = ui_word.STR_MISSION_LABEL,
		width = 88,
		height = 32,
		call_back = ClsTeamMissionPortUI.gotoMissionPanel,
	}
	local cell = ClsMissionPortItem.new(CCSize(self.cell_width, BTN_CELL_HEIGHT), btn_info)
	self.cells[#self.cells + 1] = cell
end

function ClsTeamMissionPortUI:selectTab(bid)
	local playerData = getGameData():getPlayerData()
	playerData:setChooseTag(bid)
	if self.s_type == bid then
		if bid == SELECT_MISSION then
			local team_data = getGameData():getTeamData()
			if (team_data:isInTeam() and not team_data:isTeamLeader()) then
				local ERROR_INDEX = 591
				local text = require("game_config/error_info")[ERROR_INDEX].message
				Alert:warning({msg = text, size = 26})
				self.btn_task:setFocused(true)
				return
			end
		end
		event_by_index[bid].second_tap(self)
		self:selectEffect(bid)
	else
		-- 副本类型
		local SCENE_TYPE_MAP = {
			GUILD_BATTLE = 1, --公会据点战
			SPORTS = 2, --竞速副本
			TREASURE = 3, --寻宝副本
			MANUAL = 4, --新手引导副本
			MELEE = 5, --大乱斗系统
		}
		local SCENE_TPYE = {
			PORT = "port",
			EXPLORE = "explore", --普通探索
			COPY = "copy",
		}
		local scenedata_handler = getGameData():getSceneDataHandler()
		local is_Guild_battle = false
		if scenedata_handler:getSceneType() == SCENE_TPYE.COPY and scenedata_handler:getMapId() == SCENE_TYPE_MAP.GUILD_BATTLE then
			is_Guild_battle = true
		end
		if is_Guild_battle and bid == SELECT_MISSION and self.is_click_task_or_team_btn == true then
				self.is_click_task_or_team_btn = false
				Alert:warning({msg = require("game_config/news").GUILD_BATTLE_TASK_BTN_TIPS.msg, size = 26})
				return
			end
		self.s_type = bid
		event_by_index[bid].first_tap(self)
		self:selectEffect(bid)
	end
end

function ClsTeamMissionPortUI:defaultSelect()
	if not self.isNeedTaskBtn then
		self:selectTab(SELECT_TEAM)
		return
	end

	local playerData = getGameData():getPlayerData()
	local onOffData = getGameData():getOnOffData()
	local choose_tag = playerData:getChooseTag()
	if not onOffData:isOpen(on_off_info.ORGANIZETEAM.value) then
		choose_tag = SELECT_MISSION
		playerData:setChooseTag(choose_tag)
	end
	if choose_tag then
		self:selectTab(choose_tag)
	end
end

function ClsTeamMissionPortUI:selectEffect(bid)
	for k, btn in ipairs(self.btn_tab) do
		btn:setFocused(false)
		self["icon_selected_"..k]:setVisible(false)
	end
	self.btn_tab[bid]:setFocused(true)
	self["icon_selected_"..bid]:setVisible(true)
end

function ClsTeamMissionPortUI:showTeamPanel()
	if self.is_panel_hide then
		self:showOrHidePanel()
	end
	if self.s_type ~= SELECT_TEAM then
		self:selectTab(SELECT_TEAM)
	end

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
   	ClsSceneManage:doLogic("hideTeamBtn")
end

function ClsTeamMissionPortUI:checkIsHide()
	local teamData = getGameData():getTeamData()
	if self.isNeedTaskBtn and isExplore and not teamData:isInTeam() then
		-- self.is_panel_hide = true
	end
end

function ClsTeamMissionPortUI:hideTeamBtn()
	setBtnStatus(self.btn_creat, false)
	setBtnStatus(self.btn_invite, false)
	setBtnStatus(self.btn_find, false)
end

function ClsTeamMissionPortUI:setTouch(enable)
	self.enable = enable
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enable)
	end
	for _, btn in ipairs(self.btn_tab) do
		btn:setTouchEnabled(enable)
	end
	for mid, _ in pairs(self.guide_tbl) do
		ClsGuideMgr:hideOrShowGuide(mid, enable)
	end
end

function ClsTeamMissionPortUI:getSelectType()
	return self.s_type
end

function ClsTeamMissionPortUI:onExit()
	self.guide_tbl = {}
	UnLoadPlist(self.plist)
	UnRegTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
end

return ClsTeamMissionPortUI
