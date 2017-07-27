local on_off_info = require("game_config/on_off_info")
local boat_info = require("game_config/boat/boat_info")
local music_info = require("game_config/music_info")
local dataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local uiTools = require("gameobj/uiTools")
local SwitchView = require("ui/tools/SwitchView")
local Alert = require("ui/tools/alert")
local news = require("game_config/news")
local music_info = require("game_config/music_info")

local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local onOffKey_with_taksKey = {
	[1] = {on_off_info.FRIEND_MY.value, {on_off_info.FRIEND_MY.value,}},
	[2] = {on_off_info.FRIEND_ADD.value,{on_off_info.FRIEND_ADD.value,}},
}

local use_main_tab_widget_info = {
	[1] = {name = "tab_my_friends", text = "tab_my_friends_text", index = FRIEND_MYFRIEND},
	[2] = {name = "tab_add_friends", text = "tab_add_friends_text", index = FRIEND_ADDFRIEND},
    [3] = {name = "tab_wechat", text = "tab_wechat_txt", index = FRIEND_WECHAT},
    [4] = {name = "tab_near", text = "tab_near_txt", index = FRIEND_NEAR},
    [5] = {name = "tab_report", text = "tab_report_txt", index = FRIEND_REPORT}
}

local ClsBaseView = require("ui/view/clsBaseView")
local ClsFriendMainUI = class("ClsFriendMainUI", ClsBaseView)
function ClsFriendMainUI:getViewConfig()
    return {
        name = "ClsFriendMainUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        hide_before_view = true,
        effect = UI_EFFECT.FADE,
    }
end

function ClsFriendMainUI:onEnter()
	self.res_plist = {
		["ui/friend_ui.plist"] = 1,
	}
	LoadPlist(self.res_plist)
	self.main_tabs = {} --主页签集
	self.panels = {}--面板索引集
    self.tab_pos = {}
	self:configUI()
	self:configEvent()
	self:executeSelectTabLogic(FRIEND_MYFRIEND)
end

function ClsFriendMainUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend.json")
    self:addWidget(self.panel)

    local taskData = getGameData():getTaskData()
    for k, v in ipairs(use_main_tab_widget_info) do
    	local item = getConvertChildByName(self.panel, v.name)
        local pos = item:getPosition()
        table.insert(self.tab_pos, pos)
    	item.name = v.name
    	item.index = v.index
    	item.text = getConvertChildByName(self.panel, v.text)

    	item:addEventListener(function() 
    		setUILabelColor(item.text, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))	
    	end, TOUCH_EVENT_BEGAN)

    	item:addEventListener(function() 
    		setUILabelColor(item.text, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))	
    	end, TOUCH_EVENT_CANCELED)

    	item:addEventListener(function()
    		audioExt.playEffect(music_info.COMMON_BUTTON.res)
    		self:executeSelectTabLogic(v.index)
    	end, TOUCH_EVENT_ENDED)

        if onOffKey_with_taksKey[k] then
            v.onOffKey = onOffKey_with_taksKey[k][1]
        	v.task_keys = onOffKey_with_taksKey[k][2]
        	if v.task_keys then
        		local task_parameter = {
                    [1] = item,
                    [2] = v.task_keys,
                    [3] = KIND_RECTANGLE,
                    [4] = v.onOffKey,
                    [5] = 60,
                    [6] = 30,
                    [7] = true,
                }
    	  		taskData:regTask(unpack(task_parameter))
    		end
        end
        self[v.name] = item
        table.insert(self.main_tabs, item)
    end
    
    local friend_data = getGameData():getFriendDataHandler()
    local cur_platform = friend_data:getPlatform()

    if cur_platform and (cur_platform == PLATFORM_QQ or cur_platform == PLATFORM_WEIXIN) then
        self.tab_wechat:setVisible(true)
        if cur_platform == PLATFORM_QQ then
            self.tab_wechat.text:setText(ui_word.FRIEND_TAB_QQ)
        elseif cur_platform == PLATFORM_WEIXIN then
            self.tab_wechat.text:setText(ui_word.FRIEND_TAB_WECHAT)
        end
    else
        self.tab_wechat:setVisible(false)
        self.tab_near:setVisible(false)
        self.tab_near:setTouchEnabled(false)
    end
        
    local on_off_data = getGameData():getOnOffData()
    local is_open_loot = on_off_data:isOpen(on_off_info.PORT_QUAY_ROB.value)
    self.tab_report:setVisible(is_open_loot)

    self.tab_panel_layer = getConvertChildByName(self.panel, "tab_panel_layer")
    local func = self.tab_panel_layer.addChild

    function self.tab_panel_layer:addChild(panel)
    	func(self, panel)
    	local main_ui = getUIManager():get("ClsFriendMainUI")
    	main_ui:insertPanelByName(panel.panel_index, panel)
    	main_ui.cur_panel = panel
    end

 	self.expand_panel_layer = getConvertChildByName(self.panel, "expand_panel_layer")
    self.btn_close = getConvertChildByName(self.panel, "btn_close")

    local pos_index = 1
    for k, v in ipairs(self.main_tabs) do
        local is_visible = v:isVisible()
        if is_visible then
            local pos = self.tab_pos[pos_index]
            v:setPosition(ccp(pos.x, pos.y))
            pos_index = pos_index + 1
        end
    end
end

function ClsFriendMainUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()
		self:closeExpandPanel()
	end, TOUCH_EVENT_ENDED)
end

function ClsFriendMainUI:clickFriendTabEvent()
    local panel = self:getPanelByName("ClsFriendPanelUI")
    if tolua.isnull(panel) then
    	local ClsFriendPanelUI = require("gameobj/friend/clsFriendPanelUI")
    	panel = ClsFriendPanelUI.new()
    	panel.panel_index = "ClsFriendPanelUI"
    	self.tab_panel_layer:addChild(panel)
    	panel:executeSelectLogic(TAB_RANK)
   	end
end

function ClsFriendMainUI:clickAddTabEvent()
	local panel = self:getPanelByName("ClsAddPanelUI")
    if tolua.isnull(panel) then
    	local ClsAddPanelUI = require("gameobj/friend/clsAddPanelUI")
    	panel = ClsAddPanelUI.new()
    	panel.panel_index = "ClsAddPanelUI"
    	self.tab_panel_layer:addChild(panel)
   	end
   	panel:updateFriendNum()
end

function ClsFriendMainUI:clickWechatTabEvent()
    local panel = self:getPanelByName("ClsFriendQQWechat")
    if tolua.isnull(panel) then
        local ClsFriendQQWechat = require("gameobj/friend/clsFriendQQWechat")
        panel = ClsFriendQQWechat.new()
        panel.panel_index = "ClsFriendQQWechat"
        self.tab_panel_layer:addChild(panel)
    end
end

function ClsFriendMainUI:clickNearTabEvent()
    local friend_data = getGameData():getFriendDataHandler()
    local near_list = friend_data:getNeatFriend()
    if not near_list or #near_list == 0 then
        Alert:warning({msg = ui_word.GET_NEAR_FRIEND_TIPS, size = 26})
    end
    friend_data:getNearbyPersonInfo()
    local panel = self:getPanelByName("ClsFriendNear")
    if tolua.isnull(panel) then
        local ClsFriendQQWechat = require("gameobj/friend/clsFriendNear")
        panel = ClsFriendQQWechat.new()
        panel.panel_index = "ClsFriendNear"
        self.tab_panel_layer:addChild(panel)
    end
end

function ClsFriendMainUI:clickBattleReport()
    local panel = self:getPanelByName("ClsReportManagerUI")
    if tolua.isnull(panel) then
        local ClsReportManagerUI = require("gameobj/loot/clsReportManagerUI")
        panel = ClsReportManagerUI.new()
        panel.panel_index = "ClsReportManagerUI"
        self.tab_panel_layer:addChild(panel)
        panel:executeSelectLogic(TAB_PLUNDER)
    end
end

local tab_events = {
	[FRIEND_MYFRIEND] = ClsFriendMainUI.clickFriendTabEvent,
	[FRIEND_ADDFRIEND] = ClsFriendMainUI.clickAddTabEvent,
    [FRIEND_WECHAT] = ClsFriendMainUI.clickWechatTabEvent,
    [FRIEND_NEAR] = ClsFriendMainUI.clickNearTabEvent,
    [FRIEND_REPORT] = ClsFriendMainUI.clickBattleReport,
}

function ClsFriendMainUI:executeSelectTabLogic(index)
	self:closeExpandPanel()
	for k, v in ipairs(self.main_tabs) do
		v:setFocused(index == v.index)
        local is_visible = v:isVisible()
		v:setTouchEnabled((index ~= v.index) and is_visible)

		if not tolua.isnull(self.cur_panel) then
			self.cur_panel:removeFromParentAndCleanup(true)
		end

        local color = COLOR_BTN_SELECTED
        if index ~= v.index then
            color = COLOR_BTN_UNSELECTED
        end

        v.text:setUILabelColor(color)
	end
	tab_events[index](self)
end

function ClsFriendMainUI:getPanelByName(name)
    return self.panels[name]
end

function ClsFriendMainUI:insertPanelByName(name, panel)
    self.panels[name] = panel
end

function ClsFriendMainUI:closeExpandPanel()
	getUIManager():close("ClsCommonExpand")
end

function ClsFriendMainUI:onTouchChange(is_touch)
    local add_ui = self.panels["ClsAddPanelUI"]
    if not tolua.isnull(add_ui) then
        add_ui:setEditBoxTouch(is_touch)
    end
end

function ClsFriendMainUI:openExpandPanel(select_cell)
	if tolua.isnull(select_cell) then return end
	local player_data = getGameData():getPlayerData()
	if player_data:getUid() == select_cell.m_cell_date.uid then
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:closeExpandPanel()
		return
	end

	local ui = getUIManager():get("ClsCommonExpand")
	if tolua.isnull(ui) then --扩展面板不存在
		ui = getUIManager():create("gameobj/friend/clsCommonExpand")
	else
        if ui:isOnePerson(select_cell.m_cell_date.uid) then
            self:closeExpandPanel()
            return
        end
    end
    audioExt.playEffect(music_info.TOWN_CARD.res)
    ui:setBindCell(select_cell)
end

return ClsFriendMainUI