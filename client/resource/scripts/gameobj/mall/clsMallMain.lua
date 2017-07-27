-- 商城主界面
-- Author: Ltian
-- Date: 2016-11-20 15:22:45
--
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsNormolGoodsUI = require("gameobj/mall/clsNormolGoodsUI")
local ClsLimitGoodsUI = require("gameobj/mall/clsLimitGoodsUI")
local ClsDiamondUI = require("gameobj/mall/clsDiamondUI")
local ClsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")

local ClsMallMain = class("ClsMallMain", ClsBaseView)

function ClsMallMain:getViewConfig()
    return { hide_before_view = true, 
		 effect = UI_EFFECT.FADE, 
		}
end

local widget_name = {
	"btn_sales",
	"btn_item",
	"btn_recharge",
	"btn_close",
	"btn_service",
}

local btn_label = {
	"sales_txt_1",
	"sales_txt_2",
	"item_txt_1",
	"item_txt_2",
}
function ClsMallMain:onEnter(index)
	self.plist = {
		["ui/shop_ui.plist"] = 1,	
	}
	
	self.default_index = index or 1
	LoadPlist(self.plist)
	self:mkUI()
	self:initEvent()
	self:defaultSelect()
end

function ClsMallMain:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shop.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)		
	end
	for k,v in pairs(btn_label) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	local cash_layer = ClsPlayerInfoItem.new(ITEM_INDEX_CASH)
 	cash_layer:setPosition(80, 15)
 	self:addChild(cash_layer)

  	local tili_layer = ClsPlayerInfoItem.new(ITEM_INDEX_TILI)
 	tili_layer:setPosition(250, 15)
 	self:addChild(tili_layer)

 	local diamond_layer = ClsPlayerInfoItem.new(ITEM_INDEX_GOLD)
 	diamond_layer:setPosition(420, 15)
 	self:addChild(diamond_layer)
end

function ClsMallMain:initEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:setTouchEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()
	end, TOUCH_EVENT_ENDED)

	self.btn_service:setPressedActionEnabled(true)
	self.btn_service:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.openPayService()
	end, TOUCH_EVENT_ENDED)

	for i=1,3 do
		self[widget_name[i]]:addEventListener(function(...)
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:selectTab(i)
		end, TOUCH_EVENT_ENDED)
		self[widget_name[i]]:addEventListener(function()
			self:changeColor(i, true)
			--self
		end, TOUCH_EVENT_BEGAN)
		self[widget_name[i]]:addEventListener(function()
			self:selectBtnUpdate()
		end, TOUCH_EVENT_CANCELED)
		self[widget_name[i]]:addEventListener(function(...)
			local touch_pos = self[widget_name[i]]:getTouchMovePos()
			local pos = self[widget_name[i]]:convertToWorldSpace(ccp(0, 0))
			local size = self[widget_name[i]]:getContentSize()
			local rect = CCRect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height)
			local in_rect = rect:containsPoint(ccp(touch_pos.x, touch_pos.y))
			if in_rect then
				self:changeColor(i, true)
			else
				self:changeColor(i, false)
			end
		end, TOUCH_EVENT_MOVED)
	end
end

function ClsMallMain:selectBtnUpdate(index)
	index = index or self.select_index
	for k,v in pairs(btn_label) do
		color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
		setUILabelColor(self[v], color)	
	end
	if index <= 2 then
		self:changeColor(index, true)
	end
end

function ClsMallMain:changeColor(index, is_select)
	if index > 2 then
		return
	end
	local color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
	if is_select then
		color = ccc3(dexToColor3B(COLOR_BTN_SELECTED))
	end
	local pos = index * 2 - 1
	setUILabelColor(self[btn_label[pos]], color)	
	setUILabelColor(self[btn_label[pos + 1]], color)
end

function ClsMallMain:defaultSelect()
	self:selectTab(self.default_index)
end

function ClsMallMain:selectTab(index)
	self.select_index = index
	for i=1,3 do
		self[widget_name[i]]:setFocused(false)
		self[widget_name[i]]:setTouchEnabled(true)
	end
	self:selectBtnUpdate(index)
	self[widget_name[index]]:setFocused(true)
	self[widget_name[index]]:setTouchEnabled(false)
	self[widget_name[3]]:setVisible(index ~= 3)--支付界面出来隐藏支付按钮

	self.btn_service:setVisible(false)
	if index == 3 and not GTab.IS_VERIFY then
		local module_game_sdk = require("module/sdk/gameSdk")
		local platform = module_game_sdk.getPlatform()
		self.btn_service:setVisible(platform == PLATFORM_WEIXIN or platform == PLATFORM_QQ)
	end

	if not tolua.isnull(self.old_tab) then
		self.old_tab:removeFromParentAndCleanup(true)
		self.old_tab = nil
	end
	if index == 1 then
		self.old_tab = ClsLimitGoodsUI.new()
	elseif index == 2 then
		self.old_tab = ClsNormolGoodsUI.new()
	else
		self.old_tab = ClsDiamondUI.new()
	end
	self:addWidget(self.old_tab)
end


function ClsMallMain:updateView()
	if not tolua.isnull(self.old_tab) and type(self.old_tab.updateView) == "function" then
		self.old_tab:updateView()
	end
end

function ClsMallMain:onExit()
	UnLoadPlist(self.plist)
end

return ClsMallMain