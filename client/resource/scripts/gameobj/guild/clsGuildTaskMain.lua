local ui_word = require("game_config/ui_word")
local GuildMission = require("game_config/guild/guild_mission")
local ClsUiTools = require("gameobj/uiTools")
local ClsDataTools = require("module/dataHandle/dataTools")
local guild_task_team_info = require("game_config/guild/guild_task_team_info")
local on_off_info = require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local composite_effect = require("gameobj/composite_effect")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")


local TASK_BEGIN = 1 --前往任务
local TASK_DOING = 2 --查看
local TASK_COMPLETE = 3 --可领奖
local TASK_CREATE = 5 --任务创建，但没有开始

local FLAG_JOIN = 1

-- 商会任务cell
local ClsGuildTaskCell = class("ClsGuildTaskCell", ClsScrollViewItem)

ClsGuildTaskCell.initUI = function(self, data)
  self:updateCellView(data)  
end

ClsGuildTaskCell.updateCellView = function(self, data)

	self.data = data
	self.config = guild_task_team_info[self.data.missionId]

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_bar.json")

	self:addChild(panel)
	self.panel = panel

	--获取对应的控件
	local task_bg_spr = getConvertChildByName(panel, "task_bg")
	self.task_bg_spr = task_bg_spr
	self.time_bar = getConvertChildByName(task_bg_spr, "bar_content")
	self.time_lab = getConvertChildByName(task_bg_spr, "time_percent")
	self.task_name_lab = getConvertChildByName(task_bg_spr, "task_name")
	self.task_lv_lab = getConvertChildByName(task_bg_spr, "task_lvl")
	self.task_desc_lab = getConvertChildByName(task_bg_spr, "task_description")
	self.status_ui = {}
	self.status_ui.un_start_lab = getConvertChildByName(task_bg_spr, "pre_start")
	self.status_ui.start_lab = getConvertChildByName(task_bg_spr, "started")
	self.status_ui.finish_lab = getConvertChildByName(task_bg_spr, "finished")
	self.btn = getConvertChildByName(task_bg_spr, "participate_btn")
	self.btn.join_lab = getConvertChildByName(self.btn, "participate_text")
	self.btn.get_lab = getConvertChildByName(self.btn, "get_text")
	self.btn.check_lab = getConvertChildByName(self.btn, "check_text")
	self.open_mission_tips_spr = getConvertChildByName(task_bg_spr, "task_bg_ing")
	self.multi_text = getConvertChildByName(task_bg_spr, "multi_text")
	self.multi_icon = getConvertChildByName(task_bg_spr, "multi_icon")
	self.me_icon = getConvertChildByName(task_bg_spr, "me_icon")

			
	self.btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local guildTaskData = getGameData():getGuildTaskData()
		local ui = getUIManager():get("ClsGuildTaskMain")
		if not tolua.isnull(ui) then
			--ui:setTouch(false)
		end
		if self.data.status == TASK_COMPLETE then
			guildTaskData:askguildMissionReward(self.data.missionKey)
		else
			--公会任务
			getUIManager():create("gameobj/guild/clsGuildTaskMulDetails",{}, self.data.missionKey)

		end
	end, TOUCH_EVENT_ENDED)

	--背景
	self.open_mission_tips_spr:setVisible(false)

	self.multi_icon:setVisible(1 ~= self.data.missionFlag)
	self.me_icon:setVisible(1 == self.data.missionFlag)

	if 1 == self.data.missionFlag then
		self.open_mission_tips_spr:setVisible(true)
		self.multi_text:setText(ui_word.GUILD_TASK_MINE)
		--头像
		local playerData = getGameData():getPlayerData()
		local icon = playerData:getIcon()
		local sailor_info = require("scripts/game_config/sailor/sailor_info")
		local sailor = sailor_info[tonumber(icon)]
		if sailor and sailor.star == SAILOR_STAR_SIX  then
			self.me_icon:setScale(0.25)
		end

		icon = string.format("ui/seaman/seaman_%s.png", icon)
		self.me_icon:changeTexture(icon, UI_TEX_TYPE_LOCAL)
	else
		self.multi_text:setText(ui_word.GUILD_TASK_OTHER)
	end


	--任务名字
	self.task_name_lab:setText(self.config.name)

	--任务等级
	local level = self.config.level
	if level > 0 then
		self.task_lv_lab:setText("Lv." .. self.config.level)
	else
		self.task_lv_lab:setText("")
	end

	--描述
	self.task_desc_lab:setText(self.config.desc)

	--进度
	if self.data.status == TASK_CREATE or self.data.status == TASK_BEGIN then
		self.time_bar:setPercent(0)
	else
		self.time_bar:setPercent(100 * (self.data.totalTime - self.data.remainTime) / self.data.totalTime)
	end

	local str = ClsDataTools:getMostCnTimeStr(self.data.remainTime)
	self.time_lab:setText(str)

	self.status_ui.un_start_lab:setVisible(false)
	self.status_ui.start_lab:setVisible(false)
	self.status_ui.finish_lab:setVisible(false)
	self.btn.join_lab:setVisible(false)
	self.btn.get_lab:setVisible(false)
	self.btn.check_lab:setVisible(false)
	local is_show_btn = true
	if self.data.status == TASK_CREATE then
		--点击参与
		self.status_ui.un_start_lab:setVisible(true)
		self.btn.join_lab:setVisible(true)
	elseif self.data.status == TASK_BEGIN then
		self.status_ui.un_start_lab:setVisible(true)
		self.btn.check_lab:setVisible(true)
	elseif self.data.status == TASK_DOING then
		--进行中
		self.status_ui.start_lab:setVisible(true)
		self.btn.check_lab:setVisible(true)
		is_show_btn = false


	elseif self.data.status == TASK_COMPLETE then
		--已完成
		self.status_ui.finish_lab:setVisible(true)
		self.btn.get_lab:setVisible(true)
	end
	self.btn:setEnabled(is_show_btn)
	if not is_show_btn then
		if not self.m_working_eff then
			self.m_working_eff = display.newSprite()
			self.task_bg_spr:addCCNode(self.m_working_eff)
			self.m_working_eff:setZOrder(2)
			local pos = self.btn:getPosition()
			self.m_working_eff:setPosition(pos.x, pos.y)
			composite_effect.new("tx_0099", 0, 0, self.m_working_eff, nil, function() end)
		end
		self.m_working_eff:setVisible(true)
	else
		if self.m_working_eff then
			self.m_working_eff:setVisible(false)
		end
	end
end

ClsGuildTaskCell.updateCellProgress = function(self)
	if self.data and self.data.status == TASK_DOING then
		-- print("-------------updateCellProgress--------------" .. self.data.mission_id)
		self.data.remainTime = self.data.remainTime - 1
		if  self.data.remainTime <= 0 then
			local str = ClsDataTools:getMostCnTimeStr(self.data.remainTime)
			self.time_lab:setText("100/100")
			self.time_bar:setPercent(100 * (self.data.totalTime - self.data.remainTime) / self.data.totalTime)
			local ui = getUIManager():get("ClsGuildTaskMulDetails")
			if not tolua.isnull(ui) then ui:closeView(self.data.missionKey) end
			local guildTaskData = getGameData():getGuildTaskData()
			guildTaskData:askMissionList()
			return
		end
		local str = ClsDataTools:getMostCnTimeStr(self.data.remainTime)
		self.time_lab:setText(str)
		self.time_bar:setPercent(100 * (self.data.totalTime - self.data.remainTime) / self.data.totalTime)
	end
end

ClsGuildTaskCell.removeSelf = function(self)
	if not tolua.isnull(self.panel) then
		self.panel:removeFromParentAndCleanup(true)
		self.panel = nil
	end
	self.data = nil
end


ClsGuildTaskCell.onTap = function(self)
	if self.tapFunc then
		self:tapFunc()
	end
end

ClsGuildTaskCell.setTapFunc = function(self, func)
	self.tapFunc = func
end


----------------------
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuildTaskMain = class("ClsGuildTaskMain", ClsBaseView)

local current_effect 		= nil

-- static
ClsGuildTaskMain.clearEffectOnce = function(self)
	current_effect = 0
end

-- static
ClsGuildTaskMain.getViewConfig = function(self)
	return {
		is_swallow = false, 
		effect = current_effect or UI_EFFECT.DOWN
	}
end

ClsGuildTaskMain.onCtor = function(self)
	current_effect = nil
end

ClsGuildTaskMain.onEnter = function(self, child_skip, list_pos)
	self.child_skip = child_skip
	self.list_pos = list_pos or ccp(0, 0)

	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:askMissionList()

	self.plist = {
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.cells = {}  --任务列表列表cell
	self:effectEndCallback() 
end


ClsGuildTaskMain.effectEndCallback = function(self)
	if self.child_skip and self.child_skip == "task_detail_multi" then
		local guildTaskData = getGameData():getGuildTaskData()
		local key = guildTaskData:getCurOpenMissonKey()

		getUIManager():create("gameobj/guild/clsGuildTaskMulDetails",{},key)
		self.child_skip = nil
		guildTaskData:clearCurOpenMissionKey()
	end
end

--领奖界面显示
ClsGuildTaskMain.showReward = function(self, data)
	getUIManager():create("gameobj/guild/clsGuildTaskReward",{},data)
end

ClsGuildTaskMain.updateView = function(self)

	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end

	local guildTaskData = getGameData():getGuildTaskData()
	local data = guildTaskData:getGuildTaskList()

	local listCellTab = {}
	for k, v in pairs(data) do

		local curCell = ClsGuildTaskCell.new(CCSize(740, 124), v)

		if v.status == TASK_DOING then
			curCell:setTapFunc(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				--查看公会任务详情
				getUIManager():create("gameobj/guild/clsGuildTaskMulDetails",{},v.missionKey)
			end)
		end

		self.cells[v.missionKey] = curCell
		listCellTab[#listCellTab + 1] = curCell
	end

	self.list_view = ClsScrollView.new(780, 358, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(self.list_pos.x + 110, self.list_pos.y + 26))
	self:addWidget(self.list_view)
	self.list_view:addCells(listCellTab)


	--遍历每个cell，刷新进度
	self:createCDTimer(function()
		for k, v in pairs(self.cells) do
			if not tolua.isnull(v)then
				v:updateCellProgress()
			end
		end
	end)
end

--[[
--创建倒计时定时器
]]
ClsGuildTaskMain.createCDTimer = function(self, callBack)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self:removeTimeHander()
	self.hander_time = scheduler:scheduleScriptFunc(callBack, 1, false)
end

ClsGuildTaskMain.removeTimeHander = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil 
	end
end


ClsGuildTaskMain.onExit = function(self)
	self:removeTimeHander()
	UnLoadPlist(self.plist)
end

return ClsGuildTaskMain
