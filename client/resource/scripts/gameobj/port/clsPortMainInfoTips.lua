-- 主港口信息界面tips
-- Author: chenlurong
-- Date: 2016-11-12 11:33:02
--

local ui_word = require("scripts/game_config/ui_word")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")

local ClsPortMainInfoTips = class("ClsPortMainInfoTips", ClsBaseTipsView)

function ClsPortMainInfoTips:getViewConfig(name_str, params, partner_index, item_key, x, y)
	return ClsPortMainInfoTips.super.getViewConfig(self, name_str, params, item_key, x, y)
end

local cd_widget = {
    "cd_num",
    "cd_text",
}

function ClsPortMainInfoTips:onEnter(name_str, params, partner_index, item_key, x, y)
	local port_info_layer = UIWidget:create()
	self.info_panel = GUIReader:shareReader():widgetFromJsonFile("json/main_port_info.json")
    convertUIType(self.info_panel)
    port_info_layer:addChild(self.info_panel)
    for i,v in ipairs(cd_widget) do
        self[v] = getConvertChildByName(self.info_panel, v)
        self[v]:setVisible(false)
    end

    ClsPortMainInfoTips.super.onEnter(self, name_str, params, port_info_layer, true)

    local port_data = getGameData():getPortData()
	local cur_port_info = port_data:getPortInfo()
    local port_info_text = getConvertChildByName(self.info_panel, "port_info_text")
    port_info_text:setText(cur_port_info.port_des)
    self.cd_num:setText("")

    local port_info_bg = getConvertChildByName(self.info_panel, "port_info_bg")
    local ClsUiTools = require("gameobj/uiTools")
    ClsUiTools:scrollTipShowAction(port_info_bg)
    self.btn_share = getConvertChildByName(self.info_panel, "btn_share")
    self.btn_share_text = getConvertChildByName(self.info_panel, "btn_share_text")
    self.btn_share:setPressedActionEnabled(true)
    self.btn_share:addEventListener(function ()
        if self.show_lock_time and tonumber(self.show_lock_time) > 0 then
            local Alert = require("ui/tools/alert")
            local tips = string.format(ui_word.PHOTO_NOT_SHARE_TIPS, tostring(self.show_lock_time))
            Alert:warning({msg = tips, size = 26})
            return 
        end
        local module_game_sdk = require("module/sdk/gameSdk")
        module_game_sdk.canOperate(function ()
            require("gameobj/tips/clsPostCardTips")
            local port_data = getGameData():getPortData()
            local cur_id = port_data:getPortId()
            createPostCard(cur_id)
        end)
    end, TOUCH_EVENT_ENDED)

    self:updateShareStatus(port_data:getPortId())
end

local interval_time = 60 * 60 --30分钟

function ClsPortMainInfoTips:updateCDshare()
    CCUserDefault:sharedUserDefault()
    local user_data = CCUserDefault:sharedUserDefault()
    local cur_share_time = user_data:getStringForKey("CurshareTime", "")
    local old_share_time = tonumber(cur_share_time)
    local remind_time = os.time() - old_share_time
    if remind_time < interval_time and remind_time > 0 then --小鱼30分钟
        for i,v in ipairs(cd_widget) do
            self[v]:setVisible(true)
        end
        local show_remian = math.ceil((interval_time - remind_time)/60)
        self.cd_num:setText(show_remian.."m")
        self.show_lock_time = show_remian
    else
        

    end

end

function ClsPortMainInfoTips:updateShareStatus( port_id )
    local port_data = getGameData():getPortData()
    local cur_id = port_data:getPortId()
    if port_id == cur_id then
        local module_game_sdk = require("module/sdk/gameSdk")
        if module_game_sdk.getPlatform() <= 1 then
            self.btn_share:disable()
            self.btn_share:setTouchEnabled(false) 
        end

        local map_attrs_data = getGameData():getWorldMapAttrsData()
        local has_share_reward = map_attrs_data:isPortShareReward(port_data:getPortId())

        if not has_share_reward then
            self.btn_share_text:setText(ui_word.STR_SHARE_HAD_BTN_TXT)
            self.btn_share:disable()
            self.btn_share:setTouchEnabled(false) 
        else
            self:updateCDshare()
        end
        self.btn_share:setVisible(not GTab.IS_VERIFY)
    end
end

function ClsPortMainInfoTips:closePortInfoPanel()
	local port_info_bg = getConvertChildByName(self.info_panel, "port_info_bg")
	local ClsUiTools = require("gameobj/uiTools")
	ClsUiTools:scrollTipCloseAction(port_info_bg, function()
		self:close()
	end)
end

function ClsPortMainInfoTips:bgOnTouch(event, x, y)
    if event == "began" then
    	self:closePortInfoPanel()
        return false
    end
end


return ClsPortMainInfoTips
