-- 活动主界面
-- Author: Ltian
-- Date: 2016-06-29 16:27:00
--
local on_off_info=require("game_config/on_off_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local music_info=require("game_config/music_info")
local ClsArenaMainUI = require("gameobj/arena/clsArenaMainUI")
local ui_word = require("game_config/ui_word")
local ClsDailyTargetTab = require("gameobj/activity/clsDailyTargetTab")
local clsDoingActivityTab = require("gameobj/activity/clsDoingActivityTab")
local clsWillOpenActivityTab = require("gameobj/activity/clsWillOpenTab")
local clsWeekActivityTab = require("gameobj/activity/clsWeekActivityTab")
local ClsSailorAwake = require("gameobj/activity/clsSailorAwake")
local Alert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsActivityMain = class("ClsActivityMain", ClsBaseView)

function ClsActivityMain:getViewConfig()
    return { hide_before_view = true,
    	effect = UI_EFFECT.FADE, 

    }
end

local widget_name = {
	{res = "tab_open",on_off_key = on_off_info.ACTIVITY_EVERYDAY.value, task_keys = {
		on_off_info.ACTIVITY_EVERYDAY.value,
	}, label = "tab_task_text", btn_lbl = "text_open"},
	{res = "tab_closed",on_off_key = on_off_info.ACTIVE_TIMEACTIVE.value, task_keys = {
		on_off_info.ACTIVE_TIMEACTIVE.value,
	}, label = "tab_legend_text", btn_lbl = "text_closed"},
	{res = "tab_target", on_off_key = on_off_info.ACTIVITY_DAILY.value, task_keys = {
		on_off_info.ACTIVITY_DAILY.value,
	}, label = "tab_vip_text", btn_lbl = "text_target", open_key = on_off_info.ACTIVITY_DAILY.value},
	{res = "tab_week", label = "tab_race_text", btn_lbl = "text_week"},
	{res = "tab_sailor", on_off_key = on_off_info.LEGEND_SAILOR_ACTIVITY.value, task_keys = {
		on_off_info.LEGEND_SAILOR_ACTIVITY.value, --新一轮的传奇航海士更新时标红点
	},label = "tab_sailor_text", btn_lbl = "text_sailor", open_key = on_off_info.LEGEND_SAILOR_ACTIVITY.value},
}



function ClsActivityMain:regChild(name,child)
	if not self.child_list then
		self.child_list = {}
	end
	self.child_list[name] = child
end

function ClsActivityMain:getRegChild(name)
	if self.child_list then
		return self.child_list[name]
	end
end

function ClsActivityMain:unRegChild(name)
	if self.child_list then
		self.child_list[name] = nil
	end
end

function ClsActivityMain:onEnter(tab_id, call_back)
	self.default_tab = tab_id or 1
	self:requestData()
	self.plist = {
		["ui/activity_ui.plist"] = 1,
		["ui/box.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/shipyard_ui.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.show_view = nil
	-- self:regFunc()
	self:initView()
	self:configEvent()
	self:defaultSelect()
	self.call_back = call_back

	-- self:setTimeLimitRedPoint()
end

function ClsActivityMain:requestData()
	local course_data  = getGameData():getDailyCourseData()
	-- 页签3
	course_data:requestDailyLiveness() -- 请求每日活跃度数据
	course_data:requestDailyTarget() -- 请求每日目标数据
	-- 页签4 ?
	course_data:requestDailyActivityType() -- 请求活动类型
	local activity_data = getGameData():getActivityData()
	if self.default_tab ~= 1 then
		activity_data:requestActivityInfo() --请求活动数据列表
	end
end

function ClsActivityMain:destroy()
	self:close()
end

function ClsActivityMain:preClose()
	self:cleanCurrentView()
end

function ClsActivityMain:closeView()
	audioExt.playEffect(music_info.COMMON_CLOSE.res)
	self:effectClose()
	
	-- self:setTouch(false)
end

function ClsActivityMain:initView()
	self.ui_layer = UIWidget:create()
	self:addWidget(self.ui_layer)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity.json")
	self.sailor_activity_panel = getConvertChildByName(self.panel, "sailor_activity_panel")
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	local task_data = getGameData():getTaskData()
	for i,v in ipairs(widget_name) do
		local btn_res = v.res
		self[btn_res] = getConvertChildByName(self.panel, btn_res)
		if v.btn_lbl then
			self[btn_res].btn_lbl = getConvertChildByName(self.panel, v.btn_lbl)
		end
		if v.task_keys and v.on_off_key then
			task_data:regTask(self[btn_res], v.task_keys, KIND_RECTANGLE, v.on_off_key, 60, 30, true)
		end
	end

	self.btn_tab = {
		self.tab_open,
		self.tab_closed,
		self.tab_target,
		self.tab_week,
		self.tab_sailor,
	}

	for _,btn in ipairs(self.btn_tab) do
		btn:setTouchEnabled(false)
	end
	
	self.girl_panel = getConvertChildByName(self.panel, "girl_panel")
	self.close_btn = getConvertChildByName(self.panel, "close_btn")
	self.close_btn:setPressedActionEnabled(true)
	self.close_btn:addEventListener(function()
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	local onOffData = getGameData():getOnOffData()
	-- self.lock_btns = onOffData:pushOpenBtn(on_off_info.ACTIVITY_DAILY.value, {openBtn = self.tab_target, openEnable = true,
	-- 	addLock = true, btnRes = "#common_btn_tab3.png", parent = "ClsActivityMain"})

	-- self.tab_sailor_btn = onOffData:pushOpenBtn(on_off_info.LEGEND_SAILOR_ACTIVITY.value, {openBtn = self.tab_sailor, openEnable = true,
	-- 	addLock = true, btnRes = "#common_btn_tab3.png", parent = "ClsActivityMain"})

	local voice_info = getLangVoiceInfo()
	self:updateBtnPos()
	audioExt.playEffect(voice_info.VOICE_SWITCH_1005.res)
end

function ClsActivityMain:updateBtnPos()
	local onOffData = getGameData():getOnOffData()
	local start_y = 265
	local offset_y = 80
	local index = 1
	for i,v in ipairs(widget_name) do
		--print(v.open_key)
		if not v.open_key or (v.open_key and onOffData:isOpen(v.open_key)) then
			local pos = self[v.res]:getPosition()
			self[v.res]:setPosition(ccp(pos.x, start_y - offset_y * index))
			index = index + 1
		else
			self[v.res]:setVisible(false)
			self[v.res]:setTouchEnabled(false)
		end
	end
	-- body
end
function ClsActivityMain:getChildPanel(v)
	return getConvertChildByName(self.panel, v)
end

function ClsActivityMain:configEvent()
	for btn_type, btn in ipairs(self.btn_tab) do
		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:selectTab(btn_type)
		end, TOUCH_EVENT_ENDED)

		btn:addEventListener(function()
			self:selectEffect(btn_type)
		end, TOUCH_EVENT_BEGAN)

		btn:addEventListener(function()
			self:selectEffect(self.s_type)
		end, TOUCH_EVENT_CANCELED)
	end
end

function ClsActivityMain:selectEffect(btn_id)
	local color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
	for _, index in pairs(widget_name) do
		self[index.res]:setFocused(false)
		self[index.res]:setTouchEnabled(true)
		setUILabelColor(self[index.res].btn_lbl, color)
	end
	self[widget_name[btn_id].res]:setFocused(true)
	self[widget_name[btn_id].res]:setTouchEnabled(false)

	color = ccc3(dexToColor3B(COLOR_BTN_SELECTED))
	setUILabelColor(self[widget_name[btn_id].res].btn_lbl, color)
end

function ClsActivityMain:mkUI()
	-- body
end

function ClsActivityMain:setTimeLimitRedPoint(enable)
	local task_data = getGameData():getTaskData()
	task_data:setTask(on_off_info.ACTIVE_TIMEACTIVE.value, enable)
end

function ClsActivityMain:defaultSelect()
	self:selectTab(self.default_tab)
end

function ClsActivityMain:selectTab(tab)
	self.s_type = tab
	self:selectEffect(tab) 
	self:cleanCurrentView()
	self.girl_panel:setVisible(false)
	if tab == 1 then
		self.show_view = clsDoingActivityTab.new()
	elseif tab == 2 then
		self.show_view = clsWillOpenActivityTab.new()
	elseif tab == 3 then
		self.show_view = ClsDailyTargetTab.new()
	elseif tab == 4 then
		self.girl_panel:setVisible(true)
		self.show_view = clsWeekActivityTab.new()
	elseif tab == 5 then
		self.show_view = ClsSailorAwake.new()
	end
	if self.show_view then
		self.sailor_activity_panel:addChild(self.show_view)
	end

	ClsGuideMgr:tryGuide("ClsActivityMain")
end

function ClsActivityMain:getTouchPriority()
	return self.ui_layer:getTouchPriority()
end

function ClsActivityMain:deliverTouchPriority(priority)
	if not tolua.isnull(self.tab_target) then
		if self.tab_target.tips then
			for k, v in ipairs(self.tab_target.tips) do
				v:setMenuPriority(priority - 1)
			end
		end
	end
end


function ClsActivityMain:cleanCurrentView()
	if self.show_view and not tolua.isnull(self.show_view) then
		self.show_view:preClose()
		self.show_view:removeFromParentAndCleanup(true)
		self.show_view = nil
	end
end

function ClsActivityMain:onExit()
	-- body
end

function ClsActivityMain:onFinish()
	-- self:cleanCurrentView()
	UnLoadPlist(self.plist)
	if type(self.call_back) == "function" then
		self.call_back()
	end
end

function ClsActivityMain:canEnterArena()
	getUIManager():create("gameobj/arena/clsArenaMainUI")
end

function ClsActivityMain:notCanEnterArena(msg)
	Alert:warning({msg = msg})
end

function ClsActivityMain:setTouch(enable)

end


return ClsActivityMain
