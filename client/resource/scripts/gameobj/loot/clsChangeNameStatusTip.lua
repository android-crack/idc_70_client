local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsBaseView = require("ui/view/clsBaseView")
local ClsChangeNameStatusTip = class("ClsChangeNameStatusTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsChangeNameStatusTip:getViewConfig()
    return {
        name = "ClsChangeNameStatusTip",
        type = UI_TYPE.TIP,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsChangeNameStatusTip:onEnter(parameter)
    self.kind = parameter.kind
	self.name = parameter.name
	self.end_time = parameter.end_time
    self:configUI()
    self:openScheduler()
end

function ClsChangeNameStatusTip:configLeaderUI()
	self.countdown_num = getConvertChildByName(self.initiative_panel, "countdown_num")
	self.countdown_num:setText(8)
	self.answer_tips = getConvertChildByName(self.initiative_panel, "answer_tips")
	self.answer_tips:setText(ui_word.PLEASE_TEAMTER_AGREE)
end

local passivity_panel_widgets = {
	[1] = {name = "btn_accept"},
	[2] = {name = "btn_refuse"},
	[3] = {name = "btn_close"},
	[4] = {name = "pk_text"},
	[5] = {name = "countdown_num"}
}

function ClsChangeNameStatusTip:configTeamaterUI()
	for k, v in ipairs(passivity_panel_widgets) do
		local item = getConvertChildByName(self.panel, v.name)
		if item:getDescription() == "Button" then
			item:setPressedActionEnabled(true)
			item:setTouchEnabled(true)
		end
		self[v.name] = item
	end

	self.pk_text:setText(ui_word.TEAM_CHANGE_NAME_STATUS)
	self.countdown_num:setText(8)
	self:configEvent()
end

local kind_events = {
	[IS_LEADER] = ClsChangeNameStatusTip.configLeaderUI,
	[IS_TEAMATER] = ClsChangeNameStatusTip.configTeamaterUI,
}

function ClsChangeNameStatusTip:configEvent()
	self.btn_accept:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:closeScheduler()
		local loot_data = getGameData():getLootData()
		self:close()
		loot_data:askChangeNameStatus(1)
	end, TOUCH_EVENT_ENDED)

	self.btn_refuse:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

function ClsChangeNameStatusTip:closeView()
	self:closeScheduler()
	if self.kind ~= IS_LEADER then
		local loot_data = getGameData():getLootData()
		loot_data:askChangeNameStatus(0)
	end
	self:close()
end

function ClsChangeNameStatusTip:closeScheduler()
	if self.update_scheduler then
		scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
	end
end

function ClsChangeNameStatusTip:openScheduler()
	local function updateCount()
		local player_data = getGameData():getPlayerData()
		local current_time = player_data:getCurServerTime()
    	if self.end_time > current_time then
    		if not tolua.isnull(self.countdown_num) then
    			self.countdown_num:setText(tostring(self.end_time - current_time))
    		end
        else
        	self:closeScheduler()
			self:closeView()
        end
    end

    self:closeScheduler()
    self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

local panel_info = {
	[1] = {name = "initiative_panel", kind = IS_LEADER},
	[2] = {name = "passivity_panel", kind = IS_TEAMATER}
}

function ClsChangeNameStatusTip:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_pk.json")
    self:addWidget(self.panel)

	local panel_size = self.panel:getContentSize()
	self.panel:setPosition(ccp(display.cx - panel_size.width / 2, display.cy - panel_size.height / 2))
	self.panels = {}
	for k, v in ipairs(panel_info) do
		self[v.name] = getConvertChildByName(self.panel, v.name)
		self[v.name].kind = v.kind
		self[v.name]:setVisible(v.kind == self.kind)
	end
	kind_events[self.kind](self)
end

function ClsChangeNameStatusTip:onExit()
	self:closeScheduler()
end

return ClsChangeNameStatusTip