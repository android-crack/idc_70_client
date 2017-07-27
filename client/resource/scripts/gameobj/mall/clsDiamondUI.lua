-- 钻石tab
-- Author: Ltian
-- Date: 2016-11-20 15:29:09
--


local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local item_info = require("game_config/propItem/item_info")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local CompositeEffect = require("gameobj/composite_effect")

local ClsGoodsItem = class("ClsGoodsItem", function () return UIWidget:create() end)
local widget_name = {
	"sale_limit",
	"gold_icon",
	"gold_num",
	"item_pic",
	"gift_txt",
	"diamond_icon",
	"diamond_num",
	"item_recharge",
	"green_banner",
	"diamond_icon",

}

function ClsGoodsItem:ctor(data)
	self.data = data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shop_item_recharge.json")
	--self.item_normal =  getConvertChildByName(self.panel, "item_normal")
	convertUIType(self.panel)
	self:addChild(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	
    self:mkUI()
end

function ClsGoodsItem:mkUI()
	local item_res, amount, scale = getCommonRewardIcon({key = ITEM_TYPE_MAP[self.data.goods_type], id = self.data.goods_id, value = self.data.goods_amount})
	self.gold_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.gold_num:setText(tostring(self.data.goods_amount))
	if self.data.pic_icon ~= "" then
		self.item_pic:changeTexture(convertResources(self.data.pic_icon), UI_TEX_TYPE_PLIST)
	else
		self.item_pic:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	end
	self.diamond_num:setText(self.data.price)
	if self.data.has_charge == 1 then
		self.gift_txt:setText(self.data.sales_text[1])
		self.sale_limit:setVisible(true)
	else
		self.sale_limit:setVisible(false)
		self.gift_txt:setText(self.data.sales_text[2])
	end
	self:adapteUI()
end


function ClsGoodsItem:adapteUI()
	local size = self.diamond_num:getContentSize()
	if size.width < 20 then
	 	local pos = self.diamond_num:getPosition()
		self.diamond_num:setPosition(ccp(pos.x + 25 - size.width, pos.y))
	end
end



function ClsGoodsItem:onTap(x, y)
	local diamond_count = self.data.goods_amount
	local tips = string.format(ui_word.BUY_DIAMOND_TIPS, tostring(diamond_count))
	
	Alert:showAttention(tips, function ()
		getGameData():getShopData():payGood(self.data.id)
	end, nil, nil, {ok_text = ui_word.MAIN_SURE_BUG, cancel_text = ui_word.SYS_CLOSE})
	

end

local ClsGoodsCell = class("ClsGoodsCell", ClsScrollViewItem)

function ClsGoodsCell:initUI()
	self.items = {}
	for i,v in ipairs(self.datas) do
		self.items[i] = ClsGoodsItem.new(v)
		self.items[i]:setPosition(ccp(15, 384 - 192*i))
		self:addChild(self.items[i])
	end
	
end
function ClsGoodsCell:insertData(data)
	if not self.datas then self.datas = {} end
    self.datas[#self.datas + 1] = data
end

function ClsGoodsCell:onTap(x, y)
	
	for i,v in ipairs(self.items) do
		local pos = self.items[i].item_recharge:convertToWorldSpace(ccp(0, 0))
		local size = self.items[i].item_recharge:getContentSize()
		local rect = CCRect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height)
		local in_rect = rect:containsPoint(ccp(x, y))

		if in_rect then
			self.items[i]:onTap(x, y)
		end
	end
	

end

function ClsGoodsCell:getGoodItem()
	return self.items
end


local ClsDiamondUI = class("ClsDiamondUI", function () return UIWidget:create() end)

function ClsDiamondUI:ctor( ... )
	self:mkUI()
	self:playAction()
end
local ALL_HORIZONTAL_SHOW_GIF_NUM = 3
function ClsDiamondUI:mkUI()
	if tolua.isnull(self.list_view) then
        self.list_view = ClsScrollView.new(678, 384, false, function()
            return cell_ui
        end, {is_fit_bottom = true})
        self.list_view:setPosition(ccp(90, 85))
        self.list_view:setZOrder(100)
        self:addChild(self.list_view)
    end
   	self.list_view:removeAllCells()
    
    local mall_data = getGameData():getShopData()
    local limit_goods = mall_data:getDiamondGoodsInfo()
    local current_cells = {}
    
	for k, v in ipairs(limit_goods) do
        if k <= ALL_HORIZONTAL_SHOW_GIF_NUM then
            local current_cell = ClsGoodsCell.new(CCSize(222, 387),{index = index})
            current_cell:insertData(v)
            current_cells[#current_cells + 1] = current_cell
   		else
   			current_cells[k - ALL_HORIZONTAL_SHOW_GIF_NUM]:insertData(v)
        end
        
    end
    
    self.list_view:addCells(current_cells)
end


function ClsDiamondUI:playAction()
	
    local cells = self.list_view:getCells()
    local items = {}
    for i=1,5 do
    	if not tolua.isnull(cells[i]) then
    		local good_items = cells[i]:getGoodItem()
    	
    		if type(good_items) == "table" then
    			items[#items + 1] = good_items
    			for k,v in ipairs(good_items) do
    				v.item_recharge:setVisible(false)
    			end
    		end
    	end
    end
    local array = CCArray:create()

    
    for i=1,2 do
    	for _,item in ipairs(items) do
    		array:addObject(CCCallFunc:create(function ( )
    			if not tolua.isnull(item[i]) then
    				item[i].item_recharge:setVisible(true)
	    			item[i].item_recharge:setScale(0.8)
	    			item[i].item_recharge:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.08, 1.2), CCScaleTo:create(0.04, 1)))
    				CompositeEffect.new("tx_shop_item", 0, 0, item[i].item_recharge, nil, nil, nil, nil, true)
    				
    			end
    			
    		end))
    		array:addObject(CCDelayTime:create(0.1))
    	end
    end
    self:runAction(CCSequence:create(array))
    
end

function ClsDiamondUI:updateView()
	self:mkUI()
end


return ClsDiamondUI