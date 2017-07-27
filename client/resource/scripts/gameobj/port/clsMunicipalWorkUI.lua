--
-- Author: lzg0496
-- Date: 2017-01-02 14:49:08
--

local clsBaseView = require("ui/view/clsBaseView")
local clsScrollView = require("ui/view/clsScrollView")
local clsScrollViewItem = require("ui/view/clsScrollViewItem")
local cfg_municipal_work = require("game_config/port/municipal_work")
local clsDataTools = require("module/dataHandle/dataTools")
local clsUiTools = require("gameobj/uiTools")
local cls_music_info = require("game_config/music_info")
local clsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")
local ClsAlert = require("ui/tools/alert")
local ClsUiWord = require("game_config/ui_word")
local ClsCompositeEffect = require("gameobj/composite_effect")

------------------------------------------ task item -------------------------------------------------

local NOT_ACCEPT_STATUS = 0
local ACCEPT_STATUS = 1
local DONE_STATUS = 2

local CELL_WIGHT = 732
local CELL_HEIGHT = 134
 
local clsMunicipalTaskItem = class("clsMunicipalTaskItem", clsScrollViewItem)

function clsMunicipalTaskItem:updateUI(data, cell)
	self.data = data

	local need_widget_name = {
		lbl_task_name = "task_name",
		spr_task_icon = "task_icon",
		lbl_task_content = "task_content",
		btn_get = "btn",
		lbl_btn_collect = "btn_collect",
		lbl_btn_accept = "btn_accept",
		bar_task_schedule = "bar",
		spr_done_bar = "bar_bg",
		lbl_done_txt = "task_progress",
		pal_power_consume = "power_panel",
		lbl_power_consume = "power_num",
		pal_expect = "expect_panel",
		lbl_expect = "expect_time",
		pal_countdown = "countdown_panel",
		lbl_countdown_time = "countdown_time",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(cell, v)
	end


	for i = 1, 2 do
		self["spr_reward_icon_" .. i] = getConvertChildByName(cell, "reward_icon_" .. i)
		self["lbl_reward_num_" .. i] = getConvertChildByName(cell, "reward_num_" .. i)
	end
	
	self.cfg_item = cfg_municipal_work[self.data.workId]
	self.lbl_task_name:setText(self.cfg_item.title)
	local res = convertResources(self.cfg_item.res)
	self.spr_task_icon:changeTexture(self.cfg_item.res, UI_TEX_TYPE_PLIST)
	self.lbl_task_content:setText(self.cfg_item.details)
	for i = 1, 3 do
		local spr_star = getConvertChildByName(cell, "star_" .. i)
		spr_star:setVisible(i <= self.cfg_item.star)
	end

	local status = self.data.status
	self.lbl_btn_accept:setVisible(status == NOT_ACCEPT_STATUS)
	self.lbl_btn_collect:setVisible(status ~= NOT_ACCEPT_STATUS)
	self.pal_power_consume:setVisible(status == NOT_ACCEPT_STATUS)
	self.pal_expect:setVisible(status == NOT_ACCEPT_STATUS)
	self.pal_countdown:setVisible(status == ACCEPT_STATUS)
	self.lbl_reward_num_1:setText(self.cfg_item.exp) --默认读配置表的经验
	local reward_data = require("game_config/reward/" .. self.cfg_item.rewards)
	local reward_item = getCommonRewardData(reward_data['2'])
	local icon, amount = getCommonRewardIcon(reward_item)
	icon = convertResources(icon)
	self.spr_reward_icon_2:changeTexture(icon, UI_TEX_TYPE_PLIST)
	self.lbl_reward_num_2:setText(amount)
	self.lbl_power_consume:setText(self.cfg_item.food)
	self.lbl_expect:setText(clsDataTools:getTimeStrNormal(self.cfg_item.time))
	self.lbl_countdown_time:setText(clsDataTools:getTimeStrNormal(self.data.remain_time))
	self.lbl_done_txt:setVisible(status ~= NOT_ACCEPT_STATUS)
	self.spr_done_bar:setVisible(status ~= NOT_ACCEPT_STATUS)
	self.btn_get:active()
	if status == ACCEPT_STATUS then
		self.btn_get:disable()
	end

	self.btn_get:setPressedActionEnabled(true)
	self.btn_get:addEventListener(function()
		local municipal_work_data = getGameData():getMunicipalWorkData()
		if self.data.status == DONE_STATUS then
			municipal_work_data:askTaskReward(self.data.workId)
		elseif self.data.status == NOT_ACCEPT_STATUS then
			local str = string.format(ClsUiWord.STR_MUNICIPAL_WORK_USE_FOOD_TIPS, self.cfg_item.food)
			ClsAlert:showAttention(str, function()
				local player_data = getGameData():getPlayerData()
				if player_data:getPower() >= self.cfg_item.food then
					ClsCompositeEffect.new("tx_cityhall_refresh", CELL_WIGHT / 2, CELL_HEIGHT / 2, self, 0.3, function()
						municipal_work_data:askTaskAccept(self.data.workId)
					end)
					return
				end
				municipal_work_data:askTaskAccept(self.data.workId)
			end) 
		end
	end, TOUCH_EVENT_ENDED)
	
	self:tryDoingTask()
end 

function clsMunicipalTaskItem:tryDoingTask()
	self.lbl_countdown_time:stopAllActions()
	local status = self.data.status
	if status == NOT_ACCEPT_STATUS or status == DONE_STATUS then
		if status == DONE_STATUS then
			self.bar_task_schedule:setPercent(100)
		end
		return
	end
	
	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		self.data.remain_time = self.data.remain_time - 1
		if self.data.remain_time <= 0 then
			self.btn_get:active()
			self.data.status = DONE_STATUS
			self.lbl_countdown_time:stopAllActions()
			self.pal_countdown:setVisible(false)
		end	
		self.lbl_countdown_time:setText(clsDataTools:getTimeStrNormal(self.data.remain_time))
		local percent = (self.cfg_item.time - self.data.remain_time) / self.cfg_item.time * 100
		self.bar_task_schedule:setPercent(percent)
	end))
	arr_action:addObject(CCDelayTime:create(1))
	self.lbl_countdown_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end 

------------------------------------------ task item -------------------------------------------------

local clsMunicipalWorkUI = class("clsMunicipalWorkUI", function() return UIWidget:create() end)

function clsMunicipalWorkUI:ctor()
	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	self:askBaseData()
	self:mkUI()
	self:initUI()
	self:configEvent()
end

function clsMunicipalWorkUI:askBaseData()
	local municipal_work_data = getGameData():getMunicipalWorkData()
	municipal_work_data:askTaskInfo()
end

function clsMunicipalWorkUI:mkUI()
	self.panel = createPanelByJson("json/cityhall_task.json")
	convertUIType(self.panel)
	self:addChild(self.panel)
	
	local need_widget_name = {
		btn_close = "close_btn",
		not_have_task = "no_task",
		spr_ui_frame = "ui_frame",
		diamond_bar = "resource_panel",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end

	local diamond_layer = clsPlayerInfoItem.new(ITEM_INDEX_TILI)
	self.diamond_bar:addCCNode(diamond_layer)

	self.not_have_task:setVisible(false)
end

function clsMunicipalWorkUI:initUI()
end

function clsMunicipalWorkUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cls_music_info.COMMON_CLOSE.res)
		getUIManager():get("clsPortTownUI"):showEffectClose()
	end, TOUCH_EVENT_ENDED)
end

function clsMunicipalWorkUI:updateUI()
	if not tolua.isnull(self.task_list_view) then
		self.task_list_view:removeFromParentAndCleanup(true)
	end
	local municipal_work_data = getGameData():getMunicipalWorkData()
	local task_list = municipal_work_data:getTaskList()
	self.not_have_task:setVisible(#task_list == 0)	
	if #task_list == 0 then
		return 
	end	

	self.task_list_view = clsScrollView.new(765, 330, true, function()
		local cell = createPanelByJson("json/cityhall_task_list.json")
		return cell
	end, {is_fit_bottom = true})
	self.spr_ui_frame:addChild(self.task_list_view)
	local cells = {}
	for k, v in ipairs(task_list) do
		cells[#cells + 1] = clsMunicipalTaskItem.new(CCSizeMake(CELL_WIGHT, CELL_HEIGHT), v)
	end

	self.task_list_view:addCells(cells)
	self.task_list_view:setPosition(ccp(-365, -130))
end

function clsMunicipalWorkUI:onExit()
end

return clsMunicipalWorkUI
