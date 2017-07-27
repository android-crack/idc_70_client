--这个是购买物品弹出的tip框
local music_info = require("game_config/music_info")
local item_info = require("game_config/propItem/item_info") -- 道具数据
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsShopAlertPanel = class("ClsShopAlertPanel",ClsBaseView)

local LIMIT_NUM = 10

ClsShopAlertPanel.TYPE_CONTRIBUTE = 1
local type_res = {
	[ClsShopAlertPanel.TYPE_CONTRIBUTE] = "#txt_common_icon_guild_contribution.png"
}
function ClsShopAlertPanel:getViewConfig(...)
    return {
    	is_back_bg = true,
    	effect = UI_EFFECT.SCALE,
    }
end

function ClsShopAlertPanel:onEnter()
	self.ui_layer = UIWidget:create()

    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_shop.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addWidget(self.ui_layer)


	self:configUI()
	self:configEvent()
	self.cur_num = 1--当前数量
	self.max_num = 1--最大数量
	self.price_num = 0--单价
	self.call_back = nil --回调函数
	self.item = nil --道具数据
	self.item_id = nil
end

function ClsShopAlertPanel:configUI()
	local panel_size = self.panel:getContentSize()
    self.panel:setPosition(ccp(display.cx - panel_size.width / 2, display.cy - panel_size.height / 2))

    local wideget_info = {
    	[1] = {name = "btn_reduce",kind = BTN}, --减号按钮
    	[2] = {name = "btn_add",kind = BTN}, -- 加好
    	[3] = {name = "max_bg",kind = BTN}, --最大
    	[4] = {name = "btn_buy",label = "btn_buy_num",kind = BTN}, --购买
    	[5] = {name = "mid_num"}, --数量
    	[6] = {name = "goods_price_num"}, --单价
    	[7] = {name = "goods_info_text"}, --物品介绍
    	[8] = {name = "goods_text"}, --物品名字
    	[9] = {name = "goods_icon"}, --图标
    	--[10] = {name = "price_icon"},--单价图标
    	[10] = {name = "btn_buy_icon"}, --单价图标2按钮上的
    	[11] = {name = "btn_close"}, --关闭按钮
    	[12] = {name = "btn_buy_num"},

    	[13] = {name = "goods_price_text"}, -- 不显示
    	[14] = {name = "goods_price_num"}, -- 不显示
    	[15] = {name = "goods_amount"}, -- 数量
	}

	for k,v in ipairs(wideget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        if v.label then
        	self[v.name].label = getConvertChildByName(self[v.name], v.label)
        end
        if v.kind == BTN then
        	self[v.name]:setPressedActionEnabled(true)
        end
	end

    local touch_rect = CCRect(display.cx - panel_size.width / 2, display.cy - panel_size.height / 2, panel_size.width, panel_size.height)

    -- self:registerScriptTouchEvent({rect = touch_rect, is_event_rect = false, priority = TOUCH_PRIORITY_DIALOG_LAYER})
	ClsGuideMgr:tryGuide("ClsShopAlertPanel")
end

function ClsShopAlertPanel:configEvent()
	self.btn_reduce:addEventListener(function() --减
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.cur_num > 1 then
			self.cur_num = self.cur_num - 1
			self:updateGoodsNum()
		end
	end,TOUCH_EVENT_ENDED)

	self.btn_add:addEventListener(function() --加
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.cur_num < self.max_num then
			self.cur_num = self.cur_num + 1
			if self.cur_num > LIMIT_NUM then
				self.cur_num = LIMIT_NUM
			end
			self:updateGoodsNum()
		end
	end,TOUCH_EVENT_ENDED)

	self.max_bg:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.cur_num ~= self.max_num then
			self.cur_num = self.max_num
			if self.max_num > LIMIT_NUM then
				self.cur_num = LIMIT_NUM
			end
			self:updateGoodsNum()
		end
	end,TOUCH_EVENT_ENDED)

	self.btn_buy:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.call_back(self.item_id,self.cur_num)
		-- self:removeFromParentAndCleanup(true)
		self:hide()
	end,TOUCH_EVENT_ENDED)

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:hide()
	end,TOUCH_EVENT_ENDED)
end

function ClsShopAlertPanel:layerOutBtn()
	local back_width = self.btn_buy:getContentSize().width
	local txt_width = self.btn_buy_num:getContentSize().width
	local icon_width = self.btn_buy_icon:getContentSize().width * self.btn_buy_icon:getScaleX()

	local start_pos =  - (txt_width + icon_width) / 2 - 3

	self.btn_buy_icon:setPosition(ccp(start_pos + icon_width / 2,self.btn_buy_icon:getPosition().y))
	self.btn_buy_num:setPosition(ccp(start_pos + icon_width + 5,self.btn_buy_num:getPosition().y))
end

--刷新界面,更新购买数量,价格
function ClsShopAlertPanel:updateGoodsNum()
	self.mid_num:setText(tostring(self.cur_num))
	self.btn_buy.label:setText(tostring(self.price_num * self.cur_num)) --显示总价格
	self:layerOutBtn()
end

--显示,传入item,单价,最大数量
function ClsShopAlertPanel:showShopByItem(item_id,item,price_num,price_type,max_num,call_back)
	self.item_id = item_id
	self.item = item
	self.goods_text:setText(item.name)
	self.goods_info_text:setText(item.desc)
	local reward_res = convertResources(item.res)
	self.goods_icon:changeTexture(reward_res, UI_TEX_TYPE_PLIST)
	self.goods_price_num:setText(tostring(price_num))
	--self.price_icon:changeTexture(convertResources(type_res[price_type]))
	self.btn_buy_icon:changeTexture(convertResources(type_res[price_type]))

	if max_num == nil or max_num < 1 then
		max_num = 1
	end

	-- print(' ---------- item --- ')
	-- table.print(item)
	if item.stock == 0 then
		self.goods_price_text:setVisible(false)
		self.goods_price_num:setVisible(false)
	else
		self.goods_price_num:setText(item.left_num)
	end
	self.goods_amount:setText(item.amount)

	self.price_num = price_num
	self.max_num = max_num
	self.cur_num = 1
	self.call_back = call_back
	self:updateGoodsNum()
end

function ClsShopAlertPanel:onExit()

end

function ClsShopAlertPanel:hide()
	self:close()
end

function ClsShopAlertPanel:onTouchEnded(x, y)
	if self.drag.is_tap then
		-- self:removeFromParentAndCleanup(true)

		-- if self.parent then
			self:hide()
	        -- local parent = self:getParent()
       	 -- 	parent:setTouch(true)
        	-- self:removeFromParentAndCleanup(true)
		-- end
	end
end


return ClsShopAlertPanel
