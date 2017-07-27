--
-- Author: lzg0496
-- Date: 2016-11-09 11:57:07
-- Function: 进港口的UI

-- local mission_guide = require("gameobj/mission/missionGuide")
local ClsBaseView = require("ui/view/clsBaseView")
local port_info = require("game_config/port/port_info")
local port_type_info = require("game_config/port/port_type_info")
local goods_type_info = require('game_config/port/goods_type_info')
local music_info = require("scripts/game_config/music_info")
local news = require("game_config/news")
local ClsAlert = require("ui/tools/alert")

local clsEnterPortUI = class("clsEnterPortUI", ClsBaseView)

function clsEnterPortUI:onEnter(params)
    -- mission_guide:clearGuideMaskLayer()
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():setStopFoodReason("clsEnterPortUI_show")
	end

    self.plistTab = {
        ["ui/skill_icon.plist"] = 1,
        ["ui/material_icon.plist"] = 1,
    }
    LoadPlist(self.plistTab)
    
    -- local needGuideMaskLayer = mission_guide:needGuideMaskLayer(mission_guide.GUIDE_MASK_TYPE_ENTER_PORT_UI)

    local port = port_info[params.portId]
    local typeInfo = port_type_info[port.type]

    --资源释放
    local function closeFunc()
        if type(params.closeCallBack) =="function" then params.closeCallBack() end
    end

    local map_attrs = getGameData():getWorldMapAttrsData()

    local status = map_attrs:getPortStatus(params.portId)

    --添加探索开始图标
    local explore_relic_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_sea_port.json")
    self:addWidget(explore_relic_ui)
    local panel_size = explore_relic_ui:getSize()

    local bg_ui = getConvertChildByName(explore_relic_ui, "bg")
    local enter_btn = getConvertChildByName(bg_ui, "btn_enter")
    self.m_supply_btn = getConvertChildByName(bg_ui, "btn_add")
    local close_btn = getConvertChildByName(bg_ui, "btn_close")
    local title_lab = getConvertChildByName(bg_ui, "title")
    local info_text_lab = getConvertChildByName(bg_ui, "info_text")
    title_lab:setText(tostring(port.name))
    info_text_lab:setText(port.port_des)

    close_btn:setPressedActionEnabled(true)
    close_btn:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_CLOSE.res)
            self:close()
            closeFunc()
        end, TOUCH_EVENT_ENDED)

    enter_btn:setPressedActionEnabled(true)
    enter_btn:addEventListener(function()
            self:close()
            audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
            if type(params.okCallBack)=="function" then
                params.okCallBack()
            end
            if params.quickEnterPort then
                EventTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT, params.portId)
            else
                EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = params.portId, navType = EXPLORE_NAV_TYPE_PORT})
            end
        end, TOUCH_EVENT_ENDED)
		
	self.m_supply_btn:setPressedActionEnabled(true)
	self.m_supply_btn:addEventListener(function()
			self.m_supply_btn:setTouchEnabled(false)
			audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
			local supplyData = getGameData():getSupplyData()
			--调用这个记录消耗值
			supplyData:getSupplyConsumeCash()
			supplyData:askSupplyFull()
		end, TOUCH_EVENT_ENDED)

    -- if needGuideMaskLayer then
    --     close_btn:setEnabled(false)
    -- end

    --获取需求品
    map_attrs:getPortNeed(params.portId, function(need_ids)
        if not getUIManager():isLive("clsEnterPortUI") then
            return
        end
        need_ids = need_ids or {}
        for i = 1, 2 do
            local need_bg_spr = getConvertChildByName(bg_ui, "need_bg_"..i)
            local need_icon_spr = getConvertChildByName(need_bg_spr, "need_icon_"..i)
            local need_name_lab = getConvertChildByName(need_bg_spr, "need_info_"..i)
            local good_id = need_ids[i]
            if good_id then
                local goods_type_item = goods_type_info[good_id]
                need_icon_spr:changeTexture(goods_type_item.res, UI_TEX_TYPE_PLIST)
                autoScaleWithLength(need_icon_spr, 78)
                need_name_lab:setText(goods_type_item.name)
            else
                need_bg_spr:setVisible(false)
            end
        end
    end)
end

function clsEnterPortUI:showAfterSupply()
	self.m_supply_btn:setTouchEnabled(true)
	local supplyData = getGameData():getSupplyData()
	supplyData:saveConsumeCash()
	local text = string.format(news.EXPLORER_SUPPLY_CASH.msg, supplyData:getComsumeCash())
	ClsAlert:explorerSupplyAttention(text, function() self:close() end)
end

function clsEnterPortUI:onExit()
	UnLoadPlist(self.plistTab)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():releaseStopFoodReason("clsEnterPortUI_show")
	end
end

return clsEnterPortUI
