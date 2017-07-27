--
-- Author: 商会徽章界面
-- Date: 2015-09-06 19:56:29
--
local ClsGuildBadge = require("game_config/guild/guild_badge")
local ClsMusicInfo = require("game_config/music_info")
local ClsUiWord = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local ClsUiTools = require("gameobj/uiTools")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

---------------------------------------------------------------------------------
local ClsGuildBadgeItem = class("ClsGuildBadgeItem", ClsScrollViewItem)

function ClsGuildBadgeItem:initUI(cell_date)
    if not cell_date then
        return;
    end
    self.data = cell_date
    -- self.item_index = i
    -- self.call_back = call_back
    self:mkUi()
end

function ClsGuildBadgeItem:mkUi(index)
    self.ui_layer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_badge_icon.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addChild(self.ui_layer)

    local badge_data = self.data.data

    self.badge_name = getConvertChildByName(self.panel, "badge_name")
    self.badge_name:setText(badge_data.name)

    self.badge_icon = getConvertChildByName(self.panel, "badge_icon")
    self.badge_icon:changeTexture(badge_data.res, UI_TEX_TYPE_PLIST)

    self.btn_badge = getConvertChildByName(self.panel, "btn_badge")
    self.btn_badge:addEventListener(function()
            self.call_back(self)
        end,TOUCH_EVENT_ENDED)

    if self.scale_state then
        self:updateState(self.scale_state)
    end
end

function ClsGuildBadgeItem:updateState(scale)
    if not tolua.isnull(self.btn_badge) then
        self.btn_badge:setTouchEnabled(scale ~= 1)
        self.btn_badge:setScale(1 * scale)
        self.btn_badge:setFocused(scale == 1)
    else 
        self.scale_state = scale
    end    
end

function ClsGuildBadgeItem:onTap(x, y)
    self.call_back(self)
end

---------------------------------------------------------------------------------------

local ClsGuildBadgePanel = class("ClsGuildBadgePanel", ClsBaseView)

function ClsGuildBadgePanel:getViewConfig(...)
    return {
        is_back_bg = true,
        effect = UI_EFFECT.DOWN,
    }
end

local rect = CCRect(100, 127, 758, 337)
local select_item = nil

function ClsGuildBadgePanel:onEnter(call_back)
    self.res_plist ={
        ["ui/hotel_ui.plist"] = 1,
        ["ui/guild_badge.plist"] = 1,
    }
    LoadPlist(self.res_plist)
    self.call_back = call_back
    self:initUI()
    self:initEvent()
    self:showList()
end

function ClsGuildBadgePanel:initUI()
	self.ui_layer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_badge.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addWidget(self.ui_layer)

    self.gold_num = getConvertChildByName(self.panel, "gold_num")
    self.btn_left = getConvertChildByName(self.panel, "btn_left")
    self.btn_right = getConvertChildByName(self.panel, "btn_right")
    self.btn__badge = getConvertChildByName(self.panel, "btn__badge")
    self.btn_close = getConvertChildByName(self.panel, "btn_close")

    self.tips_panel = getConvertChildByName(self.panel, "tips_panel")
    self.info_text_1 = getConvertChildByName(self.panel, "info_text_1")
    self.btn__badge_txt_1 = getConvertChildByName(self.panel, "btn__badge_txt_1")
    self.btn__badge_txt = getConvertChildByName(self.panel, "btn__badge_txt")

    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)

    if self.call_back then
        self.tips_panel:setVisible(false)
        self.info_text_1:setVisible(true)
        self.btn__badge_txt_1:setVisible(true)
        self.btn__badge_txt:setVisible(false)
    else
        self.tips_panel:setVisible(true)
        self.info_text_1:setVisible(false)
        self.btn__badge_txt_1:setVisible(false)
        self.btn__badge_txt:setVisible(true)
    end

    local value = self.gold_num:getStringValue()
    local gold = tonumber(value)
    local playerData = getGameData():getPlayerData()
    if gold > playerData:getGold() then
        setUILabelColor(self.gold_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
    end
end

function ClsGuildBadgePanel:initEvent()
	self.btn__badge:setPressedActionEnabled(true) 
    self.btn__badge:addEventListener(function()
            if not select_item then
                return
            end
            if self.call_back then
                self.call_back(select_item.data.key)
            else
                local guild_info_data = getGameData():getGuildInfoData()
                if guild_info_data:isCaptain() then
                    local value = self.gold_num:getStringValue()
                    local gold = tonumber(value)
                    local playerData = getGameData():getPlayerData()
                    if gold > playerData:getGold() then
                        self:closeEffect()
                        audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
                        local guild_info_ui = getUIManager():get("ClsGuildInfoPanel")
                        ClsAlert:showJumpWindow(DIAMOND_NOT_ENOUGH, guild_info_ui)
                    else
                        if guild_info_data:getBadgeId() == select_item.data.key then
                            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
                            ClsAlert:warning({msg = ClsUiWord.STR_GUILD_BADGE_SELECTED_TIPS, size = 26})
                            return
                        end
                        audioExt.playEffect(ClsMusicInfo.COMMON_GOLD.res)
                        guild_info_data:askEditIcon(select_item.data.key)
                        self:closeEffect()
                    end
                else
                    audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
                    ClsAlert:warning({msg = ClsUiWord.STR_GUILD_BADGE_EDIT_TIPS, size = 26})
                end
            end
        end,TOUCH_EVENT_ENDED) 

    self.btn_close:setPressedActionEnabled(true) 
    self.btn_close:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
        end,TOUCH_EVENT_BEGAN)
    self.btn_close:addEventListener(function()
            self:closeEffect()
        end,TOUCH_EVENT_ENDED)
end

function ClsGuildBadgePanel:showList()
	if not tolua.isnull(self.list_view) then
        -- self.list_view:removeFromParentAndCleanup(true)
        -- self.list_view = nil
        self.list_view.removeAllCells()
    end

    local col_num = 3
    self.item_list_table = {}

    local list_cell_size = CCSizeMake(rect.size.width/col_num, rect.size.height) 

    if tolua.isnull(self.list_view) then
        self.list_view = ClsScrollView.new(rect.size.width,rect.size.height,false,nil,{is_fit_bottom = true})
        self.list_view:setPosition(rect.origin)
        self.ui_layer:addChild(self.list_view)
    end
    

    self.badge_data = {}
    local badge_num = 0
    for k, v in pairs(ClsGuildBadge) do
        badge_num = badge_num + 1
        self.badge_data[k] = {data = v, key = k}
    end

    for i,v in ipairs(self.badge_data) do
        local info_item = ClsGuildBadgeItem.new( list_cell_size, v)
        info_item.item_index = i
        info_item.call_back = function(cell)
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:selectBadgeEffect( cell.item_index )
        end

        self.list_view:addCell(info_item)
        self.item_list_table[i] = info_item
        info_item:updateState(0.8)
    end

    -- self.list_view:setCurrentIndex(1)
    
    if col_num < badge_num then
        self.list_view:setTouchEnabled(true)
        self.btn_left:setVisible(true)
        self.btn_right:setVisible(true)
    else
        self.list_view:setTouchEnabled(false)
        self.btn_left:setVisible(false)
        self.btn_right:setVisible(false)
    end
    self:updateBadgeState()
end

function ClsGuildBadgePanel:updateBadgeState()
    local guild_info_data = getGameData():getGuildInfoData()
    self:selectBadgeEffect(guild_info_data:getBadgeId())
end

function ClsGuildBadgePanel:selectBadgeEffect( index )
    if select_item then
        select_item:updateState(0.8)
    end
    
    select_item = self.item_list_table[index]
    select_item:updateState(1)
end

function ClsGuildBadgePanel:setTouch(enable)
	if not tolua.isnull(self.ui_layer) then
		self.ui_layer:setTouchEnabled(enable)
	end
    if not tolua.isnull(self.list_view) then
        if self.list_view:isTouchEnabled() then
            self.list_view:setTouchEnabled(enable)
        end
    end
end

function ClsGuildBadgePanel:closeEffect()
    self:setTouch(false)
    self:close()
end

function ClsGuildBadgePanel:onExit()
    UnLoadPlist(self.res_plist)
end

return ClsGuildBadgePanel