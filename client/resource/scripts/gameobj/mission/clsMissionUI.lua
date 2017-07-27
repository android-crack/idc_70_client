
--create by zhuling

local ui_word = require("game_config/ui_word")
local missionGuide = require("gameobj/mission/missionGuide")
local MissionEvent = require("gameobj/mission/missionEvent")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsBaseView = require("ui/view/clsBaseView")
local ClsMissionUI = class("ClsMissionUI" , ClsBaseView)

local icon_config = {
	gold = {res = "common_icon_diamond.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_GOLD},
	royal = {res = "common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR}, -- royal
	honour = {res = "common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR}, -- honor
	silver = {res = "common_icon_coin.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_CASH},
	exp = { res = "common_icon_exp.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_EXP},
	power = {res = "common_icon_power.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_POWER},
	promote = {res = "bo_load.png", scale = {0.4,0.5}, type = "string"},
	starcrest = { res = "common_item_medal.png", scale = {0.4,0.5}, type = "number"},
	trearuse = {res = "common_item_trearusemap.png", scale = {0.4,0.5}, type = "number"}, 
	baowu = {res = nil, scale = {0.4,0.5}, type = "string"},
	item = {res = nil, scale = {0.4,0.5}, type = "string"},
	shipyard_map = {res = "common_item_letter.png", scale = {0.4,0.5}, type = "number"},
	rum = {res = "common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR},
	boat = {res = "common_icon_elite.png", account = 1},
}

-- 接受任务所需控件
local widget1 = {
	"title",
	"figure_left",
	"figure_right",
	"bg",
	"get_task",
	"get_award",
	"get_award_icon",
	"get_award_num",
	"btn_get",
	"btn_get_text",
	"go_port",
	"award_text",
}

-- 完成任务面板所需控件
local widget2 = {
	"title",
	"figure_left",
	"figure_right",
	"bg",
	"task_done",
	"done_award",
	"done_award_icon",
	"done_award_num",
	"done_stamp",
}

-- 完成悬赏任务面板所需控件
local widget3 = {
	"title",
	"figure_left",
	"figure_right",
	"bg",
	"wanted_done",
	"wanted_stamp",
	"text_guild",
	"text_go",
}

local param = {
	json_res = "main_task.json",
	plists = {
		["ui/material_icon.plist"] = 1, 
		["ui/mission.plist"] = 1,
	}
}

function ClsMissionUI:getViewConfig()
    return {
        name = "ClsMissionUI",
    }
end

function ClsMissionUI:loadJson()
    if not self.json_res then return end
    local path = string.format("json/%s", self.json_res)
    self.panel = GUIReader:shareReader():widgetFromJsonFile(path)
    convertUIType(self.panel)
    self:addWidget(self.panel)
end

-- @param task_status: 任务状态   详见：全局搜索  TASK_STATUS 
function ClsMissionUI:onEnter(mission_tab , task_status)
	if param then
        self.json_res = param.json_res
        self.plists = param.plists
        if self.plists then
            LoadPlist(self.plists)
        end
    end
    self:loadJson()

	-- 根据name储存widget
	self.widget = {}
	-- 任务数据表
	self.mission_tab = mission_tab
	-- 调度器句柄
	self.schedule_handle = nil
	-- 任务状态
	self.task_status = task_status

	self.bg = getConvertChildByName(self.panel, "bg")

	if task_status == TASK_STATUS.get then
		self:initGetTask()
	elseif task_status == TASK_STATUS.complete then
		self:initComplete()
	elseif task_status == TASK_STATUS.complete_reward then
		self:initCompleteReward()
	end
end

function ClsMissionUI:setTitle(str)
	local widget = self.widget
	widget.title:setText(str)
	decorateAdapter(widget.title , widget.figure_left , widget.figure_right)
end

-- 初始化接受任务面板
function ClsMissionUI:initGetTask()
	local widget = self.widget
	local task_data = self.mission_tab
	self:setWidget(widget1)
	widget.get_task:setVisible(true)

	self:setTitle(task_data.name)

	widget.btn_get_text:setText(ui_word.TASK_ACCEPT)

	local desc = self:createDescribe(task_data.desc)
	-- 初始化任务描述
	widget.go_port:setText(desc)
	
	widget.btn_get:setTouchEnabled(false)
	self:initRewardList(widget.get_task , widget.get_award , task_data.reward_list)

	audioExt.pauseMusic()
	audioExt.playEffect(music_info.MISSION_ACCEPT.res, false)

	self:regTouchEvent(self, function()
		self:close()
	end)
end

function ClsMissionUI:endGetTask()
	local item = self.mission_tab
	if item.event then 
		self:taskEvent(item.event) 
	end
	local onOffData = getGameData():getOnOffData()	
	self:openMissionGuide(item)
	onOffData:openNewButton()
end

-- 初始化完成任务面板
function ClsMissionUI:initComplete()
	local widget = self.widget
	local task_data = self.mission_tab
	
	self:setWidget(widget2)
	self:setTitle(task_data.name)

	audioExt.pauseMusic()
	audioExt.playEffect(music_info.MISSION_COMPLETE.res, false)

	widget.task_done:setVisible(true)

	self:initRewardList(widget.task_done , widget.done_award , task_data.reward_list)

	self.schedule_handle = scheduler:scheduleScriptFunc(function()
		if self.schedule_handle then
			scheduler:unscheduleScriptEntry(self.schedule_handle)
			self.schedule_handle = nil
		end
		self:close()
	end, 3, false)

	self:regTouchEvent(self, function()
		self:close()
	end)
end

function ClsMissionUI:endComplete()
	local mission_tab = self.mission_tab
	missionGuide:openLastMissionGuide(mission_tab)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:askGetMissionReward(mission_tab.id)
	self:playCompleteEffects()
end

-- 初始化完成悬赏任务面板
function ClsMissionUI:initCompleteReward()
	local widget = self.widget
	local task_data = self.mission_tab

	self:setWidget(widget3)
	widget.wanted_done:setVisible(true)

	self:setTitle(task_data.name)

	widget.text_guild:setText(ui_word.DAILY_FIND_TREASUREMAP_TIPS_COMPELETE)

	widget.text_go:setText(ui_word.DAILY_REWARD_GET_TIPS)

	self:registerTouchEvent(function()
		self:close()
	end)

	audioExt.pauseMusic()
	audioExt.playEffect(music_info.MISSION_COMPLETE.res, false)

	self.schedule_handle = scheduler:scheduleScriptFunc(function()
		if self.schedule_handle then
			scheduler:unscheduleScriptEntry(self.schedule_handle)
			self.schedule_handle = nil
		end
		self:close()
	end, 3, false)
end

function ClsMissionUI:endCompleteReward()
	local portLayer = getUIManager():get("ClsPortLayer")
	if tolua.isnull(portLayer) then
		getGameData():getExploreData():exploreOver()
		self:close()
		return
	end
	if not tolua.isnull(portLayer) and not tolua.isnull(portLayer.portItem) then 
		portLayer.portItem:removeFromParentAndCleanup(true)
		portLayer.portItem = nil
	end
	local skipToLayer = require("gameobj/mission/missionSkipLayer")
	skipToLayer:skipLayerByName("guild_task", nil)
end

function ClsMissionUI:registerTouchEvent(callback)
	self.panel:setTouchEnabled(true)
	self.panel:addEventListener(function()
        if callback then
    		callback()
		end

	end, TOUCH_EVENT_ENDED)
end

function ClsMissionUI:taskEvent(item)
	local event = item.event 
	local params = item.params
	if MissionEvent[event] then
		MissionEvent[event](params)
	end 
end

function ClsMissionUI:openMissionGuide(mission_tab)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setPortSelectMisId(mission_tab.id)
	missionGuide:openGuideByMission(mission_tab)
end

function ClsMissionUI:initRewardList(parent , temp , list)
	local widget = self.widget
	-- 用于储存奖励panel
	local panels = {}
	local count = 1
	for name, num in pairs(list) do
		local panel
		local image
		local label
		if count > 1 then
			panel = createPanelByJson("json/main_task_award.json")
			image = getConvertChildByName(panel , "award_icon")
			label = getConvertChildByName(panel , "award_num")
			parent:addChild(panel)
		else
			panel = temp
			if self.task_status == TASK_STATUS.get then
				image = getConvertChildByName(panel , "get_award_icon")
				label = getConvertChildByName(panel , "get_award_num")
			elseif self.task_status == TASK_STATUS.complete then
				image = getConvertChildByName(panel , "done_award_icon")
				label = getConvertChildByName(panel , "done_award_num")
			end
		end
		panel.icon = image
		panel.label = label
		image:changeTexture(icon_config[name].res , UI_TEX_TYPE_PLIST)
		label:setText(icon_config[name].account or num)
		table.insert(panels , panel)
		count = count + 1
	end
	self:updatePos(panels)
end

function ClsMissionUI:updatePos(panels)
	local real_widths = {}
	local height = nil
	for k, v in ipairs(panels) do
		local item_size = v:getSize()
		if height == nil then
			height = item_size.height
		end
		local cur_width = item_size.width
	    local label_cur_width = v.label:getSize().width
	    local label_pos_x = v.label:getPosition().x
	    local real_width = label_pos_x + label_cur_width
	    table.insert(real_widths, real_width)
	end

	local total_width = 0
	for k, v in ipairs(real_widths) do
		total_width = total_width + v
	end

	local offset = 20
	total_width = total_width + offset

	local bg_size = self.bg:getSize()
	local right_offset = (bg_size.width - total_width) / 2
	local y = (bg_size.height - height) / 2 - 30
	local x = right_offset
	for k, v in ipairs(panels) do
		v:setPosition(ccp(x, y))
		x = x + v:getSize().width + offset
	end
end

function ClsMissionUI:playCompleteEffects()
	local reward_list = self.mission_tab.reward_list
	if reward_list.gold then
		audioExt.playEffect(music_info.COMMON_GOLD.res, false)
	end
	if reward_list.silver then
		audioExt.playEffect(music_info.COMMON_CASH.res, false)
	end
	if reward_list.seaman or reward_list.boat or reward_list.equip then
		audioExt.playEffect(music_info.TOWN_CARD.res, false)
	end
	if reward_list.exp or reward_list.honor or reward_list.honor then
		audioExt.playEffect(music_info.COMMON_HONOUR.res, false)
	end
end

function ClsMissionUI:onExit()
	audioExt.resumeMusic()
	if self.schedule_handle then
		scheduler:unscheduleScriptEntry(self.schedule_handle)
		self.schedule_handle = nil
	end
	
	if self.plists then
        UnLoadPlist(self.plists)
    end
end

function ClsMissionUI:onFinish()
	local callback = self.mission_tab.call_back
	if callback and type (callback) == "function" then
		callback()
	end

	if self.task_status == TASK_STATUS.get then
		self:endGetTask()
	elseif self.task_status == TASK_STATUS.complete then
		self:endComplete()
	elseif self.task_status == TASK_STATUS.complete_reward then
		self:endCompleteReward()
	end
end

function ClsMissionUI:createDescribe(describes)
	local desc = ""
	for k, v in ipairs(describes) do
		local str = v
		local index = string.find(v, "#", 0)
		if index then
			str = string.sub(v, index + 1)
		else
			index = string.find(v, "@", 0)
			if index then
				str = string.sub(v, index + 1)
			end
		end
		desc = desc .. str
	end
	return desc
end

--获取需要的控件
function ClsMissionUI:setWidget(widget_map)
	local widget = self.widget
	for _ , widget_name in pairs(widget_map) do
		widget[widget_name] = getConvertChildByName(self.panel , widget_name)
	end
end

return ClsMissionUI

