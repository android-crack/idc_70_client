local music_info = require("game_config/music_info")
local time_plunder_info = require("game_config/loot/time_plunder_info")
local tool = require("module/dataHandle/dataTools")
local ui_word = require("scripts/game_config/ui_word")
local Alert = require("ui/tools/alert")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsTradeCompeteDescribe = require("gameobj/activity/clsTradeCompeteDescribe")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsReportCell = class("ClsReportCell", ClsScrollViewItem)

function ClsReportCell:updateUI(cell_date, panel)
    self.show_text = getConvertChildByName(panel, "show_text")
	local data = cell_date
	local show_type = data.is_active ~= 0 and ui_word.EXPLORE_LOOT_REPORT_SHOW_1 or ui_word.EXPLORE_LOOT_REPORT_SHOW_2
	local get_or_lose_txt = data.value > 0 and ui_word.EXPLORE_LOOT_GET or ui_word.EXPLORE_LOOT_LOSE
	local show_txt = string.format(show_type, data.name, get_or_lose_txt, math.abs(data.value))
	self.show_text:setText(show_txt)
end

local ClsBaseView = require("ui/view/clsBaseView")
local ClsPortTradeCompete = class("ClsPortTradeCompete", ClsBaseView)

function ClsPortTradeCompete:getViewConfig()
    return {
        is_back_bg = true,
    }
end

function ClsPortTradeCompete:onEnter()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_trade.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    self.btn_tab = {}
    self.btn_status_tab = {}
    self.show_widget_tab = {}
    self:configUI()
    self:configEvent()
    local trade_complete_data = getGameData():getTradeCompleteData()
	trade_complete_data:askTimePlunderOpenInfo()
end

local btn_info = {
	[1] = {name = "btn_accpet", status = TASK_CAN_ACCEPT_STATUS},
	[2] = {name = "close_btn"},
	[3] = {name = "btn_working", status = TASK_ACCEPTED_STATUS},
	[4] = {name = "btn_info"},
	[5] = {name = "btn_finish", status = TASK_FINISH_STATUS}
}

local task_show_info = {
	[1] = {name = "task_title"},
	[2] = {name = "task_info_text"},
	[3] = {name = "from_port"},
	[4] = {name = "purpose_port"},
	[5] = {name = "award_num"},
	[6] = {name = "times_num"},
	[7] = {name = "award_bar"},
	[8] = {name = "no_report"},
	[9] = {name = "award_bar_bg"},
	[10] = {name = "no_open_des", no_open_show = true},
	[11] = {name = "award_icon"}
}

function ClsPortTradeCompete:configUI()
	for k, v in ipairs(btn_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        self[v.name].status = v.status
        self[v.name]:setPressedActionEnabled(true)
        self.btn_tab[#self.btn_tab + 1] = self[v.name]
        if v.status then
        	self.btn_status_tab[#self.btn_status_tab + 1] = self[v.name]
        end
    end

    for k, v in ipairs(task_show_info) do
    	self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        self[v.name].no_open_show = v.no_open_show or false
        self[v.name]:setVisible(false)
        self.show_widget_tab[#self.show_widget_tab + 1] = self[v.name]
    end
    self.last_time = getConvertChildByName(self.panel, "last_time")
    self.last_time:setVisible(false)
    self:updateView()
    self:updateListView()
end

function ClsPortTradeCompete:configEvent()
	local port_data = getGameData():getPortData()
	self.btn_accpet:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local current_port_id = port_data:getPortId()
		local function callBack()
			local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
			local layer = missionSkipLayer:skipLayerByName("team_trade")
		end

		if current_port_id == self.go_port_id then
			self:closeView()
			getUIManager():close("ClsActivityMain")
			callBack()
			return
		end

		Alert:showAttention(ui_word.TEAM_TRADE_GO_TIPS, function() 
		    port_data:setEnterPortCallBack(callBack)
			local trade_complete_data = getGameData():getTradeCompleteData()
			trade_complete_data:askEnterPort(self.go_port_id)
		end)
	end, TOUCH_EVENT_ENDED)

	self.btn_working:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		Alert:warning({msg = ui_word.TRADE_TASKING_TIP})
	end, TOUCH_EVENT_ENDED)

	self.close_btn:addEventListener(function()
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	self.btn_info:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if tolua.isnull(self.describe_panel) then
			getUIManager():create("gameobj/activity/clsTradeCompeteDescribe")
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_finish:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		Alert:warning({msg = ui_word.TRADE_FINISH_TIP})
	end, TOUCH_EVENT_ENDED)
end

function ClsPortTradeCompete:closeView()
	audioExt.playEffect(music_info.COMMON_CLOSE.res)
	audioExt.playEffect(music_info.PAPER_STRETCH.res)
	self:close()
end

function ClsPortTradeCompete:revertBtns()
	for k, v in ipairs(self.btn_status_tab) do
		v:active()
		v:setVisible(false)
		v:setTouchEnabled(false)
	end
end

function ClsPortTradeCompete:updateView()
	local trade_complete_data = getGameData():getTradeCompleteData()
	local is_open = trade_complete_data:getIsOpen()

	self:revertBtns()
	self:setTextInfoShow(false)
	if not is_open then
		self.no_open_des:setVisible(true)
		self.btn_accpet:setVisible(true)
		self.btn_accpet:disable()
		self:openCountDownScheduler()
	else
		local info = trade_complete_data:getTradeCompleteInfo()
		if not info then return end
		local limit = info.limit or 2
		local current_count = info.count
		local current_status = info.status
		if current_count == limit then
			if current_status == TASK_FINISH_STATUS then
				self.no_open_des:setVisible(true)
			elseif current_status == TASK_ACCEPTED_STATUS then
				self:setTaskShowInfo()
				self:activeBtn(self.btn_working)
				self:openCountDownScheduler()
			elseif current_status == TASK_CAN_ACCEPT_STATUS then
				self.btn_accpet:setVisible(true)
				self.btn_accpet:disable()
				self:setTaskShowInfo()
				self:openCountDownScheduler()
			end
		elseif current_count < limit then
			if current_status == TASK_ACCEPTED_STATUS then
				self:activeBtn(self.btn_working)
			elseif current_status == TASK_CAN_ACCEPT_STATUS then
				self:activeBtn(self.btn_accpet)
			end
			self:setTaskShowInfo()
			self:openCountDownScheduler()
		end
	end
end

function ClsPortTradeCompete:updateListView()
	if not tolua.isnull(self.list_view) then  
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end
	local trade_complete_data = getGameData():getTradeCompleteData()
	local report_list = trade_complete_data:getReportList()
 	
 	if not report_list or #report_list < 1 then return end
	self.no_report:setVisible(false)

    self.list_view = ClsScrollView.new(260, 253, true, function()
    	local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/report_list_cell.json")
        return cell_ui
    end, {is_fit_bottom = true})

    self.cells = {}
    for k, v in ipairs(report_list) do
        local cell = ClsReportCell.new(CCSize(253, 48), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(598, 161))
    self:addWidget(self.list_view)
end

function ClsPortTradeCompete:activeBtn(target)
	target:setVisible(true)
	target:setTouchEnabled(true)
end

function ClsPortTradeCompete:setTextInfoShow(enable)
	for k, v in ipairs(self.show_widget_tab) do
		if enable then
			v:setVisible(not v.no_open_show)
		else
			v:setVisible(enable)
		end
	end
end

function ClsPortTradeCompete:setTaskShowInfo()
	local trade_complete_data = getGameData():getTradeCompleteData()
	local info = trade_complete_data:getTradeCompleteInfo()
	if not info then return end
	self:setTextInfoShow(true)
	local task_id = info.id
	local task_info = time_plunder_info[task_id]
	self.go_port_id = task_info.accept_mission_port_id
	local port_info = require("game_config/port/port_info")
	local task_port_id = 0
	local goal_port_id = 0
	for k, v in ipairs(port_info) do
		if v.name == task_info.src_port then
			task_port_id = k
		end
		if v.name == task_info.dst_port then
			goal_port_id = k
		end
	end
	self.task_title:setText(string.format("%s", task_info.name))
	self.task_info_text:setText(task_info.desc)
	self.from_port:setText(task_info.src_port)
	self.purpose_port:setText(task_info.dst_port)
	self.award_num:setText(info.gold)
	self.award_bar:setPercent(info.gold * 100 / task_info.reward)
	local times_txt = string.format("%d/%d", info.count, info.limit)
	self.times_num:setText(times_txt)

	local trade_complete_data = getGameData():getTradeCompleteData()
	local report_list = trade_complete_data:getReportList()
	if not report_list or #report_list < 1 then return end
	self.no_report:setVisible(false)
end

function ClsPortTradeCompete:closeCountDownScheduler()
    if self.update_count_shceduler then
        scheduler:unscheduleScriptEntry(self.update_count_shceduler)
        self.update_count_shceduler = nil
    end
end

function ClsPortTradeCompete:closeInquiryServerScheduler()
	if self.inquiry_scheduler then
  		scheduler:unscheduleScriptEntry(self.inquiry_scheduler)
        self.inquiry_scheduler = nil
	end
end

function ClsPortTradeCompete:openInquiryServerScheduler()
	self.time = 0
	local function updateCount()
    	self.time = self.time + 1
        if self.time <= 4 then
        	local trade_complete_data = getGameData():getTradeCompleteData()
			trade_complete_data:askTimePlunderOpenInfo()
        else
        	self.time = 0
        	self:closeInquiryServerScheduler()
        end
    end

    self:closeInquiryServerScheduler()
    self.inquiry_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

function ClsPortTradeCompete:openCountDownScheduler()
	local trade_complete_data = getGameData():getTradeCompleteData()
	local is_open = trade_complete_data:getIsOpen()
	local txt = is_open and ui_word.TRADE_COMPLETE_REMAIN_TIME or ui_word.TRADE_COMPLETE_OPEN_TIME
	local time = trade_complete_data:getCd()
	local current_time = os.time()
	local player_data = getGameData():getPlayerData()
	current_time = current_time + player_data:getTimeDelta()
	if time <= current_time then
		if self.inquiry_scheduler then return end
		self:openInquiryServerScheduler()
		return 
	end
    local function updateCount()
    	if tolua.isnull(self) then return end
    	current_time = os.time()
	    current_time = current_time + player_data:getTimeDelta()

        if current_time < time then
        	local show_txt = string.format(txt, tostring(tool:getTimeStrNormal(time - current_time)))
            self.last_time:setText(show_txt)
            if not self.last_time:isVisible() then
            	self.last_time:setVisible(true)
            end
        else
        	self.last_time:setVisible(false)
            self:closeCountDownScheduler()
            local trade_complete_data = getGameData():getTradeCompleteData()
			trade_complete_data:askTimePlunderOpenInfo()
        end
    end

    self:closeCountDownScheduler()
    self.update_count_shceduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

function ClsPortTradeCompete:onExit()
	ClsPortTradeCompete.super.onExit(self)
	self:closeCountDownScheduler()
	self:closeInquiryServerScheduler()
end

return ClsPortTradeCompete
