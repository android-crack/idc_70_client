
----商会预开放tips


local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local ClsUiTools = require("gameobj/uiTools")
local ClsBaseView = require("ui/view/clsBaseView")
local guild_advance_open = require("scripts/game_config/guild/guild_advance_open")

local ClsGuildWillOpenTips = class("ClsGuildWillOpenTips", ClsBaseView)
-- function ClsGuildWillOpenTips:getViewConfig()

-- end

function ClsGuildWillOpenTips:onEnter(tag)

	self.info_panel = GUIReader:shareReader():widgetFromJsonFile("json/main_port_info.json")
    convertUIType(self.info_panel)
	self:addWidget(self.info_panel)

  	local info = guild_advance_open[tag]
    local port_info_title = getConvertChildByName(self.info_panel, "port_info_title")
    port_info_title:setText(info.name)

    local port_info_text = getConvertChildByName(self.info_panel, "port_info_text")
    port_info_text:setText(info.target_tips)

   	self.port_info_bg = getConvertChildByName(self.info_panel, "port_info_bg")
    local ClsUiTools = require("gameobj/uiTools")
    ClsUiTools:scrollTipShowAction(self.port_info_bg)
    local btn_share = getConvertChildByName(self.info_panel, "btn_share")
    btn_share:setVisible(false)

    local cd_text = getConvertChildByName(self.info_panel, "cd_text")
    cd_text:setVisible(false)
    local cd_num = getConvertChildByName(self.info_panel, "cd_num")
    cd_num:setVisible(false)
	self:regTouchEvent(self, function(event, x, y)
	return self:bgOnTouch(event, x, y) end)

end

function ClsGuildWillOpenTips:closePortInfoPanel()
	ClsUiTools:scrollTipCloseAction(self.port_info_bg, function()
		self:close()
	end)
end

function ClsGuildWillOpenTips:bgOnTouch(event, x, y)
    if event == "began" then
    	self:closePortInfoPanel()
        return false
    end
end

return ClsGuildWillOpenTips