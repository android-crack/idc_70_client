local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsBaseView = require("ui/view/clsBaseView")
local ClsFriendPkTip = class("ClsFriendPkTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFriendPkTip:getViewConfig()
    return {
        name = "ClsFriendPkTip",
        type = UI_TYPE.TIP,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsFriendPkTip:onEnter(parameter)
    self.kind = parameter.kind
	self.name = parameter.name
	self.end_time = parameter.end_time
	self.attacker = parameter.attacker
    self:configUI()
    self:openScheduler()
end

function ClsFriendPkTip:configInitiativePlunderUI()
	self.countdown_num = getConvertChildByName(self.initiative_panel, "countdown_num")
end

local passivity_panel_widgets = {
	[1] = {name = "btn_accept", kind = BTN},
	[2] = {name = "btn_refuse", kind = BTN},
	[3] = {name = "btn_close", kind = BTN},
	[4] = {name = "pk_text"},
	[5] = {name = "countdown_num"}
}

function ClsFriendPkTip:configPassivityPlunderUI()
	for k, v in ipairs(passivity_panel_widgets) do
		self[v.name] = getConvertChildByName(self.panel, v.name)
		if v.kind == BTN then
			self[v.name]:setPressedActionEnabled(true)
			self[v.name]:setTouchEnabled(true)
		end
	end
	local show_txt = string.format(ui_word.PASSIVITY_PLUNDER_TIP_TEXT, self.name)
	self.pk_text:setText(show_txt)
	self:configEvent()
end

local kind_events = {
	[INITIATIVE_PK_TIP] = ClsFriendPkTip.configInitiativePlunderUI,
	[PASSIVITY_PK_TIP] = ClsFriendPkTip.configPassivityPlunderUI,
}

function ClsFriendPkTip:configEvent()
	self.btn_accept:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:closeScheduler()
		local friend_data_handler = getGameData():getFriendDataHandler()
		friend_data_handler:askAgreePk(1, self.attacker)
		self:close()
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

function ClsFriendPkTip:closeView()
	self:closeScheduler()
	local friend_data_handler = getGameData():getFriendDataHandler()
	friend_data_handler:askAgreePk(2, self.attacker)
	self:close()
end

function ClsFriendPkTip:closeScheduler()
	if self.update_scheduler then
		scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
	end
end

function ClsFriendPkTip:openScheduler()
	local function updateCount()
		local player_data = getGameData():getPlayerData()
		local current_time = player_data:getCurServerTime()
    	if self.end_time > current_time then
    		if not tolua.isnull(self.countdown_num) then
    			self.countdown_num:setText(tostring(self.end_time - current_time))
    		end
        else
        	if self.kind == INITIATIVE_PK_TIP then
				Alert:warning({msg = ui_word.FRIEND_NOT_ASK})
			end

        	self:closeScheduler()
			self:closeView()
        end
    end

    self:closeScheduler()
    self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

local panel_info = {
	[1] = {name = "initiative_panel", kind = INITIATIVE_PK_TIP},
	[2] = {name = "passivity_panel", kind = PASSIVITY_PK_TIP}
}

function ClsFriendPkTip:configUI()
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

function ClsFriendPkTip:onExit()
	self:closeScheduler()
end

return ClsFriendPkTip