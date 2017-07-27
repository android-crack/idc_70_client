local music_info = require("game_config/music_info")
local ClsPlayerPanelUI = class("ClsPlayerPanelUI", function() return UIWidget:create() end)
function ClsPlayerPanelUI:ctor()
    self.panels = {}
    self:configUI()
end

local show_view_by_kind = {
    [PLAYER_STATUS_PRIVATE] = {class_name = "ClsPrivateListUI", path = "gameobj/chat/clsPrivateListUI"},
    [PLAYER_STATUS_BLACK] = {class_name = "ClsBlackListUI", path = "gameobj/chat/clsBlackListUI"},
}

function ClsPlayerPanelUI:configUI()
    self:removeAllChildren()
    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    local status = main_ui:getPlayerBtnStatus()
  	if not tolua.isnull(self.cur_panel) then
  		self.cur_panel:removeFromParentAndCleanup(true)
  		self.cur_panel = nil
  	end
    
    local show_info = show_view_by_kind[status]
	if show_info == nil then 
		print("status is error !!!", status)
		return
	end 
	
    local class_name = require(show_info.path)
    local panel = class_name.new()
    self:addChild(panel)
    self:insertPanelByName(show_info.class_name, panel)
    self.cur_panel = panel
    self.status = status
end

function ClsPlayerPanelUI:getPanelByName(name)
    return self.panels[name]
end

function ClsPlayerPanelUI:getCurPanel()
    return self.cur_panel
end

function ClsPlayerPanelUI:insertPanelByName(name, panel)
    self.panels[name] = panel
end

function ClsPlayerPanelUI:enterCall()
    self.cur_panel:enterCall()
end

function ClsPlayerPanelUI:setEidtBoxStr(copy_str)
    if type(self.cur_panel.setEidtBoxStr) == "function" then
        self.cur_panel:setEidtBoxStr(copy_str)
    end
end

function ClsPlayerPanelUI:cleanEidtBox()
    if type(self.cur_panel.cleanEidtBox) == "function" then
        self.cur_panel:cleanEidtBox()
    end
end

return ClsPlayerPanelUI