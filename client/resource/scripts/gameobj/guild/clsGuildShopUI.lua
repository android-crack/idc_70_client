-- 商会商店
-- Author: chenlurog
-- Date: 2015-12-16 11:53:28
--s
local music_info=require("scripts/game_config/music_info")
local ClsGuildShopListUI = require("gameobj/guild/clsGuildShopListUI")
local ClsGuildShopGiftUI = require("gameobj/guild/clsGuildShopGiftUI")
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsGuildShopUI = class("ClsGuildShopUI", ClsBaseView)
local SELECT_GIFT_BTN = 2

function ClsGuildShopUI:getViewConfig(...)
    return {
    	is_back_bg = true,
    	effect = UI_EFFECT.DOWN,
    }
end

function ClsGuildShopUI:onEnter(index)

	self.resPlist = {
		["ui/material_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
		["ui/box.plist"] = 1,
    }

    LoadPlist(self.resPlist)
    self:initUI()
    self:initEvent()

    self.guide_tbl = {
		[170] = on_off_info.DRAWING_10.value,
	}

    index = index or GUILD_CONTRIBUTE_SHOP
	self:updateTabSelected( index )
end


function ClsGuildShopUI:initUI()
	self.uiLayer = UIWidget:create()

    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_new.json")
    convertUIType(self.panel)
    self.uiLayer:addChild(self.panel)
    self:addWidget(self.uiLayer)

    local task_data = getGameData():getTaskData()
    self.tab_btn = {
			{name = "contribution_shop", label = "shop_text", func = function()
				self:createShopSellPanel()
			end}, 
			{name = "gift_storage", label = "storage_text", func = function()
				self:createShopGiftPanel()
			end, on_off_key = on_off_info.GUILD_DEPOT_GIFT.value, task_keys = {
				on_off_info.GUILD_DEPOT_GIFT.value,
			}}, 
		}
	self.main_menu = {}
	for i, v in ipairs( self.tab_btn ) do
		self.main_menu[i] = {}
	  	self.main_menu[i].btn = getConvertChildByName(self.panel, v.name)
	  	self.main_menu[i].label = getConvertChildByName(self.panel, v.label)
	  	if v.on_off_key and v.task_keys then
  			task_data:regTask(self.main_menu[i].btn, v.task_keys, KIND_RECTANGLE, v.on_off_key, 40, 10, true)
	  	end
	end

  	self.btn_close = getConvertChildByName(self.panel, "btn_close")
end

function ClsGuildShopUI:initEvent()
	for i = 1, #self.main_menu do
	  	self.main_menu[i].btn:addEventListener(function()
	  		local mission_key_tbl = missionGuide:getGuideKeyTbl()
	  		for _, _key in pairs(self.guide_tbl) do
	  			local mid = mission_key_tbl[_key]
	  			if mid and i == SELECT_GIFT_BTN then
	  				return
	  			end
	  		end

	  		audioExt.playEffect(music_info.COMMON_BUTTON.res)
    		self:updateTabSelected( i )
    	end,TOUCH_EVENT_ENDED)

        self.main_menu[i].btn:addEventListener(function()
            setUILabelColor(self.main_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
        end,TOUCH_EVENT_BEGAN) 

        self.main_menu[i].btn:addEventListener(function()
            setUILabelColor(self.main_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
        end,TOUCH_EVENT_CANCELED)
	end

	self.btn_close:setPressedActionEnabled(true) 
	self.btn_close:addEventListener(function()
    		audioExt.playEffect(music_info.COMMON_CLOSE.res)
			local parent = self:getParent()--其他界面不足打开后，关闭界面刷新
			if not tolua.isnull(parent) then
				parent = parent:getParent()--商会中的界面都是在商会场景上，所以多一步
				if not tolua.isnull(parent) and type(parent.updateLabelCallBack) == "function" then
					parent:updateLabelCallBack()
				end
			end
			self:close()
    	end,TOUCH_EVENT_ENDED)

end

function ClsGuildShopUI:updateTabSelected( index )
	self.cur_select_type = index
	for i = 1, #self.main_menu do
		local selectState = index == i
		self.main_menu[i].btn:setFocused( selectState )
		self.main_menu[i].btn:setTouchEnabled( not selectState )
		if not tolua.isnull(self.main_menu[i].panel) then
			self.main_menu[i].panel:setVisible(selectState)
			self.main_menu[i].panel:setTouch(selectState)
		end

		if selectState then
            setUILabelColor(self.main_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
        else
            setUILabelColor(self.main_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
        end
	end	

	self.tab_btn[self.cur_select_type].func()
end

function ClsGuildShopUI:createShopSellPanel()
	if not tolua.isnull(self.shop_gift_ui) then
		self.shop_gift_ui:removeFromParentAndCleanup(true)
		self.shop_gift_ui = nil
	end

	local shop_list_ui = self.main_menu[GUILD_CONTRIBUTE_SHOP].panel
	if tolua.isnull(shop_list_ui) then
		shop_list_ui = ClsGuildShopListUI.new()
		self.main_menu[GUILD_CONTRIBUTE_SHOP].panel = shop_list_ui
		self.uiLayer:addChild(shop_list_ui)
	end
end

function ClsGuildShopUI:createShopGiftPanel()
	local shop_gift_ui = ClsGuildShopGiftUI.new()
	self.main_menu[GUILD_GIFT].panel = shop_gift_ui
	self.uiLayer:addChild(shop_gift_ui)
	self.shop_gift_ui = shop_gift_ui
end

function ClsGuildShopUI:askGuildGifInfo()
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:askGuildGifInfo()
end

function ClsGuildShopUI:updateContribute(value)
	local shop_list_ui = self.main_menu[GUILD_CONTRIBUTE_SHOP].panel
	if not tolua.isnull(shop_list_ui) then
		shop_list_ui:updateContribute(value)
	end
end

function ClsGuildShopUI:updateItem(info)
	local shop_list_ui = self.main_menu[GUILD_CONTRIBUTE_SHOP].panel
	if not tolua.isnull(shop_list_ui) then
		shop_list_ui:updateItem(info)
	end
end

function ClsGuildShopUI:updateList(shop_list)
	local shop_list_ui = self.main_menu[GUILD_CONTRIBUTE_SHOP].panel
	if not tolua.isnull(shop_list_ui) then
		shop_list_ui:updateList(shop_list)
	end
end

function ClsGuildShopUI:updateShopLeftNum(shop_id, num)
	local shop_list_ui = self.main_menu[GUILD_CONTRIBUTE_SHOP].panel
	if not tolua.isnull(shop_list_ui) then
		shop_list_ui:updateShopLeftNum(shop_id, num)
	end
end

function ClsGuildShopUI:updateGiftInfo(gifts)
	local shop_gift_ui = self.main_menu[GUILD_GIFT].panel
	if not tolua.isnull(shop_gift_ui) then
		shop_gift_ui:updateGiftInfo(gifts)
	end
end

function ClsGuildShopUI:updateRewardBtn( status )
	local shop_gift_ui = self.main_menu[GUILD_GIFT].panel
	if not tolua.isnull(shop_gift_ui) then
		shop_gift_ui:updateRewardBtn( status )
	end
end

function ClsGuildShopUI:updateGiftTouchState( state )
	local shop_gift_ui = self.main_menu[GUILD_GIFT].panel
	if not tolua.isnull(shop_gift_ui) and shop_gift_ui:isVisible() then
		shop_gift_ui:setTouch(state)
	end
end

function ClsGuildShopUI:setTouch(enable)
	-- for i = 1, #self.main_menu do
	-- 	local selectState = self.cur_select_type == i
	-- 	self.main_menu[i].btn:setFocused( selectState )
	-- 	self.main_menu[i].btn:setTouchEnabled(enable and not selectState)
	-- 	if not tolua.isnull(self.main_menu[i].panel) then
	-- 		self.main_menu[i].panel:setTouch(enable and selectState)
	-- 	end
	-- end
	-- self.btn_close:setTouchEnabled(enable)
end

function ClsGuildShopUI:getGuildGiftUI()
	return self.shop_gift_ui
end

function ClsGuildShopUI:onExit()
	UnLoadPlist(self.resPlist)
end 

return ClsGuildShopUI