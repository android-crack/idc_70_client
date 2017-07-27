--
-- Author: lzg0496
-- Date: 2016-03-07 19:52:54
-- Function: 海上新星活动
--

local sea_star_info = require("game_config/seaStar/new_star_data")
local sea_star_reward = require("game_config/seaStar/new_star_reward")
local dataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local item_info = require("game_config/propItem/item_info")
local alert = require("ui/tools/alert")
local composite_effect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local DAYS = {
	DAY_1 = 1,
	DAY_2 = 2,
	DAY_3 = 3,
	DAY_4 = 4,
	DAY_5 = 5,
}

local SEA_DAYS = {
	ui_word.SEA_DAY_1,
	ui_word.SEA_DAY_2,
	ui_word.SEA_DAY_3,
	ui_word.SEA_DAY_4,
	ui_word.SEA_DAY_5,
}

local DOWN_HEIGHT = {
	[1] = 75,
	[2] = 125,
	[3] = 178,
	[4] = 235,
	[5] = 292,
}

local MAX_DAY = 5

local REWARD_MAX_NUM = 4
local TASK_MAX_ITEM = 5

local KEEPSAKES = {
	[81] = "E",
	[82] = "D",
	[83] = "C",
	[84] = "B",
	[85] = "A",
	[86] = "S",
}

local DAY_TASK_KEYS = {
	on_off_info.SEA_STAR_FIRST.value,
	on_off_info.SEA_STAR_SECOND.value,
	on_off_info.SEA_STAR_THIRD.value,
	on_off_info.SEA_STAR_FORTH.value,
	on_off_info.SEA_STAR_FIFTH.value,
}

local TASK_STATUS_RECEIVE = 1
local TASK_STATUS_UNRECEIVE = 0
local STAR_STATUS_OPEN = 1
local STAR_STATUS_CLOSE = 0


local ClsSeaStarUI = class("ClsSeaStarUI", ClsBaseView)

function ClsSeaStarUI:getViewConfig()
	return {is_swallow = false}
end

function ClsSeaStarUI:onEnter()
	local wefare_main_ui = getUIManager():get("ClsWefareMain")
	if not tolua.isnull(wefare_main_ui) then
		wefare_main_ui:showHelpBTN(true)
	end

	getGameData():getSeaStarData():askSeaStarList()
	self.plist = {
		["ui/box.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.armatureTab = {}

	local seaStarData = getGameData():getSeaStarData()
	self.cur_day_index = seaStarData:getUnlockDay()
	if self.cur_day_index > MAX_DAY then
		self.cur_day_index = MAX_DAY
	end
	self:makeUI()
	self:initUI()
	self:configEvent()
end

function ClsSeaStarUI:makeUI()
	self.new_star = GUIReader:shareReader():widgetFromJsonFile("json/new_star.json")
	self:addWidget(self.new_star)

	local needWidgetName = {
		["lbl_tip_ended"] = {name = "award_text_end"},
		["lbl_tip_do"] = {name = "award_text_do"},
		["lbl_tip_do_time"] = {name = "award_num"},
		["btn_day"] = {name = "btn_day", lbl_txt = "day_text"},
		["bar_task"] = {name = "task_bar"},
		["lbl_task_num"] = {name = "my_box_num"},
 	}

 	local task_data = getGameData():getTaskData()

 	for k, v in pairs(needWidgetName) do
 		self[k] = getConvertChildByName(self.new_star, v.name)
 		if v.lbl_txt then
 			self[k].lbl_txt = getConvertChildByName(self.new_star, v.lbl_txt)
 		end
 	end

 	for i = 1, REWARD_MAX_NUM do
 		self["btn_reward_box_" .. i] = getConvertChildByName(self.new_star, "box_" .. i)
 		self["lbl_reward_box_num_" .. i] = getConvertChildByName(self.new_star, "box_num_" .. i)
 		self["lbl_raward_amount_" .. i] = getConvertChildByName(self.new_star, "award_amount_" .. i)
 		self["spr_raward_icon_" .. i] = getConvertChildByName(self.new_star, "award_icon_" .. i)
 		self["spr_reward_light_" .. i] = getConvertChildByName(self.new_star, "award_light_" .. i)
 		self["spr_get_pic_" .. i] = getConvertChildByName(self.new_star, "get_pic_" .. i)
 	end

 	for i = 1, TASK_MAX_ITEM do
 		self["pal_list_" .. i] = getConvertChildByName(self.new_star, "list_" .. i)

 		local needWidgetName = {
	   		["lbl_name_" .. i] = "name_" .. i,
	   		["lbl_content_" .. i] = "tips_" .. i,
	   		["lbl_full_content_" .. i] = "tips_add_" .. i,
	   		["spr_pass_" .. i] = "pass_icon_" .. i,
	   		["spr_expired_" .. i] = "expired_icon_" .. i,
	   		["bar_progress_" .. i] = "bar_" .. i,
	   		["spr_progress_bg_" .. i] = "bar_bg_" .. i,
	   		["lbl_progress_cur_num_" .. i] = "bar_num_" .. i,
	   		["spr_reward_icon_" .. i] = "coin_icon_" .. i,
	   		["lbl_reward_num_" .. i] = "award_num_" .. i,
	   		["btn_reward_" .. i] = "btn_get_" .. i,
	   		["lbl_award_text_" .. i] = "award_text_" .. i,
	   	}

	   	for k, v in pairs(needWidgetName) do
	   		self[k] = getConvertChildByName(self["pal_list_" .. i], v)
	   	end
 	end

 
end

function ClsSeaStarUI:initUI()
	local seaStarData = getGameData():getSeaStarData()
	local seaStarInfo = seaStarData:getInfoData()
	local today = seaStarInfo.today

	if not tolua.isnull(self.days_view) then
		self.days_view:removeFromParentAndCleanup(true)
	end


	self:selectDay(self.cur_day_index)
	self.lbl_tip_do_time:stopAllActions()
	if seaStarInfo.remainTime == 0 then
		self.lbl_tip_ended:setVisible(true)
		self.lbl_tip_do:setVisible(false)
		self.lbl_tip_do_time:setVisible(false)
	else
		self.lbl_tip_do:setVisible(true)
		self.lbl_tip_do_time:setVisible(true)
		local arr_action = CCArray:create()
		arr_action:addObject(CCCallFunc:create(function()
			if seaStarInfo.remainTime == 0 then
				self.lbl_tip_ended:setVisible(true)
				self.lbl_tip_do:setVisible(false)
				self.lbl_tip_do_time:setVisible(false)
				self.lbl_tip_do_time:stopAllActions()
			end
			seaStarInfo.remainTime = seaStarInfo.remainTime - 1
			local str_time = dataTools:getCnTimeStr(seaStarInfo.remainTime)
			self.lbl_tip_do_time:setText(str_time)
		end))

		arr_action:addObject(CCDelayTime:create(1))
		self.lbl_tip_do_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
	end

	local finish_point, sum_point = seaStarData:getFinishStarPointNum()
	self.bar_task:setPercent(finish_point / sum_point * 100)
	self.lbl_task_num:setText(finish_point .. "/" .. sum_point)

	local reward_indexs = seaStarInfo.rewardIndex
	local find = false

	for i = 1, REWARD_MAX_NUM do
		for k, index in pairs(reward_indexs) do
			if i == index then
				find = true
				self["btn_reward_box_" .. i]:setTouchEnabled(false)
				self["spr_get_pic_" .. i]:setVisible(true)
				self["spr_reward_light_" .. i]:setVisible(false)
				break
			end
		end

		if not find then
			local box_point = sea_star_reward[i].point
			self["btn_reward_box_" .. i]:setTouchEnabled(box_point <= finish_point)
			self["spr_reward_light_" .. i]:setVisible(box_point <= finish_point)
			if box_point <= finish_point then
				local fadeIn = CCFadeTo:create(0.25, 255 * 0.5)
				local fadeOut = CCFadeTo:create(0.25, 255)
				local actions = CCArray:create()
				actions:addObject(fadeIn)
				actions:addObject(fadeOut)
				local action = CCSequence:create(actions)
				self["spr_reward_light_" .. i]:runAction(CCRepeatForever:create(action))				
			end
			self["spr_get_pic_" .. i]:setVisible(false)
		end
		find = false
	end

	for i = 1, REWARD_MAX_NUM do
		self["lbl_reward_box_num_" .. i]:setText(sea_star_reward[i].point)

		local rewards = require("game_config/seaStar/" .. sea_star_reward[i].rewards)
		local tmp_reward = self:getReward(rewards)
		if not tolua.isnull(self["lbl_raward_amount_" .. i]) then
			self["lbl_raward_amount_" .. i]:setText(tmp_reward[1].amount)
		end
		if tmp_reward[1].icon then
			local str_icon = convertResources(tmp_reward[1].icon)
			if string.find(str_icon, "ui/") then
				self["spr_raward_icon_" .. i]:changeTexture(str_icon)
				self["spr_raward_icon_" .. i]:setScale(0.3)
			else
				self["spr_raward_icon_" .. i]:changeTexture(str_icon, UI_TEX_TYPE_PLIST)
			end
		end
	end

	if not tolua.isnull(self.days_view_layer) then
		self.days_view_layer:removeFromParentAndCleanup(true)
	end
end

function ClsSeaStarUI:configEvent()
	for i = 1, REWARD_MAX_NUM do
		self["btn_reward_box_" .. i]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)

			if not tolua.isnull(self.days_view_layer) then
				self.days_view_layer:removeFromParentAndCleanup(true)
			end

			local myself_point = sea_star_reward[i].point
			local seaStarData = getGameData():getSeaStarData()
			local finish_point, sum_point = seaStarData:getFinishStarPointNum()
			if myself_point <= finish_point then
				self["btn_reward_box_" .. i]:setTouchEnabled(false)
				seaStarData:askSeaStarTotalTaskReward(i)
				return
			end
		end, TOUCH_EVENT_BEGAN)
	end

	self.btn_day:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:showDaysList()
	end, TOUCH_EVENT_ENDED)
end

function ClsSeaStarUI:showDaysList()
	if not tolua.isnull(self.days_view) then
		self.days_view:removeFromParentAndCleanup(true)
		self.days_view = nil
		return

	end

	self.days_view = GUIReader:shareReader():widgetFromJsonFile("json/new_star_btn.json")
	convertUIType(self.days_view)
	self:addWidget(self.days_view)

	local needWidgetName = {
		["down_bg"] = "down_bg",
	}

	for k, v in pairs(needWidgetName) do
 		self.days_view[k] = getConvertChildByName(self.days_view, v)
 	end

	for i = 1, MAX_DAY do
		local btn_day_name = string.format("btn_day_%d", i)
		self.days_view[btn_day_name] = getConvertChildByName(self.days_view, btn_day_name)
		self.days_view[btn_day_name]:addEventListener(function()
			if not tolua.isnull(self.days_view) then
				self.days_view:removeFromParentAndCleanup(true)
			end
			if i ~= self.cur_day_index then
				self:setTouch(false)
				self:hideTaskList()
				self:selectDay(i)
				self:showTaskList()
				self:setTouch(true)
			end
		end, TOUCH_EVENT_ENDED)
	end

	local new_today = self:getUnlockDay()
	self.days_view.down_bg:setAnchorPoint(ccp(0.5, 0))
	self.days_view.down_bg:setPosition(ccp(878 , 70))
	self.days_view.down_bg:setSize(CCSize(160, DOWN_HEIGHT[new_today]))

	local task_data = getGameData():getTaskData()
	for i = 1, MAX_DAY do
		local btn_day_name = string.format("btn_day_%d", i)
		task_data:regTask(self.days_view[btn_day_name], {DAY_TASK_KEYS[i]}, KIND_RECTANGLE, on_off_info.SEA_STAR.value, 60, 25, true)
		if i > new_today then
			self.days_view[btn_day_name]:setVisible(false)
		else
			self.days_view[btn_day_name]:setPosition(ccp(0, 40 + (i - 1) * 53))
		end
	end
end

function ClsSeaStarUI:onTouch(event, x, y)
	if event == "began" then
		if not tolua.isnull(self.days_view) then
			self.days_view:removeFromParentAndCleanup(true)
		end
		return false
	end
end

function ClsSeaStarUI:selectDay(index)
	self.cur_day_index = index
	local seaStarData = getGameData():getSeaStarData()
	local days = seaStarData:getDayInfo(index)

	local data_list = {}
	for i = 1, TASK_MAX_ITEM do
		local day_data = seaStarData:getMissionData(days[i].id)
		local sea_star_single_reward = require("game_config/seaStar/" .. days[i].rewards)
		local reward = self:getReward(sea_star_single_reward)
		data_list[i] = {reward = reward[1], name = days[i].name, desc = days[i].describe,
			max_progress = day_data.max_progress, cur_progress = day_data.progress,
			status = day_data.status, mission_id = days[i].id}
	end

	self:updateTaskUI(data_list)

	self.btn_day.lbl_txt:setText(SEA_DAYS[self.cur_day_index])
end

function ClsSeaStarUI:hideTaskList()
	for i = 1, TASK_MAX_ITEM do
 		self["pal_list_" .. i]:setVisible(false)
 	end
end

function ClsSeaStarUI:showTaskList()
	for i = 1, TASK_MAX_ITEM do
 		self["pal_list_" .. i]:setVisible(true)
 	end
end


function ClsSeaStarUI:getUnlockDay()
	local seaStarData = getGameData():getSeaStarData()
	local seaStarInfo = seaStarData:getInfoData()

	local today = seaStarInfo.today
	local new_today = seaStarData:getUnlockDay()
	if today > MAX_DAY then
		today = MAX_DAY
	end

	if new_today <= today then
		new_today = today
	end

	if new_today > MAX_DAY then
		new_today = MAX_DAY
	end

	return new_today
end

function ClsSeaStarUI:getReward(rewards)
	local loot_table = rewards
	local result_tab = {}
	for k, v in pairs(loot_table) do
		local temp = getCommonRewardData(v)
	    local icoStr, amount, scale, name, diTuStr, armature_res = getCommonRewardIcon(temp)
	    result_tab[#result_tab + 1] = {icon = icoStr, scale = scale, amount = amount, armature = armature_res, key = temp["key"]}
	end
	return result_tab
end

function ClsSeaStarUI:updateTaskUI(data_list)
	self:setTouch(true)
	for i, data in ipairs(data_list) do
	   	self["lbl_name_" .. i]:setText(data.name)
	   	self["lbl_content_" .. i]:setText(data.desc)

	   	local seaStarData = getGameData():getSeaStarData()
	   	local seaStarInfo = seaStarData:getInfoData()
	   	if seaStarInfo.isOpen == STAR_STATUS_CLOSE then
	   		if data.status == TASK_STATUS_RECEIVE then
	   			self["spr_pass_" .. i]:setVisible(true)
	   			self["spr_expired_" .. i]:setVisible(false)
	   		else
	   			self["spr_expired_" .. i]:setVisible(true)
	   			self["spr_pass_" .. i]:setVisible(false)
	   		end
	   		self["lbl_progress_cur_num_" .. i]:setVisible(false)
	   		self["spr_progress_bg_" .. i]:setVisible(false)
	   		self["lbl_award_text_" .. i]:setVisible(false)
	   		self["spr_reward_icon_" .. i]:setVisible(false)
	   		self["btn_reward_" .. i]:setEnabled(false)
	   		self["btn_reward_" .. i]:setTouchEnabled(false)
	   		self["lbl_reward_num_" .. i]:setVisible(false)
	   	else
	   		self["spr_expired_" .. i]:setVisible(false)
		   	self["spr_progress_bg_" .. i]:setVisible(true)
		   	self["bar_progress_" .. i]:setPercent(data.cur_progress / data.max_progress * 100)
		   	self["lbl_progress_cur_num_" .. i]:setVisible(true)
		   	self["lbl_progress_cur_num_" .. i]:setText(data.cur_progress .. "/" .. data.max_progress)
		   	self["spr_pass_" .. i]:setVisible(false)
		   	self["spr_expired_" .. i]:setVisible(false)

		   	if data.status == TASK_STATUS_UNRECEIVE then
				self["spr_reward_icon_" .. i]:setVisible(true)
			   	self["lbl_reward_num_" .. i]:setVisible(true)
			   	local amount = data.reward.amount
			   	if not amount or amount == 0 then
			   		amount = 1
			   	end
			   	self["lbl_reward_num_" .. i]:setText(amount)
			   	local size_width = self["spr_reward_icon_" .. i]:getContentSize().width

			   	local str_icon = data.reward.icon
				str_icon = convertResources(str_icon)

				--TODO 这里不应该这么做，
				if str_icon == "" or not str_icon  then
					str_icon = "common_random_treasure.png"
				end
			   	self["spr_reward_icon_" .. i]:changeTexture(str_icon, UI_TEX_TYPE_PLIST)

			   	self["spr_reward_icon_" .. i]:setScale(size_width * self["spr_reward_icon_" .. i]:getScaleX() / (self["spr_reward_icon_" .. i]:getContentSize().width))

			   	self["lbl_award_text_" .. i]:setVisible(true)

			   	self["btn_reward_" .. i]:setVisible(data.cur_progress == data.max_progress)
			   	self["btn_reward_" .. i]:setEnabled(data.cur_progress == data.max_progress)
			   	self["btn_reward_" .. i]:setTouchEnabled(data.cur_progress == data.max_progress)
			end

			if data.cur_progress == data.max_progress and data.status == TASK_STATUS_RECEIVE then
				self["spr_pass_" .. i]:setVisible(true)
				self["spr_reward_icon_" .. i]:setVisible(false)
			   	self["lbl_reward_num_" .. i]:setVisible(false)
			   	self["lbl_award_text_" .. i]:setVisible(false)
			   	self["spr_progress_bg_" .. i]:setVisible(false)
			   	self["lbl_progress_cur_num_" .. i]:setVisible(false)
			   	self["btn_reward_" .. i]:setVisible(false)
			   	self["btn_reward_" .. i]:setEnabled(false)
			   	self["btn_reward_" .. i]:setTouchEnabled(false)
			end

		   	self["btn_reward_" .. i]:setPressedActionEnabled(true)
		   	self["btn_reward_" .. i]:addEventListener(function()
		   		if tolua.isnull(self) then return end
		   		audioExt.playEffect(music_info.COMMON_BUTTON.res)

	   			if not tolua.isnull(self.days_view) then
	   				self.days_view:removeFromParentAndCleanup(true)
					self.days_view = nil
	   			end
		   
			   	self["btn_reward_" .. i]:setTouchEnabled(false)
		   		self["lbl_progress_cur_num_" .. i]:setVisible(false)
			   	self["spr_progress_bg_" .. i]:setVisible(false)
			   	self["btn_reward_" .. i]:setVisible(false)
			   	self["spr_reward_icon_" .. i]:setVisible(false)
			   	self["lbl_reward_num_" .. i]:setVisible(false)
			   	self["lbl_award_text_" .. i]:setVisible(false)
		   		local seaStarData = getGameData():getSeaStarData()
		   		seaStarData:askSeaStarSingleTaskReward(data.mission_id)
		   		self:setTouch(false)
		   	end, TOUCH_EVENT_ENDED)
	   	end
	end
end

function ClsSeaStarUI:doPassAction(index)
	if tolua.isnull(self) then --防止连续点领取的, 已经被删除。
		getGameData():getSeaStarData():askSeaStarList()
		return
	end
	self["spr_pass_" .. index]:setScale(1.5)
	self["spr_pass_" .. index]:setOpacity(0)
	self["spr_pass_" .. index]:setVisible(true)
	self["spr_pass_" .. index]:runAction(CCFadeIn:create(0.1))
	self["spr_pass_" .. index]:runAction(CCScaleTo:create(0.1, 0.6))
	getGameData():getSeaStarData():askSeaStarList()
end

function ClsSeaStarUI:setTouch(enabled)
	self.btn_day:setTouchEnabled(enabled)
end

function ClsSeaStarUI:onExit()
	local wefare_main_ui = getUIManager():get("ClsWefareMain")
	if not tolua.isnull(wefare_main_ui) then
		wefare_main_ui:showHelpBTN(false)
	end
	UnLoadPlist(self.plist)
	UnLoadArmature(self.armatureTab)
	ReleaseTexture(self)
end

return ClsSeaStarUI
