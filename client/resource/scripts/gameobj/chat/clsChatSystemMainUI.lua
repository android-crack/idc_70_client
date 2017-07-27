local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsChatBase = require("gameobj/chat/clsChatBase")
local on_off_info = require("game_config/on_off_info")

local offset_x = 510
local offset_y = 0

local use_main_tab_widget_info = {
	[1] = {name = "btn_world", text = "btn_world_text", index = INDEX_WORLD},
	[2] = {name = "btn_now", text = "btn_now_text", index = INDEX_NOW},
	[3] = {name = "btn_guild", text = "btn_guild_text", index = INDEX_GUILD},
	[4] = {name = "btn_team", text = "btn_team_text", index = INDEX_TEAM},
	[5] = {name = "btn_friend", text =  "btn_friend_text", index = INDEX_PRIVATE, task_keys = {
			on_off_info.CHAT_FRIEND.value,
		}, on_off_key = on_off_info.CHAT_FRIEND.value},
	[6] = {name = "btn_system", text =  "btn_system_text", index = INDEX_SYSTEM},
	[7] = {name = "btn_player", text = "btn_player_name", index = INDEX_PLAYER}
}

local other_widget_info = {
	[1] = { name = "tab_panel_layer" },
	[2] = { name = "btn_set" },
	[3] = { name = "btn_close" },
	[4] = { name = "chat_bg"},
}

local ClsChatSystemMainUI = class("ClsChatSystemMainUI", ClsChatBase)
function ClsChatSystemMainUI:ctor()
   	self.main_tabs = {} --主页签集
   	self.panels = {}    --面板索引

   	local base_param = {
        json_res = "chat_spread.json",
    }
    self.super.ctor(self, base_param)

    self:setPosition(ccp(-offset_x, offset_y))
   	self:configUI()
   	self:configEvent()

	local chat_data_hander = getGameData():getChatData()
    chat_data_hander:tryDispatchRedPoint()
end

function ClsChatSystemMainUI:configUI()
	local self_visible = self.setVisible
	self.setVisible = function(self, enable)
		self_visible(self, enable)
		self.bg_touch_panel:setTouchEnabled(enable)
	end

	local task_data = getGameData():getTaskData()
    for k, v in ipairs(use_main_tab_widget_info) do
		local item = getConvertChildByName(self.panel, v.name)
		item.name = v.name
		item.index = v.index
		item.text = getConvertChildByName(self.panel, v.text)

		item:addEventListener(function() 
			setUILabelColor(self[v.name].text, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))	
		end, TOUCH_EVENT_BEGAN)

		item:addEventListener(function() 
			setUILabelColor(self[v.name].text, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))	
		end, TOUCH_EVENT_CANCELED)

		item:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:executeSelectTabLogic(v.index)
		end, TOUCH_EVENT_ENDED)

		item:setTouchEnabled(true)
		self[v.name] = item
		table.insert(self.main_tabs, item)

		if v.on_off_key and v.task_keys then
			self[v.name].task_keys = v.task_keys
        	task_data:regTask(self[v.name], v.task_keys, KIND_CIRCLE, v.on_off_key, 100, 20, true)
    	end
    end

    for k, v in ipairs(other_widget_info) do
    	self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    self.bg_touch_panel = getConvertChildByName(self.panel, "bg_touch_panel")
    self.bg_touch_panel:setTouchEnabled(true)
    local close_rect = CCRect(483, 15, 475, 542)
    self.bg_touch_panel:addEventListener(function()
		local pos = self.bg_touch_panel:getTouchEndPos()
    	if close_rect:containsPoint(ccp(pos.x, pos.y)) then
            self:toPanelUI()
        end
    end, TOUCH_EVENT_ENDED)
    local func = self.tab_panel_layer.addChild
    function self.tab_panel_layer:addChild(panel)
    	func(self, panel)
    	local component_ui = getUIManager():get("ClsChatComponent")
    	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    	main_ui:insertPanelByName(panel.panel_index, panel)
    	main_ui.current_panel = panel
    	panel.tag = panel.panel_index
    end

    function self.btn_player:setStatus(status)
    	self.status = status
    end

    function self.btn_player:setParameter(parameter)
    	self.parameter = parameter
    end

    function self.btn_player:getStatus()
    	return self.status
    end

    function self.btn_player:getParameter()
    	return self.parameter
    end

    function self.btn_player:setText(txt)
    	self.text:setText(txt)
    end
end

function ClsChatSystemMainUI:configEvent()
	self.btn_set:setTouchEnabled(true)
	self.btn_set:setPressedActionEnabled(true)
	self.btn_set:addEventListener(function()
		getUIManager():create("gameobj/chat/clsChatSetUI", {layer_pos = UI_TYPE.TOP})
	end, TOUCH_EVENT_ENDED)

	self.btn_close:setTouchEnabled(true)
	self.btn_close:addEventListener(function()
		if type(self.close_call) == "function" then
			self.close_call()
			return
		end
		self:toPanelUI()
	end, TOUCH_EVENT_ENDED)
end

function ClsChatSystemMainUI:setCloseCall(call)
	self.close_call = call
end

function ClsChatSystemMainUI:addPanel(tag, path)
	local panel = self:getPanelByName(tag)
    if tolua.isnull(panel) then
    	local class_name = require(path)
    	panel = class_name.new()
    	panel.panel_index = tag
    	self.tab_panel_layer:addChild(panel)
   	end

   	return panel
end

local panel_info = {
	[INDEX_WORLD] = {class_name = "ClsWorldChatPanelUI", path = "gameobj/chat/clsWorldChatPanelUI"},
	[INDEX_NOW] = {class_name = "ClsNowChatPanelUI", path = "gameobj/chat/clsNowChatPanelUI"},
	[INDEX_GUILD] = {class_name = "ClsGuildChatPanelUI", path = "gameobj/chat/clsGuildChatPanelUI"},
	[INDEX_TEAM] = {class_name = "ClsTeamChatPanelUI", path = "gameobj/chat/clsTeamChatPanelUI"},
	[INDEX_PRIVATE] = {class_name = "ClsPrivateObjUI", path = "gameobj/chat/clsPrivateObjUI"},
	[INDEX_SYSTEM] = {class_name = "ClsSystemChatPanelUI", path = "gameobj/chat/clsSystemChatPanelUI"},
	[INDEX_PLAYER] = {class_name = "ClsPlayerPanelUI", path = "gameobj/chat/clsPlayerPanelUI"}
}

function ClsChatSystemMainUI:executeSelectTabLogic(index, not_save_channel)
	getUIManager():close("ClsExpandWin")
	self.select_index = index
	local chat_data_hander = getGameData():getChatData()
    if not not_save_channel then
	   chat_data_hander:setPreSelectChannel(index)
    end
	for k, v in ipairs(self.main_tabs) do
		v:setFocused(index == v.index)
		v:setTouchEnabled(index ~= v.index and v.index ~= INDEX_PLAYER)

		if not tolua.isnull(self.current_panel) then
			self.current_panel:removeFromParentAndCleanup(true)
		end

		local color = COLOR_BTN_SELECTED
		if index ~= v.index then
			color = COLOR_BTN_UNSELECTED
		end
		v.text:setUILabelColor(color)
	end
	self.btn_player:setVisible(index == INDEX_PLAYER)

	local panel = panel_info[index]
	local panel = self:addPanel(panel.class_name, panel.path)
	panel:enterCall()
end

function ClsChatSystemMainUI:setPlayerBtnInfo(status, para)
	self.btn_player:setStatus(status)
	self.btn_player:setParameter(para)
	if status == PLAYER_STATUS_PRIVATE then
		local name = string.format(ui_word.WITH_CAHTTING, para.name)
		self.btn_player:setText(name)
	elseif status == PLAYER_STATUS_BLACK then
		self.btn_player:setText(ui_word.BLACK_LIST)
	end
end

function ClsChatSystemMainUI:getPlayerBtnStatus()
	return self.btn_player:getStatus() or PLAYER_STATUS_NO
end

function ClsChatSystemMainUI:getPlayerBtnPara()
	return self.btn_player:getParameter()
end

function ClsChatSystemMainUI:toPanelUI()
	if not tolua.isnull(self.current_panel) then
		self.current_panel:removeFromParentAndCleanup(true)
	end

	self:goOut()
end

function ClsChatSystemMainUI:getPanelByName(name)
	return self.panels[name]
end

function ClsChatSystemMainUI:insertPanelByName(name, panel)
	self.panels[name] = panel
end

function ClsChatSystemMainUI:getCurPanel()
	return self.current_panel
end

function ClsChatSystemMainUI:cleanEidtBox()
	if tolua.isnull(self.current_panel) then return end
    if type(self.current_panel.cleanEidtBox) == "function" then
	   self.current_panel:cleanEidtBox()
    end
end

function ClsChatSystemMainUI:getCurrentChannel()
	return self.select_index
end

--大框进入
function ClsChatSystemMainUI:goInto()
	self:setPosition(ccp(-offset_x, offset_y))
	if not self:isVisible() then
		self:setVisible(true)
	end
	local audio_act = CCCallFunc:create(function() 
		audioExt.playEffect(music_info.PORT_INFO_UP.res)
	end)
	local move_act = CCMoveTo:create(0.1, ccp(0, 0))
	local act = CCSpawn:createWithTwoActions(audio_act, move_act)
	self:runAction(act)
end

--大框出去
function ClsChatSystemMainUI:goOut()
	local arr = CCArray:create()
	local audio_act = CCCallFunc:create(function() 
		audioExt.playEffect(music_info.PORT_INFO_UP.res)
	end)
	local move_act = CCMoveTo:create(0.1, ccp(-offset_x, 0))
	local act = CCSpawn:createWithTwoActions(audio_act, move_act)
    arr:addObject(act)
    arr:addObject(CCCallFunc:create(function() 
    	self:setVisible(false)
    	local component_ui = getUIManager():get("ClsChatComponent")
	    local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
	    if not tolua.isnull(panel_ui) then
	    	panel_ui:setVisible(true)
	    end
    end))
	self:runAction(CCSequence:create(arr))
end

return ClsChatSystemMainUI